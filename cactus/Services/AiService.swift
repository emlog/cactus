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
            TextContentModel.shared.resultText = ""
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
        
        // 持续处理缓冲区中的完整行
        while let range = buffer.firstRange(of: Data("\n".utf8)) {
            let lineData = buffer.subdata(in: 0..<range.lowerBound) // 获取一行的数据 (不包含 \n)
            buffer.removeSubrange(0..<range.upperBound) // 从缓冲区移除这一行和 \n
            
            // 将行数据转换为字符串进行处理
            if let line = String(data: lineData, encoding: .utf8) {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty {
                    continue // 跳过空行
                }
                
                if trimmedLine.hasPrefix("data: ") {
                    let dataContent = trimmedLine.dropFirst(6) // 移除 "data: " 前缀
                    
                    if dataContent == "[DONE]" {
                        print("流式输出完成")
                        continue // 继续处理缓冲区中的下一行
                    }
                    
                    if let jsonData = String(dataContent).data(using: .utf8) {
                        do {
                            let streamResponse = try JSONDecoder().decode(StreamResponse.self, from: jsonData)
                            if let content = streamResponse.choices.first?.delta.content {
                                fullContent += content
                                
                                DispatchQueue.main.async {
                                    // 确保 TextContentModel.shared 实例存在且属性可访问
                                    // 在更新 UI 前，修剪 fullContent 的首尾空白
                                    TextContentModel.shared.resultText = self.fullContent.trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                            }
                        } catch {
                            // 打印原始 JSON 字符串以便调试
                            print("JSON解析错误: \(error.localizedDescription), Raw JSON: \(String(dataContent))")
                        }
                    }
                } else {
                    // 可以选择打印非 data: 前缀的行，以供调试
                    print("Skipping non-data line: \(trimmedLine)")
                }
            } else {
                print("无法将行数据解码为 UTF-8 字符串")
                // 这里可以选择如何处理解码失败，例如跳过或记录错误
            }
        }
        // 循环结束后，buffer 中可能剩下不完整的最后一行数据，等待下一次 didReceive data
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("请求错误: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil  // 清除回调引用
        }
        // 可以在这里处理 buffer 中可能残留的最后一部分数据，虽然对于 SSE [DONE] 标记来说通常不需要
        if !buffer.isEmpty {
            print("Warning: Buffer not empty after task completion. Remaining data: \(String(data: buffer, encoding: .utf8) ?? "Non-UTF8 data")")
            buffer.removeAll() // 清空残留数据
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
