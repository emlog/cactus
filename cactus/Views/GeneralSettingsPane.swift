import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsPane: View {
    
    @ObservedObject private var preferences = PreferencesModel.shared
    
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
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 默认主窗口功能
                    SettingRow(
                        label: NSLocalizedString("default_main_function", comment: "默认主窗口功能"),
                        description: NSLocalizedString("default_main_function_description", comment: "按下回车键时主窗口默认触发的功能")
                    ) {
                        // 在默认主窗口功能的Picker中
                        Picker("", selection: $preferences.defaultMainFunction) {
                            ForEach(preferences.functionKeys, id: \.self) { functionKey in
                                Text(preferences.availableFunctions[functionKey] ?? functionKey).tag(functionKey)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 200, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)
                
                VStack{
                    // 常用语言
                    SettingRow(
                        label: NSLocalizedString("preferred_language", comment: "常用语言"),
                        description: NSLocalizedString("preferred_language_description", comment: "翻译的目标语言，一般为母语")
                    ) {
                        Picker("", selection: $preferences.preferredLanguage) {
                            ForEach(preferences.languageKeys, id: \.self) { key in
                                Text(preferences.availableLanguages[key] ?? key)
                                    .tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 200, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 常用外语
                    SettingRow(
                        label: NSLocalizedString("common_foreign_language", comment: "常用外语"),
                        description: NSLocalizedString("common_foreign_language_description", comment: "正在学习和使用的第一外语")
                    ) {
                        Picker("", selection: $preferences.commonForeignLanguage) {
                            ForEach(preferences.languageKeys, id: \.self) { key in
                                Text(preferences.availableLanguages[key] ?? key)
                                    .tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 200, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)

                VStack{
                    // 打开主窗口快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_openmain", comment: "打开主窗口快捷键"),
                        description: NSLocalizedString("shortcut_openmain_description", comment: "打开主窗口，并将选中的文字填充到输入框内")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutMain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 选中翻译快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_translate", comment: "选中翻译快捷键"),
                        description: NSLocalizedString("shortcut_translate_description", comment: "选中要翻译的文字，按下快捷键快速翻译")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcut)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 总结摘要快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_summary", comment: "总结摘要快捷键"),
                        description: NSLocalizedString("shortcut_summary_description", comment: "选中要总结的内容，按下快捷键总结摘要")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutSummary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 字典查询快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_dict", comment: "字典查询快捷键"),
                        description: NSLocalizedString("shortcut_dict_description", comment: "选中要查询的字词，按下快捷键查询")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutDictionary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 截屏翻译快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_ocr_translate", comment: "截屏翻译快捷键"),
                        description: NSLocalizedString("shortcut_ocr_translate_description", comment: "截取屏幕上的文字区域，自动OCR识别并翻译")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutScreenshotTranslate)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 重置快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_reset", comment: "重置快捷键"),
                        description: NSLocalizedString("shortcut_reset_description", comment: "快速重置输入和输出窗口内容")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutReset)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    // 复制输出快捷键
                    SettingRow(
                        label: NSLocalizedString("shortcut_copy_output", comment: "复制输出快捷键"),
                        description: NSLocalizedString("shortcut_copy_output_description", comment: "快速复制输出内容到剪贴板")
                    ) {
                        KeyboardShortcuts.Recorder(for: PreferencesModel.aiShortcutCopyOutput)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)
            }
        }
        .frame(width: 800, height: 680)
    }
}
