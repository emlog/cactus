import SwiftUI

struct ModelSelectionMenuView: View {
    @ObservedObject var preferences = PreferencesModel.shared
    
    var body: some View {
        Menu {
            Menu(NSLocalizedString("service", comment: "AI服务")) {
                ForEach(preferences.providerKeys, id: \.self) { key in
                    if let provider = preferences.defaultProviders[key] {
                        if (provider.model.isEmpty || provider.apiKey.isEmpty) {
                            // noting
                        } else {
                            Button(action: {
                                preferences.selectedProvider = key
                            }) {
                                HStack {
                                    Text(provider.requiresCustomConfig ? "\(provider.title) - \(getModelDisplayName(for: provider))" : provider.title)
                                    Spacer()
                                    if preferences.selectedProvider == key {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Divider()
            Menu(NSLocalizedString("preferred_language", comment: "常用语言")) {
                ForEach(preferences.languageKeys, id: \.self) { languageKey in
                    Button(action: {
                        preferences.preferredLanguage = languageKey
                    }) {
                        HStack {
                            Text(preferences.availableLanguages[languageKey] ?? languageKey)
                            Spacer()
                            if preferences.preferredLanguage == languageKey {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Divider()
            Menu(NSLocalizedString("common_foreign_language", comment: "常用外语")) {
                ForEach(preferences.languageKeys, id: \.self) { languageKey in
                    Button(action: {
                        preferences.commonForeignLanguage = languageKey
                    }) {
                        HStack {
                            Text(preferences.availableLanguages[languageKey] ?? languageKey)
                            Spacer()
                            if preferences.commonForeignLanguage == languageKey {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Divider()
            Menu(NSLocalizedString("default_main_function", comment: "默认功能")) {
                ForEach(preferences.functionKeys, id: \.self) { functionKey in
                    Button(action: {
                        preferences.defaultMainFunction = functionKey
                    }) {
                        HStack {
                            Text(preferences.availableFunctions[functionKey] ?? functionKey)
                            Spacer()
                            if preferences.defaultMainFunction == functionKey {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuIndicator(.hidden) // Hide the menu indicator arrow
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(maxWidth: 20, alignment: .trailing)
    }
    
    // 获取模型的友好名称
    private func getModelDisplayName(for provider: ProviderSettings) -> String {
        if provider.requiresCustomConfig {
            if provider.model.isEmpty {
                return "NA"
            }
            // 从availableModels中获取友好名称，如果没有找到则使用原始model名称
            return provider.availableModels[provider.model] ?? provider.model
        }
        return provider.title
    }
}
