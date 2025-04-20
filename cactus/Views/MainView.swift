import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    @State private var showCopyToast = false
    @State private var toastMessage = ""
    @State var isProcessing = false
    @State private var isResultSectionExpanded = true  // 新增状态变量
    
    // 添加状态变量来跟踪文本高度
    @State private var inputTextHeight: CGFloat = 100
    @State private var resultTextHeight: CGFloat = 100
    
    var body: some View {
        Form {
            // 添加一个隐藏的按钮来监听 ESC 键，关闭当前窗口
            Button("") {
                NSApplication.shared.keyWindow?.close()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .frame(width: 0, height: 0) // 使按钮不可见
            .hidden() // 进一步隐藏

            Section() {
                TextEditor(text: $contentModel.text)
                    .font(.system(size: 15))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, maxHeight: min(200, inputTextHeight))
                    .padding(10)
                    .background(Color(.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .onChange(of: contentModel.text) {
                        // 当文本变化时，计算新的高度
                        inputTextHeight = calculateTextHeight(text: contentModel.text, width: 480)
                        // 通知窗口调整大小
                        NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                    }
            }
            
            Section() {
                HStack(spacing: 12) {
                    Button(action: {
                        // 翻译助手
                        performAIAction(promptPrefix: "翻译助手，请将下面的内容在简体中文和英文之间进行翻译，直接输出翻译结果，不要输出任何提示内容和原文：")
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_translate", comment: "翻译文本"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(isProcessing)

                    Button(action: {
                        // 摘要总结
                        performAIAction(promptPrefix: "请将下面的内容用尽可能简短的中文总结关键信息：")
                    }) {
                        Image(systemName: "rectangle.dashed.and.paperclip")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_summary", comment: "总结摘要"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(isProcessing)

                    Button(action: {
                        // 解释说明
                        performAIAction(promptPrefix: "请用通俗易懂、简短的中文解释下面的内容中主要的概念：")
                    }) {
                        Image(systemName: "graduationcap")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_explain", comment: "解释说明"))
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .disabled(isProcessing)

                    // 复制原文
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .help(NSLocalizedString("help_copy", comment: "复制"))

                    Spacer()

                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 20)
                            .padding(0)
                    }
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
                TextEditor(text: .constant(contentModel.resultText ?? ""))
                    .font(.system(size: 15))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, maxHeight: min(500, inputTextHeight))
                    .padding(10)
                    .background(Color(.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .onChange(of: contentModel.resultText) {
                        // 当结果文本变化时，计算新的高度
                        if let text = contentModel.resultText {
                            resultTextHeight = calculateTextHeight(text: text, width: 480)
                            // 通知窗口调整大小
                            NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
                        }
                    }
            }
            Section() {
                HStack(spacing: 12) {
                    Button(action: {
                        copyResp()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle()) // 应用优化后的样式
                    .help(NSLocalizedString("help_copy", comment: "复制"))

                    Spacer()
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
        .frame(minWidth: 500, minHeight: 300)
        .toast(isPresenting: $showCopyToast) {
            AlertToast(type: .regular, title: toastMessage)
        }
    }
    
    // 添加计算文本高度的方法
    private func calculateTextHeight(text: String, width: CGFloat) -> CGFloat {
        let font = NSFont.systemFont(ofSize: 15)
        let attributes = [NSAttributedString.Key.font: font]
        let textStorage = NSTextStorage(string: text, attributes: attributes)
        
        let textContainer = NSTextContainer(containerSize: NSSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRange(for: textContainer)
        let height = layoutManager.usedRect(for: textContainer).height
        
        // 添加一些额外空间，并设置最小高度
        return min(max(height + 40, 100), 500) // 最小100，最大500
    }
    
    func fillText(_ newText: String) {
        DispatchQueue.main.async {
            // 过滤开头和结尾的空行及空白
            let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.contentModel.text = trimmedText
            // 计算新文本的高度
            self.inputTextHeight = self.calculateTextHeight(text: trimmedText, width: 480)
            // 通知窗口调整大小
            NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
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
    
    // 添加一个可以从外部调用的翻译方法
    func translateText() {
        // 使用重构后的方法
        performAIAction(promptPrefix: "翻译助手，请将下面的内容在简体中文和英文之间进行翻译，直接输出翻译结果，不要输出任何提示内容和原文：")
    }

    // 新增：重构 AI 操作的私有方法
    private func performAIAction(promptPrefix: String) {
        if contentModel.text.isEmpty {
            toastMessage = NSLocalizedString("pop_text_empty", comment: "请先输入内容")
            showCopyToast = true
        } else {
            isProcessing = true
            let aiService = AiService() // 统一变量命名规范
            let fullPrompt = promptPrefix + "\n\n" + contentModel.text

            DispatchQueue.global(qos: .userInitiated).async {
                aiService.chat(text: fullPrompt) { // 使用正确的变量名
                    DispatchQueue.main.async {
                        isProcessing = false
                    }
                }
            }
        }
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
