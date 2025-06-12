import AppKit
import SwiftUI
import KeyboardShortcuts
import Settings
import Foundation
import ApplicationServices	

class WindowManager: NSObject, NSWindowDelegate {
    var settingsWindow: NSWindow?
    var mainWindow: NSWindow?
    var vocabularyWindow: NSWindow?
    var favoriteWindow: NSWindow?
    private var isMainWindowPinned = false
    private var pinnedWindowOrigin: NSPoint?
    private var pinButton: NSButton?
    private var settingsWindowController: SettingsWindowController?
    
    func initializeWindows() {
        initializeMainWindow()
        initializeVocabularyWindow()
        initializeFavoriteWindow()
    }
    
    private func initializeMainWindow() {
        // 初始化主窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // 使标题栏透明并隐藏标题文本
        mainWindow?.titlebarAppearsTransparent = true
        mainWindow?.titleVisibility = .hidden
        
        // 设置窗口始终置顶
        mainWindow?.level = .floating
        mainWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary]
        mainWindow?.level = NSWindow.Level.statusBar
        
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow?.contentViewController = hostingController
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.delegate = self
        
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
        
        setupPinButton()
    }
    
    private func initializeVocabularyWindow() {
        // 初始化生词本窗口
        vocabularyWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let vocabularyView = VocabularyView()
        let vocabularyHostingController = NSHostingController(rootView: vocabularyView)
        vocabularyWindow?.contentViewController = vocabularyHostingController
        vocabularyWindow?.title = NSLocalizedString("vocabulary", comment: "生词本")
        vocabularyWindow?.isReleasedWhenClosed = false
        vocabularyWindow?.collectionBehavior = [.fullScreenPrimary]
    }
    
    private func initializeFavoriteWindow() {
        // 初始化收藏夹窗口
        favoriteWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let favoriteView = FavoriteView()
        let favoriteHostingController = NSHostingController(rootView: favoriteView)
        favoriteWindow?.contentViewController = favoriteHostingController
        favoriteWindow?.title = NSLocalizedString("favorites", comment: "收藏夹")
        favoriteWindow?.isReleasedWhenClosed = false
        favoriteWindow?.collectionBehavior = [.fullScreenPrimary]
    }
    
    private func setupPinButton() {
        // 添加 Pin 按钮到标题栏
        let titlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        titlebarAccessoryViewController.layoutAttribute = .trailing
        
        pinButton = NSButton()
        pinButton?.image = NSImage(systemSymbolName: "pin", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
        pinButton?.bezelStyle = .texturedRounded
        pinButton?.isBordered = false
        pinButton?.imageScaling = .scaleProportionallyDown
        pinButton?.target = self
        pinButton?.action = #selector(pinButtonTapped)
        pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")
        pinButton?.sendAction(on: .leftMouseDown)
        pinButton?.frame = NSRect(x: 0, y: 0, width: 30, height: 24)
        
        titlebarAccessoryViewController.view = pinButton!
        mainWindow?.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
    }
    
    // MARK: - Window Management
    @objc private func adjustWindowSize() {
        guard let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> else {
            return
        }
        
        let contentSize = hostingController.sizeThatFits(in: NSSize(width: mainWindow?.frame.width ?? 500, height: CGFloat.greatestFiniteMagnitude))
        
        if let window = mainWindow, window.isVisible {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                window.animator().setContentSize(contentSize)
            }
        } else {
            mainWindow?.setContentSize(contentSize)
        }
    }
    
    // MARK: - Window Opening Methods
    func openMain(action: ActionType = .translate) {
        checkAccessibilityPermissionAndGetClipboard(action: action) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success {
                    guard let window = self.mainWindow else { return }
                    
                    if self.isMainWindowPinned, let pinnedOrigin = self.pinnedWindowOrigin {
                        window.setFrameOrigin(pinnedOrigin)
                    } else {
                        window.center()
                    }
                    
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                    NSApp.activate(ignoringOtherApps: true)
                } else {
                    print("未能成功获取选中文本或用户取消了操作。")
                }
            }
        }
    }
    
    func openVocabulary() {
        let wordCount = VocabularyManager.shared.wordEntries.count
        let isPremium = PurchaseManager.shared.isPremiumUser
        
        if wordCount > 20 && !isPremium {
            openPreferences()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.settingsWindowController?.show(pane: .premium)
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            vocabularyWindow?.center()
            vocabularyWindow?.makeKeyAndOrderFront(nil)
            vocabularyWindow?.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func openFavorites() {
        let favCount = FavoriteManager.shared.favoriteEntries.count
        let isPremium = PurchaseManager.shared.isPremiumUser
        
        if favCount > 20 && !isPremium {
            openPreferences()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.settingsWindowController?.show(pane: .premium)
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            favoriteWindow?.center()
            favoriteWindow?.makeKeyAndOrderFront(nil)
            favoriteWindow?.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func openPreferences() {
        if let existingController = settingsWindowController {
            existingController.window?.close()
            settingsWindowController = nil
        }
        
        createSettingsWindowController()
        
        if let window = settingsWindowController?.window {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        settingsWindowController?.show()
        settingsWindowController?.window?.orderFrontRegardless()
    }
    
    private func createSettingsWindowController() {
        let generalIcon = NSImage(systemSymbolName: "gear", accessibilityDescription: "General Settings") ?? NSImage()
        let aiIcon = NSImage(systemSymbolName: "lanyardcard", accessibilityDescription: "Storage Settings") ?? NSImage()
        let premiumIcon = NSImage(systemSymbolName: "checkmark.seal", accessibilityDescription: "Premium Settings") ?? NSImage()
        let aboutIcon = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About Settings") ?? NSImage()
        
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
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.premium,
                    title: NSLocalizedString("premium", comment: "高级版"),
                    toolbarIcon: premiumIcon
                ) {
                    PremiumPane()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.about,
                    title: NSLocalizedString("about", comment: "关于"),
                    toolbarIcon: aboutIcon
                ) {
                    AboutPane()
                }
            ]
        )
    }
    
    @objc private func settingsWindowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.willCloseNotification,
            object: notification.object
        )
        settingsWindowController = nil
    }
    
    // MARK: - Accessibility and Clipboard Methods
    func checkAccessibilityPermissionAndGetClipboard(action: ActionType = .nothing, completion: @escaping (Bool) -> Void) {
        // 检查辅助功能权限
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if accessEnabled {
            // 如果有权限，尝试获取剪贴板内容
            getClipboardContent(action: action) { _ in
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
            
            DispatchQueue.main.async {
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func getClipboardContent(action: ActionType, completion: @escaping (Bool) -> Void) {
        // 保存当前剪贴板内容
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
        
        // 使用模拟复制功能获取选中文本
        simulateCopy()
        
        // 给系统一点时间处理复制操作，然后读取剪贴板
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let mainViewController = self.mainWindow?.contentViewController as? NSHostingController<MainView> else {
                if let originalContent = originalContent {
                    self.copyToClipBoard(textToCopy: originalContent)
                }
                completion(false)
                return
            }
            
            let mainView = mainViewController.rootView
            let newContent = pasteboard.string(forType: .string)
            var success = false
            
            // 如果有新内容，且与原内容不同
            if let newContent = newContent, !newContent.isEmpty, newContent != originalContent {
                mainView.fillText(newContent)
                
                // 添加延迟以确保文本已填充
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 根据 action 调用不同的方法
                    switch action {
                    case .translate:
                        mainView.translateText()
                    case .summarize:
                        mainView.summaryText()
                    case .dictionary:
                        mainView.dictionaryText()
                    case .nothing:
                        mainView.noactionText()
                    }
                }
                success = true
            }
            
            // 恢复原始剪贴板内容
            if let originalContent = originalContent {
                self.copyToClipBoard(textToCopy: originalContent)
            }
            
            completion(success)
        }
    }
    
    private func simulateCopy() {
        // 模拟 Command+C 复制操作
        let source = CGEventSource(stateID: .combinedSessionState)
        
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
    
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    // MARK: - Pin Functionality
    @objc private func pinButtonTapped() {
        isMainWindowPinned.toggle()
        updatePinState()
    }
    
    private func updatePinState() {
        guard let window = mainWindow else { return }
        
        if isMainWindowPinned {
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary, .ignoresCycle]
            pinnedWindowOrigin = window.frame.origin
            
            pinButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: NSLocalizedString("help_unpin", comment: "取消置顶"))
            pinButton?.contentTintColor = .red
            pinButton?.toolTip = NSLocalizedString("help_unpin", comment: "取消置顶")
        } else {
            window.level = .normal
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary]
            pinnedWindowOrigin = nil
            
            pinButton?.image = NSImage(systemSymbolName: "pin", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
            pinButton?.contentTintColor = nil
            pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")
            
            if !window.isKeyWindow {
                window.close()
            }
        }
    }
    
    // MARK: - NSWindowDelegate
    func windowDidMove(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow, isMainWindowPinned {
            self.pinnedWindowOrigin = window.frame.origin
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            if !isMainWindowPinned {
                window.close()
            }
        }
    }
}
