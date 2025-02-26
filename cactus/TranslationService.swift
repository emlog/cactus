//
//  TranslationService.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/22.
//


import Foundation

enum TranslationError: Error {
    case invalidResponse
    case networkError
}

class TranslationService {
    static func translate(text: String, completion: @escaping (Result<String, TranslationError>) -> Void) {
        // 示例：简单反转文本
        let translatedText = String(text.reversed())
        completion(.success(translatedText))
        // 实际应用中应替换为翻译API调用
    }
}
