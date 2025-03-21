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
        // 使用逗号 , 是 Swift 中处理可选绑定和多个条件的惯用方式。它允许在一个 if 语句中同时进行可选绑定和条件检查，而 && 不能用于可选绑定的场景。
        // 当你需要同时检查多个条件时，使用逗号可以使代码更清晰，并且可以避免嵌套的 if 语句。
        if let selectedText = getSelectedText(), !selectedText.isEmpty {
            print("Selected Text2: \(selectedText)")
            
            // 将选中的文本填充到 MainView 的文本区域
            if let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> {
                print("Selected Text3: \(selectedText)")
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
            }
            print("Selected Text4: \(selectedText)")
        }
    }
    
    // 获取当前选中文本的函数
    func getSelectedText() -> String? {
        print("Fetching selected text...")
        
        // 检查辅助功能权限
        if !AXIsProcessTrusted() {
            print("Accessibility permissions are not granted. Please enable them in System Settings > Security & Privacy > Accessibility.")
            return nil
        }
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let focusResult = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard focusResult == .success, let element = focusedElement else {
            print("Failed to get focused element, error: \(focusResult)")
            return nil
        }
        
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        guard textResult == .success, let text = selectedText as? String else {
            print("Failed to get selected text, error: \(textResult)")
            return nil
        }
        
        print("Selected Text: \(text)")
        return text
    }
}
