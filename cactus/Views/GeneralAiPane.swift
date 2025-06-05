import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralAiPane: View {
    
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    var body: some View {
        Settings.Container(contentWidth: 500) {
            Settings.Section(label: { Text(NSLocalizedString("select_service", comment: "选择提供商")) }) {
                Picker(selection: $settingsModel.selectedProvider, label: EmptyView()) {
                    providerOptions
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 400) // 添加此行来限制宽度
            }
        }
        if settingsModel.selectedProvider == "openai" {
            Settings.Container(contentWidth: 400) {
                Settings.Section(label: { Text(NSLocalizedString("api_key", comment: "API密钥")) }) {
                    SecureField(NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: $settingsModel.openaiApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                }
                
                Settings.Section(label: { Text(NSLocalizedString("model", comment: "模型")) }) {
                    Picker(selection: $settingsModel.selectedOpenAIModel, label: EmptyView()) {
                        ForEach(Array(settingsModel.openaiModels.keys.sorted()), id: \.self) { key in
                            Text(settingsModel.openaiModels[key] ?? key).tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 300) // 添加此行来限制宽度
                }
            }
            .padding(.leading, 30)
        }
        
        if settingsModel.selectedProvider == "siliconflow" {
            Settings.Container(contentWidth: 400) {
                Settings.Section(label: { Text(NSLocalizedString("api_key", comment: "API密钥")) }) {
                    SecureField(NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: $settingsModel.siliconflowApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                }
                
                Settings.Section(label: { Text(NSLocalizedString("model", comment: "模型")) }) {
                    Picker(selection: $settingsModel.selectedSiliconflowModel, label: EmptyView()) {
                        ForEach(Array(settingsModel.siliconflowModels.keys.sorted()), id: \.self) { key in
                            Text(settingsModel.siliconflowModels[key] ?? key).tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 300) // 添加此行来限制宽度
                }
            }
            .padding(.leading, 30)
        }
    }
    
    private var providerOptions: some View {
        ForEach(Array(settingsModel.defaultProviders.keys.sorted()), id: \.self) { key in
            Text(providerDisplayText(for: key)).tag(key)
        }
    }
    
    private func providerDisplayText(for key: String) -> String {
        guard let provider = settingsModel.defaultProviders[key] else {
            return key
        }
        return provider.title
    }
}
