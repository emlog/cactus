import SwiftUI

struct ModelSelectionMenuView: View {
    @ObservedObject var settings = SettingsModel.shared
    
    var body: some View {
        Menu {
            Menu(NSLocalizedString("service", comment: "AI服务")) {
                ForEach(settings.providerKeys, id: \.self) { key in
                    if let provider = settings.defaultProviders[key] {
                        if (provider.model.isEmpty || provider.apiKey.isEmpty) {
                            // noting
                        } else {
                            Button(action: {
                                settings.selectedProvider = key
                            }) {
                                HStack {
                                    Text(provider.requiresCustomConfig ? "\(provider.title) - \(getModelDisplayName(for: provider))" : provider.title)
                                    Spacer()
                                    if settings.selectedProvider == key {
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
                ForEach(settings.languageKeys, id: \.self) { languageKey in
                    Button(action: {
                        settings.preferredLanguage = languageKey
                    }) {
                        HStack {
                            Text(settings.availableLanguages[languageKey] ?? languageKey)
                            Spacer()
                            if settings.preferredLanguage == languageKey {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Divider()
            Menu(NSLocalizedString("common_foreign_language", comment: "常用外语")) {
                ForEach(settings.languageKeys, id: \.self) { languageKey in
                    Button(action: {
                        settings.commonForeignLanguage = languageKey
                    }) {
                        HStack {
                            Text(settings.availableLanguages[languageKey] ?? languageKey)
                            Spacer()
                            if settings.commonForeignLanguage == languageKey {
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
