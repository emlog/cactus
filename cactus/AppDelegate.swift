//
//  AppDelegate.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/21.
//

import AppKit
import SwiftUI
import Settings
import Foundation
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarManager: StatusBarManager?
    private var windowManager: WindowManager?
    private var shortcutManager: ShortcutManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建并初始化窗口管理器
        windowManager = WindowManager()
        windowManager?.initializeWindows()
        windowManager?.checkAccessibilityAndShowAlert()
        
        // 创建并设置状态栏管理器
        statusBarManager = StatusBarManager(windowManager: windowManager!)
        statusBarManager?.setupStatusBar()
        
        // 创建并设置快捷键管理器
        shortcutManager = ShortcutManager(windowManager: windowManager!)
        shortcutManager?.setupGlobalShortcuts()
    }
}
