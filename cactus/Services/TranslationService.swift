import Foundation

struct TranslationService {
    
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
        
        // Update the body to include the 'messages' parameter
        let body: [String: Any] = [
            "model": settings.model,
            "messages": [
                ["role": "user", "content": "请把 === 后面的中文翻译为英文，其他语言则翻译为中文，注意不要输出任何提示内容 === " + text]
            ],
            "max_tokens": 1000
        ]
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = httpBody
            print("Request Body: \(String(data: httpBody, encoding: .utf8) ?? "")")
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let data = data {
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "")")
                if let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                    // 使用 DispatchQueue.main.async 确保在主线程上更新 translatedText
                    DispatchQueue.main.async {
                        TextContentModel.shared.translatedText = result.choices.first?.message.content
                    }
                }
            }
        }.resume()
        
        semaphore.wait()
    }
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
