import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralAiPane: View {
    
    @ObservedObject private var preferences = PreferencesModel.shared
    
    // 检查是否为高级用户
    var isPremiumUser: Bool {
        return PurchaseManager.shared.isPremiumUser
    }
    
    // 计算内容高度
    private var contentHeight: CGFloat {
        var height: CGFloat = 100 // 基础高度（提供商选择部分）
        
        if preferences.currentProviderRequiresConfig && isPremiumUser {
            height += 140 // 配置界面的高度
        }
        
        return height
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
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(20)
                
                // 通用配置界面 - 适用于需要自定义配置的提供商
                if preferences.currentProviderRequiresConfig && isPremiumUser {
                    providerConfigurationView
                }
            }
        }
        .frame(width: 800, height: contentHeight)
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
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
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
        .padding(20)
        
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
            if (key == "zhipu" || key == "siliconflow" || key == "deepseek" || key == "volcengine" || key == "claude" || key == "openai" || key == "google_gemini") && !isPremiumUser {
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
