import AVFoundation

@MainActor
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isSpeaking = false
    var onSpeakingStateChanged: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    func speak(_ text: String, langCode: String) {
        stopSpeaking()
        guard !text.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: langCode)
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        isSpeaking = true
        onSpeakingStateChanged?(true)
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        onSpeakingStateChanged?(false)
    }
    
    // - nonisolated 告诉编译器这个方法可以在任何线程上被调用
    // - Task { @MainActor in } 创建一个新的任务，并确保其中的代码在主线程上执行
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
            onSpeakingStateChanged?(false)
        }
    }
}
