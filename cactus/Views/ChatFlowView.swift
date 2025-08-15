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
                        .background(Color.accentColor.opacity(0.1))
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
    
    // MARK: - 配置属性
    let maxHeight: CGFloat
    
    // MARK: - 常量
    private let minResultTextHeight: CGFloat = 100
    
    // MARK: - 回调闭包
    let onHeightUpdate: () -> Void
    
    /// 初始化对话流视图
    /// - Parameters:
    ///   - chatMessages: 聊天消息数组的绑定
    ///   - resultTextHeight: 结果文本高度的绑定
    ///   - maxHeight: 最大高度限制
    ///   - onHeightUpdate: 高度更新时的回调闭包
    init(chatMessages: Binding<[ChatMessage]>,
         resultTextHeight: Binding<CGFloat>,
         maxHeight: CGFloat = 600,
         onHeightUpdate: @escaping () -> Void) {
        self._chatMessages = chatMessages
        self._resultTextHeight = resultTextHeight
        self.maxHeight = maxHeight
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
            // 监听AI回复内容变化，实现实时滚动和高度调整
            .onChange(of: contentModel.resultText) { _ in
                if contentModel.isChatting {
                    scrollToBottom(proxy: proxy)
                    updateChatFlowHeight()
                }
            }
            // 监听聊天状态变化，确保在聊天开始和结束时调整高度
            .onChange(of: contentModel.isChatting) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateChatFlowHeight()
                }
            }
            // 在视图出现时立即调整高度
            .onAppear {
                updateChatFlowHeight()
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
        var totalHeight: CGFloat = 40 // 上下padding
        
        // 计算已有消息的高度
        for message in chatMessages {
            let messageHeight = calculateMessageHeight(content: message.content, isUser: message.isUser)
            totalHeight += messageHeight + 16 // 16为消息间距(spacing: 12 + padding: 4)
        }
        
        // 如果AI正在回复，计算当前回复内容的高度
        if contentModel.isChatting, let resultText = contentModel.resultText, !resultText.isEmpty {
            let typingMessageHeight = calculateMessageHeight(content: resultText, isUser: false)
            totalHeight += typingMessageHeight + 16
        }
        
        // 确保至少有最小高度，并限制最大高度
        return min(max(totalHeight, minResultTextHeight), maxHeight)
    }
    
    /// 计算单条消息的高度
    /// - Parameters:
    ///   - content: 消息内容
    ///   - isUser: 是否为用户消息
    /// - Returns: 消息高度
    private func calculateMessageHeight(content: String, isUser: Bool) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        // 计算可用宽度（考虑消息气泡的padding和边距）
        let availableWidth: CGFloat = 600 - 24 - 24 // 总宽度 - 水平padding - 消息内边距
        
        let textStorage = NSTextStorage(string: content, attributes: attributes)
        let textContainer = NSTextContainer(containerSize: NSSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.ensureLayout(for: textContainer)
        let textHeight = layoutManager.usedRect(for: textContainer).height
        
        // 添加消息气泡的内边距和基础高度
        let messageHeight = textHeight + 16 + 8 // 16为垂直padding，8为额外空间
        
        // 为AI消息添加图标高度（如果需要）
        let minMessageHeight: CGFloat = isUser ? 40 : 48 // AI消息需要更多空间放图标
        
        return max(messageHeight, minMessageHeight)
    }
}
