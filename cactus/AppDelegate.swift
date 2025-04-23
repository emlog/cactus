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

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?
    var mainWindow: NSWindow?
    private var isMainWindowPinned = false // 跟踪主窗口置顶状态
    private var pinnedWindowOrigin: NSPoint? // 存储置顶时的窗口左下角坐标

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
            
            // 获取当前快捷键
            let (keyEquivalent, modifierMask) = getCurrentShortcutForMenu()
            
            let translateMenuItem = NSMenuItem(
                title: NSLocalizedString("main", comment: "AI助手"),
                action: #selector(openMain),
                keyEquivalent: keyEquivalent
            )
            translateMenuItem.keyEquivalentModifierMask = modifierMask
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

        // 监听置顶状态切换通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(togglePinState(_:)),
            name: NSNotification.Name("TogglePinState"),
            object: nil
        )
    }

    private func initializeWindows() {
        // 初始化主窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable],  // Allow window resizing but disable zoom button
            backing: .buffered,
            defer: false
        )
        // 初始状态不置顶，使用 normal level
        mainWindow?.level = .normal
        mainWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        // mainWindow?.level = .floating // 移除此处的默认浮动设置
        
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow?.contentViewController = hostingController
        mainWindow?.title = ""
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.delegate = self // 设置 mainWindow 的代理为 AppDelegate 实例
        
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
    
    // 偏好设置窗口
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
    
    // 关于窗口
    @objc func openAbout() {
#if DEBUG
        // 仅在调试环境中执行的代码
        clearUserDefaults()
#endif
        
        // 调整窗口位置到当前屏幕的中心
        aboutWindow?.center()
        aboutWindow?.makeKeyAndOrderFront(nil)
        aboutWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // 主窗口
    @objc func openMain() {
        // 1. 先尝试获取剪贴板内容（这会触发模拟复制）
        checkAccessibilityPermissionAndGetClipboard { [weak self] success in
            // 2. 无论成功与否，都激活并显示窗口
            // 使用 DispatchQueue.main.async 确保在主线程执行 UI 操作
            DispatchQueue.main.async {
                guard let self = self else { return }
                // 确保窗口存在
                guard let window = self.mainWindow else { return }

                // 如果窗口已置顶且有存储的位置，则恢复该位置，否则居中
                if self.isMainWindowPinned, let pinnedOrigin = self.pinnedWindowOrigin {
                    window.setFrameOrigin(pinnedOrigin)
                } else {
                    window.center() // 只有在非置顶或首次置顶时才居中
                }

                // 确保窗口在最上层
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                
                // 可以在这里根据 success 的结果决定是否显示提示信息等
                if !success {
                    print("未能成功获取选中文本。")
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
    /*
     你遇到的问题——即使开启了辅助功能权限， CGEvent 模拟复制依然无效——通常 不是 因为缺少苹果的特殊沙盒例外授权（Temporary Exception Entitlement）。
     CGEvent 模拟键盘事件（如 Command+C）的核心依赖是 辅助功能权限 ，而不是沙盒例外授权。沙盒例外授权主要用于突破沙盒对特定资源（如跨应用通信、访问特定文件区域等）的访问限制。只要用户授予了辅助功能权限，你的应用原则上就应该能够通过 CGEvent 发送系统级的键盘事件。
     那么为什么它可能不起作用呢？最常见的原因是 焦点问题 和 时序问题 ：
     1. 焦点丢失 ：这是最可能的原因。在你的 `openMain` 方法中，你首先调用了 NSApp.activate(ignoringOtherApps: true) 来激活你的应用窗口。这会导致你的应用（Cactus）成为当前活动的应用，获得键盘焦点。紧接着，在 `checkAccessibilityPermissionAndGetClipboard` -> `getClipboardContent` 中调用的 `simulateCopy` 发送的 Command+C 事件，实际上是发送给了 你自己的应用 （Cactus），而不是用户之前正在使用的、选中文本的那个应用。自然，如果你的应用当前没有可选中的文本，剪贴板内容就不会改变。
     2. 时序问题 ：虽然你加入了一些延迟 ( DispatchQueue.main.asyncAfter , usleep )，但系统处理焦点切换和事件响应的时间可能不确定。即使焦点理论上应该在其他应用，过早或过晚地发送事件或读取剪贴板都可能导致失败。
     解决方案建议：调整执行顺序：先模拟复制操作， 然后 再激活你的应用窗口并读取剪贴板。
     */
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
    
    // 处理置顶状态切换的方法
    @objc private func togglePinState(_ notification: Notification) {
        guard let shouldPin = notification.object as? Bool else { return }
        self.isMainWindowPinned = shouldPin
        DispatchQueue.main.async { // 确保在主线程更新 UI 相关属性
            if self.isMainWindowPinned {
                self.mainWindow?.level = .floating // 置顶
                // 首次置顶时，记录当前位置
                if self.pinnedWindowOrigin == nil {
                    self.pinnedWindowOrigin = self.mainWindow?.frame.origin
                }
            } else {
                self.mainWindow?.level = .normal // 取消置顶
                self.pinnedWindowOrigin = nil // 取消置顶时清除位置记录
            }
        }
    }

    // 当窗口被pin在一个固定位置的时候，按下快捷键 窗口位置保持不变。
    // 实现 NSWindowDelegate 的 windowDidMove 方法
    func windowDidMove(_ notification: Notification) {
        // 检查移动的窗口是否是 mainWindow 并且当前处于置顶状态
        if let window = notification.object as? NSWindow, window == mainWindow, isMainWindowPinned {
            // 更新存储的置顶位置
            self.pinnedWindowOrigin = window.frame.origin
        }
    }

    // 修改：实现 NSWindowDelegate 方法，当窗口失去焦点时调用
    func windowDidResignKey(_ notification: Notification) {
        // 检查失去焦点的窗口是否是 mainWindow
        if let window = notification.object as? NSWindow, window == mainWindow {
            // 只有在未置顶的情况下才关闭窗口
            if !isMainWindowPinned {
                window.close()
            }
        }
    }
    
    func clearUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}


/// 获取当前设置的快捷键，用于菜单展示
private func getCurrentShortcutForMenu() -> (String, NSEvent.ModifierFlags) {
    if let shortcut = KeyboardShortcuts.getShortcut(for: SettingsModel.aiShortcut) {
        // Manually map KeyboardShortcuts.Shortcut.Key to String
        let keyEquivalent: String
        switch shortcut.key {
        case .a: keyEquivalent = "a"
        case .b: keyEquivalent = "b"
        case .c: keyEquivalent = "c"
        case .d: keyEquivalent = "d"
        case .e: keyEquivalent = "e"
        case .f: keyEquivalent = "f"
        case .g: keyEquivalent = "g"
        case .h: keyEquivalent = "h"
        case .i: keyEquivalent = "i"
        case .j: keyEquivalent = "j"
        case .k: keyEquivalent = "k"
        case .l: keyEquivalent = "l"
        case .m: keyEquivalent = "m"
        case .n: keyEquivalent = "n"
        case .o: keyEquivalent = "o"
        case .p: keyEquivalent = "p"
        case .q: keyEquivalent = "q"
        case .r: keyEquivalent = "r"
        case .s: keyEquivalent = "s"
        case .t: keyEquivalent = "t"
        case .u: keyEquivalent = "u"
        case .v: keyEquivalent = "v"
        case .w: keyEquivalent = "w"
        case .x: keyEquivalent = "x"
        case .y: keyEquivalent = "y"
        case .z: keyEquivalent = "z"
        case .zero: keyEquivalent = "0"
        case .one: keyEquivalent = "1"
        case .two: keyEquivalent = "2"
        case .three: keyEquivalent = "3"
        case .four: keyEquivalent = "4"
        case .five: keyEquivalent = "5"
        case .six: keyEquivalent = "6"
        case .seven: keyEquivalent = "7"
        case .eight: keyEquivalent = "8"
        case .nine: keyEquivalent = "9"
        case .return: keyEquivalent = "\r"
        case .space: keyEquivalent = " "
        case .tab: keyEquivalent = "\t"
        case .delete: keyEquivalent = "\u{8}"
        case .escape: keyEquivalent = "\u{1b}"
        default: keyEquivalent = "" // Add more cases as needed
        }

        var modifierMask: NSEvent.ModifierFlags = []
        if shortcut.modifiers.contains(.command) { modifierMask.insert(.command) }
        if shortcut.modifiers.contains(.option) { modifierMask.insert(.option) }
        if shortcut.modifiers.contains(.shift) { modifierMask.insert(.shift) }
        if shortcut.modifiers.contains(.control) { modifierMask.insert(.control) }
        return (keyEquivalent, modifierMask)
    }
    // Default value (e.g., Option+X)
    return ("x", [.option])
}
