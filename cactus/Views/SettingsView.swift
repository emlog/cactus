import SwiftUI

struct SettingsView: View {
    enum Tab: String {
        case general = "通用"
        case aiService = "AI 服务"
    }
    
    @State private var selectedTab: Tab? = .general
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.general) {
                    Label("通用", systemImage: "gear")
                }
                
                NavigationLink(value: Tab.aiService) {
                    Label("AI 服务", systemImage: "brain")
                }
            }
            .listStyle(SidebarListStyle())
            .toolbar {  // 隐藏侧边栏按钮
                ToolbarItem(placement: .navigation) {
                    EmptyView()
                }
            }
        } detail: {
            if let tab = selectedTab {
                switch tab {
                case .general:
                    GeneralSettingsView()
                case .aiService:
                    AIServiceSettingsView()
                }
            } else {
                Text("请选择一个选项")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 600, minHeight: 400)  // 确保整个视图有足够的空间
    }
}

struct GeneralSettingsView: View {
    @State private var shortcutKey: String = "⌘o"  // 默认快捷键

    var body: some View {
        Form {
            Section(header: Text("通用设置").font(.headline)) {
                // 这里添加通用设置项
            }
            
            Section(header: Text("快捷键设置").font(.headline)) {
                HStack {
                    Text("选中文字翻译快捷键:")
                    Spacer()
                    TextField("快捷键", text: $shortcutKey)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AIServiceSettingsView: View {
    @State private var baseURL: String = "https://api.openai.com"  // 默认 Base URL
    @State private var apiKey: String = ""  // API Key
    @State private var model: String = "gpt-3.5-turbo"  // 默认模型

    var body: some View {
        Form {
            Section(header: Text("AI 服务设置").font(.headline)) {
                TextField("Base URL", text: $baseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Model", text: $model)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
