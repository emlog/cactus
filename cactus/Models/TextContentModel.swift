import Foundation
import SwiftUI

class TextContentModel: ObservableObject {
    static let shared = TextContentModel()
    
    @Published var text: String = ""
    @Published var promptText: String? = nil
}