//
//  AppDelegate.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/21.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    // 添加窗口属性
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?
    var mainWindow: NSWindow?
    
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
            
            menu.addItem(NSMenuItem(title: "翻译总结", action: #selector(openMain), keyEquivalent: "o"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "偏好设置", action: #selector(openSettings), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "关于", action: #selector(openAbout), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem?.menu = menu
        }
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],  // Add more window controls
                backing: .buffered,
                defer: false
            )

            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.title = "偏好设置"
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.minSize = NSSize(width: 600, height: 400)  // Set minimum size
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openAbout() {
        if aboutWindow == nil {
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 280, height: 160),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            let aboutView = AboutView()
            let hostingController = NSHostingController(rootView: aboutView)
            
            aboutWindow?.contentViewController = hostingController
            aboutWindow?.title = "关于"
            aboutWindow?.center()
            aboutWindow?.isReleasedWhenClosed = false
        }
        
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openMain() {
        if mainWindow == nil {
            mainWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            // 确保使用 Views 目录下的 MainView
            let mainView = MainView()
            let hostingController = NSHostingController(rootView: mainView)
            
            mainWindow?.contentViewController = hostingController
            mainWindow?.title = "翻译总结"
            mainWindow?.center()
            mainWindow?.isReleasedWhenClosed = false
        }
        
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
