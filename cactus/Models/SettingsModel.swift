import Foundation
import KeyboardShortcuts

struct ProviderSettings: Codable { // Conform to Codable
    var baseURL: String
    var apiKey: String
    var model: String
}

class SettingsModel: ObservableObject {
    
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
        
        // 从 UserDefaults 中加载提供商配置
        if let data = UserDefaults.standard.data(forKey: "providers"),
           let savedProviders = try? JSONDecoder().decode([String: ProviderSettings].self, from: data) {
            self.providers = savedProviders
        } else {
            self.providers = [
                "OpenAI": ProviderSettings(baseURL: "https://api.openai.com/v1/chat/completions", apiKey: "", model: "GPT-4o"),
                "DeepSeek": ProviderSettings(baseURL: "https://api.deepseek.com/v1/chat/completions", apiKey: "", model: "deepseek-chat"),
                "zhipu": ProviderSettings(baseURL: "https://open.bigmodel.cn/api/paas/v4/chat/completions", apiKey: "", model: "glm-4-plus")
            ]
        }
        
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "OpenAI"
    }
}
