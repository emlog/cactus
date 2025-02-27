import SwiftUI

struct MainView: View {
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // 多行文本输入框
            TextEditor(text: $inputText)
                .font(.system(.body))
                .frame(maxWidth: .infinity, minHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(action: {
                    // 翻译操作
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
}