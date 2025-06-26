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
        switch dominantLanguage {
        case .simplifiedChinese:
            return "zh-Hans"
        case .traditionalChinese:
            return "zh-Hant"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .english:
            return "en"
        case .french:
            return "fr"
        case .spanish:
            return "es"
        case .german:
            return "de"
        default:
            // 对于其他语言，检查原始值是否是我们支持的语言
            let rawValue = dominantLanguage.rawValue
            switch rawValue {
            case "zh-Hans":
                return "zh-Hans"
            case "zh-Hant":
                return "zh-Hant"
            case "ja":
                return "ja"
            case "ko":
                return "ko"
            case "en":
                return "en"
            case "fr":
                return "fr"
            case "es":
                return "es"
            case "de":
                return "de"
            default:
                return "en"  // 不支持的语言返回英语
            }
        }
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
