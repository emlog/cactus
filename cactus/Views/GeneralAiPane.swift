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
                            TextField("Base URL", text: $settingsModel.baseURL)  // 绑定到 SettingsModel 的属性
                                .textFieldStyle(RoundedBorderTextFieldStyle())
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
