import SwiftUI

struct MainView: View {
    @State private var text: String = ""
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
                    if let translatedText = translationService.translate(text: text) {
                        text = translatedText
                    } else {
                        text = "Translation failed"
                    }
                }) {
                    Text("翻译")
                        .frame(width: 80)
                }
                
                Button(action: {
                    // 总结操作
                }) {
                    Text("总结")
                        .frame(width: 80)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: 300)
    }

    func fillText(_ newText: String) {
        text = newText
    }
}
