//
//  StatusBarController.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/22.
//

import AppKit
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "文本工具")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
    }
    
    @objc func openSettings() {
        // 打开设置窗口
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.center()
        settingsWindow.title = "设置"
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow.makeKeyAndOrderFront(nil)
    }
}
