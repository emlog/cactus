import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct GeneralAiPane: View {
    
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    // 检查是否为高级用户
    var isPremiumUser: Bool {
        return PurchaseManager.shared.isPremiumUser
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack{
                    // 选择提供商
                    SettingRow(
                        label: NSLocalizedString("select_service", comment: "选择提供商")
                    ) {
                        Picker(selection: $settingsModel.selectedProvider, label: EmptyView()) {
                            providerOptions
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 300, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .padding(20)
                
                // 通用配置界面 - 适用于需要自定义配置的提供商
                if settingsModel.currentProviderRequiresConfig && isPremiumUser {
                    Divider()
                    
                    providerConfigurationView
                }
            }
        }
        .frame(width: 800, height: 230)
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
                    if let helpUrl = settingsModel.defaultProviders[settingsModel.selectedProvider]?.helpUrl,
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
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .padding(20)
        
    }
    
    // 计算属性：配置标题
    private var providerConfigTitle: String {
        switch settingsModel.selectedProvider {
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
        switch settingsModel.selectedProvider {
        case "zhipu":
            return $settingsModel.zhipuApiKey
        case "deepseek":
            return $settingsModel.deepseekApiKey
        case "volcengine":
            return $settingsModel.volcengineApiKey
        case "siliconflow":
            return $settingsModel.siliconflowApiKey
        case "openai":
            return $settingsModel.openaiApiKey
        case "google_gemini":
            return $settingsModel.googleGeminiApiKey
        case "claude":
            return $settingsModel.claudeApiKey
        default:
            return .constant("")
        }
    }
    
    // 计算属性：模型选择绑定
    private var modelBinding: Binding<String> {
        switch settingsModel.selectedProvider {
        case "zhipu":
            return $settingsModel.selectedZhipuModel
        case "deepseek":
            return $settingsModel.selectedDeepseekModel
        case "volcengine":
            return $settingsModel.selectedVolcengineModel
        case "siliconflow":
            return $settingsModel.selectedSiliconflowModel
        case "openai":
            return $settingsModel.selectedOpenAIModel
        case "google_gemini":
            return $settingsModel.selectedGoogleGeminiModel
        case "claude":
            return $settingsModel.selectedClaudeModel
        default:
            return .constant("")
        }
    }
    
    // 计算属性：可用模型键列表
    private var availableModelKeys: [String] {
        return Array(settingsModel.defaultProviders[settingsModel.selectedProvider]?.availableModels.keys.sorted() ?? [])
    }
    
    // 获取模型显示名称
    private func availableModelDisplayName(for key: String) -> String {
        return settingsModel.defaultProviders[settingsModel.selectedProvider]?.availableModels[key] ?? key
    }
    
    private var providerOptions: some View {
        ForEach(settingsModel.providerKeys, id: \.self) { key in
            // 高级版可以看到更多模型
            if (key == "zhipu" || key == "siliconflow" || key == "deepseek" || key == "volcengine" || key == "claude" || key == "openai" || key == "google_gemini") && !isPremiumUser {
                EmptyView()
            } else {
                Text(providerDisplayText(for: key)).tag(key)
            }
        }
    }
    
    private func providerDisplayText(for key: String) -> String {
        guard let provider = settingsModel.defaultProviders[key] else {
            return key
        }
        return provider.title
    }
}
