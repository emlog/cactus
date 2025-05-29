//
//  cactusApp.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/19.
//

import SwiftUI

@main
struct cactusApp: App {
    init() {
        // 应用启动时立即初始化PurchaseManager，开始加载产品信息
        _ = PurchaseManager.shared
    }
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // It's impossible to create sceneless application,
    // so we are hacking this around by creating a menubar
    // scene that is always hidden.
    @State private var hiddenMenu: Bool = false
    
    var body: some Scene {
        MenuBarExtra("", isInserted: $hiddenMenu) {
            EmptyView()
        }
    }
}
