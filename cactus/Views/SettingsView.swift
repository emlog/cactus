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
        VStack {
            Form {
                Section {
                    TextField("划线翻译快捷键", text: $shortcutKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  // 确保内容靠上排列
    }
}

struct AIServiceSettingsView: View {
    @State private var baseURL: String = "https://api.openai.com"  // 默认 Base URL
    @State private var apiKey: String = ""  // API Key
    @State private var model: String = "gpt-3.5-turbo"  // 默认模型

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Base URL", text: $baseURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Model", text: $model)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  // 确保内容靠上排列
    }
}
