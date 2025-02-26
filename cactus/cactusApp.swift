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
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
