import SwiftUI

struct MainView: View {
    @State private var text: String = ""
    @State private var translatedText: String? = nil // 用于存储翻译结果
    @ObservedObject var settings = SettingsModel() // 添加 SettingsModel 作为 ObservedObject

    var body: some View {
        VStack(spacing: 16) {
            // 多行文本输入框
            TextEditor(text: $text)
                .font(.system(.body))
                .frame(maxWidth: .infinity, minHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(action: {
                    // 使用 SettingsModel 中的配置信息进行翻译操作
                    let translationService = TranslationService(
                        baseURL: settings.baseURL,
                        apiKey: settings.apiKey,
                        model: settings.model
                    )
                    translatedText = translationService.translate(text: text) // 更新翻译结果
                }) {
                    Image(systemName: "globe") // 使用地球图标表示翻译
                        .frame(width: 80)
                }
                
                Button(action: {
                    // 复制文本操作
                }) {
                    Image(systemName: "doc.on.doc") // 使用复制图标
                        .frame(width: 80)
                }
            }
            .padding(.top, 8)
            
            // 动态生成的文本框，用于展示翻译结果
            if let translatedText = translatedText {
                TextEditor(text: .constant(translatedText))
                    .font(.system(.body))
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: translatedText == nil ? 300 : 400) // 动态调整高度
    }

    func fillText(_ newText: String) {
        text = newText
    }
}
