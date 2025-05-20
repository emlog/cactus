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
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut", default: .init(.x, modifiers: [.option]))
    static let aiShortcutSummary = KeyboardShortcuts.Name("aiShortcutSummary", default: .init(.s, modifiers: [.option]))
    
    // 内置的AI服务
    public var defaultProviders: [String: ProviderSettings] = [
        "model_zhipu_glm4": ProviderSettings(
            title: NSLocalizedString("model_zhipu_glm4", comment: "model_zhipuai"),
            baseURL: "https://api.siliconflow.cn/v1/chat/completions",
            apiKey: "sk-ugnakenapgoouiubjkshrgfveopwxcrxakcuepjqgixvstye",
            model: "THUDM/glm-4-9b-chat"
        ),
        "model_cactusai_mix": ProviderSettings(
            title: NSLocalizedString("model_cactusai_mix", comment: "model_cactusai_max"),
            baseURL: "https://api.cactusai.cc/v1/chat/completions",
            apiKey: "sk-xxx",
            model: "internlm/internlm2_5-7b-chat"
        )
    ]
    
    // 选中的AI服务
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    init() {
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "model_zhipu_glm4"
    }
}
