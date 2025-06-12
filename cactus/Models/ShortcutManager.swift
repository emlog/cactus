//
//  ShortcutManager.swift
//  cactus
//
//  Created by AI Assistant
//

import AppKit
import KeyboardShortcuts
import Foundation

enum ActionType {
    case nothing
    case translate
    case summarize
    case dictionary
}

class ShortcutManager {
    private weak var windowManager: WindowManager?
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    
    // 设置全局快捷键
    func setupGlobalShortcuts() {
        // 注册主窗口快捷键
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutMain) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .nothing)
            }
        }
        
        // 注册翻译快捷键
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcut) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .translate)
            }
        }
        
        // 注册总结快捷键
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutSummary) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .summarize)
            }
        }
        
        // 注册字典快捷键
        KeyboardShortcuts.onKeyDown(for: SettingsModel.aiShortcutDictionary) { [weak self] in
            DispatchQueue.main.async {
                self?.openMain(action: .dictionary)
            }
        }
    }

    // 主窗口 - 保留此方法因为快捷键管理器需要使用
    private func openMain(action: ActionType = .translate) {
        windowManager?.openMain(action: action)
    }
}
