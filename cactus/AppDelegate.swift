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
        // 创建并初始化窗口管理器
        windowManager = WindowManager(appDelegate: self)
        windowManager?.initializeWindows()
        
        // 创建并设置状态栏管理器，传入windowManager引用
        statusBarManager = StatusBarManager(windowManager: windowManager!)
        statusBarManager?.setupStatusBar()
        
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
    
    // 主窗口 - 保留此方法因为全局快捷键需要使用
    func openMain(action: ActionType = .translate) {
        windowManager?.openMain(action: action)
    }
}
