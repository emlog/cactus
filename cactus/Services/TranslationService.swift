import Foundation

class TranslationService: NSObject, URLSessionDataDelegate {
    private var fullContent = ""
    private var buffer = Data()
    
    func translate(text: String) {
        let settings = SettingsModel.shared
        guard let url = URL(string: settings.baseURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Request URL: \(url)")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // 更新请求体，添加 stream 参数
        let body: [String: Any] = [
            "model": settings.model,
            "messages": [
                ["role": "user", "content":  text + "\n\n 尽可能快的将上面的中文翻译为英文，非中文则翻译为中文，注意不要输出任何提示内容"]
            ],
            "max_tokens": 1000,
            "stream": true // 启用流式输出
        ]
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = httpBody
            print("Request Body: \(String(data: httpBody, encoding: .utf8) ?? "")")
        }
        
        // 清空之前的翻译结果和缓存
        DispatchQueue.main.async {
            TextContentModel.shared.translatedText = ""
        }
        fullContent = ""
        buffer = Data()
        
        // 创建自定义的URLSession，使用self作为delegate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    // URLSessionDataDelegate方法，处理接收到的数据片段
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        // 尝试从buffer中提取完整的SSE消息
        if let bufferString = String(data: buffer, encoding: .utf8) {
            let lines = bufferString.components(separatedBy: "\n")
            var processedUpTo = 0
            
            for (index, line) in lines.enumerated() {
                // 跳过空行
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty {
                    processedUpTo = index + 1
                    continue
                }
                
                // 检查是否是数据行
                if trimmedLine.hasPrefix("data: ") {
                    let dataContent = trimmedLine.dropFirst(6) // 移除 "data: " 前缀
                    
                    // 检查是否是结束标记
                    if dataContent == "[DONE]" {
                        print("流式输出完成")
                        processedUpTo = index + 1
                        continue
                    }
                    
                    // 尝试解析 JSON
                    if let jsonData = String(dataContent).data(using: .utf8),
                       let streamResponse = try? JSONDecoder().decode(StreamResponse.self, from: jsonData),
                       let content = streamResponse.choices.first?.delta.content {
                        
                        // 累积内容
                        fullContent += content
                        
                        // 更新 UI
                        DispatchQueue.main.async {
                            TextContentModel.shared.translatedText = self.fullContent
                        }
                    }
                    
                    processedUpTo = index + 1
                }
            }
            
            // 移除已处理的部分
            if processedUpTo > 0 {
                let processedData = lines[..<processedUpTo].joined(separator: "\n").data(using: .utf8) ?? Data()
                buffer.removeFirst(min(processedData.count, buffer.count))
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("请求错误: \(error.localizedDescription)")
        } else {
            print("请求完成")
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
