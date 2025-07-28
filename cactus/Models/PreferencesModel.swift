import Foundation
import KeyboardShortcuts

/// 自定义提示词数据结构
struct CustomPrompt: Codable, Identifiable {
    var id = UUID()
    var name: String
    var content: String
}

struct ProviderSettings: Codable {
    var title: String
    var baseURL: String
    var apiKey: String
    var model: String
    var helpUrl: String = ""
    var requiresCustomConfig: Bool = false // 标识是否需要用户自定义配置
    var availableModels: [String: String] = [:]
}

class PreferencesModel: ObservableObject {
    
    static let shared = PreferencesModel()
    
    // 快捷键
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut", default: .init(.x, modifiers: [.option]))
    static let aiShortcutSummary = KeyboardShortcuts.Name("aiShortcutSummary", default: .init(.s, modifiers: [.option]))
    static let aiShortcutMain = KeyboardShortcuts.Name("aiShortcutMain", default: .init(.c, modifiers: [.option]))
    static let aiShortcutDictionary = KeyboardShortcuts.Name("aiShortcutDictionary", default: .init(.z, modifiers: [.option]))
    static let aiShortcutScreenshotTranslate = KeyboardShortcuts.Name("aiShortcutScreenshotTranslate", default: .init(.a, modifiers: [.option]))
    
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
    ]
    
    let languageKeys = ["zh-Hans", "zh-Hant", "en", "ja", "ko", "fr", "de", "es", "id", "pt-PT", "ru", "it", "th", "vi"]
    
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
        "zhipu": ProviderSettings(
            title: NSLocalizedString("model_zhipu", comment: "zhipu"),
            baseURL: "https://open.bigmodel.cn/api/paas/v4/chat/completions",
            apiKey: "",
            model: "",
            helpUrl: "https://bigmodel.cn/usercenter/proj-mgmt/apikeys",
            requiresCustomConfig: true,
            availableModels: [
                "glm-4-flash-250414": "GLM-4-Flash-250414 (Free)",
                "glm-4-flash": "GLM-4-Flash (Free)",
                "glm-4v-flash": "GLM-4v-Flash",
                "glm-4-plus": "GLM-4-Plus",
                "glm-4v-plus": "GLM-4v-Plus"
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
                "THUDM/GLM-4-32B-0414": "GLM-4-32B-0414",
                "THUDM/GLM-4-9B-0414": "GLM-4-9B-0414 (Free)",
                "deepseek-ai/DeepSeek-V3": "DeepSeek-V3",
                "Qwen/Qwen2.5-7B-Instruct": "Qwen2.5-7B-Instruct (Free)",
                "Qwen/Qwen2.5-VL-32B-Instruct": "Qwen2.5-VL-32B-Instruct"
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
                "deepseek-chat": "DeepSeek-V3",
                "deepseek-reasoner": "DeepSeek-R1"
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
                "doubao-seed-1-6-250615": "Doubao-Seed-1.6",
                "doubao-1-5-pro-32k-250115": "Doubao-1.5-Pro",
                "doubao-lite-32k-240828": "Doubao-Lite",
                "deepseek-v3-250324": "DeepSeek-V3"
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
                "gpt-4.1-2025-04-14": "GPT-4.1",
                "gpt-4.1-mini-2025-04-14": "GPT-4.1 mini",
                "gpt-4o-mini-2024-07-18": "GPT-4o mini"
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
                "claude-sonnet-4-20250514": "claude-4-Sonnet",
                "claude-3-7-sonnet-20250219": "Claude-3.7-Sonnet",
                "claude-3-5-sonnet-20241022": "Claude-3.5-Sonnet"
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
                "anthropic/claude-sonnet-4": "Claude-4-Sonnet",
                "anthropic/claude-3.7-sonnet": "Claude-3.7-Sonnet",
                "anthropic/claude-3.5-sonnet": "Claude-3.5-Sonnet",
                "openai/gpt-4.1": "GPT-4.1",
                "openai/gpt-4.1-mini": "GPT-4.1-Mini",
                "openai/gpt-4o": "GPT-4o",
                "openai/gpt-4o-mini": "GPT-4o-Mini",
                "google/gemini-2.5-flash": "Gemini-2.5-Flash",
                "google/gemini-2.5-pro": "Gemini-2.5-Pro",
                "x-ai/grok-3-mini": "Grok-3-Mini",
                "x-ai/grok-3": "Grok-3",
                "qwen/qwen2.5-vl-32b-instruct:free": "Qwen-2.5-VL-32B-Instruct-Free",
                "qwen/qwen3-8b:free": "Qwen-3.8B-Free",
                "qwen/qwen-7b-chat": "Qwen-1.5-7B-Chat",
                "deepseek/deepseek-chat": "DeepSeek-V3",
                "deepseek/deepseek-chat:free": "DeepSeek-V3-Free",
                "thudm/glm-4-32b:free": "GLM-4-32B-Free",
            ]
        )
    ]
    
    // 保持原始顺序的键数组
    public var providerKeys: [String] = [
        "model_zhipu_glm4",
        "model_qwen3",
        "model_cactusai_mix",
        "zhipu",
        "siliconflow",
        "deepseek",
        "volcengine",
        "openai",
        "google_gemini",
        "claude",
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
    
    // 选中的自定义提示词
    @Published var selectedCustomPrompt: String? {
        didSet {
            if let selectedCustomPrompt = selectedCustomPrompt {
                UserDefaults.standard.set(selectedCustomPrompt, forKey: "selectedCustomPrompt")
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
        
        // 添加这行来初始化 selectedCustomPrompt
        self.selectedCustomPrompt = UserDefaults.standard.string(forKey: "selectedCustomPrompt")
        self.openaiApiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
        self.selectedOpenAIModel = UserDefaults.standard.string(forKey: "selectedOpenAIModel") ?? ""
        
        self.siliconflowApiKey = UserDefaults.standard.string(forKey: "siliconflowApiKey") ?? ""
        self.selectedSiliconflowModel = UserDefaults.standard.string(forKey: "selectedSiliconflowModel") ?? ""
        
        self.googleGeminiApiKey = UserDefaults.standard.string(forKey: "googleGeminiApiKey") ?? ""
        self.selectedGoogleGeminiModel = UserDefaults.standard.string(forKey: "selectedGoogleGeminiModel") ?? ""
        
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
        if let selectedPromptName = selectedCustomPrompt,
           let promptToDelete = customPrompts.first(where: { $0.id == id }),
           promptToDelete.name == selectedPromptName {
            // 如果删除的是当前选中的提示词，将selectedCustomPrompt设置为空
            selectedCustomPrompt = nil
        }
        
        customPrompts.removeAll { $0.id == id }
    }
    
    /// 根据名称获取提示词内容
    func getCustomPromptContent(by name: String) -> String? {
        return customPrompts.first { $0.name == name }?.content
    }
}
