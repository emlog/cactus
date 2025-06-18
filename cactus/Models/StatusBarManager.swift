//
//  StatusBarManager.swift
//  cactus
//
//  Created by AI Assistant
//

import AppKit
import SwiftUI
import KeyboardShortcuts
import Settings
import Foundation

class StatusBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private weak var windowManager: WindowManager?
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init()
    }
    
    @MainActor func setupStatusBar() {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            if let image = NSImage(named: "StatusIcon") {
                image.isTemplate = true  // 设置为模板图标，使其变为单色
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            }
            
            let menu = NSMenu()
            
            // 打开主窗口
            let mainMenuItem = NSMenuItem(
                title: NSLocalizedString("openmain", comment: "打开主窗口"),
                action: #selector(openMainAction),
                keyEquivalent: ""
            )
            mainMenuItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
            mainMenuItem.setShortcut(for: SettingsModel.aiShortcutMain)
            mainMenuItem.target = self
            menu.addItem(mainMenuItem)
            
            // 选中翻译
            let translateMenuItem = NSMenuItem(
                title: NSLocalizedString("translate", comment: "选中翻译"),
                action: #selector(openMainTranslateAction),
                keyEquivalent: "" // 初始值设为空，由 setShortcut 管理
            )
            translateMenuItem.image = NSImage(systemSymbolName: "translate", accessibilityDescription: nil)
            translateMenuItem.setShortcut(for: SettingsModel.aiShortcut) // 使用 setShortcut(for:) 来设置快捷键并自动更新
            translateMenuItem.target = self
            menu.addItem(translateMenuItem)
            
            // 截图翻译 - 新增菜单项
            let screenshotMenuItem = NSMenuItem(
                title: NSLocalizedString("ocr_translate", comment: "截图翻译"),
                action: #selector(openMainScreenshotAction),
                keyEquivalent: ""
            )
            screenshotMenuItem.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: nil)
            screenshotMenuItem.setShortcut(for: SettingsModel.aiShortcutScreenshotTranslate)
            screenshotMenuItem.target = self
            menu.addItem(screenshotMenuItem)
            
            // 总结摘要
            let summaryMenuItem = NSMenuItem(
                title: NSLocalizedString("summary", comment: "总结摘要"),
                action: #selector(openMainSummaryAction),
                keyEquivalent: ""
            )
            summaryMenuItem.image = NSImage(systemSymbolName: "pencil.and.list.clipboard.rtl", accessibilityDescription: nil)
            summaryMenuItem.setShortcut(for: SettingsModel.aiShortcutSummary)
            summaryMenuItem.target = self
            menu.addItem(summaryMenuItem)
            
            // 字典查询
            let dictionaryMenuItem = NSMenuItem(
                title: NSLocalizedString("dictionary", comment: "字典查询"),
                action: #selector(openMainDictionaryAction),
                keyEquivalent: ""
            )
            dictionaryMenuItem.image = NSImage(systemSymbolName: "books.vertical", accessibilityDescription: nil)
            dictionaryMenuItem.setShortcut(for: SettingsModel.aiShortcutDictionary)
            dictionaryMenuItem.target = self
            menu.addItem(dictionaryMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 生词本
            let vocabularyMenuItem = NSMenuItem(
                title: NSLocalizedString("vocabulary", comment: "生词本"),
                action: #selector(openVocabulary),
                keyEquivalent: ""
            )
            vocabularyMenuItem.image = NSImage(systemSymbolName: "book.pages", accessibilityDescription: nil)
            vocabularyMenuItem.target = self
            menu.addItem(vocabularyMenuItem)
            
            // 收藏夹
            let favoritesMenuItem = NSMenuItem(
                title: NSLocalizedString("favorites", comment: "收藏夹"),
                action: #selector(openFavorites),
                keyEquivalent: ""
            )
            favoritesMenuItem.image = NSImage(systemSymbolName: "heart", accessibilityDescription: nil)
            favoritesMenuItem.target = self
            menu.addItem(favoritesMenuItem)
            
            // 历史记录
            let historyMenuItem = NSMenuItem(
                title: NSLocalizedString("history", comment: "历史记录"),
                action: #selector(openHistory),
                keyEquivalent: ""
            )
            historyMenuItem.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            historyMenuItem.target = self
            menu.addItem(historyMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 偏好设置
            let preferencesMenuItem = NSMenuItem(
                title: NSLocalizedString("setting", comment: "偏好设置"),
                action: #selector(openPreferences),
                keyEquivalent: ""
            )
            preferencesMenuItem.target = self
            menu.addItem(preferencesMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 反馈问题
            let contactMenuItem = NSMenuItem(
                title: NSLocalizedString("report_issue", comment: "反馈问题"),
                action: #selector(openContact),
                keyEquivalent: ""
            )
            contactMenuItem.target = self
            menu.addItem(contactMenuItem)
            
            // 给个好评吧
            let rateMenuItem = NSMenuItem(
                title: NSLocalizedString("rate_app", comment: "给个好评吧"),
                action: #selector(rateApp),
                keyEquivalent: ""
            )
            rateMenuItem.target = self
            menu.addItem(rateMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // 退出
            let quitMenuItem = NSMenuItem(
                title: NSLocalizedString("quit", comment: "退出"),
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
            menu.addItem(quitMenuItem)
            
            statusItem?.menu = menu
        }
    }
    
    // MARK: - Menu Actions - 直接调用WindowManager的方法
    
    @objc private func openMainAction() {
        windowManager?.openMain(action: .nothing)
    }
    
    @objc private func openMainTranslateAction() {
        windowManager?.openMain(action: .translate)
    }
    
    @objc private func openMainSummaryAction() {
        windowManager?.openMain(action: .summarize)
    }
    
    @objc private func openMainDictionaryAction() {
        windowManager?.openMain(action: .dictionary)
    }
    
    @objc private func openVocabulary() {
        windowManager?.openVocabulary()
    }
    
    @objc private func openFavorites() {
        windowManager?.openFavorites()
    }
    
    @objc private func openPreferences() {
        windowManager?.openPreferences()
    }
    
    @objc private func openContact() {
        if let url = URL(string: "https://cactusai.cc/about") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func rateApp() {
        if let url = URL(string: "macappstore://apps.apple.com/app/id6743790378?action=write-review") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func openMainScreenshotAction() {
        windowManager?.openMain(action: .screenshotTranslate)
    }
    
    @objc private func openHistory() {
        windowManager?.openHistory()
    }
}
