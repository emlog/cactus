import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralSettingsPane: View {

    @StateObject private var settingsModel = SettingsModel()

    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "", bottomDivider: true) {
                VStack {
                    Form {
                        Section {
                            TextField("划线翻译快捷键", text: $settingsModel.shortcutKey)  // 绑定到 SettingsModel 的属性
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
