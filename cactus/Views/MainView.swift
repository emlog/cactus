import SwiftUI
import Foundation
import MarkdownUI

// Define loading type enum
enum LoadingType {
    case translate
    case summary
    case dictionary
    case chat
}

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var preferences = PreferencesModel.shared
    @ObservedObject private var vocabularyManager = VocabularyManager.shared
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @ObservedObject private var historyManager = HistoryManager.shared
    @State private var Ai = AiService.shared
    @State private var Lang = LangService.shared
    @State private var Prompt = promptService.shared
    
    // 注意：聊天数据管理已移至 TextContentModel 中统一管理
    
    // 吐司提示管理器 - 使用单例实例避免 StateObject 重复初始化问题
    @ObservedObject private var toastManager = ToastManager.shared
    
    // 复制成功状态，用于按钮图标动画
    @State private var showInputCopySuccess = false
    @State private var showResultCopySuccess = false
    // 收藏成功状态
    @State private var showFavoriteSuccess = false
    
    // 默认尺寸
    private let minInputTextHeight: CGFloat = 100
    private let minResultTextHeight: CGFloat = 100
    private let maxInputTextHeight: CGFloat = 160
    private let maxResultTextHeight: CGFloat = 660
    private let minTextWidth: CGFloat = 690
    
    // 输入框：使用一个状态变量来驱动 CustomTextEditor 的高度
    @State private var inputTextHeight: CGFloat = 100
    @State private var resultTextHeight: CGFloat = 100
    
    // 用于控制输入框焦点的状态变量
    @FocusState private var isInputEditorFocused: Bool
    
    // 语音朗读相关状态
    @State private var isSpeakingInput = false
    @State private var isSpeakingResult = false
    private let speechService = SpeechService.shared
    
    // 跟踪输出窗口是否已展开
    @State private var isResultViewExpanded = false
    
    // 添加自定义提示词按钮的引用
    @State private var customPromptButton = CustomPromptButton()
    
    // MARK: - 通知观察者token管理,防止内存泄漏
    @State private var notificationTokens: [NSObjectProtocol] = []
    
    // 将计算属性移到这里（MainView结构体的顶层）
    private var customPromptButtonView: some View {
        CustomPromptButton(selectedPrompt: $preferences.selectedCustomPrompt)
    }
    
    /// 对话流视图组件
    private var chatFlowView: some View {
        ChatFlowView(
            resultTextHeight: $resultTextHeight,
            maxHeight: dynamicMaxResultHeight,
            onHeightUpdate: {
                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
            }
        )
    }
    
    /// 传统结果显示视图（用于翻译、总结、词典等功能）
    private func traditionalResultView(resultText: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                Markdown(resultText)
                    .markdownTheme(.cactusMD)
                    .textSelection(.enabled)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 30) // 增加底部内边距，为按钮留出空间
            }
            .frame(maxWidth: .infinity, minHeight: minResultTextHeight, maxHeight: resultTextHeight, alignment: .leading)
            .background(Color(.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separatorColor), lineWidth: 1)
            )
            .onChange(of: contentModel.resultText, perform: { value in
                // 动态调整结果文本高度
                if let text = value, !text.isEmpty {
                    // 计算文本高度并设置
                    resultTextHeight = calculateTextHeight(text: text, width: minTextWidth)
                } else {
                    resultTextHeight = minResultTextHeight // 如果结果为空，重置为最小高度
                }
                // 通知窗口调整大小
                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
            })
            
            HStack(spacing: 8) {
                Button(action: {
                    speakText(contentModel.resultText ?? "")
                }) {
                    Image(systemName: "speaker.wave.2")
                        .frame(width: 15, height: 15)
                        .foregroundColor(isSpeakingResult ? .red : .secondary)
                }
                .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                .help(NSLocalizedString("help_speak", comment: "朗读"))
                .disabled(contentModel.resultText?.isEmpty ?? true)
                
                Button(action: {
                    copyResp()// 复制输出
                }) {
                    Image(systemName: showResultCopySuccess ? "checkmark" : "square.on.square")
                        .frame(width: 15, height: 15)
                        .foregroundColor(showResultCopySuccess ? .green : .secondary) // 成功时绿色
                }
                .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                .help(NSLocalizedString("help_copy", comment: "复制"))
                .animation(.easeInOut, value: showResultCopySuccess) // 添加动画效果
                .disabled(contentModel.resultText?.isEmpty ?? true) // 结果为空时禁用
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.controlBackgroundColor).opacity(0.9))
            )
        }
        .transition(.opacity.combined(with: .scale)) // ZStack自身的过渡动画保持不变
    }
    
    var body: some View {
        Form {
            Section() {
                ZStack(alignment: .bottomTrailing) {
                    CustomTextEditor(text: $contentModel.text, onCommit: {
                        triggerDefaultMainFunction()
                    }, calculatedHeight: $inputTextHeight) // 传递高度绑定
                    .focused($isInputEditorFocused) // 绑定焦点状态
                    .frame(height: inputTextHeight) // 使用状态变量设置高度
                    .padding(.bottom, 25) // 增加底部内边距，为按钮留出空间
                    .padding(.horizontal, 0) // 保持水平内边距为0（如果 CustomTextEditor 内部已处理）
                    .padding(.top, 5)        // 保持顶部内边距为0
                    .background(Color(.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FillTextToInput"))) { notification in
                        if let userInfo = notification.userInfo,
                           let text = userInfo["text"] as? String {
                            fillText(text)
                            isInputEditorFocused = true
                        }
                    }
                    
                    HStack(spacing: 8) {
                        // 清除按钮
                        Button(action: {
                            clearAll()
                        }) {
                            Image(systemName: "xmark.circle")
                                .frame(width: 15, height: 15)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_clear", comment: "清空"))
                        .disabled(contentModel.text.isEmpty && (contentModel.resultText?.isEmpty ?? true) && !contentModel.hasChatData())
                        
                        // 收藏按钮
                        Button(action: {
                            addToFavorites()
                        }) {
                            Label("", systemImage: showFavoriteSuccess ? "heart.fill" : "heart")
                                .labelStyle(.iconOnly)
                                .foregroundColor(showFavoriteSuccess ? .red : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_favorite", comment: "收藏"))
                        .animation(.easeInOut, value: showFavoriteSuccess) // 添加动画效果
                        .disabled(contentModel.text.isEmpty)
                        
                        // 语音朗读（输入）
                        Button(action: {
                            speakText(contentModel.text)
                        }) {
                            Image(systemName: "speaker.wave.2")
                                .frame(width: 15, height: 15)
                                .foregroundColor(isSpeakingInput ? .red : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_speak", comment: "朗读"))
                        .disabled(contentModel.text.isEmpty)
                        
                        // 复制按钮
                        Button(action: {
                            copyWriting()
                        }) {
                            Image(systemName: showInputCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showInputCopySuccess ? .green : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                        .animation(.easeInOut, value: showInputCopySuccess) // 添加动画效果
                        .disabled(contentModel.text.isEmpty) // 输入为空时禁用
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                }
            }
            
            Section() {
                HStack(spacing: 2) {
                    // 翻译按钮
                    Button(action: {
                        if contentModel.isTranslating {
                            stopAIRequest()
                        } else {
                            translateText()
                        }
                    }) {
                        Image(systemName: contentModel.isTranslating ? "stop.fill" : "character.textbox")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing && !contentModel.isTranslating)
                    .hoverTooltip(contentModel.isTranslating ? NSLocalizedString("stop", comment: "停止") : NSLocalizedString("help_translate", comment: "翻译文本"), delay: 0.5)
                    
                    // 摘要按钮
                    Button(action: {
                        if contentModel.isSummarizing {
                            stopAIRequest()
                        } else {
                            summaryText()
                        }
                    }) {
                        Image(systemName: contentModel.isSummarizing ? "stop.fill" : "list.dash.header.rectangle")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing && !contentModel.isSummarizing)
                    .hoverTooltip(contentModel.isSummarizing ? NSLocalizedString("stop", comment: "停止") : NSLocalizedString("help_summary", comment: "总结摘要"), delay: 0.5)
                    
                    // 字典按钮
                    Button(action: {
                        if contentModel.isDictionaryLookup {
                            stopAIRequest()
                        } else {
                            dictionaryText()
                        }
                    }) {
                        Image(systemName: contentModel.isDictionaryLookup ? "stop.fill" : "book")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing && !contentModel.isDictionaryLookup)
                    .hoverTooltip(contentModel.isDictionaryLookup ? NSLocalizedString("stop", comment: "停止") : NSLocalizedString("help_dict", comment: "解释说明"), delay: 0.5)
                    
                    // 分隔符
                    Rectangle()
                        .frame(width: 1, height: 15)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.horizontal, 5)
                    
                    // 对话问答按钮
                    Button(action: {
                        if contentModel.isChatting {
                            stopAIRequest()
                        } else {
                            chatText()
                        }
                    }) {
                        Image(systemName: contentModel.isChatting ? "stop.fill" : "arrow.up")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing && !contentModel.isChatting)
                    .hoverTooltip(contentModel.isChatting ? NSLocalizedString("stop", comment: "停止") : NSLocalizedString("help_chat", comment: "发送消息"), delay: 0.5)
                    
                    // 自定义提示词选择按钮
                    customPromptButtonView
                    
                    Spacer()
                    
                    // 将loading动画移到最右端
                    if contentModel.isProcessing {
                        MiniLoadingView()
                            .frame(width: 20, height: 20)
                    }
                    
                    // 隐藏的按钮来监听 ESC 键，关闭当前窗口
                    Button("") {
                        NSApplication.shared.keyWindow?.close()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    .frame(width: 0, height: 0) // 使按钮不可见
                    .hidden() // 进一步隐藏
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                )
            }
            
            Section() {
                // 对话流显示区域 - 仅在聊天模式下显示
                if contentModel.hasChatData() {
                    chatFlowView
                }
                // 其他功能的结果显示区域（翻译、总结、词典）
                else if let resultText = contentModel.resultText, !resultText.isEmpty || isResultViewExpanded {
                    traditionalResultView(resultText: resultText)
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        .frame(minWidth: minTextWidth)
        .toast(toastManager)
        .onAppear {
            // 监听窗口关闭通知
            let closeToken = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: nil,
                queue: .main
            ) { _ in
                stopSpeaking()
                // 不再清空聊天历史和消息流，保持对话状态
            }
            notificationTokens.append(closeToken)
            
            // 监听复制成功通知
            let copySuccessToken = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowCopySuccessToast"),
                object: nil,
                queue: .main
            ) { _ in
                self.showCopySuccessToast()
            }
            notificationTokens.append(copySuccessToken)
            
            // 监听复制错误通知
            let copyErrorToken = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowCopyErrorToast"),
                object: nil,
                queue: .main
            ) { _ in
                self.showCopyErrorToast()
            }
            notificationTokens.append(copyErrorToken)
            
            // MARK: - 监听应用进入后台,清理内存
            let resignActiveToken = NotificationCenter.default.addObserver(
                forName: NSApplication.didResignActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.cleanupMemory()
            }
            notificationTokens.append(resignActiveToken)
        }
        .onDisappear {
            // 移除所有通知观察者,防止内存泄漏
            notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
            notificationTokens.removeAll()
            stopSpeaking()
        }
        .onChange(of: preferences.selectedCustomPrompt) { _ in
            // 切换自定义提示词时不清空聊天记录，保持对话连续性
            // 用户可以在不同提示词下继续对话
        }
    }
    
    // MARK: - 辅助函数
    
    /// 动态最大结果高度
    // 在 MainView 结构体中添加新的计算属性
    private var dynamicMaxResultHeight: CGFloat {
        guard let screen = NSScreen.main else {
            return maxResultTextHeight // 回退到固定值
        }
        
        // 获取可用屏幕高度（减去菜单栏和dock栏）
        let availableHeight = screen.visibleFrame.height
        
        // 计算窗口其他部分的高度（输入框、按钮栏、边距等）
        let otherComponentsHeight: CGFloat = inputTextHeight + 60 + 40 // 输入框 + 按钮栏 + 边距
        
        // 为结果区域保留80%的可用空间，但至少保证最小高度
        let maxAllowedHeight = max(availableHeight * 0.8 - otherComponentsHeight, minResultTextHeight)
        
        return min(maxAllowedHeight, 800) // 设置一个合理的上限
    }
    
    // 修改 calculateTextHeight 方法
    private func calculateTextHeight(text: String, width: CGFloat) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 15)
        // 应用行间距到属性字符串
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        let textStorage = NSTextStorage(string: text, attributes: attributes)
        
        // 减去 TextEditor 的内边距和 NSTextContainer 的 lineFragmentPadding
        let effectiveWidth = width - 20 // (padding * 2)
        let textContainer = NSTextContainer(containerSize: NSSize(width: effectiveWidth, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 5 // NSTextView 默认的 padding
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.ensureLayout(for: textContainer) // 确保布局完成
        let height = layoutManager.usedRect(for: textContainer).height
        
        // 添加 TextEditor 的垂直内边距 (padding * 2) 和一些额外空间
        let totalHeight = height + 20 + 10 // 加上垂直 padding 和额外空间
        
        // 使用动态最大高度限制
        return min(max(totalHeight, minResultTextHeight), dynamicMaxResultHeight)
    }
    
    func fillText(_ newText: String) {
        DispatchQueue.main.async {
            let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.contentModel.text = trimmedText
        }
    }
    
    // 清除所有内容
    /// 清空所有内容，包括输入文本、结果文本和聊天记录
    func clearAll() {
        let isInputEmpty = contentModel.text.isEmpty
        let isResultEmpty = contentModel.resultText?.isEmpty ?? true
        let isChatEmpty = !contentModel.hasChatData()
        
        if isInputEmpty && isResultEmpty && isChatEmpty {
            return
        }
        
        stopSpeaking()
        
        DispatchQueue.main.async {
            self.contentModel.text = ""
            self.contentModel.resultText = nil
            // 使用 TextContentModel 的统一清空方法
            self.contentModel.clearChatData()
            // 重置输入和输出区域的高度为默认值
            self.inputTextHeight = minInputTextHeight
            self.resultTextHeight = minResultTextHeight
            // 重置展开状态
            self.isResultViewExpanded = false
            // 清除后，通知窗口调整大小
            NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
            // 设置输入框焦点
            self.isInputEditorFocused = true
        }
    }
    
    // 复制输入
    func copyWriting() {
        if contentModel.text.isEmpty {
            toastManager.showError(NSLocalizedString("pop_text_empty", comment: "没有可复制的内容"))
        } else {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(contentModel.text, forType: .string)
            // 恢复成功提示
            toastManager.showSuccess(NSLocalizedString("pop_copy_success", comment: "复制成功"))
            
            // 触发成功动画
            withAnimation {
                showInputCopySuccess = true
            }
            // 1.5秒后恢复图标
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showInputCopySuccess = false
                }
            }
        }
    }
    
    // 复制输出
    func copyResp() {
        if let promptText = contentModel.resultText, !promptText.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(promptText, forType: .string)
            // 恢复成功提示
            toastManager.showSuccess(NSLocalizedString("pop_copy_success", comment: "复制成功"))
            
            // 触发成功动画
            withAnimation {
                showResultCopySuccess = true
            }
            // 1.5秒后恢复图标
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showResultCopySuccess = false
                }
            }
        } else {
            toastManager.showError(NSLocalizedString("pop_text_empty", comment: "没有可复制的内容"))
        }
    }
    
    /// 显示复制成功吐司提示（供WindowManager调用）
    func showCopySuccessToast() {
        toastManager.showSuccess(NSLocalizedString("pop_copy_success", comment: "复制成功"))
        
        // 触发成功动画
        withAnimation {
            showResultCopySuccess = true
        }
        // 1.5秒后恢复图标
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showResultCopySuccess = false
            }
        }
    }
    
    /// 显示复制错误吐司提示（供WindowManager调用）
    func showCopyErrorToast() {
        toastManager.showError(NSLocalizedString("pop_text_empty", comment: "没有可复制的内容"))
    }
    
    // 翻译
    func translateText() {
        let inputText = contentModel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if inputText.isEmpty {
            toastManager.showError(NSLocalizedString("pop_translate_text_empty", comment: "请先输入内容"))
            return
        }
        
        contentModel.clearChatData()
        
        let systemMessage: String
        
        // 翻译规则：
        // 1、如果是常用语言，翻译为第一外语
        // 2、如果不是常用语言，翻译为常用语言（母语）
        if Lang.isTextInPreferredLanguage(inputText) {
            systemMessage = Prompt.getSystemMessageForTranslateToCommonForeignLanguage() // 常用语言翻译为第一外语
            performAIAction(systemMessage: systemMessage, actionType: .basic, loadingType: .translate)
        } else if Lang.isSentence(inputText) == false && Lang.isWordInSupportedLanguages(inputText) {
            // 翻译为常用语言：单词翻译（只支持英语、法语、西班牙语、德语）
            systemMessage = Prompt.getSystemMessageForTranslateWord()
            performAIAction(systemMessage: systemMessage, actionType: .vocabulary(word: inputText), loadingType: .translate)
            return
        } else {
            // 翻译为常用语言：句子翻译
            systemMessage = Prompt.getSystemMessageForTranslate()
            performAIAction(systemMessage: systemMessage, actionType: .basic, loadingType: .translate)
        }
    }
    
    // 总结
    func summaryText() {
        let inputText = contentModel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if inputText.isEmpty {
            toastManager.showError(NSLocalizedString("pop_summary_text_empty", comment: "请先输入内容"))
            return
        }
        
        contentModel.clearChatData()
        
        let systemMessage = Prompt.getSystemMessageForSummary()
        performAIAction(systemMessage: systemMessage, actionType: .basic, loadingType: .summary)
    }
    
    // 字典（主要查询母语词语）
    func dictionaryText() {
        let systemMessage: String
        let inputText = contentModel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if inputText.isEmpty {
            toastManager.showError(NSLocalizedString("pop_dict_text_empty", comment: "请先输入内容"))
            return
        }
        if Lang.isSentence(inputText) == true {
            toastManager.showError(NSLocalizedString("pop_dict_text_empty", comment: "请先输入内容"))
            return
        }
        
        contentModel.clearChatData()
        
        if Lang.isTextInPreferredLanguage(inputText) {
            systemMessage = Prompt.getSystemMessageForDict() // 查母语字典
        } else {
            systemMessage = Prompt.getSystemMessageForTranslateWord() // 单词翻译
        }
        performAIAction(systemMessage: systemMessage, actionType: .basic, loadingType: .dictionary)
    }
    
    // 对话
    func chatText() {
        let inputText = contentModel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if inputText.isEmpty {
            toastManager.showError(NSLocalizedString("pop_chat_text_empty", comment: "请先输入内容"))
            return
        }
        
        // 检查是否有选中的自定义提示词 - 使用UUID读取
        var systemMessage: String
        if let selectedPromptId = preferences.selectedCustomPrompt,
           let customPromptContent = preferences.getCustomPromptContent(by: selectedPromptId) {
            systemMessage = customPromptContent
        } else {
            systemMessage = Prompt.getSystemMessageForChat()
        }
        
        // 使用 TextContentModel 的统一方法添加用户消息
        contentModel.addUserMessage(inputText)
        
        // 保存当前输入文本用于历史记录
        let currentInput = contentModel.text
        
        // 清空输入框
        contentModel.text = ""
        
        performAIAction(systemMessage: systemMessage, actionType: .chat(chatHistory: contentModel.getChatHistory(), originalInput: currentInput), loadingType: .chat)
    }
    
    // 只做一些清理窗口的动作
    func noactionText() {
        contentModel.resultText = nil
        isResultViewExpanded = false
    }
    
    // 语音朗读
    func speakText(_ text: String) {
        guard !text.isEmpty else { return }
        
        let langCode = Lang.detectLanguageCode(for: text)
        let speechLanguageCode = Lang.convertToSpeechLanguageCode(langCode)
        speechService.speak(text, speechLanguageCode: speechLanguageCode)
    }
    
    private func stopSpeaking() {
        speechService.stopSpeaking()
    }
    
    // 添加收藏
    func addToFavorites() {
        let inputText = contentModel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let resultText = contentModel.resultText ?? ""
        guard !inputText.isEmpty else {
            toastManager.showError("favorite content is empty")
            return
        }
        
        FavoriteManager.shared.addFavorite(
            inputContent: contentModel.text,
            outputContent: resultText
        )
        
        toastManager.showSuccess(NSLocalizedString("pop_favorite_added", comment: "已添加到收藏夹"))
        
        // 触发收藏成功动画
        withAnimation {
            showFavoriteSuccess = true
        }
        // 1.5秒后恢复图标
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showFavoriteSuccess = false
            }
        }
    }
    
    // 发起AI请求
    private func performAIAction(systemMessage: String, actionType: AIActionType = .basic, loadingType: LoadingType) {
        guard (preferences.defaultProviders[preferences.selectedProvider]?.title) != nil else {
            toastManager.showError(NSLocalizedString("pop_select_model_first", comment: "请先在设置中选择 AI 模型"))
            return
        }
        
        // 设置对应的loading状态
        setLoadingState(loadingType, isLoading: true)
        contentModel.isProcessing = true
        contentModel.resultText = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 根据actionType选择不同的AI调用方式
            switch actionType {
            case .basic, .vocabulary:
                Ai.chat(text: contentModel.text, systemMessage: systemMessage) {
                    DispatchQueue.main.async {
                        self.handleAIResponse(actionType: actionType, loadingType: loadingType)
                    }
                } onError: { errorMessage in
                    DispatchQueue.main.async {
                        self.handleAIError(errorMessage: errorMessage, loadingType: loadingType)
                    }
                }
                
            case .chat(let chatHistory, _):
                // 传递chatHistory的同时，也传递当前输入文本作为备用
                Ai.chat(text: contentModel.text, chatHistory: chatHistory, systemMessage: systemMessage) {
                    DispatchQueue.main.async {
                        self.handleAIResponse(actionType: actionType, loadingType: loadingType)
                    }
                } onError: { errorMessage in
                    DispatchQueue.main.async {
                        self.handleAIError(errorMessage: errorMessage, loadingType: loadingType)
                    }
                }
            }
        }
    }
    
    // 设置loading状态的辅助方法
    private func setLoadingState(_ loadingType: LoadingType, isLoading: Bool) {
        switch loadingType {
        case .translate:
            contentModel.isTranslating = isLoading
        case .summary:
            contentModel.isSummarizing = isLoading
        case .dictionary:
            contentModel.isDictionaryLookup = isLoading
        case .chat:
            contentModel.isChatting = isLoading
        }
    }
    
    private func handleAIResponse(actionType: AIActionType, loadingType: LoadingType) {
        isResultViewExpanded = true
        contentModel.isProcessing = false
        setLoadingState(loadingType, isLoading: false)
        
        guard let resultText = contentModel.resultText, !resultText.isEmpty else { return }
        
        // 根据actionType处理不同的后续操作
        switch actionType {
        case .basic:
            // 只保存历史记录
            HistoryManager.shared.addHistory(
                inputContent: contentModel.text,
                outputContent: resultText
            )
            
        case .vocabulary(let word):
            // 保存到生词本 + 保存历史记录
            vocabularyManager.addWord(word, definition: resultText)
            HistoryManager.shared.addHistory(
                inputContent: contentModel.text,
                outputContent: resultText
            )
            
        case .chat(_, let originalInput):
            // 保存历史记录
            HistoryManager.shared.addHistory(
                inputContent: originalInput,
                outputContent: resultText
            )
            
            // 使用 TextContentModel 的统一方法添加AI回复
            contentModel.addAIMessage(resultText)
        }
    }
    
    private func handleAIError(errorMessage: String, loadingType: LoadingType) {
        self.toastManager.showError(errorMessage)
        contentModel.resultText = errorMessage
        contentModel.isProcessing = false
        setLoadingState(loadingType, isLoading: false)
    }
    
    // 根据设置触发默认主窗口功能
    func triggerDefaultMainFunction() {
        switch preferences.defaultMainFunction {
        case "translate":
            translateText()
        case "summary":
            summaryText()
        case "dictionary":
            dictionaryText()
        case "chat":
            fallthrough
        default:
            chatText()
        }
    }
    
    // 添加停止AI请求的方法
    private func stopAIRequest() {
        contentModel.shouldStopRequest = true
        Ai.stopCurrentRequest()
        
        DispatchQueue.main.async {
            self.contentModel.isProcessing = false
            self.contentModel.isTranslating = false
            self.contentModel.isSummarizing = false
            self.contentModel.isDictionaryLookup = false
            self.contentModel.isChatting = false
        }
    }
    
    /// 内存清理方法:应用进入后台时调用,防止内存累积
    private func cleanupMemory() {
        // 停止语音播放,释放资源
        stopSpeaking()
        
        // 限制聊天历史长度,防止长对话导致内存过大
        // 保留最近20条消息(约10轮对话)
        if contentModel.chatMessages.count > 20 {
            let recentMessages = Array(contentModel.chatMessages.suffix(20))
            contentModel.chatMessages = recentMessages
            
            // 同步更新API历史
            let recentHistory = Array(contentModel.chatHistory.suffix(20))
            contentModel.chatHistory = recentHistory
        }
        
        // 如果没有正在进行的请求,清理结果文本以释放内存
        if !contentModel.isProcessing {
            // 注意:不清理resultText,因为用户可能需要查看上次结果
            // 只清理过长的结果文本(超过10000字符)
            if let resultText = contentModel.resultText, resultText.count > 10000 {
                // 保留前5000字符
                let truncated = String(resultText.prefix(5000)) + "\n\n...(内容已截断)"
                contentModel.resultText = truncated
            }
        }
    }
}
