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
        var koreanCount = 0
        var englishCount = 0
        
        // 统计各种语言字符的数量
        for scalar in text.unicodeScalars {
            let scalarString = String(scalar)
            
            if hiraganaRange.contains(scalarString) {
                hiraganaCount += 1
            } else if katakanaRange.contains(scalarString) {
                katakanaCount += 1
            } else if chineseRange.contains(scalarString) {
                chineseCount += 1
            } else if scalarString.range(of: koreanRegex, options: .regularExpression) != nil {
                koreanCount += 1
            } else if scalarString.range(of: englishRegex, options: .regularExpression) != nil {
                englishCount += 1
            }
        }
        
        let totalCharacters = text.count
        let halfThreshold = Double(totalCharacters) / 2.0
        
        // 如果文本为空，返回默认语言
        if totalCharacters == 0 {
            return "en-US"
        }
        
        // 检查日文：假名字符超过一半
        let japaneseCount = hiraganaCount + katakanaCount
        if Double(japaneseCount) > halfThreshold {
            return "ja-JP"
        }
        
        // 检查中文：汉字字符超过一半且没有假名
        if Double(chineseCount) > halfThreshold && hiraganaCount == 0 && katakanaCount == 0 {
            return "zh-CN"
        }
        
        // 检查韩文：韩文字符超过一半
        if Double(koreanCount) > halfThreshold {
            return "ko-KR"
        }
        
        // 检查英文：英文字符超过一半
        if Double(englishCount) > halfThreshold {
            return "en-US"
        }
        
        // 如果没有任何语言的字符超过一半，返回默认语言
        return "en-US"
    }
    
    // 判断文本是句子还是单词
    public func isSentence(_ text: String) -> Bool {
        // 去除首尾空格
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果文本为空，返回false
        if trimmedText.isEmpty {
            return false
        }
        
        // 检查是否包含句子终止符号（句号、问号、感叹号等）
        let sentenceEndingPunctuation = [".", "?", "!", "。", "？", "！", "…", "、"]
        let containsEndingPunctuation = sentenceEndingPunctuation.contains { trimmedText.contains($0) }
        
        // 检查是否包含空格（多个单词的特征）
        let containsSpace = trimmedText.contains(" ")
        
        // 检查长度（通常句子比单个单词长）
        let isLongEnough = trimmedText.count > 3
        
        // 综合判断：
        // 1. 如果包含句子终止符号，很可能是句子
        // 2. 如果包含空格（多个单词），很可能是句子
        // 3. 如果文本足够长，更可能是句子而不是单词
        return containsEndingPunctuation || (containsSpace && isLongEnough)
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
    
    // Added new function to get system language code
    public func getSystemLanguageCode() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en-US"
        if preferredLanguage.starts(with: "zh-Hans") {
            return "zh-CN"
        } else if preferredLanguage.starts(with: "zh-Hant") {
            return "zh-TW"
        } else if preferredLanguage.starts(with: "ja") {
            return "ja-JP"
        } else if preferredLanguage.starts(with: "ko") {
            return "ko-KR"
        } else if preferredLanguage.starts(with: "en") {
            return "en-US"
        } else {
            return "en-US" // Default to English for other languages
        }
    }
    
    // 判断文本是否为系统首选语言（支持中、日、韩、繁体中文）
    public func isTextInPreferredLanguage(_ text: String) -> Bool {
        let systemLang = getSystemLanguageCode()
        let textLang = detectLanguageCode(for: text)
        // 只支持 zh-CN, zh-TW, ja-JP, ko-KR
        let supported = ["zh-CN", "zh-TW", "ja-JP", "ko-KR"]
        if supported.contains(systemLang) {
            return systemLang == textLang
        }
        return false
    }
}
