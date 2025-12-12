import Foundation
import KeyboardShortcuts

/// 自定义提示词数据结构
struct CustomPrompt: Codable, Identifiable {
    var id = UUID()
    var name: String
    var content: String
}

/// 自定义AI服务数据结构
struct CustomAIService: Codable, Identifiable {
    var id = UUID()
    var name: String
    var baseURL: String
    var apiKey: String
    var model: String
}

/// 模型选项数据结构
struct ModelOption: Codable, Identifiable {
    var id = UUID()
    var key: String
    var displayName: String
    
    init(key: String, displayName: String) {
        self.id = UUID()
        self.key = key
        self.displayName = displayName
    }
}

struct ProviderSettings: Codable {
    var title: String
    var baseURL: String
    var apiKey: String
    var model: String
    var helpUrl: String = ""
    var requiresCustomConfig: Bool = false // 标识是否需要用户自定义配置
    var availableModels: [ModelOption] = []
}

class PreferencesModel: ObservableObject {
    
    static let shared = PreferencesModel()
    
    // 快捷键
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut", default: .init(.x, modifiers: [.option]))
    static let aiShortcutSummary = KeyboardShortcuts.Name("aiShortcutSummary", default: .init(.s, modifiers: [.option]))
    static let aiShortcutMain = KeyboardShortcuts.Name("aiShortcutMain", default: .init(.c, modifiers: [.option]))
    static let aiShortcutDictionary = KeyboardShortcuts.Name("aiShortcutDictionary", default: .init(.z, modifiers: [.option]))
    static let aiShortcutScreenshotTranslate = KeyboardShortcuts.Name("aiShortcutScreenshotTranslate", default: .init(.a, modifiers: [.option]))
    static let aiShortcutReset = KeyboardShortcuts.Name("aiShortcutReset", default: .init(.delete, modifiers: [.option]))
    static let aiShortcutCopyOutput = KeyboardShortcuts.Name("aiShortcutCopyOutput", default: .init(.r, modifiers: [.option]))
    
    // 语言选项
    let availableLanguages = [
        "zh-Hans": NSLocalizedString("language_zh_hans", comment: "简体中文"),
        "zh-Hant": NSLocalizedString("language_zh_hant", comment: "繁体中文"),
        "ja": NSLocalizedString("language_ja", comment: "日语"),
        "ko": NSLocalizedString("language_ko", comment: "韩语"),
        "en": NSLocalizedString("language_en", comment: "英语"),
        "fr": NSLocalizedString("language_fr", comment: "法语"),
        "de": NSLocalizedString("language_de", comment: "德语"),
        "es": NSLocalizedString("language_es", comment: "西班牙语"),
        "id": NSLocalizedString("language_id", comment: "印尼语"),
        "pt-PT": NSLocalizedString("language_pt", comment: "葡萄牙语"),
        "ru": NSLocalizedString("language_ru", comment: "俄语"),
        "it": NSLocalizedString("language_it", comment: "意大利语"),
        "th": NSLocalizedString("language_th", comment: "泰语"),
        "vi": NSLocalizedString("language_vi", comment: "越南语"),
        "ar": NSLocalizedString("language_ar", comment: "阿拉伯语"),
    ]
    
    let languageKeys = ["zh-Hans", "zh-Hant", "en", "ja", "ko", "fr", "de", "es", "id", "pt-PT", "ru", "it", "th", "vi", "ar"]
    
    // 常用语言
    @Published var preferredLanguage: String {
        didSet {
            UserDefaults.standard.set(preferredLanguage, forKey: "preferredLanguage")
        }
    }
    
    // 常用外语
    @Published var commonForeignLanguage: String {
        didSet {
            UserDefaults.standard.set(commonForeignLanguage, forKey: "commonForeignLanguage")
        }
    }
    
    // 可复用的功能列表
    let availableFunctions = [
        "translate": NSLocalizedString("help_translate", comment: "翻译"),
        "summary": NSLocalizedString("help_summary", comment: "总结"),
        "dictionary": NSLocalizedString("help_dict", comment: "字典"),
        "chat": NSLocalizedString("help_chat", comment: "对话")
    ]
    
