import Foundation
import KeyboardShortcuts

struct ProviderSettings: Codable { // Conform to Codable
    var title: String
    var baseURL: String
    var apiKey: String
    var model: String
}

class SettingsModel: ObservableObject {
    
    static let shared = SettingsModel()

    // 快捷键
    // {{ Set default shortcut to Option + J }}
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut", default: .init(.j, modifiers: [.command]))

    // 内置的AI服务
    public var defaultProviders: [String: ProviderSettings] = [
        "ppinfra": ProviderSettings(
            title: NSLocalizedString("ppinfra", comment: "派欧算力云"),
            baseURL: "https://api.ppinfra.com/v3/openai/v1/chat/completions",
            apiKey: "sk_JMYoUFzDZ258ZTDNItfKINu35r__rx8pM_j0Zqab7CQ",
            model: "deepseek/deepseek-v3/community"
        ),
        "OpenRouter": ProviderSettings(
            title: NSLocalizedString("openRouter", comment: "OpenRouter"),
            baseURL: "https://openrouter.ai/api/v1/chat/completions",
            apiKey: "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",
            model: "deepseek/deepseek-chat:free"
        ),
        "siliconflow": ProviderSettings(
            title: NSLocalizedString("siliconflow", comment: "硅基流动"),
            baseURL: "https://api.siliconflow.cn/v1/chat/completions",
            apiKey: "sk-ugnakenapgoouiubjkshrgfveopwxcrxakcuepjqgixvstye",
            model: "THUDM/glm-4-9b-chat"
        )
    ]
    
    // 选中的AI服务
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    init() {
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "siliconflow"
    }
}
