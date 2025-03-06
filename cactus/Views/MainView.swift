import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared // 将 @StateObject 替换为 @ObservedObject
    @ObservedObject var settings = SettingsModel()
    @State private var showCopyToast = false
    @State private var toastMessage = ""
    
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
                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = "没有可被翻译的内容"
                            showCopyToast = true
                        } else {
                            // 使用 SettingsModel 中的配置信息进行翻译操作
                            let translationService = TranslationService(
                                baseURL: settings.baseURL,
                                apiKey: settings.apiKey,
                                model: settings.model
                            )
                            contentModel.translatedText = translationService.translate(text: contentModel.text)
                        }
                    }) {
                        Image(systemName: "translate") // 翻译
                            .frame(width: 30, height: 30) // 统一按钮尺寸
                    }
                    .buttonStyle(HoverButtonStyle()) // 应用自定义按钮样式
                    
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc") // 复制
                            .frame(width: 30, height: 30) // 统一按钮尺寸
                    }
                    .buttonStyle(HoverButtonStyle()) // 应用自定义按钮样式
                }
            }
            
            if let translatedText = contentModel.translatedText {
                Section() {
                    TextEditor(text: .constant(translatedText))
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
                    // 操作按钮
                    HStack(spacing: 12) {
                        Button(action: {
                            copyResp()
                        }) {
                            Image(systemName: "doc.on.doc") // 复制
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(HoverButtonStyle()) // 应用自定义按钮样式
                    }
                }
            }
        }
        .padding(10) // 减少 padding 的值
        .frame(minWidth: 500, minHeight: 300) // 动态调整高度
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
        if let translatedText = contentModel.translatedText, !translatedText.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(translatedText, forType: .string)
            toastMessage = "翻译结果复制成功"
        } else {
            toastMessage = "没有可复制的翻译结果"
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

#Preview {
    MainView()
        .environment(\.locale, .init(identifier: "en"))
}
