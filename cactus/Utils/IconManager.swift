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
            return NSImage(systemSymbolName: "globe", accessibilityDescription: NSLocalizedString("translate", comment: "选中翻译"))
        }
    }
    
    /// 获取截图翻译图标
    func getScreenshotIcon() -> NSImage? {
        return NSImage(systemSymbolName: "camera.metering.center.weighted.average", accessibilityDescription: NSLocalizedString("ocr_translate", comment: "截图翻译"))
    }
    
    /// 获取总结摘要图标
    func getSummaryIcon() -> NSImage? {
        return NSImage(systemSymbolName: "list.bullet.rectangle", accessibilityDescription: NSLocalizedString("summary", comment: "总结摘要"))
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