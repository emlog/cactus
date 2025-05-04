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
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut_translate", comment: "选中翻译快捷键")) }) {
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                Text(NSLocalizedString("shortcut_translate_description", comment: "选中要翻译的文字，按下快捷键快速翻译"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false) // <-- 添加这一行
            }
            
            Settings.Section(label: { Text(NSLocalizedString("shortcut_summary", comment: "总结摘要快捷键")) }) {
                KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutSummary)
                Text(NSLocalizedString("shortcut_translate_summary", comment: "选中要总结的内容，按下快捷键总结摘要"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false) // <-- 添加这一行
            }
        }
    }
}

#Preview {
    GeneralSettingsPane()
        .environment(\.locale, .init(identifier: "zh-Hans")) // 切换为中文预览
}
