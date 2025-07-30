//
//  DebugLog.swift
//  cactus
//
//  Created by 许大伟 on 2025/7/30.
//

enum LogLevel: String {
    case debug = "[DEBUG]"
    case info  = "[INFO]"
    case warn  = "[WARN]"
    case error = "[ERROR]"
}

func debugLog(_ level: LogLevel = .debug, _ message: @autoclosure () -> String) {
#if DEBUG
    print("\(level.rawValue) \(message())")
#endif
}
