import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsPane: View {
    
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack{
                    // 开机自启动
                    SettingRow(
                        label: NSLocalizedString("startup", comment: "开机自启动")
                    ) {
                        LaunchAtLogin.Toggle{}
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(20)
                
                VStack{
                    // 打开主窗口快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_openmain", comment: "打开主窗口快捷键"),
                        description: NSLocalizedString("shortcut_openmain_description", comment: "打开主窗口，并将选中的文字填充到输入框内")
                    ) {
                        KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutMain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 选中翻译快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_translate", comment: "选中翻译快捷键"),
                        description: NSLocalizedString("shortcut_translate_description", comment: "选中要翻译的文字，按下快捷键快速翻译")
                    ) {
                        KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcut)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 总结摘要快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_summary", comment: "总结摘要快捷键"),
                        description: NSLocalizedString("shortcut_summary_description", comment: "选中要总结的内容，按下快捷键总结摘要")
                    ) {
                        KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutSummary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 字典查询快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_dict", comment: "字典查询快捷键"),
                        description: NSLocalizedString("shortcut_dict_description", comment: "选中要查询的字词，按下快捷键查询")
                    ) {
                        KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutDictionary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 截屏翻译快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_ocr_translate", comment: "截屏翻译快捷键"),
                        description: NSLocalizedString("shortcut_ocr_translate_description", comment: "截取屏幕上的文字区域，自动OCR识别并翻译")
                    ) {
                        KeyboardShortcuts.Recorder(for: SettingsModel.aiShortcutScreenshotTranslate)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(20)
                
                VStack{
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(20)
            }
        }
        .frame(width: 800, height: 680)
    }
}
