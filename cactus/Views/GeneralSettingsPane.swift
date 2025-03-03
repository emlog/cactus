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
                        Settings.Section(label: { Text("AI助手快捷键") }) {
                            // Use the defined KeyboardShortcuts.Name
                            KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                            .help(Text("打开AI助手的快捷键"))
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
