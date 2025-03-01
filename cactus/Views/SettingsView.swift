import SwiftUI

struct SettingsView: View {
    enum Tab: String {
        case general = "通用"
        case aiService = "AI 服务"
    }
    
    @State private var selectedTab: Tab? = .general
    @StateObject private var settingsModel = SettingsModel()  // Create an instance of SettingsModel
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.general) {
                    Label("通用", systemImage: "gear")
                }
                
                NavigationLink(value: Tab.aiService) {
                    Label("AI服务", systemImage: "brain")
                }
            }
            .listStyle(SidebarListStyle())
        } detail: {
            if let tab = selectedTab {
                switch tab {
                case .general:
                    GeneralSettingsView(settingsModel: settingsModel)  // Pass the settingsModel instance
                case .aiService:
                    AIServiceSettingsView(settingsModel: settingsModel)  // Pass the settingsModel instance
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
    @ObservedObject var settingsModel: SettingsModel  // 使用 ObservedObject 引用 SettingsModel

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("划线翻译快捷键", text: $settingsModel.shortcutKey)  // 绑定到 SettingsModel 的属性
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct AIServiceSettingsView: View {
    @ObservedObject var settingsModel: SettingsModel  // 使用 ObservedObject 引用 SettingsModel

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Base URL", text: $settingsModel.baseURL)  // 绑定到 SettingsModel 的属性
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("API Key", text: $settingsModel.apiKey)  // 绑定到 SettingsModel 的属性
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Model", text: $settingsModel.model)  // 绑定到 SettingsModel 的属性
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
