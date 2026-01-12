//
//  ChatFlowView.swift
//  cactus
//
//  Created by AI Assistant on 2024.
//

import SwiftUI
import Foundation
import MarkdownUI

/// 单个聊天消息视图组件
struct ChatMessageView: View {
    let message: ChatMessage
    
    // 复制和朗读状态
    @State private var showCopySuccess = false
    @State private var isSpeaking = false
    private let speechService = SpeechService.shared
    
    // 用户消息复制状态
    @State private var showUserCopySuccess = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isUser {
                // 用户消息
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    // 消息内容
                    Text(message.content)
                        .textSelection(.enabled)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.windowBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 用户消息操作按钮
                    HStack(spacing: 5) {
                        Spacer()
                        
                        // 编辑按钮
                        Button(action: {
                            editMessage(message.content)
                        }) {
                            Image(systemName: "square.and.pencil")
                                .frame(width: 15, height: 15)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_edit", comment: "编辑"))
                        
                        // 复制按钮
                        Button(action: {
                            copyUserMessage(message.content)
                        }) {
                            Image(systemName: showUserCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showUserCopySuccess ? .green : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                        .animation(.easeInOut, value: showUserCopySuccess)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
            } else {
                // AI消息
                VStack(alignment: .leading, spacing: 4) {
                    // 消息内容
                    Markdown(message.content)
                        .markdownTheme(.cactusMD)
                        .textSelection(.enabled)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    
                    // AI消息操作按钮
                    HStack(spacing: 5) {
                        // 复制按钮
                        Button(action: {
                            copyToClipboard(message.content)
                        }) {
                            Image(systemName: showCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showCopySuccess ? .green : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                        .animation(.easeInOut, value: showCopySuccess)
                        
                        // 朗读按钮
                        Button(action: {
                            speakText(message.content)
                        }) {
                            Image(systemName: "speaker.wave.2")
                                .frame(width: 15, height: 15)
                                .foregroundColor(isSpeaking ? .red : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_speak", comment: "朗读"))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 0)
                }
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 复制文本到剪贴板
    /// - Parameter text: 要复制的文本内容
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // 触发成功动画
        withAnimation {
            showCopySuccess = true
        }
        // 1.5秒后恢复图标
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopySuccess = false
            }
        }
    }
    
    /// 朗读文本内容
    /// - Parameter text: 要朗读的文本内容
    private func speakText(_ text: String) {
        guard !text.isEmpty else { return }
        
        // 检测语言并转换为语音语言代码
        let langCode = LangService.shared.detectLanguageCode(for: text)
        let speechLanguageCode = LangService.shared.convertToSpeechLanguageCode(langCode)
        
        isSpeaking = true
        speechService.speak(text, speechLanguageCode: speechLanguageCode)
        
        // 设置朗读完成后的状态重置
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSpeaking = false
        }
    }
    
    /// 复制用户消息到剪贴板
    /// - Parameter text: 要复制的文本内容
    private func copyUserMessage(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // 触发成功动画
        withAnimation {
            showUserCopySuccess = true
        }
        // 1.5秒后恢复图标
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showUserCopySuccess = false
            }
        }
    }
    
    /// 编辑用户消息，将内容填充到输入框
    /// - Parameter text: 要编辑的文本内容
    private func editMessage(_ text: String) {
        // 通过通知中心发送编辑消息的通知
        NotificationCenter.default.post(
            name: NSNotification.Name("FillTextToInput"),
            object: nil,
            userInfo: ["text": text]
        )
    }
}

/// 对话流视图组件
/// 用于显示聊天消息流，支持实时滚动和动态高度调整
struct ChatFlowView: View {
    // MARK: - 绑定属性
    @Binding var resultTextHeight: CGFloat
    
    // MARK: - 观察对象
    @ObservedObject private var contentModel = TextContentModel.shared
    
    // MARK: - 配置属性
    let maxHeight: CGFloat
    
    // MARK: - 常量
    private let minResultTextHeight: CGFloat = 100
    
    // MARK: - 回调闭包
    let onHeightUpdate: () -> Void
    
    // MARK: - 性能优化: 节流机制,防止主线程阻塞
    @State private var lastHeightUpdateTime: Date = Date.distantPast
    @State private var heightUpdateTimer: Timer?
    
    /// 初始化对话流视图
    /// - Parameters:
    ///   - resultTextHeight: 结果文本高度的绑定
    ///   - maxHeight: 最大高度限制
    ///   - onHeightUpdate: 高度更新时的回调闭包
    init(resultTextHeight: Binding<CGFloat>,
         maxHeight: CGFloat = 600,
         onHeightUpdate: @escaping () -> Void) {
        self._resultTextHeight = resultTextHeight
        self.maxHeight = maxHeight
        self.onHeightUpdate = onHeightUpdate
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // 正常顺序显示消息，最新消息在底部
                    ForEach(contentModel.chatMessages) { message in
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
            .onChange(of: contentModel.chatMessages.count) { _ in
                // 当有新消息时（用户发送或AI回复完成），更新高度并滚动到底部一次
                updateChatFlowHeight()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToBottom(proxy: proxy)
                }
            }
            // 监听AI聊天状态变化
            .onChange(of: contentModel.isChatting) { isChatting in
                if isChatting {
                    // AI开始回复时，立即滚动到底部一次
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy)
                    }
                } else {
                    // ✅ 性能优化: 仅在AI回复完成后更新一次高度
                    // 移除流式输出时的频繁高度计算,避免主线程阻塞和CPU 100%占用
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        updateChatFlowHeight()
                    }
                }
            }

            // 在视图出现时立即调整高度
            .onAppear {
                updateChatFlowHeight()
            }
            .onDisappear {
                // 清理定时器,防止内存泄漏
                heightUpdateTimer?.invalidate()
                heightUpdateTimer = nil
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 滚动到底部的辅助方法
    /// - Parameters:
    ///   - proxy: ScrollViewReader的代理对象
    ///   - animated: 是否使用动画，默认为true
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if contentModel.isChatting {
            // AI正在回复时，滚动到正在输入的消息
            if animated {
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo("typing-ai-message", anchor: .bottom)
                }
            } else {
                proxy.scrollTo("typing-ai-message", anchor: .bottom)
            }
        } else if let lastMessage = contentModel.chatMessages.last {
            // 正常情况下滚动到最后一条消息
            if animated {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    /// 节流更新聊天流高度
    /// 使用定时器避免过于频繁的高度计算,防止主线程阻塞
    /// - Parameter throttleInterval: 节流间隔(秒),默认0.3秒
    private func updateChatFlowHeightThrottled(throttleInterval: TimeInterval = 0.3) {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastHeightUpdateTime)
        
        // 如果距离上次更新超过节流间隔,立即更新
        if timeSinceLastUpdate > throttleInterval {
            updateChatFlowHeight()
            lastHeightUpdateTime = now
        } else {
            // 否则使用定时器延迟更新,避免过于频繁
            heightUpdateTimer?.invalidate()
            heightUpdateTimer = Timer.scheduledTimer(withTimeInterval: throttleInterval, repeats: false) { [self] _ in
                updateChatFlowHeight()
                lastHeightUpdateTime = Date()
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
        for message in contentModel.chatMessages {
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
