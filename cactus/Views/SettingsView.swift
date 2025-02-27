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
    var body: some View {
        Form {
            Section {
                Text("通用设置")
                // 这里添加通用设置项
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AIServiceSettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("AI 服务设置")
                // 这里添加 AI 服务设置项
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
