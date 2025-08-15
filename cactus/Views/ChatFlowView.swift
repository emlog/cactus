//
//  ChatFlowView.swift
//  cactus
//
//  Created by AI Assistant on 2024.
//

import SwiftUI
import Foundation
import MarkdownUI

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

/// 单个聊天消息视图组件
struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isUser {
                // 用户消息
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    // 消息内容
                    Text(message.content)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                // AI消息
                VStack(alignment: .leading, spacing: 4) {
                    // 消息内容
                    Markdown(message.content)
                        .markdownTheme(.cactusMD)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

/// 对话流视图组件
/// 用于显示聊天消息流，支持实时滚动和动态高度调整
struct ChatFlowView: View {
    // MARK: - 绑定属性
    @Binding var chatMessages: [ChatMessage]
    @Binding var resultTextHeight: CGFloat
    
    // MARK: - 观察对象
    @ObservedObject private var contentModel = TextContentModel.shared
    
    // MARK: - 常量
    private let minResultTextHeight: CGFloat = 100
    
    // MARK: - 回调闭包
    let onHeightUpdate: () -> Void
    
    /// 初始化对话流视图
    /// - Parameters:
    ///   - chatMessages: 聊天消息数组的绑定
    ///   - resultTextHeight: 结果文本高度的绑定
    ///   - onHeightUpdate: 高度更新时的回调闭包
    init(chatMessages: Binding<[ChatMessage]>,
         resultTextHeight: Binding<CGFloat>,
         onHeightUpdate: @escaping () -> Void) {
        self._chatMessages = chatMessages
        self._resultTextHeight = resultTextHeight
        self.onHeightUpdate = onHeightUpdate
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // 正常顺序显示消息，最新消息在底部
                    ForEach(chatMessages) { message in
                        ChatMessageView(message: message)
                            .id(message.id)
                    }
                    
                    // 显示正在输入的AI回复（如果有）
                    if contentModel.isChatting, let resultText = contentModel.resultText, !resultText.isEmpty {
                        ChatMessageView(message: ChatMessage(content: resultText, isUser: false))
                            .id("typing-ai-message")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, minHeight: minResultTextHeight, maxHeight: resultTextHeight)
            .background(Color(.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separatorColor), lineWidth: 1)
            )
            .onChange(of: chatMessages.count) { _ in
                scrollToBottom(proxy: proxy)
                updateChatFlowHeight()
            }
            // 监听AI回复内容变化，实现实时滚动
            .onChange(of: contentModel.resultText) { _ in
                if contentModel.isChatting {
                    scrollToBottom(proxy: proxy)
                    updateChatFlowHeight()
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 滚动到底部的辅助方法
    /// - Parameter proxy: ScrollViewReader的代理对象
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if contentModel.isChatting {
            // AI正在回复时，滚动到正在输入的消息
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo("typing-ai-message", anchor: .bottom)
            }
        } else if let lastMessage = chatMessages.last {
            // 正常情况下滚动到最后一条消息
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    /// 更新聊天流高度的辅助方法
    private func updateChatFlowHeight() {
        let totalHeight = calculateChatFlowHeight()
        resultTextHeight = min(max(totalHeight, minResultTextHeight), 600)
        onHeightUpdate()
    }
    
    /// 计算聊天流高度
    /// - Returns: 计算得出的高度值
    private func calculateChatFlowHeight() -> CGFloat {
        let messageCount = chatMessages.count
        if messageCount == 0 {
            return minResultTextHeight
        }
        
        // 估算每条消息的平均高度（包括头像、内容、时间戳和间距）
        let averageMessageHeight: CGFloat = 80
        let totalHeight = CGFloat(messageCount) * averageMessageHeight + 40 // 40为上下padding
        
        return min(max(totalHeight, minResultTextHeight), 600) // 限制最大高度为600
    }
}
