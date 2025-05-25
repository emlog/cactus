import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin
import Settings

struct GeneralSettingsPane: View {
    
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some View {
        Settings.Container(contentWidth: 500) {
            Settings.Section(title: "", bottomDivider: true) {
                LaunchAtLogin.Toggle {
                    Text(NSLocalizedString("startup", comment: "开机自启动"))
                }
            }
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut_openmain", comment: "打开主窗口快捷键")) }) {
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutMain)
                Text(NSLocalizedString("shortcut_openmain_description", comment: "打开主窗口，并将选中的文字填充到输入框内"))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut_translate", comment: "选中翻译快捷键")) }) {
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                Text(NSLocalizedString("shortcut_translate_description", comment: "选中要翻译的文字，按下快捷键快速翻译"))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut_summary", comment: "总结摘要快捷键")) }) {
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutSummary)
                Text(NSLocalizedString("shortcut_translate_summary", comment: "选中要总结的内容，按下快捷键总结摘要"))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}
