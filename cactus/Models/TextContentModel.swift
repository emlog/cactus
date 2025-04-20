import Foundation
import SwiftUI

class TextContentModel: ObservableObject {
    static let shared = TextContentModel()

    @Published var text: String = ""
    @Published var resultText: String? = nil
    @Published var isProcessing: Bool = false
}
