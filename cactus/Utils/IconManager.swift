//
//  IconManager.swift
//  cactus
//
//  Created by AI Assistant
//

import AppKit
import Foundation

/// 图标管理器 - 统一管理应用中使用的所有图标
class IconManager {
    
    static let shared = IconManager()
    
    private init() {}
    
    // MARK: - 状态栏图标
    
    /// 获取状态栏主图标
    func getStatusBarIcon() -> NSImage? {
        guard let image = NSImage(named: "StatusIcon") else { return nil }
        image.isTemplate = true  // 设置为模板图标，使其变为单色
        image.size = NSSize(width: 18, height: 18)
        return image
    }
    
    // MARK: - 菜单项图标
    
    /// 获取主窗口图标
    func getMainWindowIcon() -> NSImage? {
        return NSImage(systemSymbolName: "macwindow", accessibilityDescription: NSLocalizedString("openmain", comment: "打开主窗口"))
    }
    
    /// 获取翻译图标
    /// 如果macOS版本低于14.4，使用替代图标
    func getTranslateIcon() -> NSImage? {
        // 检查macOS版本是否支持translate图标（macOS 14.4+）
        if #available(macOS 14.4, *) {
            return NSImage(systemSymbolName: "translate", accessibilityDescription: NSLocalizedString("translate", comment: "选中翻译"))
        } else {
            return NSImage(systemSymbolName: "character.textbox", accessibilityDescription: NSLocalizedString("translate", comment: "选中翻译"))
        }
    }
    
    /// 获取截图翻译图标
    func getScreenshotIcon() -> NSImage? {
        return NSImage(systemSymbolName: "camera.metering.multispot", accessibilityDescription: NSLocalizedString("ocr_translate", comment: "截图翻译"))
    }
    
    /// 获取总结摘要图标
    func getSummaryIcon() -> NSImage? {
        return NSImage(systemSymbolName: "list.dash.header.rectangle", accessibilityDescription: NSLocalizedString("summary", comment: "总结摘要"))
    }
    
    /// 获取字典查询图标
    func getDictionaryIcon() -> NSImage? {
        return NSImage(systemSymbolName: "book", accessibilityDescription: NSLocalizedString("dictionary", comment: "字典查询"))
    }
    
    /// 获取生词本图标
    func getVocabularyIcon() -> NSImage? {
        if #available(macOS 14.0, *) {
            return NSImage(systemSymbolName: "book.pages", accessibilityDescription: NSLocalizedString("vocabulary", comment: "生词本"))
        } else {
            return NSImage(systemSymbolName: "text.book.closed.fill", accessibilityDescription: NSLocalizedString("vocabulary", comment: "生词本"))
        }
    }
    
    /// 获取收藏夹图标
    func getFavoritesIcon() -> NSImage? {
        return NSImage(systemSymbolName: "heart", accessibilityDescription: NSLocalizedString("favorites", comment: "收藏夹"))
    }
    
    /// 获取历史记录图标
    func getHistoryIcon() -> NSImage? {
        return NSImage(systemSymbolName: "clock", accessibilityDescription: NSLocalizedString("history", comment: "历史记录"))
    }
    
    // MARK: - 设置窗口图标
    
    /// 获取通用设置图标
    func getGeneralSettingsIcon() -> NSImage? {
        return NSImage(systemSymbolName: "gear", accessibilityDescription: NSLocalizedString("general", comment: "通用"))
    }
    
    /// 获取AI服务设置图标
    func getAiSettingsIcon() -> NSImage? {
        return NSImage(systemSymbolName: "lanyardcard", accessibilityDescription: NSLocalizedString("service", comment: "服务"))
    }
    
    /// 获取高级版设置图标
    func getPremiumSettingsIcon() -> NSImage? {
        return NSImage(systemSymbolName: "checkmark.seal", accessibilityDescription: NSLocalizedString("premium", comment: "高级版"))
    }
    
    /// 获取关于设置图标
    func getAboutSettingsIcon() -> NSImage? {
        return NSImage(systemSymbolName: "info.circle", accessibilityDescription: NSLocalizedString("about", comment: "关于"))
    }
    
    // MARK: - 通用图标获取方法
    
    /// 根据系统符号名称获取图标
    /// - Parameters:
    ///   - symbolName: 系统符号名称
    ///   - accessibilityDescription: 无障碍描述
    /// - Returns: 对应的NSImage图标
    func getSystemIcon(symbolName: String, accessibilityDescription: String? = nil) -> NSImage? {
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityDescription)
    }
    
    /// 根据资源名称获取图标
    /// - Parameter imageName: 图片资源名称
    /// - Returns: 对应的NSImage图标
    func getNamedIcon(_ imageName: String) -> NSImage? {
        return NSImage(named: imageName)
    }
}