//
//  ClipboardManager.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/22.
//

import AppKit

class ClipboardManager {
    static func getSelectedText() -> String {
        // 示例：从剪贴板获取文本
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string) ?? ""
        // 实际应用中可优化为直接获取选中文本
    }
}
