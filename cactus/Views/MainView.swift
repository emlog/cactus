import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    
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
    
    var body: some View {
        Form {
            Section() {
                ZStack(alignment: .bottomTrailing) {
                    CustomTextEditor(text: $contentModel.text, onCommit: {
                        translateText()
                    }, calculatedHeight: $inputTextHeight) // 传递高度绑定
                    .focused($isInputEditorFocused) // 新增：绑定焦点状态
                    .frame(height: inputTextHeight) // 使用状态变量设置高度
                    .padding(0) // CustomTextEditor 内部已处理内边距
                    .background(Color(.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    
                    HStack(spacing: 8) { // 可以调整按钮间距
                        // 清除按钮 - 移动到这里
                        Button(action: {
                            clearAll()
                        }) {
                            Image(systemName: "xmark.circle")
                                .frame(width: 15, height: 15)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle()) // 使用 PlainButtonStyle
                        .help(NSLocalizedString("help_clear", comment: "清除输入和结果"))
                        .disabled(contentModel.text.isEmpty && (contentModel.resultText?.isEmpty ?? true)) // 调整禁用条件
                        
                        // 复制按钮
                        Button(action: {
                            copyWriting()
                        }) {
                            // 根据状态改变图标和颜色
                            Image(systemName: showInputCopySuccess ? "checkmark" : "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(showInputCopySuccess ? .green : .secondary) // 成功时绿色
                        }
                        .buttonStyle(PlainButtonStyle()) // 使用 PlainButtonStyle 避免背景
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                        .animation(.easeInOut, value: showInputCopySuccess) // 添加动画效果
                        .disabled(contentModel.text.isEmpty) // 输入为空时禁用
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
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
                    .help(NSLocalizedString("help_translate", comment: "翻译文本"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    
                    // 摘要按钮
                    Button(action: {
                        summaryText()
                    }) {
                        Image(systemName: "pencil.and.list.clipboard.rtl")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_summary", comment: "总结摘要"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    
                    // 说明按钮
                    Button(action: {
                        explainText()
                    }) {
                        Image(systemName: "lightbulb.max")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_explain", comment: "解释说明"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    
                    // 对话问答按钮
                    Button(action: {
                        chatText()
                    }) {
                        Image(systemName: "questionmark.bubble")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_chat", comment: "对话问答"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    
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
                    
                    // 添加一个隐藏的按钮来监听 ESC 键，关闭当前窗口
                    Button("") {
                        NSApplication.shared.keyWindow?.close()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    .frame(width: 0, height: 0) // 使按钮不可见
                    .hidden() // 进一步隐藏
                }
                .padding(.horizontal, 8) // 为HStack添加水平内边距
                .padding(.vertical, 5)   // 为HStack添加垂直内边距
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
                        .padding(10)
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
                    
                    // 复制按钮
                    Button(action: {
                        copyResp()
                    }) {
                        // 根据状态改变图标和颜色
                        Image(systemName: showResultCopySuccess ? "checkmark" : "square.on.square")
                            .frame(width: 15, height: 15)
                            .foregroundColor(showResultCopySuccess ? .green : .secondary) // 成功时绿色
                    }
                    .buttonStyle(PlainButtonStyle()) // 使用 PlainButtonStyle
                    .help(NSLocalizedString("help_copy", comment: "复制"))
                    .animation(.easeInOut, value: showResultCopySuccess) // 添加动画效果
                    .disabled(contentModel.resultText?.isEmpty ?? true) // 结果为空时禁用
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        .frame(minWidth: 500, minHeight: 390) // 调整最小高度以适应内容
        .toast(isPresenting: $showCompleteToast) {
            AlertToast(displayMode: .hud, type: .systemImage("checkmark.circle", .green), title: toastMessage)
        }
        .toast(isPresenting: $showErrorToast) {
            AlertToast(displayMode: .hud, type: .systemImage("xmark.circle", .red), title: toastMessage)
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
        let targetLanguage = getPreferredLanguageName()
        
        if isLikelyChinese(inputText) {
            // 如果检测到中文，则翻译为英文
            promptPrefix = "请将下面的内容翻译为英文，直接输出翻译结果，不要输出任何提示内容和原文："
        } else {
            promptPrefix = "请将下面的内容翻译为\(targetLanguage)，直接输出翻译结果，不要输出任何提示内容和原文："
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
        let targetLanguage = getPreferredLanguageName()
        // 修改 prompt，使其使用目标语言进行总结
        performAIAction(promptPrefix: "请将下面的内容用尽可能简短的\(targetLanguage)总结关键信息：")
    }
    
    // 解释
    func explainText() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_explain_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let targetLanguage = getPreferredLanguageName()
        performAIAction(promptPrefix: "请用通俗易懂、简短的\(targetLanguage)解释下面的内容中主要的概念：")
    }
    
    // 对话
    func chatText() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_chat_text_empty", comment: "请先输入内容")
            showErrorToast = true
            return
        }
        let targetLanguage = getPreferredLanguageName()
        performAIAction(promptPrefix: "你是我的私人助理，总是能简洁专业的解答我下面提出的要求或问题，并用\(targetLanguage)回答：")
    }
    
    // 辅助函数：获取系统首选语言的本地化名称
    private func getPreferredLanguageName() -> String {
        // 获取首选语言代码，默认为简体中文
        let preferredLanguageCode = Locale.preferredLanguages.first ?? "zh-Hans-CN"
        // 获取语言的本地化名称，默认为 "简体中文"
        let preferredLanguageName = Locale.current.localizedString(forLanguageCode: preferredLanguageCode) ?? "简体中文"
        print("Preferred Language Detected: \(preferredLanguageName) (Code: \(preferredLanguageCode))")
        return preferredLanguageName
    }
    
    // 辅助函数：判断字符串是否可能主要是简体中文
    private func isLikelyChinese(_ text: String) -> Bool {
        var containsChinese = false
        for scalar in text.unicodeScalars {
            let value = scalar.value
            // 检查日文平假名 (U+3040...U+309F) 或片假名 (U+30A0...U+30FF)
            if (0x3040...0x30FF).contains(value) {
                return false // 包含日文假名，判定为非中文
            }
            // 检查韩文谚文音节 (U+AC00...U+D7AF)
            if (0xAC00...0xD7AF).contains(value) {
                return false // 包含韩文谚文，判定为非中文
            }
            // 检查 CJK 统一表意文字的主要范围 (U+4E00...U+9FFF)
            // 这个范围包含了中日韩共用的汉字
            if (0x4E00...0x9FFF).contains(value) {
                containsChinese = true // 标记包含汉字字符
            }
            // 可以根据需要添加其他 CJK 范围的检查，但主要范围通常足够
        }
        // 只有在包含了汉字字符，并且没有检测到日文假名或韩文谚文时，才判定为中文
        return containsChinese
    }
    
    // 调用AI服务
    private func performAIAction(promptPrefix: String) {
        guard (settings.defaultProviders[settings.selectedProvider]?.title) != nil else {
            toastMessage = NSLocalizedString("pop_select_model_first", comment: "请先在设置中选择 AI 模型")
            showErrorToast = true
            return
        }
        
        contentModel.isProcessing = true // 开始处理
        contentModel.resultText = "" // 清空旧结果
        
        let aiService = AiService() // 统一变量命名规范
        let fullPrompt = promptPrefix + "\n\n" + contentModel.text
        
        DispatchQueue.global(qos: .userInitiated).async {
            aiService.chat(text: fullPrompt) { // 使用正确的变量名
                DispatchQueue.main.async {
                    contentModel.isProcessing = false // 修改：使用 contentModel.isProcessing
                }
            }
        }
    }
}
