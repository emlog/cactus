import AVFoundation

class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
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
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        onSpeakingStateChanged?(false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        onSpeakingStateChanged?(false)
    }
}
