import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralSettingsPane: View {
    
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "", bottomDivider: true) {
                LaunchAtLogin.Toggle {
                    Text(NSLocalizedString("startup", comment: "开机自启动"))
                }
            }
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut", comment: "AI助手快捷键")) }) {
                // Use the defined KeyboardShortcuts.Name
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                    .help(Text(NSLocalizedString("shortcut", comment: "打开AI助手的快捷键")))
            }
        }
    }
}

#Preview {
    GeneralSettingsPane()
        .environment(\.locale, .init(identifier: "en"))
}
