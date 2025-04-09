import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralAiPane: View {
    
    @StateObject private var settingsModel = SettingsModel()
    
    private func updateSettingsForProvider() {
        if let providerSettings = settingsModel.providers[settingsModel.selectedProvider] {
            settingsModel.providers[settingsModel.selectedProvider]?.apiKey = providerSettings.apiKey
            settingsModel.providers[settingsModel.selectedProvider]?.model = providerSettings.model
            
            // 确保更新传播到共享实例
            SettingsModel.shared.providers = settingsModel.providers
            SettingsModel.shared.selectedProvider = settingsModel.selectedProvider
        }
    }

    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack {
                    Form {
                        Section {
                            Picker(selection: $settingsModel.selectedProvider, label: HStack {
                                Text(NSLocalizedString("select_service", comment: "选择提供商"))
                            }) {
                                ForEach(Array(settingsModel.providers.keys), id: \.self) { key in
                                    if let providerName = SettingsModel.providersName[key], !providerName.isEmpty {
                                        Text(providerName).tag(key)
                                    }
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.bottom, 10)
                            .onChange(of: settingsModel.selectedProvider) { oldValue, newValue in
                                updateSettingsForProvider()
                            }
                            
                            if !SettingsModel.presetProviders.contains(settingsModel.selectedProvider) {
                                SecureField("API Key", text: Binding(
                                    get: { settingsModel.providers[settingsModel.selectedProvider]?.apiKey ?? "" },
                                    set: { settingsModel.providers[settingsModel.selectedProvider]?.apiKey = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Model", text: Binding(
                                    get: { settingsModel.providers[settingsModel.selectedProvider]?.model ?? "" },
                                    set: { settingsModel.providers[settingsModel.selectedProvider]?.model = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
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
