import AlertToast
import SwiftUI
import AVFoundation
import KeyboardShortcuts

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    @ObservedObject private var vocabularyManager = VocabularyManager.shared // 添加这行
    @State private var Ai = AiService.shared
    @State private var Lang = LangService.shared
    @State private var Prompt = promptService.shared
    // 吐司提示
    @State private var showCompleteToast = false
    @State private var showErrorToast = false
    @State private var toastMessage = ""
    
    // 复制成功状态，用于按钮图标动画
    @State private var showInputCopySuccess = false
    @State private var showResultCopySuccess = false
    
    // 默认尺寸
    private let minInputTextHeight: CGFloat = 100
    private let minResultTextHeight: CGFloat = 100
    private let maxResultTextHeight: CGFloat = 500
    private let minTextWidth: CGFloat = 580
    
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
    
    var body: some View {
        Form {
            Section() {
                ZStack(alignment: .bottomTrailing) {
                    CustomTextEditor(text: $contentModel.text, onCommit: {
                        chatText()
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
                        .disabled(contentModel.text.isEmpty && (contentModel.resultText?.isEmpty ?? true))
                        
                        // 收藏按钮
                        Button(action: {
                            addToFavorites()
                        }) {
                            Label("", systemImage: "heart")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        .help(NSLocalizedString("help_favorite", comment: "收藏"))
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
                HStack(spacing: 4) {
                    // 翻译按钮
                    Button(action: {
                        translateText()
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(String(format: NSLocalizedString("help_translate", comment: "翻译文本 (%@)"), KeyboardShortcuts.getShortcut(for: SettingsModel.aiShortcut)?.description ?? ""), delay: 0.5)
                    
                    // 摘要按钮
                    Button(action: {
                        summaryText()
                    }) {
                        Image(systemName: "pencil.and.list.clipboard.rtl")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(String(format: NSLocalizedString("help_summary", comment: "总结摘要 (%@)"), KeyboardShortcuts.getShortcut(for: SettingsModel.aiShortcutSummary)?.description ?? ""), delay: 0.5)
                    
                    // 字典按钮
                    Button(action: {
                        dictionaryText()
                    }) {
                        Image(systemName: "books.vertical")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_dict", comment: "解释说明"), delay: 0.5)
                    
                    Rectangle()
                        .frame(width: 1, height: 15)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.horizontal, 5)
                    
                    // 对话问答按钮
                    Button(action: {
                        chatText()
                    }) {
                        Image(systemName: "paperplane")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_chat", comment: "对话问答"), delay: 0.5)
                    
                    if contentModel.isProcessing {
                        // 显示loading动画
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 20)
                            .padding(0)
                    }
                    
                    Spacer()
                    
                    // Model selection menu button
                    Menu {
                        ForEach(settings.providerKeys, id: \.self) { key in
                            if let provider = settings.defaultProviders[key] {
                                Button(action: {
                                    settings.selectedProvider = key
                                }) {
                                    HStack {
                                        Text(provider.requiresCustomConfig ? "\(provider.title) - \(provider.model.isEmpty ? "NA" : provider.model)" : provider.title)
                                        Spacer()
                                        if settings.selectedProvider == key {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .menuIndicator(.hidden) // Hide the menu indicator arrow
                    .menuStyle(BorderlessButtonMenuStyle())
                    .frame(maxWidth: 20, alignment: .trailing)
                    
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
                // 当 resultText 不为 nil 且 不为空 或 窗口已展开时，显示结果区域
                if let resultText = contentModel.resultText, !resultText.isEmpty || isResultViewExpanded {
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: .constant(resultText)) // 使用解包后的 resultText
                            .font(.system(size: 15))
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, minHeight: minResultTextHeight, maxHeight: resultTextHeight)
                            .padding(.bottom, 25) // 增加底部内边距，为按钮留出空间
                            .padding(.horizontal, 5) // 保持水平内边距为0（如果 CustomTextEditor 内部已处理）
                            .padding(.top, 10)        // 保持顶部内边距为0
                            .background(Color(.textBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                            .onChange(of: contentModel.resultText, perform: { value in
                                // 当结果文本变化时，计算新的高度
                                if let text = value, !text.isEmpty {
                                    // 使用 calculateTextHeight 计算结果区域高度
                                    resultTextHeight = calculateTextHeight(text: text, width: minTextWidth)
                                } else {
                                    resultTextHeight = minResultTextHeight // 如果结果为空，重置为最小高度
                                }
                                // 通知窗口调整大小
                                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                            })
                        // 在结果区域的操作按钮中添加收藏按钮
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
                    }
                    .transition(.opacity.combined(with: .scale)) // ZStack自身的过渡动画保持不变
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        .frame(minWidth: minTextWidth)
        .toast(isPresenting: $showCompleteToast) {
            AlertToast(displayMode: .hud, type: .systemImage("checkmark.circle", .green), title: toastMessage)
        }
        .toast(isPresenting: $showErrorToast) {
            AlertToast(displayMode: .hud, type: .systemImage("xmark.circle", .red), title: toastMessage)
        }
        .onAppear {
            // 监听窗口关闭通知
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { _ in
                stopSpeaking()
            }
        }
        .onDisappear {
            // 移除通知监听，防止内存泄漏
            NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
            stopSpeaking()
        }
    }
    
    // 保留 calculateTextHeight 方法，用于计算结果区域的高度
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
        
        // 设置最小和最大高度限制
        return min(max(totalHeight, minResultTextHeight), maxResultTextHeight)
    }
    
    func fillText(_ newText: String) {
        DispatchQueue.main.async {
            let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.contentModel.text = trimmedText
        }
    }
    
    // 清除所有内容
    func clearAll() {
        let isInputEmpty = contentModel.text.isEmpty
        let isResultEmpty = contentModel.resultText?.isEmpty ?? true
        
        if isInputEmpty && isResultEmpty {
            return
        }
        
        stopSpeaking()
        
        DispatchQueue.main.async {
            self.contentModel.text = ""
            self.contentModel.resultText = nil // 将结果设置为空
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
            toastMessage = NSLocalizedString("pop_text_empty", comment: "没有可复制的内容")
            showErrorToast = true
        } else {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(contentModel.text, forType: .string)
            // 恢复成功提示
            toastMessage = NSLocalizedString("pop_copy_success", comment: "复制成功")
            showCompleteToast = true
            
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
            toastMessage = NSLocalizedString("pop_copy_success", comment: "复制成功")
            showCompleteToast = true
            
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
            toastMessage = NSLocalizedString("pop_text_empty", comment: "没有可复制的内容")
            showErrorToast = true
        }
    }
    
    // 翻译
    func translateText() {
        let inputText = contentModel.text.trimmingCharacters(in: .whitespaces)
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_translate_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        
        let systemMessage: String
        
        if Lang.isTextInPreferredLanguage(inputText) {
            // 如果是自己系统语言（中文、韩文、日文、繁体中文） => 英文翻译
            systemMessage = Prompt.getSystemMessageForTranslateToEnglish()
        } else if Lang.isSentence(inputText) == false {
            // 单词翻译
            systemMessage = Prompt.getSystemMessageForTranslateWord()
            // 保存到生词本
            performAIActionWithVocabulary(systemMessage: systemMessage, word: inputText)
            return
        } else {
            // 句子翻译
            systemMessage = Prompt.getSystemMessageForTranslate()
        }
        performAIAction(systemMessage: systemMessage)
    }
    
    // 带生词本保存功能的AI调用
    private func performAIActionWithVocabulary(systemMessage: String, word: String) {
        guard (settings.defaultProviders[settings.selectedProvider]?.title) != nil else {
            toastMessage = NSLocalizedString("pop_select_model_first", comment: "请先在设置中选择 AI 模型")
            showErrorToast = true
            return
        }
        
        contentModel.isProcessing = true
        contentModel.resultText = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            Ai.chat(text: contentModel.text, systemMessage: systemMessage) {
                DispatchQueue.main.async {
                    isResultViewExpanded = true
                    contentModel.isProcessing = false
                    
                    // 保存到生词本
                    if let definition = contentModel.resultText, !definition.isEmpty {
                        vocabularyManager.addWord(word, definition: definition)
                    }
                }
            } onError: { errorMessage in
                DispatchQueue.main.async {
                    self.toastMessage = errorMessage
                    self.showErrorToast = true
                    contentModel.resultText = errorMessage
                    contentModel.isProcessing = false
                }
            }
        }
    }
    
    // 总结
    func summaryText() {
        let inputText = contentModel.text.trimmingCharacters(in: .whitespaces)
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_summary_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let systemMessage = Prompt.getSystemMessageForSummary()
        performAIAction(systemMessage: systemMessage)
    }
    
    // 字典
    func dictionaryText() {
        let inputText = contentModel.text.trimmingCharacters(in: .whitespaces)
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_dict_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let systemMessage = Prompt.getSystemMessageForDict()
        performAIAction(systemMessage: systemMessage)
    }
    
    // 对话
    func chatText() {
        let inputText = contentModel.text.trimmingCharacters(in: .whitespaces)
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_chat_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let systemMessage = Prompt.getSystemMessageForChat()
        
        performAIAction(systemMessage: systemMessage)
    }
    
    // 只做一些清理窗口的动作
    func noactionText() {
        contentModel.resultText = nil
        isResultViewExpanded = false
    }
    
    // 调用AI服务
    private func performAIAction(systemMessage: String) {
        guard (settings.defaultProviders[settings.selectedProvider]?.title) != nil else {
            toastMessage = NSLocalizedString("pop_select_model_first", comment: "请先在设置中选择 AI 模型")
            showErrorToast = true
            return
        }
        
        contentModel.isProcessing = true
        contentModel.resultText = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            Ai.chat(text: contentModel.text, systemMessage: systemMessage) {
                DispatchQueue.main.async {
                    // 设置窗口已展开状态，避免重复展开和收起输出窗口导致页面跳动，之前放在输出view的onchage中，这依赖内容是否变更来触发，某些情况输出内容并无变化。
                    isResultViewExpanded = true
                    contentModel.isProcessing = false
                }
            } onError: { errorMessage in
                DispatchQueue.main.async {
                    self.toastMessage = errorMessage
                    self.showErrorToast = true
                    contentModel.resultText = errorMessage // 将错误信息显示在主输出区域
                    contentModel.isProcessing = false
                }
            }
        }
    }
    
    // 语音朗读
    func speakText(_ text: String) {
        guard !text.isEmpty else { return }
        
        let langCode = Lang.detectLanguageCode(for: text)
        print("lang: " + langCode)
        speechService.speak(text, langCode: langCode)
    }
    
    private func stopSpeaking() {
        speechService.stopSpeaking()
    }
    
    // 添加收藏功能方法
    func addToFavorites() {
        let inputText = contentModel.text.trimmingCharacters(in: .whitespaces)
        let resultText = contentModel.resultText ?? ""
        guard !inputText.isEmpty else {
            toastMessage = "favorite content is empty"
            showErrorToast = true
            return
        }
        
        FavoriteManager.shared.addFavorite(
            inputContent: contentModel.text,
            outputContent: resultText
        )
        
        toastMessage = NSLocalizedString("pop_favorite_added", comment: "已添加到收藏夹")
        showCompleteToast = true
    }
}
