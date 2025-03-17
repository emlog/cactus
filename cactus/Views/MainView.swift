import AlertToast
import SwiftUI

struct MainView: View {
    @ObservedObject private var contentModel = TextContentModel.shared // 将 @StateObject 替换为 @ObservedObject
    @ObservedObject var settings = SettingsModel.shared
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
                HStack(spacing: 12) {
                     // 翻译
                    Button(action: {
                        if contentModel.text.isEmpty {
                            toastMessage = "没有可被翻译的内容"
                            showCopyToast = true
                        } else {
                            let translationService = TranslationService()
                            translationService.translate(text: contentModel.text)
                        }
                    }) {
                        Image(systemName: "translate")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
                     // 复制
                    Button(action: {
                        copyWriting()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(HoverButtonStyle())
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
                    HStack(spacing: 12) {
                        Button(action: {
                            copyResp()
                        }) {
                            Image(systemName: "doc.on.doc") // 复制
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(HoverButtonStyle())
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
        if let translatedText = contentModel.translatedText, !translatedText.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(translatedText, forType: .string)
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
