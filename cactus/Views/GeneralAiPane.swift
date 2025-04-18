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
                            Picker(selection: $settingsModel.selectedProvider, label: HStack {
                                Text(NSLocalizedString("select_service", comment: "选择提供商"))
                            }) {
                                ForEach(Array(settingsModel.defaultProviders.keys.sorted()), id: \.self) { key in
                                    Text(settingsModel.defaultProviders[key]!.title + " - " + settingsModel.defaultProviders[key]!.model).tag(key)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: settingsModel.selectedProvider) { oldValue, newValue in
                                updateSettingsForProvider()
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
    
    private func updateSettingsForProvider() {
        SettingsModel.shared.selectedProvider = settingsModel.selectedProvider
    }
}
