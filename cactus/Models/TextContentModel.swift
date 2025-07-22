import Foundation
import SwiftUI

class TextContentModel: ObservableObject {
    static let shared = TextContentModel()
    
    @Published var text: String = ""
    @Published var resultText: String? = nil
    @Published var isProcessing: Bool = false
    
    // Add specific loading states for each function
    @Published var isTranslating: Bool = false
    @Published var isSummarizing: Bool = false
    @Published var isDictionaryLookup: Bool = false
    @Published var isChatting: Bool = false
    
    // 添加停止状态管理
    @Published var shouldStopRequest: Bool = false
}
