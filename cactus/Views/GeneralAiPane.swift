import SwiftUI
import Foundation
import AppKit

struct GeneralAiPane: View {
    
    @ObservedObject private var preferences = PreferencesModel.shared
    
    // 自定义提示词编辑状态
    @State private var showingAddPrompt = false
    @State private var editingPrompt: CustomPrompt?
    @State private var newPromptName = ""
    @State private var newPromptContent = ""
    
    // 自定义AI服务编辑状态
    @State private var showingAddAIService = false
    @State private var editingAIService: CustomAIService?
    @State private var newServiceName = ""
    @State private var newServiceBaseURL = ""
    @State private var newServiceApiKey = ""
    @State private var newServiceModel = ""
    
    // AI服务测试状态
    @State private var isTestingService = false
    @State private var testResult: String = ""
    @State private var showingTestResult = false
    
    // 提示词库状态
    @State private var showingPromptLibrary = false
    
    // 检查是否为高级用户
    var isPremiumUser: Bool {
        return PurchaseManager.shared.isPremiumUser
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack{
                    // AI服务选择区域 - 新的卡片式设计
                    aiServiceSelectionView
                    // 通用配置界面 - 适用于需要自定义配置的提供商
                    if preferences.currentProviderRequiresConfig && isPremiumUser {
                        providerConfigurationView
                    }
                    // 自定义AI服务配置界面
                    if preferences.selectedProvider.hasPrefix("custom_") && isPremiumUser {
                        customProviderConfigurationView
                    }
                }
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)
                
