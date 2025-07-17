//
//  LangService.swift
//  cactus
//
//  Created by 许大伟 on 2025/5/14.
//

import SwiftUI
import NaturalLanguage

class LangService {
    static let shared = LangService()
    private init() {}
    
    // 使用NaturalLanguage框架准确识别文本语言类型，返回对应的语言代码
    public func detectLanguageCode(for text: String) -> String {
        // 如果文本为空，返回默认语言
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "en"
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            return "en"  // 如果无法识别，返回英语
        }
        
        // 将NLLanguage转换为我们需要的语言代码格式
        var detectedLanguage: String
        switch dominantLanguage {
        case .simplifiedChinese:
            detectedLanguage = "zh-Hans"
        case .traditionalChinese:
            detectedLanguage = "zh-Hant"
        case .japanese:
            detectedLanguage = "ja"
        case .korean:
            detectedLanguage = "ko"
        case .english:
            detectedLanguage = "en"
        case .french:
            detectedLanguage = "fr"
        case .spanish:
            detectedLanguage = "es"
        case .german:
            detectedLanguage = "de"
        case .portuguese:
            detectedLanguage = "pt-PT"
        case .indonesian:
            detectedLanguage = "id"
        default:
            // 对于其他语言，检查原始值是否是我们支持的语言
            let rawValue = dominantLanguage.rawValue
            switch rawValue {
            case "zh-Hans":
                detectedLanguage = "zh-Hans"
            case "zh-Hant":
                detectedLanguage = "zh-Hant"
            case "ja":
                detectedLanguage = "ja"
            case "ko":
                detectedLanguage = "ko"
            case "en":
                detectedLanguage = "en"
            case "fr":
                detectedLanguage = "fr"
            case "es":
                detectedLanguage = "es"
            case "de":
                detectedLanguage = "de"
            case "pt", "pt-PT", "pt-BR":
                detectedLanguage = "pt-PT"
            case "id":
                detectedLanguage = "id"
            default:
                detectedLanguage = "en"  // 不支持的语言返回英语
            }
        }
        
        // 如果识别为日语，使用正则表达式方法进行重复验证
        if detectedLanguage == "ja" {
            let regexResult = detectLanguageCodeByRegx(for: text)
            // 如果正则表达式验证结果也是日语，则确认为日语
            // 否则返回正则表达式的验证结果
            return regexResult == "ja" ? "ja" : regexResult
        }
        
        return detectedLanguage
    }
    
    // 通过正则表达式识别文本语言类型，返回对应的语言代码，主要针对中文、日文、韩文
    public func detectLanguageCodeByRegx(for text: String) -> String {
        // 日文假名 Unicode 范围
        let hiraganaRange = "\u{3040}"..."\u{309F}"
        let katakanaRange = "\u{30A0}"..."\u{30FF}"
        // 中文汉字 Unicode 范围
        let chineseRange = "\u{4E00}"..."\u{9FFF}"
        // 韩文
        let koreanRegex = "[\\u1100-\\u11FF\\u3130-\\u318F\\uAC00-\\uD7AF]"
        
        var hiraganaCount = 0
        var katakanaCount = 0
        var chineseCount = 0
        var koreanCount = 0
        
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
            }
        }
        
        let totalCharacters = text.count
        let halfThreshold = Double(totalCharacters) / 2.0
        
        // 如果文本为空，返回默认语言
        if totalCharacters == 0 {
            return "zh-Hans"
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
        
        // 如果没有任何语言的字符超过一半，返回默认语言
        return "zh-Hans"
    }
    
    // 判断文本是句子还是单词
    public func isSentence(_ text: String) -> Bool {
        // 去除首尾空格
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else { return false }
        
        // 定义所有句子相关的标点符号（包括分隔符和终止符）
        let sentencePunctuation: Set<Character> = [
            ".", "?", "!", "。", "？", "！", "…",  // 终止符
            ",", "，", ";", "；", ":", "："        // 分隔符
        ]
        
        // 检查是否包含句子标点符号
        let hasPunctuation = trimmedText.contains { sentencePunctuation.contains($0) }
        
        // 检查是否包含空格（多个单词）
        let hasMultipleWords = trimmedText.firstMatch(of: /[\s]+/) != nil
        
        // 句子的判断条件：包含标点符号或包含多个单词
        return hasPunctuation || hasMultipleWords
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
    
    // 获取系统首选语言
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
        case
            _ where systemLanguage.hasPrefix("fr"),
            _ where systemLanguage.hasPrefix("fr-CA"):
            return "fr"
        case _ where systemLanguage.hasPrefix("de"):
            return "de"
        case
            _ where systemLanguage.hasPrefix("es"),
            _ where systemLanguage.hasPrefix("es-US"),
            _ where systemLanguage.hasPrefix("es-419"):
            return "es"
        case _ where systemLanguage.hasPrefix("id"):
            return "id"
        case _ where systemLanguage.hasPrefix("pt-BR"),
            _ where systemLanguage.hasPrefix("pt-PT"),
            _ where systemLanguage.hasPrefix("pt"):
            return "pt-PT"
        default:
            return "en"
        }
    }
    
    // 判断文本是否为系统首选语言,支持 zh-Hans, zh-Hant, ja, ko, en, fr, de, es
    public func isTextInPreferredLanguage(_ text: String) -> Bool {
        let preferredLanguage = PreferencesModel.shared.preferredLanguage
        let textLang = detectLanguageCode(for: text)
        
        print("prefer lang: \(preferredLanguage)， textLang:  \(textLang)\n")
        
        let supported = ["zh-Hans", "zh-Hant", "ja", "ko", "en", "fr", "de", "es"]
        if supported.contains(preferredLanguage) {
            // 应对某些简体中文词语会被识别为繁体中文，无法精确
            // 如果首选语言是繁体中文，则简体中文和繁体中文都认为是相等的
            // 如果首选语言是简体中文，则简体中文和繁体中文都认为是相等的
            if preferredLanguage == "zh-Hans" || preferredLanguage == "zh-Hant" {
                return textLang == "zh-Hans" || textLang == "zh-Hant"
            } else {
                return preferredLanguage == textLang // 其他语言保持原有的精确匹配
            }
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
        case "fr":
            return "fr-FR"
        case "de":
            return "de-DE"
        case "es":
            return "es-ES"
        case "pt-PT":
            return "pt-PT"
        case "id":
            return "id-ID"
        default:
            return "en-US"
        }
    }
    
    // 检查输入的单词是否属于英语、法语、西班牙语、德语中的一种
    // 单词查询考虑到音标、词根等 只适用于英语等语言
    public func isWordInSupportedLanguages(_ word: String) -> Bool {
        // 去除首尾空格
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果文本为空，返回false
        if trimmedWord.isEmpty {
            return false
        }
        
        // 检测单词的语言
        let detectedLanguage = detectLanguageCode(for: trimmedWord)
        
        // 支持的语言列表：英语、法语、西班牙语、德语
        let supportedLanguages = ["en", "fr", "es", "de"]
        
        // 判断检测到的语言是否在支持的语言列表中
        return supportedLanguages.contains(detectedLanguage)
    }
}
