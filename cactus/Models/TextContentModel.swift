import Foundation
import SwiftUI

/// 聊天消息数据模型
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    /// 初始化聊天消息
    /// - Parameters:
    ///   - content: 消息内容
    ///   - isUser: 是否为用户消息
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

class TextContentModel: ObservableObject {
    static let shared = TextContentModel()
    
    @Published var text: String = ""
    @Published var resultText: String? = nil
    @Published var isProcessing: Bool = false
    
    // Add specific loading states for each function
    @Published var isTranslating: Bool = false
    @Published var isSummarizing: Bool = false
    @Published var isDictionaryLookup: Bool = false
    @Published var isChatting: Bool = false
    
    // 添加停止状态管理
    @Published var shouldStopRequest: Bool = false
    
    // MARK: - 统一的聊天数据管理
    /// 对话历史（用于API调用）
    @Published var chatHistory: [[String: String]] = []
    
    /// 对话消息流（用于UI显示）
    @Published var chatMessages: [ChatMessage] = []
    
    // MARK: - 聊天管理方法
    
    /// 添加用户消息到对话流和历史
    /// - Parameter content: 用户输入内容
    func addUserMessage(_ content: String) {
        // 添加到API历史
        chatHistory.append(["role": "user", "content": content])
        
        // 添加到UI消息流
        let userMessage = ChatMessage(content: content, isUser: true)
        chatMessages.append(userMessage)
    }
    
    /// 添加AI回复到对话流和历史
    /// - Parameter content: AI回复内容
    func addAIMessage(_ content: String) {
        // 添加到API历史
        chatHistory.append(["role": "assistant", "content": content])
        
        // 添加到UI消息流
        let aiMessage = ChatMessage(content: content, isUser: false)
        chatMessages.append(aiMessage)
    }
    
    /// 清空所有聊天数据
    func clearChatData() {
        chatHistory = []
        chatMessages = []
    }
    
    /// 获取当前对话历史（用于API调用）
    /// - Returns: 对话历史数组
    func getChatHistory() -> [[String: String]] {
        return chatHistory
    }
    
    /// 检查是否有聊天数据
    /// - Returns: 是否有聊天消息
    func hasChatData() -> Bool {
        return !chatMessages.isEmpty
    }
}
