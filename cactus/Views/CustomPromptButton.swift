import SwiftUI

/// 自定义提示词选择按钮组件
struct CustomPromptButton: View {
    @ObservedObject private var preferences = PreferencesModel.shared
    @State private var selectedPrompt: String? = nil
    @State private var showPromptMenu = false
    
    var body: some View {
        // 如果没有自定义提示词，则不显示按钮
        if preferences.customPrompts.isEmpty {
            EmptyView()
        } else {
            Menu {
                // 清除选择选项
                if selectedPrompt != nil {
                    Button(NSLocalizedString("cancel", comment: "取消")) {
                        selectedPrompt = nil
                    }
                    Divider()
                }
                
                // 自定义提示词选项
                ForEach(preferences.customPrompts) { prompt in
                    Button(action: {
                        selectedPrompt = prompt.name
                    }) {
                        HStack {
                            // 为选中的提示词显示对勾标记
                            if selectedPrompt == prompt.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            Text(prompt.name)
                            Spacer()
                        }
                    }
                }
            } label: {
                Image(systemName: selectedPrompt != nil ? "circle.hexagonpath.fill" : "circle.hexagonpath")
                    .frame(width: 10, height: 10)
                    .foregroundColor(selectedPrompt != nil ? .accentColor : .secondary)
            }
            .buttonStyle(HoverButtonStyle(horizontalPadding: 6, verticalPadding: 4))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedPrompt != nil ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
    }
    
    /// 获取当前选中的提示词内容
    func getSelectedPromptContent() -> String? {
        guard let selectedPrompt = selectedPrompt else { return nil }
        return preferences.getCustomPromptContent(by: selectedPrompt)
    }
}
