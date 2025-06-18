//
//  Settings.PaneIdentifier+Panes.swift
//  cactus
//
//  Created by 许大伟 on 2025/3/3.
//

import Settings

extension Settings.PaneIdentifier {
    static let general = Self("general")
    static let ai = Self("ai")
    static let premium = Self("premium")
    static let about = Self("about")
    
    // 数据管理相关标识符
    static let vocabulary = Self("vocabulary")
    static let favorites = Self("favorites")
    static let history = Self("history")
}