    let functionKeys = ["translate", "summary", "dictionary", "chat"]
    
    // 默认主窗口功能
    @Published var defaultMainFunction: String {
        didSet {
            UserDefaults.standard.set(defaultMainFunction, forKey: "defaultMainFunction")
        }
    }
    
    // 内置的AI服务 + OpenAI选项
    public var defaultProviders: [String: ProviderSettings] = [
        "model_zhipu_glm4": ProviderSettings(
            title: NSLocalizedString("model_zhipu_glm4", comment: "model_zhipuai"),
            baseURL: "https://api.siliconflow.cn/v1/chat/completions",
            apiKey: "sk-ugnakenapgoouiubjkshrgfveopwxcrxakcuepjqgixvstye",
            model: "THUDM/glm-4-9b-chat"
        ),
        "openrouter-default": ProviderSettings(
            title: NSLocalizedString("openrouter-default", comment: "openrouter-default"),
            baseURL: "https://openrouter.ai/api/v1/chat/completions",
            apiKey: "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",
            model: "z-ai/glm-4.5-air:free"
        ),
        "model_zhipu_glm4_flash": ProviderSettings(
            title: NSLocalizedString("model_zhipu_glm4_flash", comment: "model_zhipu_glm4_flash"),
            baseURL: "https://open.bigmodel.cn/api/paas/v4/chat/completions",
            apiKey: "b7138f6b57d3407882f915c7a75f21af.WBN4TkuNpLpclqGV",
            model: "glm-4.5-flash"
        ),
        "zhipu": ProviderSettings(
            title: NSLocalizedString("model_zhipu", comment: "zhipu"),
            baseURL: "https://open.bigmodel.cn/api/paas/v4/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://bigmodel.cn/usercenter/proj-mgmt/apikeys",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "glm-4.6", displayName: "GLM-4.6"),
                ModelOption(key: "glm-4.5", displayName: "GLM-4.5"),
                ModelOption(key: "glm-4.5-airx", displayName: "GLM-4.5-AIRX"),
                ModelOption(key: "glm-4.5-flash", displayName: "GLM-4.5-Flash (Free)"),
                ModelOption(key: "glm-4-flash-250414", displayName: "GLM-4-Flash-250414 (Free)"),
                ModelOption(key: "glm-4-flash", displayName: "GLM-4-Flash (Free)"),
                ModelOption(key: "glm-4v-flash", displayName: "GLM-4v-Flash"),
                ModelOption(key: "glm-4-plus", displayName: "GLM-4-Plus"),
                ModelOption(key: "glm-4v-plus", displayName: "GLM-4v-Plus")
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
                ModelOption(key: "zai-org/GLM-4.6", displayName: "GLM-4.6"),
                ModelOption(key: "THUDM/GLM-4-32B-0414", displayName: "GLM-4-32B-0414"),
                ModelOption(key: "THUDM/GLM-4-9B-0414", displayName: "GLM-4-9B-0414 (Free)"),
                ModelOption(key: "deepseek-ai/DeepSeek-V3", displayName: "DeepSeek-V3"),
                ModelOption(key: "Qwen/Qwen3-8B", displayName: "Qwen3-8B (Free)"),
                ModelOption(key: "Qwen/Qwen2.5-7B-Instruct", displayName: "Qwen2.5-7B-Instruct (Free)"),
                ModelOption(key: "Qwen/Qwen2.5-VL-32B-Instruct", displayName: "Qwen2.5-VL-32B-Instruct")
            ]
        ),
        "deepseek": ProviderSettings(
            title: NSLocalizedString("model_deepseek", comment: "deepseek"),
            baseURL: "https://api.deepseek.com/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://platform.deepseek.com/api_keys",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "deepseek-chat", displayName: "DeepSeek-V3.2"),
                ModelOption(key: "deepseek-reasoner", displayName: "DeepSeek-V3.2 (Thinking)")
            ]
        ),
        "volcengine": ProviderSettings(
            title: NSLocalizedString("model_volcengine", comment: "volcengine"),
            baseURL: "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://console.volcengine.com/ark/region:ark+cn-beijing/apiKey",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "doubao-seed-1-6-250615", displayName: "Doubao-Seed-1.6"),
                ModelOption(key: "doubao-1-5-pro-32k-250115", displayName: "Doubao-1.5-Pro"),
                ModelOption(key: "doubao-lite-32k-240828", displayName: "Doubao-Lite"),
                ModelOption(key: "deepseek-v3-250324", displayName: "DeepSeek-V3")
            ]
        ),
        "openai": ProviderSettings(
            title: NSLocalizedString("model_openai", comment: "openai"),
            baseURL: "https://api.openai.com/v1/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://platform.openai.com/api-keys",
            requiresCustomConfig: true,
            availableModels: [
//                ModelOption(key: "gpt-5.1-2025-11-13", displayName: "GPT-5.1"),
//                ModelOption(key: "gpt-5-2025-08-07", displayName: "GPT-5"),
//                ModelOption(key: "gpt-5-mini-2025-08-07", displayName: "GPT-5-mini"),
//                ModelOption(key: "gpt-5-nano-2025-08-07", displayName: "GPT-5-nano"),
                ModelOption(key: "gpt-4.1-2025-04-14", displayName: "GPT-4.1"),
                ModelOption(key: "gpt-4.1-mini-2025-04-14", displayName: "GPT-4.1-mini"),
                ModelOption(key: "gpt-4o-2024-11-20", displayName: "GPT-4o"),
                ModelOption(key: "gpt-4o-mini-2024-07-18", displayName: "GPT-4o-mini")
            ]
        ),
        "google_gemini": ProviderSettings(
            title: NSLocalizedString("model_google_gemini", comment: "Google Gemini"),
            baseURL: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://aistudio.google.com/app/apikey",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "gemini-3-pro-preview", displayName: "Gemini-3.0-Pro"),
                ModelOption(key: "gemini-2.0-flash", displayName: "Gemini-2.0-Flash"),
                ModelOption(key: "gemini-2.5-pro", displayName: "Gemini-2.5-Pro")
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
                ModelOption(key: "claude-sonnet-4-5-20250929", displayName: "claude-4.5"),
                ModelOption(key: "claude-sonnet-4-20250514", displayName: "claude-4"),
                ModelOption(key: "claude-3-7-sonnet-20250219", displayName: "Claude-3.7"),
                ModelOption(key: "claude-3-5-sonnet-20241022", displayName: "Claude-3.5")
            ]
        ),
        "grok": ProviderSettings(
            title: NSLocalizedString("model_grok", comment: "Grok"),
            baseURL: "https://api.x.ai/v1/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://console.x.ai/",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "grok-4-0709", displayName: "Grok-4-0709"),
                ModelOption(key: "grok-3", displayName: "Grok-3"),
                ModelOption(key: "grok-3-fast", displayName: "Grok-3-Fast"),
                ModelOption(key: "grok-3-mini", displayName: "Grok-3-Mini")
            ]
        ),
        "openrouter": ProviderSettings(
            title: NSLocalizedString("model_openrouter", comment: "OpenRouter"),
            baseURL: "https://openrouter.ai/api/v1/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://openrouter.ai/keys",
            requiresCustomConfig: true,
            availableModels: [
                ModelOption(key: "anthropic/claude-sonnet-4", displayName: "Claude-4-Sonnet"),
                ModelOption(key: "anthropic/claude-3.7-sonnet", displayName: "Claude-3.7-Sonnet"),
                ModelOption(key: "anthropic/claude-3.5-sonnet", displayName: "Claude-3.5-Sonnet"),
                ModelOption(key: "openai/gpt-4.1", displayName: "GPT-4.1"),
                ModelOption(key: "openai/gpt-4.1-mini", displayName: "GPT-4.1-Mini"),
                ModelOption(key: "openai/gpt-4o", displayName: "GPT-4o"),
                ModelOption(key: "openai/gpt-4o-mini", displayName: "GPT-4o-Mini"),
                ModelOption(key: "google/gemini-2.5-flash", displayName: "Gemini-2.5-Flash"),
                ModelOption(key: "google/gemini-2.5-pro", displayName: "Gemini-2.5-Pro"),
                ModelOption(key: "x-ai/grok-3-mini", displayName: "Grok-3-Mini"),
                ModelOption(key: "x-ai/grok-3", displayName: "Grok-3"),
                ModelOption(key: "qwen/qwen2.5-vl-32b-instruct:free", displayName: "Qwen-2.5-VL-32B-Instruct (Free)"),
                ModelOption(key: "qwen/qwen3-8b:free", displayName: "Qwen-3.8B (Free)"),
                ModelOption(key: "qwen/qwen-7b-chat", displayName: "Qwen-1.5-7B-Chat"),
                ModelOption(key: "deepseek/deepseek-chat", displayName: "DeepSeek-V3"),
                ModelOption(key: "deepseek/deepseek-chat:free", displayName: "DeepSeek-V3 (Free)"),
                ModelOption(key: "z-ai/glm-4.5", displayName: "GLM-4.5"),
                ModelOption(key: "z-ai/glm-4.5-air:free", displayName: "GLM-4.5-Air (Free)"),
                ModelOption(key: "thudm/glm-4-32b", displayName: "GLM-4-32B")
            ]
        )
    ]
    
    // 保持原始顺序的键数组
    public var providerKeys: [String] = [
        "model_zhipu_glm4",
        "model_zhipu_glm4_flash",
        "openrouter-default",
        "zhipu",
        "siliconflow",
        "deepseek",
        "volcengine",
        "openai",
        "google_gemini",
        "claude",
        "grok",
        "openrouter"
    ]
    
    // zhipu 用户配置
    @Published var zhipuApiKey: String {
        didSet {
            UserDefaults.standard.set(zhipuApiKey, forKey: "zhipuApiKey")
            updateZhipuConfig()
        }
    }
    
    @Published var selectedZhipuModel: String {
        didSet {
            UserDefaults.standard.set(selectedZhipuModel, forKey: "selectedZhipuModel")
            updateZhipuConfig()
        }
    }
    
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
    
    // grok 用户配置
    @Published var grokApiKey: String {
        didSet {
            UserDefaults.standard.set(grokApiKey, forKey: "grokApiKey")
            updateGrokConfig()
        }
    }
    
    @Published var selectedGrokModel: String {
        didSet {
            UserDefaults.standard.set(selectedGrokModel, forKey: "selectedGrokModel")
            updateGrokConfig()
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
    
    // deepseek 用户配置
    @Published var deepseekApiKey: String {
        didSet {
            UserDefaults.standard.set(deepseekApiKey, forKey: "deepseekApiKey")
            updateDeepseekConfig()
        }
    }
    
    @Published var selectedDeepseekModel: String {
        didSet {
            UserDefaults.standard.set(selectedDeepseekModel, forKey: "selectedDeepseekModel")
            updateClaudeConfig()
        }
    }
    
    // volcengine 用户配置
    @Published var volcengineApiKey: String {
        didSet {
            UserDefaults.standard.set(volcengineApiKey, forKey: "volcengineApiKey")
            updateDeepseekConfig()
        }
    }
    
    @Published var selectedVolcengineModel: String {
        didSet {
            UserDefaults.standard.set(selectedVolcengineModel, forKey: "selectedVolcengineModel")
            updateVolcengineConfig()
        }
    }
    
    // openrouter 用户配置
    @Published var openrouterApiKey: String {
        didSet {
            UserDefaults.standard.set(openrouterApiKey, forKey: "openrouterApiKey")
            updateOpenrouterConfig()
        }
    }
    
    @Published var selectedOpenrouterModel: String {
        didSet {
            UserDefaults.standard.set(selectedOpenrouterModel, forKey: "selectedOpenrouterModel")
            updateOpenrouterConfig()
        }
    }
    
    // 选中的AI服务
    @Published var selectedProvider: String {
        didSet {
            UserDefaults.standard.set(selectedProvider, forKey: "selectedProvider")
        }
    }
    
    // 选中的自定义提示词 - 使用UUID作为唯一标识符
    @Published var selectedCustomPrompt: UUID? {
        didSet {
            if let selectedCustomPrompt = selectedCustomPrompt {
                UserDefaults.standard.set(selectedCustomPrompt.uuidString, forKey: "selectedCustomPrompt")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedCustomPrompt")
            }
        }
    }
    
    init() {
        self.selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? "model_zhipu_glm4"
        
        // 使用 LangService 获取系统语言作为默认值
        let defaultLanguage = LangService.shared.getSystemLanguage()
        
        self.preferredLanguage = UserDefaults.standard.string(forKey: "preferredLanguage") ?? defaultLanguage
        self.commonForeignLanguage = UserDefaults.standard.string(forKey: "commonForeignLanguage") ?? "en"
        
        // 添加这行来初始化 selectedCustomPrompt - 从字符串转换为UUID
        if let uuidString = UserDefaults.standard.string(forKey: "selectedCustomPrompt") {
            self.selectedCustomPrompt = UUID(uuidString: uuidString)
        } else {
            self.selectedCustomPrompt = nil
        }
        self.openaiApiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
        self.selectedOpenAIModel = UserDefaults.standard.string(forKey: "selectedOpenAIModel") ?? ""
        
        self.siliconflowApiKey = UserDefaults.standard.string(forKey: "siliconflowApiKey") ?? ""
        self.selectedSiliconflowModel = UserDefaults.standard.string(forKey: "selectedSiliconflowModel") ?? ""
        
        self.googleGeminiApiKey = UserDefaults.standard.string(forKey: "googleGeminiApiKey") ?? ""
        self.selectedGoogleGeminiModel = UserDefaults.standard.string(forKey: "selectedGoogleGeminiModel") ?? ""
        
        self.grokApiKey = UserDefaults.standard.string(forKey: "grokApiKey") ?? ""
        self.selectedGrokModel = UserDefaults.standard.string(forKey: "selectedGrokModel") ?? ""
        
        self.claudeApiKey = UserDefaults.standard.string(forKey: "claudeApiKey") ?? ""
        self.selectedClaudeModel = UserDefaults.standard.string(forKey: "selectedClaudeModel") ?? ""
        
        self.deepseekApiKey = UserDefaults.standard.string(forKey: "deepseekApiKey") ?? ""
        self.selectedDeepseekModel = UserDefaults.standard.string(forKey: "selectedDeepseekModel") ?? ""
        
        self.volcengineApiKey = UserDefaults.standard.string(forKey: "volcengineApiKey") ?? ""
        self.selectedVolcengineModel = UserDefaults.standard.string(forKey: "selectedVolcengineModel") ?? ""
        
        self.zhipuApiKey = UserDefaults.standard.string(forKey: "zhipuApiKey") ?? ""
        self.selectedZhipuModel = UserDefaults.standard.string(forKey: "selectedZhipuModel") ?? ""
        
        self.openrouterApiKey = UserDefaults.standard.string(forKey: "openrouterApiKey") ?? ""
        self.selectedOpenrouterModel = UserDefaults.standard.string(forKey: "selectedOpenrouterModel") ?? ""
        
        self.defaultMainFunction = UserDefaults.standard.string(forKey: "defaultMainFunction") ?? "translate"
        
        // 移除这行：self.customPrompts = loadCustomPrompts()
        
        // 现在所有存储属性都已初始化，可以安全调用实例方法
        updateOpenAIConfig()
        updateSiliconflowConfig()
        updateGoogleGeminiConfig()
        updateClaudeConfig()
        updateDeepseekConfig()
        updateVolcengineConfig()
        updateZhipuConfig()
        updateOpenrouterConfig()
        updateGrokConfig()
        
        // 加载自定义AI服务
        updateProviderKeysWithCustomServices()
    }
    
    private func updateZhipuConfig() {
        if var zhipuProvider = defaultProviders["zhipu"] {
            zhipuProvider.apiKey = zhipuApiKey
            zhipuProvider.model = selectedZhipuModel
            defaultProviders["zhipu"] = zhipuProvider
        }
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
    
    private func updateGrokConfig() {
        if var grokProvider = defaultProviders["grok"] {
            grokProvider.apiKey = grokApiKey
            grokProvider.model = selectedGrokModel
            defaultProviders["grok"] = grokProvider
        }
    }
    
    private func updateClaudeConfig() {
        if var claudeProvider = defaultProviders["claude"] {
            claudeProvider.apiKey = claudeApiKey
            claudeProvider.model = selectedClaudeModel
            defaultProviders["claude"] = claudeProvider
        }
    }
    
    private func updateDeepseekConfig() {
        if var deepseekProvider = defaultProviders["deepseek"] {
            deepseekProvider.apiKey = deepseekApiKey
            deepseekProvider.model = selectedDeepseekModel
            defaultProviders["deepseek"] = deepseekProvider
        }
    }
    
    private func updateVolcengineConfig() {
        if var volcengineProvider = defaultProviders["volcengine"] {
            volcengineProvider.apiKey = volcengineApiKey
            volcengineProvider.model = selectedVolcengineModel
            defaultProviders["volcengine"] = volcengineProvider
        }
    }
    
    private func updateOpenrouterConfig() {
        if var openrouterProvider = defaultProviders["openrouter"] {
            openrouterProvider.apiKey = openrouterApiKey
            openrouterProvider.model = selectedOpenrouterModel
            defaultProviders["openrouter"] = openrouterProvider
        }
    }
    
    // 检查当前选择的提供商是否需要自定义配置
    var currentProviderRequiresConfig: Bool {
        return defaultProviders[selectedProvider]?.requiresCustomConfig ?? false
    }
    
    // 自定义提示词管理 - 直接在属性声明时初始化
    @Published var customPrompts: [CustomPrompt] = {
        guard let data = UserDefaults.standard.data(forKey: "customPrompts"),
              let prompts = try? JSONDecoder().decode([CustomPrompt].self, from: data) else {
            return []
        }
        return prompts
    }() {
        didSet {
            saveCustomPrompts()
        }
    }
    
    // 自定义AI服务管理 - 直接在属性声明时初始化
    @Published var customAIServices: [CustomAIService] = {
        guard let data = UserDefaults.standard.data(forKey: "customAIServices"),
              let services = try? JSONDecoder().decode([CustomAIService].self, from: data) else {
            return []
        }
        return services
    }() {
        didSet {
            saveCustomAIServices()
            updateProviderKeysWithCustomServices()
        }
    }
    
    // MARK: - 自定义提示词管理方法
    
    /// 保存自定义提示词到UserDefaults
    private func saveCustomPrompts() {
        if let encoded = try? JSONEncoder().encode(customPrompts) {
            UserDefaults.standard.set(encoded, forKey: "customPrompts")
        }
    }
    
    /// 从UserDefaults加载自定义提示词
    private func loadCustomPrompts() -> [CustomPrompt] {
        guard let data = UserDefaults.standard.data(forKey: "customPrompts"),
              let prompts = try? JSONDecoder().decode([CustomPrompt].self, from: data) else {
            return []
        }
        return prompts
    }
    
    /// 添加自定义提示词，自动过滤空白字符并限制名称长度
    func addCustomPrompt(name: String, content: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let truncatedName = String(trimmedName.prefix(100)) // 限制名称最大长度为100字符
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPrompt = CustomPrompt(name: truncatedName, content: trimmedContent)
        customPrompts.append(newPrompt)
    }
    
    /// 更新自定义提示词，自动过滤空白字符并限制名称长度
    func updateCustomPrompt(id: UUID, name: String, content: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let truncatedName = String(trimmedName.prefix(100)) // 限制名称最大长度为100字符
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if let index = customPrompts.firstIndex(where: { $0.id == id }) {
            customPrompts[index].name = truncatedName
            customPrompts[index].content = trimmedContent
        }
    }
    
    /// 删除自定义提示词
    func deleteCustomPrompt(id: UUID) {
        // 检查要删除的提示词是否是当前选中的提示词
        if let selectedPromptId = selectedCustomPrompt,
           selectedPromptId == id {
            // 如果删除的是当前选中的提示词，将selectedCustomPrompt设置为空
            selectedCustomPrompt = nil
        }
        
        customPrompts.removeAll { $0.id == id }
    }
    
    /// 根据名称获取提示词内容
    func getCustomPromptContent(by name: String) -> String? {
        return customPrompts.first { $0.name == name }?.content
    }
    
    /// 根据UUID获取提示词内容
    func getCustomPromptContent(by id: UUID) -> String? {
        return customPrompts.first { $0.id == id }?.content
    }
    
    /// 根据UUID获取提示词对象
    func getCustomPrompt(by id: UUID) -> CustomPrompt? {
        return customPrompts.first { $0.id == id }
    }
    
    // MARK: - 自定义AI服务管理方法
    
    /// 保存自定义AI服务到UserDefaults
    private func saveCustomAIServices() {
        if let encoded = try? JSONEncoder().encode(customAIServices) {
            UserDefaults.standard.set(encoded, forKey: "customAIServices")
        }
    }
    
    /// 从UserDefaults加载自定义AI服务
    private func loadCustomAIServices() -> [CustomAIService] {
        guard let data = UserDefaults.standard.data(forKey: "customAIServices"),
              let services = try? JSONDecoder().decode([CustomAIService].self, from: data) else {
            return []
        }
        return services
    }
    
    /// 添加自定义AI服务
    func addCustomAIService(name: String, baseURL: String, apiKey: String, model: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let truncatedName = String(trimmedName.prefix(50)) // 限制名称最大长度为50字符
        let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newService = CustomAIService(
            name: truncatedName,
            baseURL: trimmedBaseURL,
            apiKey: trimmedApiKey,
            model: trimmedModel
        )
        customAIServices.append(newService)
    }
    
    /// 更新自定义AI服务
    func updateCustomAIService(id: UUID, name: String, baseURL: String, apiKey: String, model: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let truncatedName = String(trimmedName.prefix(50)) // 限制名称最大长度为50字符
        let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let index = customAIServices.firstIndex(where: { $0.id == id }) {
            customAIServices[index].name = truncatedName
            customAIServices[index].baseURL = trimmedBaseURL
            customAIServices[index].apiKey = trimmedApiKey
            customAIServices[index].model = trimmedModel
        }
    }
    
    /// 删除自定义AI服务
    func deleteCustomAIService(id: UUID) {
        // 检查要删除的服务是否是当前选中的服务
        if let serviceToDelete = customAIServices.first(where: { $0.id == id }) {
            let customServiceKey = "custom_\(serviceToDelete.id.uuidString)"
            if selectedProvider == customServiceKey {
                // 如果删除的是当前选中的服务，切换到默认服务
                selectedProvider = "model_zhipu_glm4"
            }
        }
        
        customAIServices.removeAll { $0.id == id }
    }
    
    /// 更新providerKeys以包含自定义AI服务
    private func updateProviderKeysWithCustomServices() {
        // 重置为基础的providerKeys
        let baseProviderKeys = [
            "model_zhipu_glm4",
            "model_zhipu_glm4_flash",
            "openrouter-default",
            "openai",
            "google_gemini",
            "claude",
            "grok",
            "deepseek",
            "openrouter",
            "zhipu",
            "siliconflow",
            "volcengine"
        ]
        
        // 添加自定义服务的keys
        let customServiceKeys = customAIServices.map { "custom_\($0.id.uuidString)" }
        providerKeys = baseProviderKeys + customServiceKeys
        
        // 更新defaultProviders以包含自定义服务
        updateDefaultProvidersWithCustomServices()
    }
    
    /// 更新defaultProviders以包含自定义AI服务
    private func updateDefaultProvidersWithCustomServices() {
        // 移除旧的自定义服务
        let keysToRemove = defaultProviders.keys.filter { $0.hasPrefix("custom_") }
        for key in keysToRemove {
            defaultProviders.removeValue(forKey: key)
        }
        
        // 添加新的自定义服务
        for service in customAIServices {
            let key = "custom_\(service.id.uuidString)"
            defaultProviders[key] = ProviderSettings(
                title: service.name,
                baseURL: service.baseURL,
                apiKey: service.apiKey,
                model: service.model,
                helpUrl: "",
                requiresCustomConfig: false,
                availableModels: []
            )
        }
    }
}
