import Foundation
import KeyboardShortcuts

struct ProviderSettings: Codable { // Conform to Codable
    var baseURL: String
    var apiKey: String
    var model: String
}

class SettingsModel: ObservableObject {
    static let presetProviders: [String] = ["ppinfra","OpenRouter"]
    static let providersName: [String: String] = [
        "ppinfra": NSLocalizedString("ppinfra", comment: "派欧算力云 - 免费"),
        "OpenRouter": NSLocalizedString("openRouter", comment: "OpenRouter - 免费"),
        "siliconflow": NSLocalizedString("siliconflow", comment: "硅基流动 - 免费")
    ]
    
    static let defaultProviders: [String: ProviderSettings] = [
        "ppinfra": ProviderSettings(baseURL: "https://api.ppinfra.com/v3/openai/v1/chat/completions", apiKey: "sk_JMYoUFzDZ258ZTDNItfKINu35r__rx8pM_j0Zqab7CQ", model: "deepseek/deepseek-v3/community"),
        "OpenRouter": ProviderSettings(baseURL: "https://openrouter.ai/api/v1/chat/completions", apiKey: "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", model: "deepseek/deepseek-chat:free"),
        "siliconflow": ProviderSettings(baseURL: "https://api.siliconflow.cn/v1/chat/completions", apiKey: "sk-ugnakenapgoouiubjkshrgfveopwxcrxakcuepjqgixvstye", model: "THUDM/glm-4-9b-chat")
    ]
    
    static let shared = SettingsModel()
    
    @Published var shortcutKey: String {
        didSet {
            UserDefaults.standard.set(shortcutKey, forKey: "shortcutKey")
        }
    }
    
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut")
    
    @Published var providers: [String: ProviderSettings] {
        didSet {
            // 将提供商配置存储到 UserDefaults
            let data = try? JSONEncoder().encode(providers)
            UserDefaults.standard.set(data, forKey: "providers")
        }
    }
    
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    init() {
        self.shortcutKey = UserDefaults.standard.string(forKey: "shortcutKey") ?? "⌘j"
        
        if let data = UserDefaults.standard.data(forKey: "providers"),
           let savedProviders = try? JSONDecoder().decode([String: ProviderSettings].self, from: data) {
            // 合并新版本可能添加的默认提供商
            var mergedProviders = savedProviders
            for (key, value) in Self.defaultProviders {
                if mergedProviders[key] == nil {
                    mergedProviders[key] = value
                }
            }
            self.providers = mergedProviders
        } else {
            self.providers = Self.defaultProviders
        }
        
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "OpenAI"
    }
}
