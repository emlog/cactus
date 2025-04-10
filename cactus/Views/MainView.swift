import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared
    @ObservedObject var settings = SettingsModel.shared
    @State private var showCopyToast = false
    @State private var toastMessage = ""
    @State var isProcessing = false
    
    var body: some View {
        Form {
            Section() {
                TextEditor(text: $contentModel.text)
                    .font(.system(size: 15))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .padding(10)
                    .background(Color(.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
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
                            .frame(width: 30, height: 30)
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
                            .frame(width: 30, height: 30)
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
                            .frame(width: 30, height: 30)
                    }
                    .help(NSLocalizedString("help_explain", comment: "解释说明"))
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing)
                    
                    // 复制原文
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .help(NSLocalizedString("help_copy", comment: "复制"))
                    
                    Spacer()

                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 30)
                            .padding(0)
                    }
                }
                Text("\(settings.selectedProvider) - \(settings.defaultProviders[settings.selectedProvider]?.title ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let promptText = contentModel.promptText {
                Section() {
                    TextEditor(text: .constant(promptText))
                        .font(.system(size: 15))
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .padding(10)
                        .background(Color(.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                }
                Section() {
                    HStack(spacing: 12) {
                        Button(action: {
                            copyResp()
                        }) {
                            Image(systemName: "doc.on.doc")
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(HoverButtonStyle())
                        .help(NSLocalizedString("help_copy", comment: "复制"))

                        Spacer()
                    }
                }
            }
        }
        .padding(10)
        .frame(minWidth: 500, minHeight: 300)
        .toast(isPresenting: $showCopyToast) {
            AlertToast(type: .regular, title: toastMessage)
        }
    }
    
    func fillText(_ newText: String) {
        DispatchQueue.main.async {
            print("new text: \(newText)")
            self.contentModel.text = newText
            print("updated text: \(self.contentModel.text)")
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
        if let promptText = contentModel.promptText, !promptText.isEmpty {
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

#Preview {
    MainView()
        .environment(\.locale, .init(identifier: "en"))
}
