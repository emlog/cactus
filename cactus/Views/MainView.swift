import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared // 将 @StateObject 替换为 @ObservedObject
    @ObservedObject var settings = SettingsModel.shared
    @State private var showCopyToast = false
    @State private var toastMessage = ""
    @State var isProcessing = false // 更通用的处理中状态标志，移除 private 以便外部访问
    
    var body: some View {
        Form {
            Section() {
                // 多行文本输入框，绑定到 contentModel.text
                TextEditor(text: $contentModel.text)
                    .font(.system(.body))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(10)
                    .background(Color(.textBackgroundColor)) // Use system color that adapts to dark mode
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1) // Use system color for border
                    )
            }
            
            Section() {
                HStack(spacing: 12) {
                    // 翻译
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = "请先输入内容"
                            showCopyToast = true
                        } else {
                            isProcessing = true // 开始处理，设置状态为处理中
                            let AiService = AiService()
                            
                            // 在后台线程执行翻译
                            DispatchQueue.global(qos: .userInitiated).async {
                                let text = "翻译助手，请将下面的内容在简体中文和英文之间进行翻译，注意不要输出任何提示内容：\n\n" + contentModel.text
                                AiService.chat(text: text, completion: {
                                    // 处理完成后，在主线程更新UI
                                    DispatchQueue.main.async {
                                        isProcessing = false // 处理完成，重置状态
                                    }
                                })
                            }
                        }
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing) // 处理过程中禁用按钮
                    
                    // 摘要总结
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = "请先输入内容"
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
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing) // 处理过程中禁用按钮
                    
                    // 解释说明
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = "请先输入内容"
                            showCopyToast = true
                        } else {
                            isProcessing = true // 开始处理，设置状态为处理中
                            let AiService = AiService()
                            
                            // 在后台线程执行翻译
                            DispatchQueue.global(qos: .userInitiated).async {
                                let text = "解释说明，请用更通俗易懂简洁的语言解释说下面的内容中主要的概念：\n\n" + contentModel.text
                                AiService.chat(text: text, completion: {
                                    // 处理完成后，在主线程更新UI
                                    DispatchQueue.main.async {
                                        isProcessing = false // 处理完成，重置状态
                                    }
                                })
                            }
                        }
                    }) {
                        Image(systemName: "graduationcap")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(isProcessing) // 处理过程中禁用按钮
                    
                    // 复制
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
                    
                    Spacer() // 将 ProgressView 推到最右边

                    // 添加加载指示器
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.5) // 调整尺寸
                            .frame(height: 30) // 固定高度，避免撑开容器
                            .padding(0)
                    }
                }
            }
            
            if let promptText = contentModel.promptText {
                Section() {
                    TextEditor(text: .constant(promptText))
                        .font(.system(.body))
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .padding(10)
                        .background(Color(.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                }
                Section() {
                    HStack(spacing: 12) {
                        Button(action: {
                            copyResp()
                        }) {
                            Image(systemName: "doc.on.doc") // 复制
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(HoverButtonStyle())
                        
                        Spacer()
                        
                        // 显示当前使用的AI提供商及其模型
                        Text("\(settings.selectedProvider) - \(settings.providers[settings.selectedProvider]?.model ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            toastMessage = "没有可复制的内容"
        } else {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(contentModel.text, forType: .string)
            toastMessage = "复制成功"
        }
        showCopyToast = true
    }
    
    func copyResp() {
        if let promptText = contentModel.promptText, !promptText.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(promptText, forType: .string)
            toastMessage = "复制成功"
        } else {
            toastMessage = "没有可复制的内容"
        }
        showCopyToast = true // 显示气泡提示
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
