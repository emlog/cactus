import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralAiPane: View {
    
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack {
                    Form {
                        Section {
                            providerPickerView
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
    
    private var providerPickerView: some View {
        Picker(selection: $settingsModel.selectedProvider, label: HStack {
            Text(NSLocalizedString("select_service", comment: "选择提供商"))
        }) {
            providerOptions
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: settingsModel.selectedProvider) { newValue in
            updateSettingsForProvider()
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
    
    private func updateSettingsForProvider() {
        SettingsModel.shared.selectedProvider = settingsModel.selectedProvider
    }
}
