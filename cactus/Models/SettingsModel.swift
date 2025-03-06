import Foundation
import KeyboardShortcuts

class SettingsModel: ObservableObject {
    
    static let shared = SettingsModel()
    
    @Published var shortcutKey: String {
        didSet {
            UserDefaults.standard.set(shortcutKey, forKey: "shortcutKey")
        }
    }
    
    // Define a KeyboardShortcuts.Name for the AI assistant shortcut
    static let aiShortcut = KeyboardShortcuts.Name("aiShortcut")
    
    @Published var baseURL: String {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: "baseURL")
        }
    }
    
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var model: String {
        didSet {
            UserDefaults.standard.set(model, forKey: "model")
        }
    }
    
    init() {
        self.shortcutKey = UserDefaults.standard.string(forKey: "shortcutKey") ?? "⌘j"
        self.baseURL = UserDefaults.standard.string(forKey: "baseURL") ?? ""
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.model = UserDefaults.standard.string(forKey: "model") ?? ""
    }
}
