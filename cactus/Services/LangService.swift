//
//  LangService.swift
//  cactus
//
//  Created by 许大伟 on 2025/5/14.
//

import SwiftUI

class LangService {
    static let shared = LangService()
    private init() {}

    // 检测文本是否为中文
    public func isLikelyChinese(_ text: String) -> Bool {
        var containsChinese = false
        for scalar in text.unicodeScalars {
            let value = scalar.value
            // 检查日文平假名 (U+3040...U+309F) 或片假名 (U+30A0...U+30FF)
            if (0x3040...0x30FF).contains(value) {
                return false // 包含日文假名，判定为非中文
            }
            // 检查韩文谚文音节 (U+AC00...U+D7AF)
            if (0xAC00...0xD7AF).contains(value) {
                return false // 包含韩文谚文，判定为非中文
            }
            // 检查 CJK 统一表意文字的主要范围 (U+4E00...U+9FFF)
            // 这个范围包含了中日韩共用的汉字
            if (0x4E00...0x9FFF).contains(value) {
                containsChinese = true // 标记包含汉字字符
            }
            // 可以根据需要添加其他 CJK 范围的检查，但主要范围通常足够
        }
        // 只有在包含了汉字字符，并且没有检测到日文假名或韩文谚文时，才判定为中文
        return containsChinese
    }

    // 通过正则表达式识别文本语言类型，返回对应的语言代码
    public func detectLanguageCode(for text: String) -> String {
        // 日文假名 Unicode 范围
        let hiraganaRange = "\u{3040}"..."\u{309F}"
        let katakanaRange = "\u{30A0}"..."\u{30FF}"
        // 中文汉字 Unicode 范围
        let chineseRange = "\u{4E00}"..."\u{9FFF}"
        // 韩文
        let koreanRegex = "[\\u1100-\\u11FF\\u3130-\\u318F\\uAC00-\\uD7AF]"
        // 英文
        let englishRegex = "[A-Za-z]"
    
        var hiraganaCount = 0
        var katakanaCount = 0
        var chineseCount = 0
    
        for scalar in text.unicodeScalars {
            if hiraganaRange.contains(String(scalar)) {
                hiraganaCount += 1
            } else if katakanaRange.contains(String(scalar)) {
                katakanaCount += 1
            } else if chineseRange.contains(String(scalar)) {
                chineseCount += 1
            }
        }
    
        let total = text.count
        // 如果假名占比大于2%，判为日文
        if total > 0 && Double(hiraganaCount + katakanaCount) / Double(total) > 0.02 {
            return "ja-JP"
        }
        // 如果汉字多且没有假名，判为中文
        if chineseCount > 0 && hiraganaCount == 0 && katakanaCount == 0 {
            return "zh-CN"
        }
        
        if let _ = text.range(of: koreanRegex, options: .regularExpression) {
            return "ko-KR"
        } 

        if let _ = text.range(of: englishRegex, options: .regularExpression) {
            return "en-US"
        }
        return "en-US"
    }
    
    // 获取系统首选语言的本地化名称
    public func getPreferredLanguageName() -> String {
        // 获取首选语言代码，默认为简体中文
        let preferredLanguageCode = Locale.preferredLanguages.first ?? "zh-Hans-CN"
        // 获取语言的本地化名称，默认为 "简体中文"
        let preferredLanguageName = Locale.current.localizedString(forLanguageCode: preferredLanguageCode) ?? "简体中文"
        print("Preferred Language Detected: \(preferredLanguageName) (Code: \(preferredLanguageCode))")
        return preferredLanguageName
    }
}
