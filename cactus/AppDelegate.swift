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
            
            let translateMenuItem = NSMenuItem(title: "阅读辅助", action: #selector(openMain), keyEquivalent: "j")
            translateMenuItem.image = NSImage(systemSymbolName: "book", accessibilityDescription: nil) // 添加地球图标
            menu.addItem(translateMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "偏好设置", action: #selector(openPreferences), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "关于", action: #selector(openAbout), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
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
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
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
        aboutWindow?.title = "关于"
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
    
    @objc func openPreferences() {
        if settingsWindowController == nil {
            // Use system symbols for toolbar icons with fallback
            let generalIcon = NSImage(systemSymbolName: "gear", accessibilityDescription: "General Settings") ?? NSImage()
            let aiIcon = NSImage(systemSymbolName: "lanyardcard", accessibilityDescription: "Storage Settings") ?? NSImage()
            
            settingsWindowController = SettingsWindowController(
                panes: [
                    Settings.Pane(
                        identifier: Settings.PaneIdentifier.general,
                        title: "通用",
                        toolbarIcon: generalIcon
                    ) {
                        GeneralSettingsPane()
                    },
                    Settings.Pane(
                        identifier: Settings.PaneIdentifier.ai,
                        title: "AI服务",
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
        // 确保窗口在最上层
        mainWindow?.center()
        mainWindow?.makeKeyAndOrderFront(nil)
        mainWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        
        // 使用辅助功能 API 获取选中文本
        guard let selectedText = getSelectedText(), !selectedText.isEmpty else {
            print("No text selected or text is empty.")
            return
        }
                
        // 将选中的文本填充到 MainView 的文本区域
        guard let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> else {
            print("Failed to get hosting controller.")
            return
        }
        
        DispatchQueue.main.async {
            hostingController.rootView.fillText(selectedText)
            
            // 自动翻译逻辑
            hostingController.rootView.isProcessing = true // 设置处理中状态
            let AiService = AiService()
            
            // 在后台线程执行翻译
            DispatchQueue.global(qos: .userInitiated).async {
                let text = "翻译助手，请将下面的内容在简体中文和英文之间进行翻译，注意不要输出任何提示内容：\n\n" + selectedText
                AiService.chat(text: text, completion: {
                    // 处理完成后，在主线程更新UI
                    DispatchQueue.main.async {
                        hostingController.rootView.isProcessing = false // 处理完成，重置状态
                    }
                })
            }
        }
        
        print("Selected Text: \(selectedText)")
    }
    
    // 获取当前选中文本的函数
    func getSelectedText() -> String? {
        // 检查辅助功能权限
        guard AXIsProcessTrusted() else {
            showAccessibilityPermissionAlert()
            return nil
        }
        
        // 检查 Apple Events 权限
        if !hasAppleEventsPermission() {
            showAppleEventsPermissionAlert()
            return nil
        }
        
        // 保存当前剪贴板内容
        let pasteboard = NSPasteboard.general
        let oldPasteboardItems = pasteboard.pasteboardItems
        
        var selectedText: String?
        
        // 使用 AppleScript 模拟复制操作
        var error: NSDictionary?
        let script = """
        tell application "System Events"
            keystroke "c" using {command down}
            delay 0.1
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            
            if error != nil {
                print("Error executing AppleScript: \(String(describing: error))")
                // 如果是权限错误，显示权限提示
                if let errorNumber = error?["NSAppleScriptErrorNumber"] as? Int, 
                   errorNumber == -1743 {
                    showAppleEventsPermissionAlert()
                }
                
                // 尝试备用方法获取文本
                selectedText = getSelectedTextFallback()
            } else {
                // 从剪贴板获取文本
                if let clipboardString = pasteboard.string(forType: .string) {
                    selectedText = clipboardString
                }
            }
        }
        
        // 恢复原始剪贴板内容
        if let oldItems = oldPasteboardItems, !oldItems.isEmpty {
            pasteboard.clearContents()
            for item in oldItems {
                for type in item.types {
                    if let data = item.data(forType: type) {
                        pasteboard.setData(data, forType: type)
                    }
                }
            }
        }
        
        return selectedText
    }
    
    // 备用方法：尝试通过其他方式获取选中文本
    private func getSelectedTextFallback() -> String? {
        var error: NSDictionary?
        let script = """
        set selectedText to ""
        
        tell application "System Events"
            set frontApp to first application process whose frontmost is true
            set frontAppName to name of frontApp
        end tell
        
        if frontAppName is "Safari" then
            tell application "Safari"
                set selectedText to (do JavaScript "window.getSelection().toString();" in document 1)
            end tell
        else if frontAppName is "Google Chrome" then
            tell application "Google Chrome"
                set selectedText to (execute front window's active tab javascript "window.getSelection().toString();")
            end tell
        else
            -- 尝试通过剪贴板获取
            set the clipboard to ""
            tell application "System Events" to keystroke "c" using command down
            delay 0.1
            set selectedText to the clipboard
        end if
        
        return selectedText
        """
        
        if let appleScript = NSAppleScript(source: script) {
            let output = appleScript.executeAndReturnError(&error)
            if error == nil {
                return output.stringValue
            } else {
                print("Error executing fallback AppleScript: \(String(describing: error))")
            }
        }
        return nil
    }

    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "请在系统偏好设置中启用辅助功能权限，以便应用程序能够访问选中文本。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统偏好设置")
        alert.addButton(withTitle: "取消")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // 打开系统偏好设置中的辅助功能设置
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func showAppleEventsPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要自动化权限"
        alert.informativeText = "请在系统偏好设置中允许此应用控制系统事件，以便能够获取选中的文本。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统偏好设置")
        alert.addButton(withTitle: "取消")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // 打开系统偏好设置中的自动化设置
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func hasAppleEventsPermission() -> Bool {
        _ = "com.apple.systemevents"
        
        // 使用 AppleScript 来检查权限
        let script = """
        tell application "System Events"
            return name of first application process
        end tell
        """
        
        var errorDict: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        let _ = appleScript?.executeAndReturnError(&errorDict)
        
        // 如果有错误，并且错误代码是 -1743，则表示没有权限
        if let error = errorDict, 
           let errorNumber = error["NSAppleScriptErrorNumber"] as? Int,
           errorNumber == -1743 {
            return false
        }
        
        return errorDict == nil
    }
    
    // 显示自动化授权引导弹窗
    func showAutomationPermissionAlert() -> Bool {
        // 先尝试触发一次自动化权限请求，这样应用会出现在系统偏好设置的列表中
        triggerAutomationRequest()
        
        let alert = NSAlert()
        alert.messageText = "需要自动化权限"
        alert.informativeText = "Cactus 需要控制系统事件的权限才能获取选中的文本。\n\n请按照以下步骤操作：\n1. 点击打开系统设置\n2. 在隐私与安全性中找到自动化\n3. 勾选 Cactus 旁边的系统事件选项"
        alert.alertStyle = .warning
        
        // 添加自定义图标
        if let appIcon = NSImage(named: "AppIcon") {
            alert.icon = appIcon
        }
        
        // 添加按钮
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "取消")
        
        // 显示弹窗并处理结果
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // macOS 14 及以上版本的系统设置路径
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                NSWorkspace.shared.open(url)
            }
            return true
        }
        
        return false
    }
    
    // 主动触发自动化权限请求，使应用出现在系统偏好设置的列表中
    private func triggerAutomationRequest() {
        let script = """
        tell application "System Events"
            try
                get name of first application process
            end try
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var errorDict: NSDictionary?
        appleScript?.executeAndReturnError(&errorDict)
        
        // 如果是第一次运行，这里会触发系统的权限请求对话框
        // 即使用户拒绝，应用也会被添加到系统偏好设置的自动化列表中
    }
}
