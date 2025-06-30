import Foundation

enum AIActionType {
    case basic
    case vocabulary(word: String)
    case chat(chatHistory: [[String: String]], originalInput: String)
}

class AiService: NSObject, URLSessionDataDelegate {
    private var fullContent = ""
    private var buffer = Data()
    private var completionHandler: (() -> Void)?
    private var errorHandler: ((String) -> Void)? // 错误处理回调
    private var hasReceivedValidResponse = false // 添加标志来跟踪是否收到有效响应
    
    static let shared = AiService()
    
    // 合并后的聊天方法
    func chat(text: String? = nil, chatHistory: [[String: String]]? = nil, systemMessage: String? = nil, completion: (() -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        let settings = SettingsModel.shared
        guard let providerSettings = settings.defaultProviders[settings.selectedProvider],
              let url = URL(string: providerSettings.baseURL) else {
            // 如果 URL 或配置无效，也应该触发错误回调
            let errorMessage = NSLocalizedString("error_invalid_config", comment: "AI 服务配置无效")
            DispatchQueue.main.async {
                onError?(errorMessage) // 在主线程调用错误回调
                completion?() // 确保完成回调也被调用
            }
            return
        }
        
        // 检查 API Key 是否为空
        guard !providerSettings.apiKey.isEmpty else {
            let errorMessage = NSLocalizedString("error_empty_api_key", comment: "API Key 不能为空")
            DispatchQueue.main.async {
                onError?(errorMessage)
                completion?()
            }
            return
        }
        
        // 检查 model 是否为空
        guard !providerSettings.model.isEmpty else {
            let errorMessage = NSLocalizedString("error_empty_model", comment: "模型名称不能为空")
            DispatchQueue.main.async {
                onError?(errorMessage)
                completion?()
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300 // 设置超时时间为300秒
        request.setValue("Bearer \(providerSettings.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Request URL: \(url)")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        var messages: [[String: String]] = []
        
        // 如果 systemMessage 存在且不为空，则添加到 messages 数组
        if let systemContent = systemMessage, !systemContent.isEmpty {
            messages.append(["role": "system", "content": systemContent])
        }
        
        // 根据 chatHistory 参数判断处理方式
        if let history = chatHistory, !history.isEmpty {
            // 有历史对话：添加对话历史，只取最近10次对话
            let recentHistory = Array(history.suffix(10))
            messages.append(contentsOf: recentHistory)
        } else if let userText = text, !userText.isEmpty {
            // 单次对话：添加用户消息
            messages.append(["role": "user", "content": userText])
        } else {
            // 既没有历史对话也没有新文本，返回错误
            let errorMessage = NSLocalizedString("error_no_input", comment: "没有输入内容")
            DispatchQueue.main.async {
                onError?(errorMessage)
                completion?()
            }
            return
        }
        
        let body: [String: Any] = [
            "model": providerSettings.model,
            "messages": messages,
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
        self.errorHandler = onError // 保存错误回调
        
        task.resume()
    }
    
    /**
     * URLSession Delegate 方法 1: 处理 HTTP 响应头
     * 
     * 用途：
     * - 接收并验证服务器返回的 HTTP 响应状态码
     * - 判断请求是否成功（状态码 < 400 为成功）
     * - 设置全局标志位来标记响应的有效性
     * 
     * 工作机制：
     * - 在接收到响应头时首先被调用
     * - 检查 HTTP 状态码，如果 >= 400 则标记为错误响应
     * - 通过 completionHandler(.allow) 决定是否继续接收数据
     * - 为后续的数据处理方法提供响应状态信息
     */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            // 检查是否为错误状态码
            if httpResponse.statusCode >= 400 {
                hasReceivedValidResponse = false
                // 继续接收数据以获取错误信息
                completionHandler(.allow)
                return
            } else {
                hasReceivedValidResponse = true
            }
        }
        completionHandler(.allow)
    }
    
    /**
     * URLSession Delegate 方法 2: 处理流式数据接收
     * 
     * 用途：
     * - 接收并解析 AI 服务返回的流式数据（Server-Sent Events 格式）
     * - 实时处理 JSON 数据块，提取 AI 生成的文本内容
     * - 处理错误响应的解析和显示
     * - 实时更新 UI 界面显示 AI 回复内容
     * 
     * 工作机制：
     * - 将接收到的数据追加到缓冲区（buffer）
     * - 按行解析缓冲区数据，查找以 "data:" 开头的 SSE 格式数据
     * - 对每行 JSON 数据进行解码，提取 AI 回复的文本片段
     * - 累积文本内容并实时更新到 TextContentModel.shared.resultText
     * - 如果是错误响应，解析错误信息并通过 errorHandler 回调
     * - 处理流式传输结束标记 "[DONE]"
     *
     * 流式数据处理方法
     * - 使用专门的SSE解析器处理数据
     * - 自动过滤SSE注释和控制信息
     */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        // 处理错误响应
        if !hasReceivedValidResponse {
            handleErrorResponse()
            return
        }
        
        // 处理完整的数据行
        processCompleteLines()
    }
    
    private func handleErrorResponse() {
        guard let errorString = String(data: buffer, encoding: .utf8) else { return }
        
        do {
            if let errorData = errorString.data(using: .utf8),
               let errorJson = try JSONSerialization.jsonObject(with: errorData) as? [String: Any],
               let error = errorJson["error"] as? [String: Any] {
                
                let message = error["message"] as? String ?? "Unknown error"
                let type = error["type"] as? String ?? ""
                let errorMessage = type.isEmpty ? message : "\(type): \(message)"
                
                DispatchQueue.main.async {
                    TextContentModel.shared.resultText = "\(NSLocalizedString("error_request_failed", comment: "请求失败")): \(errorMessage)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                TextContentModel.shared.resultText = "\(NSLocalizedString("error_request_failed", comment: "请求失败")): \(errorString)"
            }
        }
    }
    
    private func processCompleteLines() {
        while let range = buffer.firstRange(of: Data("\n".utf8)) {
            let lineData = buffer.subdata(in: 0..<range.lowerBound)
            buffer.removeSubrange(0..<range.upperBound)
            
            // 使用SSE解析器处理数据
            let jsonStrings = SSEParser.parseSSEData(lineData)
            
            for jsonString in jsonStrings {
                if let content = SSEParser.extractContentFromJSON(jsonString) {
                    fullContent += content
                    
                    DispatchQueue.main.async {
                        TextContentModel.shared.resultText = self.fullContent.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
        }
    }
    
    /**
     * URLSession Delegate 方法 3: 处理请求完成
     * 
     * 用途：
     * - 处理网络请求的最终完成状态（成功或失败）
     * - 执行清理工作，防止内存泄漏
     * - 调用完成回调通知调用方请求结束
     * - 处理网络错误并提供用户友好的错误信息
     * 
     * 工作机制：
     * - 在请求完全结束时被调用（无论成功还是失败）
     * - 检查是否有网络错误，如果有则调用 errorHandler 回调
     * - 调用 completionHandler 通知调用方请求完成
     * - 清除回调引用（completionHandler 和 errorHandler）防止循环引用
     * - 清空缓冲区中的残留数据
     * - 确保所有操作在主线程执行，保证 UI 更新的线程安全
     */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { // 确保在主线程执行 UI 相关操作和回调
            if let error = error {
                print("请求错误: \(error.localizedDescription)")
                // 调用错误回调，传递友好的错误信息
                let friendlyErrorMessage = NSLocalizedString("error_request_failed", comment: "请求失败")
                self.errorHandler?(friendlyErrorMessage)
            }
            
            // 确保完成回调总是被调用，无论成功还是失败
            self.completionHandler?()
            // 清除回调引用，防止循环引用
            self.completionHandler = nil
            self.errorHandler = nil
        }
        // 可以在这里处理 buffer 中可能残留的最后一部分数据，虽然对于 SSE [DONE] 标记来说通常不需要
        if !buffer.isEmpty {
            print("Warning: Buffer not empty after task completion. Remaining data: \(String(data: buffer, encoding: .utf8) ?? "Non-UTF8 data")")
            buffer.removeAll() // 清空残留数据
        }
    }
}

// SSE 数据解析器
struct SSEParser {
    static func parseSSEData(_ data: Data) -> [String] {
        guard let content = String(data: data, encoding: .utf8) else {
            return []
        }
        
        return content.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { line in
                // 只处理 data: 开头的行，过滤掉注释和其他SSE元数据
                if line.hasPrefix("data: ") {
                    let dataContent = String(line.dropFirst(6))
                    return dataContent == "[DONE]" ? nil : dataContent
                }
                // 过滤掉注释行（以 : 开头）和其他SSE控制信息
                return nil
            }
    }
    
    static func extractContentFromJSON(_ jsonString: String) -> String? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let streamResponse = try JSONDecoder().decode(StreamResponse.self, from: jsonData)
            return streamResponse.choices.first?.delta.content
        } catch {
            print("JSON解析错误: \(error.localizedDescription), Raw JSON: \(jsonString)")
            return nil
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
