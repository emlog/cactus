import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    @State private var showCopyToast = false
    @State private var toastMessage = ""
    @State private var isResultSectionExpanded = true
    @State private var isPinned = false // 跟踪置顶状态
    
    // 修改：使用一个状态变量来驱动 CustomTextEditor 的高度
    @State private var inputTextHeight: CGFloat = 100
    @State private var resultTextHeight: CGFloat = 100 // 结果区域的高度状态
    
    var body: some View {
        Form {
            Section() {
                // 使用 CustomTextEditor 替换 TextEditor
                CustomTextEditor(text: $contentModel.text, onCommit: {
                    // 当按下回车键时，触发翻译
                    translateText()
                }, calculatedHeight: $inputTextHeight) // 传递高度绑定
                .frame(height: inputTextHeight) // 使用状态变量设置高度
                .padding(0) // CustomTextEditor 内部已处理内边距
                .background(Color(.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )
            }
            
            Section() {
                HStack(spacing: 6) {
                    // 翻译按钮
                    Button(action: {
                        translateText()
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_translate", comment: "翻译文本"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(contentModel.isProcessing) // 修改：使用 contentModel.isProcessing
                    
                    // 摘要按钮
                    Button(action: {
                        summaryText()
                    }) {
                        Image(systemName: "rectangle.dashed.and.paperclip")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_summary", comment: "总结摘要"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(contentModel.isProcessing) // 修改：使用 contentModel.isProcessing
                    
                    // 说明按钮
                    Button(action: {
                        explainText()
                    }) {
                        Image(systemName: "graduationcap")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_explain", comment: "解释说明"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(contentModel.isProcessing) // 修改：使用 contentModel.isProcessing
                    
                    Spacer()
                    
                    // 清除按钮
                    Button(action: {
                        clearAll()
                    }) {
                        Image(systemName: "xmark.circle")
                            .frame(width: 15, height: 15)
                            .foregroundColor(.secondary)
                    }
                    .help(NSLocalizedString("help_clear", comment: "清除输入和结果"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(contentModel.isProcessing)
                    // 复制按钮
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "square.on.square")
                            .frame(width: 15, height: 15)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .help(NSLocalizedString("help_copy", comment: "复制"))
                    
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
                // 显示当前AI服务
                Text("\(settings.defaultProviders[settings.selectedProvider]?.title ?? "") - \(settings.defaultProviders[settings.selectedProvider]?.model ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)  // 添加这行使宽度自适应
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.controlBackgroundColor))
                    )
            }
            
            Section() {
                // 结果区域保持使用 TextEditor，因为它不需要键盘事件处理
                TextEditor(text: .constant(contentModel.resultText ?? ""))
                    .font(.system(size: 15))
                    .lineSpacing(8)
                // 使用 resultTextHeight 状态变量
                    .frame(maxWidth: .infinity, minHeight: 100, maxHeight: min(500, resultTextHeight))
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
                            resultTextHeight = 100 // 如果结果为空，重置为最小高度
                            NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                        }
                    })
                // 初始化时计算一次结果区域高度
                    .onAppear {
                        if let text = contentModel.resultText {
                            resultTextHeight = calculateTextHeight(text: text, width: 480)
                        } else {
                            resultTextHeight = 100
                        }
                    }
            }
            Section() {
                HStack(spacing: 6) {
                    // pin按钮
                    Button(action: {
                        isPinned.toggle()
                        // 发送通知，告知 AppDelegate 切换置顶状态
                        NotificationCenter.default.post(name: NSNotification.Name("TogglePinState"), object: isPinned)
                    }) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .frame(width: 20, height: 20)
                            .foregroundColor(isPinned ? .red : .primary) // 置顶时为红色，否则为默认颜色
                    }
                    .buttonStyle(HoverButtonStyle())
                    .help(isPinned ? NSLocalizedString("help_unpin", comment: "取消置顶") : NSLocalizedString("help_pin", comment: "置顶窗口"))
                    
                    Spacer()
                    
                    if contentModel.isProcessing {
                        // 显示loading动画
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 20)
                            .padding(0)
                    } else {
                        // 复制按钮
                        Button(action: {
                            copyResp()
                        }) {
                            Image(systemName: "square.on.square")
                                .frame(width: 15, height: 15)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(HoverButtonStyle())
                        .help(NSLocalizedString("help_copy", comment: "复制"))
                    }
                }
                .padding(.horizontal, 8) // 为HStack添加水平内边距
                .padding(.vertical, 5)   // 为HStack添加垂直内边距
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor)) // 保持背景一致性
                )
            }
        }
        .padding(10)
        // 修改：调整最小高度以适应内容
        .frame(minWidth: 500, minHeight: 400) // 稍微增加最小高度
        .toast(isPresenting: $showCopyToast) {
            AlertToast(type: .regular, title: toastMessage)
        }
        // 添加监听器，以便 CustomTextEditor 可以请求调整窗口大小
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AdjustWindowSize"))) { _ in
            // 可以在这里触发窗口大小调整逻辑，如果 AppDelegate 中尚未处理
            // 例如，如果你的 AppDelegate 监听这个通知并调整窗口，这里可能不需要额外操作
            // 如果需要在这里直接调整，可能需要访问 NSWindow 实例
            print("Received AdjustWindowSize notification in MainView")
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
        return min(max(totalHeight, 100), 500) // 最小100，最大500
    }
    
    func fillText(_ newText: String) {
        DispatchQueue.main.async {
            let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.contentModel.text = trimmedText
            // CustomTextEditor 会自动处理高度计算和通知
        }
    }
    
    func copyWriting() {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_text_empty", comment: "没有可复制的内容")
        } else {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(contentModel.text, forType: .string)
            toastMessage = NSLocalizedString("pop_copy_success", comment: "复制成功")
        }
        showCopyToast = true
    }
    
    func copyResp() {
        if let promptText = contentModel.resultText, !promptText.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(promptText, forType: .string)
            toastMessage = NSLocalizedString("pop_copy_success", comment: "复制成功")
        } else {
            toastMessage = NSLocalizedString("pop_text_empty", comment: "没有可复制的内容")
        }
        showCopyToast = true
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

    // 翻译
    func translateText() {
        let inputText = contentModel.text
        if inputText.isEmpty {
            toastMessage = NSLocalizedString("pop_text_empty", comment: "请先输入内容")
            showCopyToast = true
            return // 提前返回，避免执行后续逻辑
        }

        let promptPrefix: String
        if isLikelyChinese(inputText) {
            // 如果检测到中文，则翻译为英文
            promptPrefix = "请将下面的内容翻译为英文，直接输出翻译结果，不要输出任何提示内容和原文："
        } else {
            // 否则，翻译为简体中文
            promptPrefix = "请将下面的内容翻译为简体中文，直接输出翻译结果，不要输出任何提示内容和原文："
        }
        performAIAction(promptPrefix: promptPrefix)
    }

    // 总结
    func summaryText() {
        performAIAction(promptPrefix: "请将下面的内容用尽可能简短的中文总结关键信息：")
    }

    // 解释
    func explainText() {
        performAIAction(promptPrefix: "请用通俗易懂、简短的中文解释下面的内容中主要的概念：")
    }

    // 调用AI服务
    private func performAIAction(promptPrefix: String) {
        // 检查移到调用函数处，这里不再重复检查
        // if contentModel.text.isEmpty { ... }

        contentModel.isProcessing = true // 修改：使用 contentModel.isProcessing
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
    
    // 在 MainView 结构体内新增方法
    func clearAll() {
        contentModel.text = ""
        contentModel.resultText = nil
    }
}

// 优化 HoverButtonStyle
struct HoverButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5) // 给图标周围增加一些空间，让背景更明显
            .background(
                RoundedRectangle(cornerRadius: 6)
                // 悬停时改变背景色，增加透明度使其不突兀
                    .fill(isHovered ? Color.gray.opacity(0.2) : Color.clear)
            )
            .contentShape(Rectangle()) // 确保整个区域都能响应悬停和点击
            .onHover { hovering in
                isHovered = hovering
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // 添加按压效果
    }
}
