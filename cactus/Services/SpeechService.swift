import AVFoundation

final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()
    private var isSpeaking = false
    
    // 使用单一实例，避免每次创建新的合成器
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
        // 设置代理，确保回调能正常工作
        speechSynthesizer.delegate = self
    }
    
    public func speak(_ text: String, speechLanguageCode: String) {
        stopSpeaking()
        guard !text.isEmpty else { return }
        print("speak lang: " + speechLanguageCode)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: speechLanguageCode)
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        isSpeaking = true
        
        // 使用异步任务避免主线程阻塞
        Task(priority: .medium) {
            // 使用类的单一实例而不是创建新实例
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    public func stopSpeaking() {
        Task(priority: .medium) {
            // 使用类的单一实例而不是创建新实例
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            
            // 更新状态和触发回调
            // 注意：这里可能需要在主线程上执行
            await MainActor.run {
                self.isSpeaking = false
            }
        }
    }
    
    // - nonisolated 告诉编译器这个方法可以在任何线程上被调用
    // - Task { @MainActor in } 创建一个新的任务，并确保其中的代码在主线程上执行
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}
