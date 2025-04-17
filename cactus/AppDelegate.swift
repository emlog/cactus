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

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    // 添加窗口属性
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?
    var mainWindow: NSWindow?
    
    private var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置应用程序的激活策略为 .accessory，以隐藏程序坞图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            if let image = NSImage(named: "StatusIcon") {
                image.isTemplate = true  // 设置为模板图标，使其变为单色
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            }
            
            // 创建菜单
            let menu = NSMenu()
            
            let translateMenuItem = NSMenuItem(
                title: NSLocalizedString("main", comment: "AI助手"),
                action: #selector(openMain),
                keyEquivalent: "j"
            )
            translateMenuItem.image = NSImage(systemSymbolName: "shareplay", accessibilityDescription: nil) // 添加地球图标
            menu.addItem(translateMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(
                title: NSLocalizedString("setting", comment: "偏好设置"),
                action: #selector(openPreferences),
                keyEquivalent: ""
            ))
            menu.addItem(NSMenuItem(
                title: NSLocalizedString("about", comment: "关于"),
                action: #selector(openAbout),
                keyEquivalent: ""
            ))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(
                title: NSLocalizedString("quit", comment: "退出"),
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            ))
            
            statusItem?.menu = menu
        }
        
        // 初始化窗口
        initializeWindows()
        
        // 设置全局快捷键
        setupGlobalShortcut()
    }
    
    private func initializeWindows() {
        // 初始化主窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable],  // Allow window resizing but disable zoom button
            backing: .buffered,
            defer: false
        )
        mainWindow?.collectionBehavior = .fullScreenNone  // Disable zoom button
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow?.contentViewController = hostingController
        mainWindow?.title = ""
        mainWindow?.isReleasedWhenClosed = false
        
        // 动态调整窗口高度
        let contentSize = hostingController.view.intrinsicContentSize
        mainWindow?.setContentSize(contentSize)
        
        // 添加通知监听器来响应文本高度变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustWindowSize),
            name: NSNotification.Name("AdjustWindowSize"),
            object: nil
        )
        
        // 初始化关于窗口
        aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        let aboutView = AboutView()
        let aboutHostingController = NSHostingController(rootView: aboutView)
        aboutWindow?.contentViewController = aboutHostingController
        aboutWindow?.title = NSLocalizedString("about", comment: "关于")
        aboutWindow?.isReleasedWhenClosed = false
    }
    
    // Setup global keyboard shortcut using KeyboardShortcuts
    private func setupGlobalShortcut() {
        // Register the keyboard shortcut
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcut) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain()
            }
        }
    }
    
    // 添加调整窗口大小的方法
    @objc private func adjustWindowSize() {
        guard let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> else {
            return
        }
        
        // 方法1: 使用 sizeThatFits 获取合适的大小
        let contentSize = hostingController.sizeThatFits(in: NSSize(width: mainWindow?.frame.width ?? 500, height: CGFloat.greatestFiniteMagnitude))
        
        // 如果窗口已经可见，使用动画平滑过渡
        if let window = mainWindow, window.isVisible {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                window.animator().setContentSize(contentSize)
            }
        } else {
            // 否则直接设置大小
            mainWindow?.setContentSize(contentSize)
        }
    }
    
    @objc func openPreferences() {
        if settingsWindowController == nil {
            // Use system symbols for toolbar icons with fallback
            let generalIcon = NSImage(systemSymbolName: "gear", accessibilityDescription: "General Settings") ?? NSImage()
            let aiIcon = NSImage(systemSymbolName: "lanyardcard", accessibilityDescription: "Storage Settings") ?? NSImage()
            
            settingsWindowController = SettingsWindowController(
                panes: [
                    Settings.Pane(
                        identifier: Settings.PaneIdentifier.general,
                        title: NSLocalizedString("general", comment: "通用"),
                        toolbarIcon: generalIcon
                    ) {
                        GeneralSettingsPane()
                    },
                    Settings.Pane(
                        identifier: Settings.PaneIdentifier.ai,
                        title: NSLocalizedString("service", comment: "服务"),
                        toolbarIcon: aiIcon
                    ) {
                        GeneralAiPane()
                    }
                ]
            )
        }
        
        settingsWindowController?.show()
        settingsWindowController?.window?.orderFrontRegardless()
    }
    
    @objc func openAbout() {
        // 调整窗口位置到当前屏幕的中心
        aboutWindow?.center()
        aboutWindow?.makeKeyAndOrderFront(nil)
        aboutWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openMain() {
        // 1. 先尝试获取剪贴板内容（这会触发模拟复制）
        checkAccessibilityPermissionAndGetClipboard { [weak self] success in
            // 2. 无论成功与否，都激活并显示窗口
            // 使用 DispatchQueue.main.async 确保在主线程执行 UI 操作
            DispatchQueue.main.async {
                guard let self = self else { return }
                // 确保窗口在最上层
                self.mainWindow?.center()
                self.mainWindow?.makeKeyAndOrderFront(nil)
                self.mainWindow?.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)

                // 可以在这里根据 success 的结果决定是否显示提示信息等
                if !success {
                    print("未能成功获取选中文本。")
                    // 可以考虑清空输入框或显示提示
                    // 例如，如果需要清空，可以这样做：
                    // if let mainVC = self.mainWindow?.contentViewController as? NSHostingController<MainView> {
                    //     mainVC.rootView.fillText("") // 假设 fillText 可以接受空字符串来清空
                    // }
                }
            }
        }
    }
    
    // 检查并提醒用户开启：辅助功能权限
    private func checkAccessibilityPermissionAndGetClipboard(completion: @escaping (Bool) -> Void) {
        // 检查辅助功能权限
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
    
        if accessEnabled {
            // 如果有权限，立即尝试获取剪贴板内容
            getClipboardContent(completion: completion)
        } else {
            // 显示权限提示
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("accessibility_permission_title", comment: "需要辅助功能权限")
            alert.informativeText = NSLocalizedString("accessibility_permission_message", comment: "请在系统偏好设置中启用辅助功能权限，以便自动获取剪贴板内容。")
            alert.alertStyle = .warning
            alert.addButton(withTitle: NSLocalizedString("open_settings", comment: "打开设置"))
            alert.addButton(withTitle: NSLocalizedString("cancel", comment: "取消"))
    
            // 在主线程显示 Alert
            DispatchQueue.main.async {
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    // 打开辅助功能设置
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
                // 无论用户是否去设置，本次操作都视为未成功获取
                completion(false)
            }
        }
    }
    
    // 按下快捷键复制选中内容到剪贴板、并调用翻译功能
    private func getClipboardContent(completion: @escaping (Bool) -> Void) {
        // 保存当前剪贴板内容
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
    
        // 使用模拟复制功能获取选中文本，模拟复制发生在这里，此时焦点理论上还在原应用
        simulateCopy()
    
        // 给系统一点时间处理复制操作，然后读取剪贴板
        // 这个延迟仍然是必要的，但要确保它在窗口激活之前完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 使用 0.2 秒延迟
            guard let mainViewController = self.mainWindow?.contentViewController as? NSHostingController<MainView> else {
                // 如果无法获取 mainViewController，也恢复剪贴板
                if let originalContent = originalContent {
                    self.copyToClipBoard(textToCopy: originalContent)
                }
                completion(false)
                return
            }
            let mainView = mainViewController.rootView
            let newContent = pasteboard.string(forType: .string)
            var success = false
    
            // 如果有新内容，且与原内容不同（避免误触发）
            if let newContent = newContent, !newContent.isEmpty, newContent != originalContent {
                mainView.fillText(newContent)
    
                // 添加延迟以确保文本已填充 (如果 translateText 依赖于 fillText 完成后的状态)
                // 如果 fillText 内部已经是 async 更新，这个延迟可能不需要或者需要调整
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 调用翻译功能
                    mainView.translateText()
                }
                success = true
            } else {
                print("未能获取到新的剪贴板内容或内容未改变。")
            }
    
            // 恢复原始剪贴板内容
            if let originalContent = originalContent {
                self.copyToClipBoard(textToCopy: originalContent)
            }
    
            // 调用完成回调
            completion(success)
        }
    }
    
    // 添加模拟复制功能
    private func simulateCopy() {
        // 模拟 Command+C 复制操作
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // 确保事件源创建成功
        guard let eventSource = source else {
            print("无法创建事件源")
            return
        }
        
        // 按下 Command+C
        guard let keyDownC = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x08, keyDown: true) else {
            print("无法创建按键事件")
            return
        }
        keyDownC.flags = .maskCommand
        
        // 释放 Command+C
        guard let keyUpC = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x08, keyDown: false) else {
            print("无法创建释放事件")
            return
        }
        keyUpC.flags = .maskCommand
        
        // 发送事件
        keyDownC.post(tap: .cgAnnotatedSessionEventTap)
        usleep(10000)  // 10毫秒延迟
        keyUpC.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    // 添加复制到剪贴板的辅助函数
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
}
