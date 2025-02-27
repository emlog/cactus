import SwiftUI

struct SettingsView: View {
    enum Tab: String {
        case general = "通用"
        case aiService = "AI 服务"
    }
    
    @State private var selectedTab: Tab? = .general  // Change to optional
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: Tab.general) {
                    Label("通用", systemImage: "gear")
                }
                
                NavigationLink(value: Tab.aiService) {
                    Label("AI 服务", systemImage: "brain")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 150, maxWidth: 200)
            
            .navigationDestination(for: Tab.self) { tab in
                switch tab {
                case .general:
                    GeneralSettingsView()
                case .aiService:
                    AIServiceSettingsView()
                }
            }
        }
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
