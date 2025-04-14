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
                        if contentModel.text.isEmpty {
                            toastMessage = NSLocalizedString("pop_text_empty", comment: "请先输入内容")
                            showCopyToast = true
                        } else {
                            isProcessing = true
                            let AiService = AiService()
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                let text = "翻译助手，请将下面的内容在简体中文和英文之间进行翻译，直接输出翻译结果，不要输出任何提示内容和原文：\n\n" + contentModel.text
                                AiService.chat(text: text, completion: {
                                    DispatchQueue.main.async {
                                        isProcessing = false
                                    }
                                })
                            }
                        }
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_translate", comment: "翻译文本"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing)
                    
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = NSLocalizedString("pop_text_empty", comment: "请先输入内容")
                            showCopyToast = true
                        } else {
                            isProcessing = true // 开始处理，设置状态为处理中
                            let AiService = AiService()
                            
                            // 在后台线程执行翻译
                            DispatchQueue.global(qos: .userInitiated).async {
                                let text = "摘要总结，请将下面的内容的主要信息总结摘要：\n\n" + contentModel.text
                                AiService.chat(text: text, completion: {
                                    // 处理完成后，在主线程更新UI
                                    DispatchQueue.main.async {
                                        isProcessing = false // 处理完成，重置状态
                                    }
                                })
                            }
                        }
                    }) {
                        Image(systemName: "rectangle.dashed.and.paperclip")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_summary", comment: "总结摘要"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing)
                    
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = NSLocalizedString("pop_text_empty", comment: "请先输入内容")
                            showCopyToast = true
                        } else {
                            isProcessing = true
                            let AiService = AiService()
                            
                            // 在后台线程执行翻译
                            DispatchQueue.global(qos: .userInitiated).async {
                                let text = "解释说明，请用更通俗易懂简洁的语言解释说下面的内容中主要的概念：\n\n" + contentModel.text
                                AiService.chat(text: text, completion: {
                                    // 处理完成后，在主线程更新UI
                                    DispatchQueue.main.async {
                                        isProcessing = false
                                    }
                                })
                            }
                        }
                    }) {
                        Image(systemName: "graduationcap")
                            .frame(width: 20, height: 20)
                    }
                    .help(NSLocalizedString("help_explain", comment: "解释说明"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing)
                    
                    // 复制原文
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .help(NSLocalizedString("help_copy", comment: "复制"))
                    
                    Spacer()

                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 20)
                            .padding(0)
                    }
                }
                .padding(2)
                .frame(maxWidth: .infinity, alignment: .leading)  // 添加这行使宽度自适应
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
                    .buttonStyle(HoverButtonStyle())
                    .help(NSLocalizedString("help_copy", comment: "复制"))

                    Spacer()
                }
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
            self.contentModel.text = newText
            // 计算新文本的高度
            self.inputTextHeight = self.calculateTextHeight(text: newText, width: 480)
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
}

struct HoverButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(isHovered ? 0.5 : 0), lineWidth: 1)
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

//#Preview {
//    MainView()
//        .environment(\.locale, .init(identifier: "en"))
//}
