import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralAiPane: View {
    
    @StateObject private var settingsModel = SettingsModel()
    @State private var selectedProvider = "OpenAI" // 默认选择的服务商
    
    // 添加一个方法来更新 baseURL 和 model
    private func updateSettingsForProvider() {
        switch selectedProvider {
        case "OpenAI":
            settingsModel.baseURL = "https://api.openai.com/v1/chat/completions"
            settingsModel.model = "GPT-4o"
        case "DeepSeek":
            settingsModel.baseURL = "https://api.deepseek.com/v1/chat/completions"
            settingsModel.model = "deepseek-chat"
        case "zhipu":
            settingsModel.baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
            settingsModel.model = "glm-4-plus"
        default:
            settingsModel.baseURL = ""
            settingsModel.model = ""
        }
    }

    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack {
                    Form {
                        Section {
                            // 添加服务商选择器
                            Picker(selection: $selectedProvider, label: HStack {
                                Text("选择提供商") // 显示当前选择的服务商名称
                            }) {
                                Text("OpenAI").tag("OpenAI")
                                Text("DeepSeek").tag("DeepSeek")
                                Text("智谱").tag("zhipu")
                                // 可以在这里添加更多的服务商
                            }
                            .pickerStyle(MenuPickerStyle()) // 使用菜单样式
                            .padding(.bottom, 10)
                            .onChange(of: selectedProvider) { _ in
                                updateSettingsForProvider() // 当选择改变时更新设置
                            }
                            
                            // 移除 Base URL 的 TextField
                            SecureField("API Key", text: $settingsModel.apiKey)  // 绑定到 SettingsModel 的属性
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Model", text: $settingsModel.model)  // 绑定到 SettingsModel 的属性
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

// #Preview {
//   GeneralSettingsPane()
//     .environment(\.locale, .init(identifier: "en"))
// }
