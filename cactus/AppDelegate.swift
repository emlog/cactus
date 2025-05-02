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
    private var pinButton: NSButton? // 新增：持有 pin 按钮的引用

    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
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
    }
    
    private func initializeWindows() {
        // 初始化主窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            // styleMask: [.titled, .closable, .resizable], // 保持不变
            // 新增 .fullSizeContentView 使内容延伸到标题栏下方
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        // 使标题栏透明并隐藏标题文本
        mainWindow?.titlebarAppearsTransparent = true
        mainWindow?.titleVisibility = .hidden
        // 设置窗口始终置顶 - 保持不变
        mainWindow?.level = .floating
        mainWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary]
        mainWindow?.level = NSWindow.Level.statusBar

        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow?.contentViewController = hostingController
        // mainWindow?.title = "" // Title is now hidden
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.delegate = self

        // 动态调整窗口高度 - 保持不变
        let contentSize = hostingController.view.intrinsicContentSize
        mainWindow?.setContentSize(contentSize)

        // 添加通知监听器来响应文本高度变化 - 保持不变
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustWindowSize),
            name: NSNotification.Name("AdjustWindowSize"),
            object: nil
        )

        // --- 新增：添加 Pin 按钮到标题栏 ---
        let titlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        titlebarAccessoryViewController.layoutAttribute = .trailing // 放在右侧

        pinButton = NSButton()
        pinButton?.image = NSImage(systemSymbolName: "pin", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
        pinButton?.bezelStyle = .texturedRounded // 或者 .regularSquare, .shadowlessSquare
        pinButton?.isBordered = false // 通常标题栏按钮没有边框
        pinButton?.imageScaling = .scaleProportionallyDown // 确保图标大小合适
        pinButton?.target = self
        pinButton?.action = #selector(pinButtonTapped)
        pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")
        pinButton?.sendAction(on: .leftMouseDown) // 确保单击触发

        // 设置按钮大小，根据需要调整
        pinButton?.frame = NSRect(x: 0, y: 0, width: 28, height: 22) // 调整大小以适应标题栏

        titlebarAccessoryViewController.view = pinButton! // 将按钮设置为视图控制器的视图
        mainWindow?.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        // --- 结束新增 ---


        // 初始化关于窗口 - 保持不变
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
            // 2. 仅在成功获取剪贴板内容 (success == true) 时，激活并显示窗口
            // 使用 DispatchQueue.main.async 确保在主线程执行 UI 操作
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success {
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
                } else {
                    // 如果 success 为 false (权限被拒绝且点了取消，或获取剪贴板失败)
                    // 可以在这里根据需要处理，例如打印日志或显示不同的提示
                    // 当前逻辑下，如果用户点了“打开设置”，此回调根本不会执行
                    // 如果用户点了“取消”，或者权限已允许但获取剪贴板失败，会执行到这里
                    print("未能成功获取选中文本或用户取消了操作。")
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
            // 如果有权限，尝试获取剪贴板内容
            // 无论 getClipboardContent 内部是成功(true)还是失败(false)获取内容
            // 只要权限是开启的，我们就调用原始的 completion(true)，
            // 以便 openMain 函数总是能显示窗口。
            getClipboardContent { _ /* contentRetrievedSuccess - 我们忽略这个内部结果 */ in
                // 因为辅助权限已开启，所以调用 completion(true) 来触发主窗口显示
                completion(true)
            }
        } else {
            // 显示权限提示
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("accessibility_permission_title", comment: "需要辅助功能权限")
            alert.informativeText = NSLocalizedString("accessibility_permission_message", comment: "请在系统偏好设置中启用辅助功能权限")
            alert.alertStyle = .warning
            alert.addButton(withTitle: NSLocalizedString("open_settings", comment: "打开设置"))
            alert.addButton(withTitle: NSLocalizedString("cancel", comment: "取消"))
            
            // 在主线程显示 Alert
            DispatchQueue.main.async {
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    // 打开辅助功能设置
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    // 用户点击了“打开设置”，此时不调用 completion，避免触发 openMain 中的窗口显示逻辑
                } else {
                    // 用户点击了“取消”或其他方式关闭了弹窗
                    completion(false) // 明确告知操作未成功（因为权限问题），且用户未去设置
                }
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
    
    // Pin 按钮的 Action 方法 
    @objc private func pinButtonTapped() {
        isMainWindowPinned.toggle()
        updatePinState()
    }

    // 更新 Pin 状态和按钮外观的辅助方法
    private func updatePinState() {
        guard let window = mainWindow else { return }

        if isMainWindowPinned {
            // 钉住窗口
            window.level = .floating // 确保是浮动级别
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary, .ignoresCycle] // 添加 ignoresCycle 防止被 Command+` 切换掉
            // 存储当前位置
            pinnedWindowOrigin = window.frame.origin

            // 更新按钮外观
            pinButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: NSLocalizedString("help_unpin", comment: "取消置顶"))
            pinButton?.contentTintColor = .red // 设置图标颜色为红色
            pinButton?.toolTip = NSLocalizedString("help_unpin", comment: "取消置顶")

        } else {
            // 取消钉住
            window.level = .normal // 恢复正常级别
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary] // 移除 ignoresCycle
            // 清除存储的位置
            pinnedWindowOrigin = nil

            // 更新按钮外观
            pinButton?.image = NSImage(systemSymbolName: "pin", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
            pinButton?.contentTintColor = nil // 恢复默认颜色
            pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")

            // 如果窗口当前不是 key window，则关闭它
            if !window.isKeyWindow {
                 window.close()
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
    
    // 获取当前设置的快捷键，用于菜单展示
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
}
