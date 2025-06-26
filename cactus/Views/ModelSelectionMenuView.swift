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
                                    Text(provider.requiresCustomConfig ? "\(provider.title) - \(provider.model.isEmpty ? "NA" : provider.model)" : provider.title)
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
}

#Preview {
    ModelSelectionMenuView()
}