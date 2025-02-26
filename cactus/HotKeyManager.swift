//
//  HotKeyManager.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/22.
//

import Carbon
import Cocoa

class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: FourCharCode("MyHK")!, id: 1)
    private let keyCode: UInt32 = 49 // 示例：Space键
    private let modifierFlags: UInt32 = UInt32(cmdKey | shiftKey) // Cmd + Shift
    
    func setupHotKey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        let eventHandler: EventHandlerUPP = { _, event, _ in
            guard let event = event else { return noErr }
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            if hotKeyID.id == 1 {
                // 激活应用并显示窗口
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            return noErr
        }
        
        let handlerRef = eventHandler
        InstallEventHandler(GetApplicationEventTarget(), handlerRef, 1, &eventType, nil, nil)
        
        var hotKey: EventHotKeyRef?
        RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKey)
        hotKeyRef = hotKey
    }
}
