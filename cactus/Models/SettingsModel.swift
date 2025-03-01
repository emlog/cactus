import Foundation

class SettingsModel: ObservableObject {
    @Published var shortcutKey: String {
        didSet {
            UserDefaults.standard.set(shortcutKey, forKey: "shortcutKey")
        }
    }
    
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
        self.shortcutKey = UserDefaults.standard.string(forKey: "shortcutKey") ?? "⌘o"
        self.baseURL = UserDefaults.standard.string(forKey: "baseURL") ?? "https://api.openai.com"
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.model = UserDefaults.standard.string(forKey: "model") ?? "gpt-3.5-turbo"
    }
}