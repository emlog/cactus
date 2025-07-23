import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralAiPane: View {
    
    @ObservedObject private var preferences = PreferencesModel.shared
    
    // 自定义提示词编辑状态
    @State private var showingAddPrompt = false
    @State private var editingPrompt: CustomPrompt?
    @State private var newPromptName = ""
    @State private var newPromptContent = ""
    
    // 检查是否为高级用户
    var isPremiumUser: Bool {
        return PurchaseManager.shared.isPremiumUser
    }
    
    // 计算内容高度
    private var contentHeight: CGFloat {
        var height: CGFloat = 90 // 基础高度（提供商选择部分）
        
        if preferences.currentProviderRequiresConfig && isPremiumUser {
            height += 110 // 配置界面的高度
        }
        
        // 自定义提示词部分高度 - 根据条目数量动态计算
        let basePromptSectionHeight: CGFloat = 100 // 标题、按钮等基础高度
        let promptItemHeight: CGFloat = 60 // 每个提示词条目的高度
        let promptsHeight = basePromptSectionHeight + CGFloat(preferences.customPrompts.count) * promptItemHeight
        
        height += promptsHeight
        
        // 限制最大高度为680
        return min(height, 680)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack{
                    // 选择提供商
                    SettingRow(
                        label: NSLocalizedString("select_service", comment: "选择提供商")
                    ) {
                        Picker(selection: $preferences.selectedProvider, label: EmptyView()) {
                            providerOptions
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 300, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)
                
                // 通用配置界面 - 适用于需要自定义配置的提供商
                if preferences.currentProviderRequiresConfig && isPremiumUser {
                    providerConfigurationView
                }
                
                // 自定义提示词管理界面
                customPromptsManagementView
            }
        }
        .frame(width: 800, height: contentHeight)
        .sheet(isPresented: $showingAddPrompt) {
            customPromptEditView
        }
        .sheet(item: $editingPrompt) { prompt in
            customPromptEditView
        }
    }
    
    // 自定义提示词管理视图
    private var customPromptsManagementView: some View {
        VStack(spacing: 0) {
            // 标题和添加按钮
            HStack {
                Text("自定义提示词")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    newPromptName = ""
                    newPromptContent = ""
                    editingPrompt = nil
                    showingAddPrompt = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // 提示词列表
            if preferences.customPrompts.isEmpty {
                Text("暂无自定义提示词")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(preferences.customPrompts) { prompt in
                        customPromptRow(prompt: prompt)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .background(Color(NSColor.gridColor))
        .cornerRadius(12)
        .padding(16)
    }
    
    /// 自定义提示词行视图
    private func customPromptRow(prompt: CustomPrompt) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(prompt.content)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // 编辑按钮
                Button(action: {
                    newPromptName = prompt.name
                    newPromptContent = prompt.content
                    editingPrompt = prompt
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                
                // 删除按钮
                Button(action: {
                    preferences.deleteCustomPrompt(id: prompt.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    /// 自定义提示词编辑视图
    private var customPromptEditView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("名称")
                    .font(.system(size: 14, weight: .medium))
                
                TextField("", text: $newPromptName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("提示词")
                    .font(.system(size: 14, weight: .medium))
                
                TextEditor(text: $newPromptContent)
                    .padding(5)  // 添加内边距，增加文字与边框的距离
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            HStack(spacing: 12) {
                Button("取消") {
                    showingAddPrompt = false
                    editingPrompt = nil
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("保存") {
                    // 过滤空白字符并限制名称长度
                    let trimmedName = newPromptName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let truncatedName = String(trimmedName.prefix(100)) // 限制名称最大长度为100字符
                    let trimmedContent = newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if let editingPrompt = editingPrompt {
                        preferences.updateCustomPrompt(
                            id: editingPrompt.id,
                            name: truncatedName,
                            content: trimmedContent
                        )
                        self.editingPrompt = nil
                    } else {
                        preferences.addCustomPrompt(
                            name: truncatedName,
                            content: trimmedContent
                        )
                        showingAddPrompt = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPromptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.bottom)
        }
        .padding()
        .frame(width: 400, height: 280)
    }
    
    // 通用的提供商配置视图
    private var providerConfigurationView: some View {
        VStack(spacing: 0) {
            // 配置标题和帮助按钮
            HStack {
                Text(providerConfigTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    if let helpUrl = preferences.defaultProviders[preferences.selectedProvider]?.helpUrl,
                       let url = URL(string: helpUrl) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal, 10)
            
            // API密钥设置
            SettingRow(
                label: NSLocalizedString("api_key", comment: "密钥")
            ) {
                SecureField(NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: apiKeyBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // 模型选择
            SettingRow(
                label: NSLocalizedString("model", comment: "模型")
            ) {
                Picker(selection: modelBinding, label: EmptyView()) {
                    ForEach(availableModelKeys, id: \.self) { key in
                        Text(availableModelDisplayName(for: key)).tag(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 300, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(NSColor.gridColor))
        .cornerRadius(12)
        .padding(16)
        
    }
    
    // 计算属性：配置标题
    private var providerConfigTitle: String {
        switch preferences.selectedProvider {
        case "zhipu":
            return NSLocalizedString("zhipu_config", comment: "智谱配置")
        case "deepseek":
            return NSLocalizedString("deepseek_config", comment: "Deepseek 配置")
        case "volcengine":
            return NSLocalizedString("volcengine_config", comment: "Volcengine 配置")
        case "siliconflow":
            return NSLocalizedString("siliconflow_config", comment: "硅基流动配置")
        case "openai":
            return NSLocalizedString("openai_config", comment: "OpenAI配置")
        case "google_gemini":
            return NSLocalizedString("google_gemini_config", comment: "Google Gemini 配置")
        case "claude":
            return NSLocalizedString("claude_config", comment: "Claude 配置")
        case "openrouter":
            return NSLocalizedString("openrouter_config", comment: "OpenRouter 配置")
        default:
            return NSLocalizedString("provider_config", comment: "提供商配置")
        }
    }
    
    // 计算属性：API密钥绑定
    private var apiKeyBinding: Binding<String> {
        switch preferences.selectedProvider {
        case "zhipu":
            return $preferences.zhipuApiKey
        case "deepseek":
            return $preferences.deepseekApiKey
        case "volcengine":
            return $preferences.volcengineApiKey
        case "siliconflow":
            return $preferences.siliconflowApiKey
        case "openai":
            return $preferences.openaiApiKey
        case "google_gemini":
            return $preferences.googleGeminiApiKey
        case "claude":
            return $preferences.claudeApiKey
        case "openrouter":
            return $preferences.openrouterApiKey
        default:
            return .constant("")
        }
    }
    
    // 计算属性：模型选择绑定
    private var modelBinding: Binding<String> {
        switch preferences.selectedProvider {
        case "zhipu":
            return $preferences.selectedZhipuModel
        case "deepseek":
            return $preferences.selectedDeepseekModel
        case "volcengine":
            return $preferences.selectedVolcengineModel
        case "siliconflow":
            return $preferences.selectedSiliconflowModel
        case "openai":
            return $preferences.selectedOpenAIModel
        case "google_gemini":
            return $preferences.selectedGoogleGeminiModel
        case "claude":
            return $preferences.selectedClaudeModel
        case "openrouter":
            return $preferences.selectedOpenrouterModel
        default:
            return .constant("")
        }
    }
    
    // 计算属性：可用模型键列表
    private var availableModelKeys: [String] {
        return Array(preferences.defaultProviders[preferences.selectedProvider]?.availableModels.keys.sorted() ?? [])
    }
    
    // 获取模型显示名称
    private func availableModelDisplayName(for key: String) -> String {
        return preferences.defaultProviders[preferences.selectedProvider]?.availableModels[key] ?? key
    }
    
    private var providerOptions: some View {
        ForEach(preferences.providerKeys, id: \.self) { key in
            // 高级版可以看到更多模型
            if (key == "zhipu" || key == "siliconflow" || key == "deepseek" || key == "volcengine" || key == "claude" || key == "openai" || key == "google_gemini" || key == "openrouter") && !isPremiumUser {
                EmptyView()
            } else {
                Text(providerDisplayText(for: key)).tag(key)
            }
        }
    }
    
    private func providerDisplayText(for key: String) -> String {
        guard let provider = preferences.defaultProviders[key] else {
            return key
        }
        return provider.title
    }
}
