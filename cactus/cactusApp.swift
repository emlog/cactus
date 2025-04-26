//
//  cactusApp.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/19.
//

import SwiftUI

@main
struct CactusApp: App {
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
