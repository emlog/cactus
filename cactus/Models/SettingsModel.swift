import Foundation
import KeyboardShortcuts

struct ProviderSettings: Codable {
    var title: String
    var baseURL: String
    var apiKey: String
    var model: String
    var requiresCustomConfig: Bool = false // 标识是否需要用户自定义配置
}

class SettingsModel: ObservableObject {
    
    static let shared = SettingsModel()
    
    // 快捷键
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut", default: .init(.x, modifiers: [.option]))
    static let aiShortcutSummary = KeyboardShortcuts.Name("aiShortcutSummary", default: .init(.s, modifiers: [.option]))
    static let aiShortcutMain = KeyboardShortcuts.Name("aiShortcutMain", default: .init(.c, modifiers: [.option]))
    static let aiShortcutDictionary = KeyboardShortcuts.Name("aiShortcutDictionary", default: .init(.z, modifiers: [.option]))
    
    // 内置的AI服务 + OpenAI选项
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
        ),
        "model_qwen3": ProviderSettings(
            title: NSLocalizedString("model_qwen3", comment: "model_qwen3"),
            baseURL: "https://openrouter.ai/api/v1/chat/completions",
            apiKey: "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",
            model: "qwen/qwen3-8b:free"
        ),
        "openai": ProviderSettings(
            title: "OpenAI",
            baseURL: "https://api.openai.com/v1/chat/completions",
            apiKey: "",
            model: "",
            requiresCustomConfig: true
        )
    ]
    
    // OpenAI 用户配置
    @Published var openaiApiKey: String {
        didSet {
            UserDefaults.standard.set(openaiApiKey, forKey: "openaiApiKey")
            updateOpenAIConfig()
        }
    }
    
    @Published var selectedOpenAIModel: String {
        didSet {
            UserDefaults.standard.set(selectedOpenAIModel, forKey: "selectedOpenAIModel")
            updateOpenAIConfig()
        }
    }
    
    // OpenAI 可选模型
    let openaiModels = [
        "gpt-4.1-2025-04-14": "GPT-4.1",
        "gpt-4.1-mini-2025-04-14": "GPT-4.1 mini",
    ]
    
    // 选中的AI服务
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    init() {
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "model_zhipu_glm4"
        self.openaiApiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
        self.selectedOpenAIModel = UserDefaults.standard.string(forKey: "selectedOpenAIModel") ?? "gpt-4"
        
        updateOpenAIConfig()
    }
    
    // 更新OpenAI配置
    private func updateOpenAIConfig() {
        if var openaiProvider = defaultProviders["openai"] {
            openaiProvider.apiKey = openaiApiKey
            openaiProvider.model = selectedOpenAIModel
            defaultProviders["openai"] = openaiProvider
        }
    }
    
    // 检查当前选择的提供商是否需要自定义配置
    var currentProviderRequiresConfig: Bool {
        return defaultProviders[selectedProvider]?.requiresCustomConfig ?? false
    }
    
    // 检查OpenAI配置是否完整
    var isOpenAIConfigValid: Bool {
        return !openaiApiKey.isEmpty
    }
    
    // 检查是否为高级用户
    var isPremiumUser: Bool {
        return PurchaseManager.shared.isPremiumUser
    }
}