                // 自定义提示词管理界面
                customPromptsManagementView
            }
        }
        .frame(width: 800, height: 680)
        .sheet(isPresented: $showingAddPrompt) {
            customPromptEditView
        }
        .sheet(item: $editingPrompt) { (prompt: CustomPrompt) in
            customPromptEditView
        }
        .sheet(isPresented: $showingAddAIService) {
            customAIServiceEditView
        }
        .sheet(item: $editingAIService) { (service: CustomAIService) in
            customAIServiceEditView
        }
        .sheet(isPresented: $showingPromptLibrary) {
            PromptLibraryView { (name: String, content: String) in
                preferences.addCustomPrompt(name: name, content: content)
            }
        }
        .alert("", isPresented: $showingTestResult) {
            Button(NSLocalizedString("confirm", comment: "确定")) {
                showingTestResult = false
            }
        } message: {
            Text(testResult)
        }
    }
    
    // AI服务列表视图
    private var aiServiceSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和添加按钮
            HStack {
                Text(NSLocalizedString("select_service", comment: "选择提供商"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if isPremiumUser {
                    Button(action: {
                        newServiceName = ""
                        newServiceBaseURL = ""
                        newServiceApiKey = ""
                        newServiceModel = ""
                        editingAIService = nil
                        showingAddAIService = true
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 10)
            
            // AI服务卡片网格 - 每行4个
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 10) {
                ForEach(preferences.providerKeys, id: \.self) { providerKey in
                    aiServiceCard(for: providerKey)
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 10)
    }
    
    // AI服务卡片视图
    private func aiServiceCard(for providerKey: String) -> some View {
        let provider = preferences.defaultProviders[providerKey]
        let isSelected = preferences.selectedProvider == providerKey
        let isPremiumOnly = premiumOnlyProviders.contains(providerKey)
        let isAccessible = !isPremiumOnly || isPremiumUser
        
        return Button(action: {
            if isAccessible {
                preferences.selectedProvider = providerKey
            }
        }) {
            HStack(spacing: 8) {
                // 服务图标
                ZStack {
                    Circle()
                        .fill(isSelected ?
                              LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: serviceIcon(for: providerKey))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                // 服务名称和状态
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider?.title ?? providerKey)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isAccessible ? .primary : .secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    // 高级版标识
                    if isPremiumOnly {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 8))
                            Text(NSLocalizedString("premium", comment: "高级版"))
                                .font(.system(size: 8))
                        }
                        .foregroundColor(isPremiumUser ? .orange : .gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(isPremiumUser ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                        )
                    }
                }
                
                Spacer(minLength: 0)
            }
            .frame(height: 40)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ?
                          Color.accentColor.opacity(0.1) :
                            Color(NSColor.controlBackgroundColor)
                         )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.accentColor : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.2) : Color.black.opacity(0.05),
                radius: isSelected ? 4 : 2,
                x: 0,
                y: isSelected ? 2 : 1
            )
            .opacity(isAccessible ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .disabled(!isAccessible)
    }
    
    // 自定义AI服务配置视图
    private var customProviderConfigurationView: some View {
        VStack(spacing: 0) {
            // 标题和删除按钮
            HStack {
                Text(NSLocalizedString("custom_service_config", comment: "自定义服务配置"))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 测试按钮
                Button(action: {
                    testCustomAIService()
                }) {
                    HStack(spacing: 4) {
                        if isTestingService {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isTestingService)
                .help(NSLocalizedString("test_connection", comment: "验证连接"))
                
                // 删除按钮
                Button(action: {
                    if let customService = getCurrentCustomService() {
                        preferences.deleteCustomAIService(id: customService.id)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .help(NSLocalizedString("delete", comment: "删除"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            // 服务名称编辑
            SettingRow(
                label: NSLocalizedString("title", comment: "名称")
            ) {
                TextField("", text: customServiceNameBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // API地址编辑
            SettingRow(
                label: "API URL"
            ) {
                TextField("https://api.x.ai/v1/chat/completions", text: customServiceBaseURLBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // API密钥编辑
            SettingRow(
                label: NSLocalizedString("api_key", comment: "API密钥")
            ) {
                SecureInputView(placeholder: NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: customServiceApiKeyBinding)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // 模型编辑
            SettingRow(
                label: NSLocalizedString("model", comment: "模型")
            ) {
                TextField("grok-4-0709", text: customServiceModelBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .padding(16)
    }
    
    // 通用的提供商配置视图
    private var providerConfigurationView: some View {
        VStack(spacing: 0) {
            // 配置标题和操作按钮
            HStack {
                Text(providerConfigTitle)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 测试连接按钮
                Button(action: {
                    testBuiltInService()
                }) {
                    HStack(spacing: 4) {
                        if isTestingService {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isTestingService)
                .help(NSLocalizedString("test_connection", comment: "验证连接"))
                
                // 帮助按钮
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
            
            // API密钥设置
            SettingRow(
                label: NSLocalizedString("api_key", comment: "密钥")
            ) {
                SecureInputView(placeholder: NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: apiKeyBinding)
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
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .padding(16)
        
    }
    
    /// 提供商选项视图
    private var providerOptions: some View {
        ForEach(preferences.providerKeys, id: \.self) { key in
            // 检查是否为高级版专属提供商
            if premiumOnlyProviders.contains(key) && !isPremiumUser {
                EmptyView()
            } else {
                Text(providerDisplayText(for: key)).tag(key)
            }
        }
    }
    
    /// 自定义AI服务添加弹窗
    private var customAIServiceEditView: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text(editingAIService != nil ? NSLocalizedString("edit_ai_service", comment: "编辑AI服务") : NSLocalizedString("add_ai_service", comment: "添加AI服务"))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // 服务名称设置
            SettingRow(
                label: NSLocalizedString("title", comment: "名称")
            ) {
                TextField("", text: $newServiceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 20)
            
            // API URL设置
            SettingRow(
                label: "API URL"
            ) {
                TextField("https://api.x.ai/v1/chat/completions", text: $newServiceBaseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 20)
            
            // API密钥设置
            SettingRow(
                label: NSLocalizedString("api_key", comment: "密钥")
            ) {
                SecureInputView(placeholder: NSLocalizedString("enter_api_key", comment: "请输入API密钥"), text: $newServiceApiKey)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 20)
            
            // 模型设置
            SettingRow(
                label: NSLocalizedString("model", comment: "模型")
            ) {
                TextField("grok-4-0709", text: $newServiceModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            Spacer()
            
            // 按钮区域
            HStack(spacing: 12) {
                Button(NSLocalizedString("cancel", comment: "取消")) {
                    showingAddAIService = false
                    editingAIService = nil
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(NSLocalizedString("save", comment: "保存")) {
                    let trimmedName = newServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedBaseURL = newServiceBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedApiKey = newServiceApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedModel = newServiceModel.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if let editingAIService = editingAIService {
                        preferences.updateCustomAIService(
                            id: editingAIService.id,
                            name: trimmedName,
                            baseURL: trimmedBaseURL,
                            apiKey: trimmedApiKey,
                            model: trimmedModel
                        )
                        self.editingAIService = nil
                    } else {
                        preferences.addCustomAIService(
                            name: trimmedName,
                            baseURL: trimmedBaseURL,
                            apiKey: trimmedApiKey,
                            model: trimmedModel
                        )
                        showingAddAIService = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isAIServiceSaveButtonEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }
    
    // 自定义提示词管理视图
    private var customPromptsManagementView: some View {
        VStack(spacing: 0) {
            // 标题和操作按钮
            HStack {
                Text(NSLocalizedString("prompt_custom_system", comment: "自定义系统提示词"))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 提示词库按钮
                Button(action: {
                    showingPromptLibrary = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.hexagonpath")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 添加自定义提示词按钮
                Button(action: {
                    newPromptName = ""
                    newPromptContent = ""
                    editingPrompt = nil
                    showingAddPrompt = true
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            
            // 提示词列表
            if preferences.customPrompts.isEmpty {
                EmptyView()
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
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .help(NSLocalizedString("help_edit", comment: "编辑"))
                
                // 删除按钮
                Button(action: {
                    preferences.deleteCustomPrompt(id: prompt.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .help(NSLocalizedString("delete", comment: "删除"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
    
    /// 自定义提示词添加、编辑弹窗
    private var customPromptEditView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("title", comment: "名称"))
                    .font(.system(size: 14, weight: .medium))
                
                TextField("", text: $newPromptName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("prompt", comment: "提示词"))
                    .font(.system(size: 14, weight: .medium))
                
                TextEditor(text: $newPromptContent)
                    .padding(8)
                    .frame(height: 120)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)
            }
            
            HStack(spacing: 12) {
                Button(NSLocalizedString("cancel", comment: "取消")) {
                    showingAddPrompt = false
                    editingPrompt = nil
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(NSLocalizedString("save", comment: "保存")) {
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
                .disabled(!isSaveButtonEnabled)
            }
            .padding(.bottom)
        }
        .padding()
        .frame(width: 400, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }
    
    /// 获取当前选中的自定义AI服务
    private func getCurrentCustomService() -> CustomAIService? {
        guard preferences.selectedProvider.hasPrefix("custom_") else { return nil }
        let serviceId = String(preferences.selectedProvider.dropFirst(7)) // 移除 "custom_" 前缀
        guard let uuid = UUID(uuidString: serviceId) else { return nil }
        return preferences.customAIServices.first { $0.id == uuid }
    }
    
    /// 自定义服务名称绑定
    private var customServiceNameBinding: Binding<String> {
        Binding(
            get: { getCurrentCustomService()?.name ?? "" },
            set: { newValue in
                if let customService = getCurrentCustomService() {
                    preferences.updateCustomAIService(
                        id: customService.id,
                        name: newValue,
                        baseURL: customService.baseURL,
                        apiKey: customService.apiKey,
                        model: customService.model
                    )
                }
            }
        )
    }
    
    /// 自定义服务API地址绑定
    private var customServiceBaseURLBinding: Binding<String> {
        Binding(
            get: { getCurrentCustomService()?.baseURL ?? "" },
            set: { newValue in
                if let customService = getCurrentCustomService() {
                    preferences.updateCustomAIService(
                        id: customService.id,
                        name: customService.name,
                        baseURL: newValue,
                        apiKey: customService.apiKey,
                        model: customService.model
                    )
                }
            }
        )
    }
    
    /// 自定义服务API密钥绑定
    private var customServiceApiKeyBinding: Binding<String> {
        Binding(
            get: { getCurrentCustomService()?.apiKey ?? "" },
            set: { newValue in
                if let customService = getCurrentCustomService() {
                    preferences.updateCustomAIService(
                        id: customService.id,
                        name: customService.name,
                        baseURL: customService.baseURL,
                        apiKey: newValue,
                        model: customService.model
                    )
                }
            }
        )
    }
    
    /// 自定义服务模型绑定
    private var customServiceModelBinding: Binding<String> {
        Binding(
            get: { getCurrentCustomService()?.model ?? "" },
            set: { newValue in
                if let customService = getCurrentCustomService() {
                    preferences.updateCustomAIService(
                        id: customService.id,
                        name: customService.name,
                        baseURL: customService.baseURL,
                        apiKey: customService.apiKey,
                        model: newValue
                    )
                }
            }
        )
    }
    
    /// 根据服务类型返回对应的SF Symbol图标
    private func serviceIcon(for providerKey: String) -> String {
        switch providerKey {
        case "model_zhipu_glm4":
            return "diamond.circle.fill"
        case "openrouter-default":
            return "arrow.left.arrow.right"
        case "model_zhipu_glm4_flash":
            return "diamond.circle.fill"
        case "zhipu":
            return "diamond.circle.fill"
        case "siliconflow":
            return "cpu"
        case "deepseek":
            return "fish"
        case "volcengine":
            return "flame.fill"
        case "openai":
            return "circle.grid.3x3.fill"
        case "google_gemini":
            return "g.circle"
        case "claude":
            return "asterisk.circle.fill"
        case "grok":
            return "xmark"
        case "openrouter":
            return "arrow.left.arrow.right"
        default:
            return "bolt.fill"
        }
    }
    
    // 添加计算属性来检查保存按钮是否应该启用
    private var isSaveButtonEnabled: Bool {
        let trimmedName = newPromptName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedContent.isEmpty
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
        case "grok":
            return NSLocalizedString("grok_config", comment: "Grok 配置")
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
        case "grok":
            return $preferences.grokApiKey
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
        case "grok":
            return $preferences.selectedGrokModel
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
        return preferences.defaultProviders[preferences.selectedProvider]?.availableModels.map { $0.key } ?? []
    }
    
    // 获取模型显示名称
    private func availableModelDisplayName(for key: String) -> String {
        return preferences.defaultProviders[preferences.selectedProvider]?.availableModels.first { $0.key == key }?.displayName ?? key
    }
    
    /// 高级版专属提供商列表
    private var premiumOnlyProviders: Set<String> {
        return [
            "zhipu",
            "siliconflow",
            "deepseek",
            "volcengine",
            "claude",
            "openai",
            "google_gemini",
            "openrouter",
            "grok"
        ]
    }
    
    /// 获取提供商显示文本
    private func providerDisplayText(for key: String) -> String {
        guard let provider = preferences.defaultProviders[key] else {
            return key
        }
        return provider.title
    }
    
    /// 检查自定义AI服务保存按钮是否应该启用
    private var isAIServiceSaveButtonEnabled: Bool {
        let trimmedName = newServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBaseURL = newServiceBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApiKey = newServiceApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = newServiceModel.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedBaseURL.isEmpty && !trimmedApiKey.isEmpty && !trimmedModel.isEmpty
    }
    
    /// 测试自定义AI服务连接
    private func testCustomAIService() {
        guard let customService = getCurrentCustomService() else {
            testResult = NSLocalizedString("test_failed", comment: "验证失败")
            showingTestResult = true
            return
        }
        
        // 验证配置完整性
        if customService.baseURL.isEmpty || customService.apiKey.isEmpty || customService.model.isEmpty {
            testResult = NSLocalizedString("test_failed", comment: "验证失败")
            showingTestResult = true
            return
        }
        
        isTestingService = true
        testResult = ""
        
        // 临时保存当前配置
        let originalProvider = preferences.selectedProvider
        
        // 临时切换到当前自定义服务进行测试
        preferences.selectedProvider = "custom_\(customService.id.uuidString)"
        
        // 使用AiService进行测试
        AiService.shared.chat(
            text: "Hello, this is a connection test.",
            chatHistory: [[String: String]](),
            systemMessage: "",
            completion: {
                DispatchQueue.main.async {
                    // 恢复原始配置
                    self.preferences.selectedProvider = originalProvider
                    
                    self.isTestingService = false
                    self.testResult = NSLocalizedString("test_success", comment: "验证成功")
                    self.showingTestResult = true
                }
            },
            onError: { _ in
                DispatchQueue.main.async {
                    // 恢复原始配置
                    self.preferences.selectedProvider = originalProvider
                    
                    self.isTestingService = false
                    self.testResult = NSLocalizedString("test_failed", comment: "验证失败")
                    self.showingTestResult = true
                }
            }
        )
    }
    
    /// 获取指定提供商的API密钥
    private func getApiKeyForProvider(_ provider: String) -> String {
        switch provider {
        case "zhipu":
            return preferences.zhipuApiKey
        case "deepseek":
            return preferences.deepseekApiKey
        case "volcengine":
            return preferences.volcengineApiKey
        case "siliconflow":
            return preferences.siliconflowApiKey
        case "openai":
            return preferences.openaiApiKey
        case "google_gemini":
            return preferences.googleGeminiApiKey
        case "grok":
            return preferences.grokApiKey
        case "claude":
            return preferences.claudeApiKey
        case "openrouter":
            return preferences.openrouterApiKey
        default:
            return ""
        }
    }
    
    /// 获取指定提供商的模型
    private func getModelForProvider(_ provider: String) -> String {
        switch provider {
        case "zhipu":
            return preferences.selectedZhipuModel
        case "deepseek":
            return preferences.selectedDeepseekModel
        case "volcengine":
            return preferences.selectedVolcengineModel
        case "siliconflow":
            return preferences.selectedSiliconflowModel
        case "openai":
            return preferences.selectedOpenAIModel
        case "google_gemini":
            return preferences.selectedGoogleGeminiModel
        case "grok":
            return preferences.selectedGrokModel
        case "claude":
            return preferences.selectedClaudeModel
        case "openrouter":
            return preferences.selectedOpenrouterModel
        default:
            return ""
        }
    }
    
    /// 测试内置AI服务连接
    private func testBuiltInService() {
        let currentProvider = preferences.selectedProvider
        let apiKey = getApiKeyForProvider(currentProvider)
        let model = getModelForProvider(currentProvider)
        
        // 验证配置完整性
        if apiKey.isEmpty {
            testResult = NSLocalizedString("test_failed", comment: "验证失败")
            showingTestResult = true
            return
        }
        
        if model.isEmpty {
            testResult = NSLocalizedString("test_failed", comment: "验证失败")
            showingTestResult = true
            return
        }
        
        isTestingService = true
        testResult = ""
        
        // 使用AiService进行测试
        AiService.shared.chat(
            text: "Hello, this is a connection test.",
            chatHistory: [[String: String]](),
            systemMessage: "",
            completion: {
                DispatchQueue.main.async {
                    self.isTestingService = false
                    self.testResult = NSLocalizedString("test_success", comment: "验证成功")
                    self.showingTestResult = true
                }
            },
            onError: { _ in
                DispatchQueue.main.async {
                    self.isTestingService = false
                    self.testResult = NSLocalizedString("test_failed", comment: "验证失败")
                    self.showingTestResult = true
                }
            }
        )
    }
}

/// 自定义安全输入框组件，支持显示/隐藏密码
struct SecureInputView: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 8) {
            // 左侧的眼睛图标，仅在有内容时显示
            if !text.isEmpty {
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .frame(width: 300)
        }
    }
}
