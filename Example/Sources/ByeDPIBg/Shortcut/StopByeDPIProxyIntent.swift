import AppIntents
import SwByeDPI

@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
///Stop Telegram WS Proxy shortcut
struct StopTgWsProxyIntent: AudioPlaybackIntent {
    
    static let title = LocalizedStringResource("appIntentStopByeDPIProxyTitle", defaultValue: "Stop ByeDPI proxy", table: "AppIntent")
    static let description = IntentDescription(LocalizedStringResource("appIntentStopByeDPIProxyDesc", defaultValue: "Stops ByeDPI proxy", table: "AppIntent"))
    
    func perform() async throws -> some IntentResult {
        _ = ByeDPI.stop()
        PlaybackController.shared.stopPlaySilentAudio()
        return .result()
    }
}
