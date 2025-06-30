import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsPane: View {
    
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 开机自启动
                SettingRow(
                    label: NSLocalizedString("startup", comment: "开机自启动")
                ) {
                    LaunchAtLogin.Toggle{}
                }
                
                Divider()
                
                // 打开主窗口快捷键
                SettingRow(
                    label: NSLocalizedString("shortcut_openmain", comment: "打开主窗口快捷键"),
                    description: NSLocalizedString("shortcut_openmain_description", comment: "打开主窗口，并将选中的文字填充到输入框内")
                ) {
                    KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutMain)
                }
                
                // 选中翻译快捷键
                SettingRow(
                    label: NSLocalizedString("shortcut_translate", comment: "选中翻译快捷键"),
                    description: NSLocalizedString("shortcut_translate_description", comment: "选中要翻译的文字，按下快捷键快速翻译")
                ) {
                    KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                }
                
                // 总结摘要快捷键
                SettingRow(
                    label: NSLocalizedString("shortcut_summary", comment: "总结摘要快捷键"),
                    description: NSLocalizedString("shortcut_summary_description", comment: "选中要总结的内容，按下快捷键总结摘要")
                ) {
                    KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutSummary)
                }
                
                // 字典查询快捷键
                SettingRow(
                    label: NSLocalizedString("shortcut_dict", comment: "字典查询快捷键"),
                    description: NSLocalizedString("shortcut_dict_description", comment: "选中要查询的字词，按下快捷键查询")
                ) {
                    KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutDictionary)
                }
                
                // 截屏翻译快捷键
                SettingRow(
                    label: NSLocalizedString("shortcut_ocr_translate", comment: "截屏翻译快捷键"),
                    description: NSLocalizedString("shortcut_ocr_translate_description", comment: "截取屏幕上的文字区域，自动OCR识别并翻译")
                ) {
                    KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutScreenshotTranslate)
                }
                
                Divider()
                
                // 常用语言
                SettingRow(
                    label: NSLocalizedString("preferred_language", comment: "常用语言"),
                    description: NSLocalizedString("preferred_language_description", comment: "翻译的目标语言，一般为母语")
                ) {
                    Picker("", selection: $settingsModel.preferredLanguage) {
                        ForEach(settingsModel.languageKeys, id: \.self) { key in
                            Text(settingsModel.availableLanguages[key] ?? key)
                                .tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200, alignment: .leading)
                }
                
                // 常用外语
                SettingRow(
                    label: NSLocalizedString("common_foreign_language", comment: "常用外语"),
                    description: NSLocalizedString("common_foreign_language_description", comment: "正在学习和使用的第一外语")
                ) {
                    Picker("", selection: $settingsModel.commonForeignLanguage) {
                        ForEach(settingsModel.languageKeys, id: \.self) { key in
                            Text(settingsModel.availableLanguages[key] ?? key)
                                .tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200, alignment: .leading)
                }
            }
            .padding(20)
        }
        .frame(width: 660)
    }
}

// 自定义设置行组件
struct SettingRow<Content: View>: View {
    let label: String
    let description: String?
    let content: Content
    
    init(label: String, description: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // 左对齐的标签
                Text(label)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 右对齐的设置内容
                content
                    .frame(alignment: .trailing)
            }
            
            // 描述文字（如果有的话）
            if let description = description {
                HStack {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
            }
        }
    }
}
