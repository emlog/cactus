import Foundation
import KeyboardShortcuts

struct ProviderSettings: Codable {
    var title: String
    var baseURL: String
    var apiKey: String
    var model: String
    var helpUrl: String = ""
    var requiresCustomConfig: Bool = false // 标识是否需要用户自定义配置
    var availableModels: [String: String] = [:]
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
        "model_qwen3": ProviderSettings(
            title: NSLocalizedString("model_qwen3", comment: "model_qwen3"),
            baseURL: "https://openrouter.ai/api/v1/chat/completions",
            apiKey: "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",
            model: "qwen/qwen3-8b:free"
        ),
        "model_cactusai_mix": ProviderSettings(
            title: NSLocalizedString("model_cactusai_mix", comment: "model_cactusai_max"),
            baseURL: "https://api.cactusai.cc/v1/chat/completions",
            apiKey: "sk-xxx",
            model: "internlm/internlm2_5-7b-chat"
        ),
        "openai": ProviderSettings(
            title: NSLocalizedString("model_openai", comment: "openai"),
            baseURL: "https://api.openai.com/v1/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://platform.openai.com/api-keys",
            requiresCustomConfig: true,
            availableModels: [
                "gpt-4.1-2025-04-14": "GPT-4.1",
                "gpt-4.1-mini-2025-04-14": "GPT-4.1 mini",
                "gpt-4o-mini-2024-07-18": "GPT-4o mini"
            ]
        ),
        "siliconflow": ProviderSettings(
            title: NSLocalizedString("model_siliconflow", comment: "siliconflow"),
            baseURL: "https://api.siliconflow.cn/v1/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://cloud.siliconflow.cn/account/ak",
            requiresCustomConfig: true,
            availableModels: [
                "THUDM/GLM-4-32B-0414": "GLM-4-32B",
                "deepseek-ai/DeepSeek-V3": "DeepSeek-V3",
                "Qwen/Qwen2.5-VL-32B-Instruct": "Qwen2.5-VL-32B-Instruct"
            ]
        ),
        "google_gemini": ProviderSettings(
            title: NSLocalizedString("model_google_gemini", comment: "Google Gemini"),
            baseURL: "https://generativelanguage.googleapis.com/v1beta/models",
            apiKey: "",
            model: "",
            helpUrl: "https://aistudio.google.com/app/apikey",
            requiresCustomConfig: true,
            availableModels: [
                "gemini-2.0-flash": "Gemini-2.0-Flash",
                "gemini-2.5-pro-preview-06-05": "Gemini-2.5-Pro"
            ]
        ),
        "claude": ProviderSettings(
            title: NSLocalizedString("model_claude", comment: "Claude"),
            baseURL: "https://api.anthropic.com/v1/messages",
            apiKey: "",
            model: "",
            helpUrl: "https://console.anthropic.com/settings/keys",
            requiresCustomConfig: true,
            availableModels: [
                "claude-sonnet-4-20250514": "claude-sonnet-4",
                "claude-3-7-sonnet-20250219": "Claude-Sonnet-3.7",
                "claude-3-5-sonnet-20241022": "Claude-Sonnet-3.5"
            ]
        )
    ]

    // 新增：保持原始顺序的键数组
    public var providerKeys: [String] = [
        "model_zhipu_glm4",
        "model_qwen3",
        "model_cactusai_mix",
        "siliconflow",
        "openai",
        "google_gemini",
        "claude"
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
    
    // siliconflow 用户配置
    @Published var siliconflowApiKey: String {
        didSet {
            UserDefaults.standard.set(siliconflowApiKey, forKey: "siliconflowApiKey")
            updateSiliconflowConfig()
        }
    }
    
    @Published var selectedSiliconflowModel: String {
        didSet {
            UserDefaults.standard.set(selectedSiliconflowModel, forKey: "selectedSiliconflowModel")
            updateSiliconflowConfig()
        }
    }
    
    // google_gemini 用户配置
    @Published var googleGeminiApiKey: String {
        didSet {
            UserDefaults.standard.set(googleGeminiApiKey, forKey: "googleGeminiApiKey")
            updateGoogleGeminiConfig()
        }
    }

    @Published var selectedGoogleGeminiModel: String {
        didSet {
            UserDefaults.standard.set(selectedGoogleGeminiModel, forKey: "selectedGoogleGeminiModel")
            updateGoogleGeminiConfig()
        }
    }

    // claude 用户配置
    @Published var claudeApiKey: String {
        didSet {
            UserDefaults.standard.set(claudeApiKey, forKey: "claudeApiKey")
            updateClaudeConfig()
        }
    }

    @Published var selectedClaudeModel: String {
        didSet {
            UserDefaults.standard.set(selectedClaudeModel, forKey: "selectedClaudeModel")
            updateClaudeConfig()
        }
    }
    
    // 选中的AI服务
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    init() {
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "model_zhipu_glm4"
        self.openaiApiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
        self.selectedOpenAIModel = UserDefaults.standard.string(forKey: "selectedOpenAIModel") ?? ""
        
        self.siliconflowApiKey = UserDefaults.standard.string(forKey: "siliconflowApiKey") ?? ""
        self.selectedSiliconflowModel = UserDefaults.standard.string(forKey: "selectedSiliconflowModel") ?? ""

        self.googleGeminiApiKey = UserDefaults.standard.string(forKey: "googleGeminiApiKey") ?? ""
        self.selectedGoogleGeminiModel = UserDefaults.standard.string(forKey: "selectedGoogleGeminiModel") ?? ""

        self.claudeApiKey = UserDefaults.standard.string(forKey: "claudeApiKey") ?? ""
        self.selectedClaudeModel = UserDefaults.standard.string(forKey: "selectedClaudeModel") ?? ""
        
        updateOpenAIConfig()
        updateSiliconflowConfig()
        updateGoogleGeminiConfig()
        updateClaudeConfig()
    }
    
    private func updateOpenAIConfig() {
        if var openaiProvider = defaultProviders["openai"] {
            openaiProvider.apiKey = openaiApiKey
            openaiProvider.model = selectedOpenAIModel
            defaultProviders["openai"] = openaiProvider
        }
    }
    
    private func updateSiliconflowConfig() {
        if var siliconflowProvider = defaultProviders["siliconflow"] {
            siliconflowProvider.apiKey = siliconflowApiKey
            siliconflowProvider.model = selectedSiliconflowModel
            defaultProviders["siliconflow"] = siliconflowProvider
        }
    }

    private func updateGoogleGeminiConfig() {
        if var googleGeminiProvider = defaultProviders["google_gemini"] {
            googleGeminiProvider.apiKey = googleGeminiApiKey
            googleGeminiProvider.model = selectedGoogleGeminiModel
            defaultProviders["google_gemini"] = googleGeminiProvider
        }
    }

    private func updateClaudeConfig() {
        if var claudeProvider = defaultProviders["claude"] {
            claudeProvider.apiKey = claudeApiKey
            claudeProvider.model = selectedClaudeModel
            defaultProviders["claude"] = claudeProvider
        }
    }
    
    // 检查当前选择的提供商是否需要自定义配置
    var currentProviderRequiresConfig: Bool {
        return defaultProviders[selectedProvider]?.requiresCustomConfig ?? false
    }
}
