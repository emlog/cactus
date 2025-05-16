import AlertToast
import SwiftUI
import AVFoundation

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    @State private var Ai = AiService.shared
    @State private var Lang = LangService.shared
    // 吐司提示
    @State private var showCompleteToast = false
    @State private var showErrorToast = false
    @State private var toastMessage = ""
    // 复制成功状态，用于按钮图标动画
    @State private var showInputCopySuccess = false
    @State private var showResultCopySuccess = false
    // 输入框：使用一个状态变量来驱动 CustomTextEditor 的高度
    @State private var inputTextHeight: CGFloat = 100
    @State private var resultTextHeight: CGFloat = 200 // 结果区域的高度状态
    // 新增：用于控制输入框焦点的状态变量
    @FocusState private var isInputEditorFocused: Bool
    // 语音朗读相关状态
    @State private var isSpeakingInput = false
    @State private var isSpeakingResult = false
    private let speechService = SpeechService.shared
    
    var body: some View {
        Form {
            Section() {
                ZStack(alignment: .bottomTrailing) {
                    CustomTextEditor(text: $contentModel.text, onCommit: {
                        translateText()
                    }, calculatedHeight: $inputTextHeight) // 传递高度绑定
                    .focused($isInputEditorFocused) // 新增：绑定焦点状态
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
                        .buttonStyle(HoverButtonStyle())
                        .disabled(contentModel.text.isEmpty && (contentModel.resultText?.isEmpty ?? true))
                        
                        // 语音朗读（输入）
                        Button(action: {
                            speakText(contentModel.text)
                        }) {
                            Image(systemName: "speaker.wave.2.circle")
                                .frame(width: 15, height: 15)
                                .foregroundColor(isSpeakingInput ? .red : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle())
                        .disabled(contentModel.text.isEmpty)
                        
                        // 复制按钮
                        Button(action: {
                            copyWriting()
                        }) {
                            Image(systemName: showInputCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showInputCopySuccess ? .green : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle())
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
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_translate", comment: "翻译文本"), delay: 0.5)
                    
                    // 摘要按钮
                    Button(action: {
                        summaryText()
                    }) {
                        Image(systemName: "pencil.and.list.clipboard.rtl")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_summary", comment: "总结摘要"), delay: 0.5)
                    
                    // 说明按钮
                    Button(action: {
                        explainText()
                    }) {
                        Image(systemName: "lightbulb.max")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_explain", comment: "解释说明"), delay: 0.5)
                    
                    // 对话问答按钮
                    Button(action: {
                        chatText()
                    }) {
                        Image(systemName: "questionmark.bubble")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    .hoverTooltip(NSLocalizedString("help_chat", comment: "对话问答"), delay: 0.5)
                    
                    Spacer()
                    
                    if contentModel.isProcessing {
                        // 显示loading动画
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 20)
                            .padding(0)
                    }
                    
                    Text(settings.defaultProviders[settings.selectedProvider]?.title ?? "")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.65)) // 文本颜色，降低亮度
                    
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
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: .constant(contentModel.resultText ?? ""))
                        .font(.system(size: 15))
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: resultTextHeight)
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
                            if let text = value {
                                // 使用 calculateTextHeight 计算结果区域高度
                                resultTextHeight = calculateTextHeight(text: text, width: 480) // 假设宽度与输入区域类似
                                // 通知窗口调整大小
                                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                            } else {
                                resultTextHeight = 200 // 如果结果为空，重置为最小高度
                                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                            }
                        })
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            speakText(contentModel.resultText ?? "")
                        }) {
                            Image(systemName: "speaker.wave.2.circle")
                                .frame(width: 15, height: 15)
                                .foregroundColor(isSpeakingResult ? .red : .secondary)
                        }
                        .buttonStyle(HoverButtonStyle())
                        .disabled(contentModel.resultText?.isEmpty ?? true)
                        
                        Button(action: {
                            copyResp()// 复制输出
                        }) {
                            Image(systemName: showResultCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showResultCopySuccess ? .green : .secondary) // 成功时绿色
                        }
                        .buttonStyle(HoverButtonStyle())
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                        .animation(.easeInOut, value: showResultCopySuccess) // 添加动画效果
                        .disabled(contentModel.resultText?.isEmpty ?? true) // 结果为空时禁用
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        .frame(minWidth: 500, minHeight: 390)
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
        return min(max(totalHeight, 200), 500) // 最小200，最大500
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
            self.inputTextHeight = 100
            self.resultTextHeight = 200
            // 清除后，通知窗口调整大小
            NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
            // 新增：设置输入框焦点
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
        let inputText = contentModel.text
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_translate_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        
        let promptPrefix: String
        let targetLanguage = Lang.getPreferredLanguageName()
        
        if Lang.isLikelyChinese(inputText) {
            // 如果检测到中文，则翻译为英文
            promptPrefix = "请将下面的内容翻译为英文，直接输出翻译结果，不要输出任何提示内容和原文：\n"
        } else if(Lang.isSentence(inputText) == false) {
            // 如果检测到是单词
            promptPrefix = "请将下面的单词翻译为\(targetLanguage)，给出国际音标、权威词典的解释以及包含该单词的1个例句，不要输出任何提示性内容和备注，可以加入必要的换行让排版美观，但是不需要markdown格式：\n"
        } else {
            promptPrefix = "请将下面的内容翻译为\(targetLanguage)，直接输出翻译结果，不要输出任何提示内容和原文：\n"
        }
        performAIAction(promptPrefix: promptPrefix)
    }
    
    // 总结
    func summaryText() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_summary_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let targetLanguage = Lang.getPreferredLanguageName()
        // 修改 prompt，使其使用目标语言进行总结
        performAIAction(promptPrefix: "请将下面的内容用尽可能简短的\(targetLanguage)总结关键信息：\n")
    }
    
    // 解释
    func explainText() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_explain_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let targetLanguage = Lang.getPreferredLanguageName()
        performAIAction(promptPrefix: "请用简洁易懂的\(targetLanguage)解释下面内容中的核心概念：\n")
    }
    
    // 对话
    func chatText() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_chat_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let targetLanguage = Lang.getPreferredLanguageName()
        performAIAction(promptPrefix: "你是我的私人助理，总是能简洁专业的解答我下面提出的要求或问题，并用\(targetLanguage)回答：")
    }
    
    // 调用AI服务
    private func performAIAction(promptPrefix: String) {
        guard (settings.defaultProviders[settings.selectedProvider]?.title) != nil else {
            toastMessage = NSLocalizedString("pop_select_model_first", comment: "请先在设置中选择 AI 模型")
            showErrorToast = true
            return
        }
        
        contentModel.isProcessing = true
        contentModel.resultText = ""
        
        let fullPrompt = promptPrefix + "\n\n" + contentModel.text
        
        DispatchQueue.global(qos: .userInitiated).async {
            Ai.chat(text: fullPrompt) {
                DispatchQueue.main.async {
                    contentModel.isProcessing = false
                }
            } onError: { errorMessage in // 错误处理回调
                DispatchQueue.main.async {
                    self.toastMessage = errorMessage
                    self.showErrorToast = true
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
}
