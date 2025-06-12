//
//  AppDelegate.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/21.
//

import AppKit
import SwiftUI
import KeyboardShortcuts
import Settings
import Foundation
import ApplicationServices

enum ActionType {
    case nothing
    case translate
    case summarize
    case dictionary
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarManager: StatusBarManager?
    private var windowManager: WindowManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建并设置状态栏管理器
        statusBarManager = StatusBarManager(appDelegate: self)
        statusBarManager?.setupStatusBar()
        
        // 创建并初始化窗口管理器
        windowManager = WindowManager(appDelegate: self)
        windowManager?.initializeWindows()
        
        setupGlobalShortcut() // 设置全局快捷键
    }
    
    // Setup global keyboard shortcut using KeyboardShortcuts
    private func setupGlobalShortcut() {
        // Register the keyboard shortcut for openmain
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutMain) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .nothing) // 打开主窗口
            }
        }
        
        // Register the keyboard shortcut for translate
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcut) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .translate) // 指定翻译操作
            }
        }
        
        // Register the keyboard shortcut for summary
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutSummary) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .summarize) // 指定总结操作
            }
        }
        
        // Register the keyboard shortcut for dictionary
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutDictionary) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .dictionary) // 指定字典操作
            }
        }
    }
    
    // MARK: - Window Management Delegation
    // 生词本窗口
    @objc func openVocabulary() {
        windowManager?.openVocabulary()
    }
    
    // 收藏夹窗口
    @objc func openFavorites() {
        windowManager?.openFavorites()
    }
    
    // 联系我们
    @objc func openContact() {
        if let url = URL(string: "https://cactusai.cc/about") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // 给个好评吧
    @objc func rateApp() {
        if let url = URL(string: "macappstore://apps.apple.com/app/id6743790378?action=write-review") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // Preferences window
    @objc func openPreferences() {
        windowManager?.openPreferences()
    }
    
    // 主窗口
    func openMain(action: ActionType = .translate) {
        windowManager?.openMain(action: action)
    }
    
    // 菜单项的 Action 方法
    @objc private func openMainTranslateAction() {
        openMain(action: .translate)
    }
    
    @objc private func openMainSummaryAction() {
        openMain(action: .summarize)
    }
    
    @objc private func openMainAction() {
        openMain(action: .nothing)
    }
    
    @objc private func openMainDictionaryAction() {
        openMain(action: .dictionary)
    }
}
