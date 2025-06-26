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
            return "en"
        }
        
        // 检查日文：假名字符超过一半
        let japaneseCount = hiraganaCount + katakanaCount
        if Double(japaneseCount) > halfThreshold {
            return "ja"
        }
        
        // 检查中文：汉字字符超过一半且没有假名
        if Double(chineseCount) > halfThreshold && hiraganaCount == 0 && katakanaCount == 0 {
            return "zh-Hans"
        }
        
        // 检查韩文：韩文字符超过一半
        if Double(koreanCount) > halfThreshold {
            return "ko"
        }
        
        // 检查英文：英文字符超过一半
        if Double(englishCount) > halfThreshold {
            return "en"
        }
        
        // 如果没有任何语言的字符超过一半，返回默认语言
        return "en"
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
    
    public func getSystemLanguage() -> String {
        let systemLanguage = Locale.preferredLanguages.first ?? "en"
        
        switch systemLanguage {
        case _ where systemLanguage.hasPrefix("zh-Hans"),
            _ where systemLanguage.hasPrefix("zh-CN"):
            return "zh-Hans"
            
        case _ where systemLanguage.hasPrefix("zh-Hant"),
            _ where systemLanguage.hasPrefix("zh-TW"),
            _ where systemLanguage.hasPrefix("zh-HK"):
            return "zh-Hant"
            
        case _ where systemLanguage.hasPrefix("ja"):
            return "ja"
            
        case _ where systemLanguage.hasPrefix("ko"):
            return "ko"
            
        default:
            return "en"
        }
    }
    
    // 判断文本是否为系统首选语言,只支持 zh-Hans, zh-Hant, ja, ko, en
    public func isTextInPreferredLanguage(_ text: String) -> Bool {
        let preferredLanguage = SettingsModel.shared.preferredLanguage
        let textLang = detectLanguageCode(for: text)
        let supported = ["zh-Hans", "zh-Hant", "ja", "ko", "en"]
        if supported.contains(preferredLanguage) {
            return preferredLanguage == textLang
        }
        return false
    }
    
    // 将语言代码转换为AVSpeechSynthesisVoice的languageCode
    public func convertToSpeechLanguageCode(_ languageCode: String) -> String {
        switch languageCode {
        case "zh-Hans":
            return "zh-CN"
        case "zh-Hant":
            return "zh-TW"
        case "ja":
            return "ja-JP"
        case "ko":
            return "ko-KR"
        case "en":
            return "en-US"
        default:
            return "en-US"
        }
    }
}
