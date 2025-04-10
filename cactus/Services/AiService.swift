import Foundation

class AiService: NSObject, URLSessionDataDelegate {
    private var fullContent = ""
    private var buffer = Data()
    
    func chat(text: String, completion: (() -> Void)? = nil) {
        let settings = SettingsModel.shared
        guard let providerSettings = settings.defaultProviders[settings.selectedProvider],
              let url = URL(string: providerSettings.baseURL) else {
            completion?()  // 如果URL无效，立即调用完成回调
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(providerSettings.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Request URL: \(url)")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let body: [String: Any] = [
            "model": providerSettings.model,
            "messages": [
                ["role": "user", "content":  text]
            ],
            "max_tokens": 1000,
            "stream": true
        ]
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = httpBody
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                print("Request Body: \(bodyString)")
            }
        }
        
        DispatchQueue.main.async {
            TextContentModel.shared.promptText = ""
        }
        fullContent = ""
        buffer = Data()
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request)
        
        self.completionHandler = completion
        
        task.resume()
    }
    
    private var completionHandler: (() -> Void)?
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        guard let bufferString = String(data: buffer, encoding: .utf8) else {
            return // 如果无法解码数据，直接返回
        }
        
        let lines = bufferString.components(separatedBy: "\n")
        var processedUpTo = 0
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty {
                processedUpTo = index + 1
                continue
            }
            
            if trimmedLine.hasPrefix("data: ") {
                let dataContent = trimmedLine.dropFirst(6) // 移除 "data: " 前缀
                
                if dataContent == "[DONE]" {
                    print("流式输出完成")
                    processedUpTo = index + 1
                    continue
                }
                
                if let jsonData = String(dataContent).data(using: .utf8) {
                    do {
                        let streamResponse = try JSONDecoder().decode(StreamResponse.self, from: jsonData)
                        if let content = streamResponse.choices.first?.delta.content {
                            fullContent += content
                            
                            DispatchQueue.main.async {
                                TextContentModel.shared.promptText = self.fullContent
                            }
                        }
                    } catch {
                        print("JSON解析错误: \(error.localizedDescription)")
                    }
                }
                
                processedUpTo = index + 1
            }
        }
        
        // 移除已处理的数据以避免内存溢出
        if processedUpTo > 0 && processedUpTo <= lines.count {
            let processedLines = lines[..<processedUpTo].joined(separator: "\n")
            if let processedData = processedLines.data(using: .utf8) {
                let bytesToRemove = min(processedData.count, buffer.count)
                if bytesToRemove > 0 {
                    buffer.removeFirst(bytesToRemove)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("请求错误: \(error.localizedDescription)")
        } else {
            print("请求完成")
        }
        
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil  // 清除回调引用
        }
    }
}

// 流式响应的解码结构
struct StreamResponse: Codable {
    struct Choice: Codable {
        let delta: Delta
    }
    
    struct Delta: Codable {
        let content: String?
    }
    
    let choices: [Choice]
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}
