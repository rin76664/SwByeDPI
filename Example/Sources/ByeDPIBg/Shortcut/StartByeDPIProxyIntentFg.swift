import AppIntents
import SwByeDPI

@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
///Start ByeDPI Proxy shortcut in foreground
struct StartTgWsProxyIntentFg: AudioPlaybackIntent {
    
    static let title = LocalizedStringResource("appIntentStartByeDPIProxyTitle", defaultValue: "Start ByeDPI proxy", table: "AppIntent")
    static let description = IntentDescription(LocalizedStringResource("appIntentStartByeDPIProxyDesc", defaultValue: "Starts ByeDPI proxy", table: "AppIntent"))
    static let openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        if (ByeDPI.proxyStarted) {
#if DEBUG
            print("ByeDPI proxy already running - can't start")
#endif
            return .result(value: false)
        }
        let opSuccess = PlaybackController.shared.startPlaySilentAudio()
        if (opSuccess) {
            let args = AppProperties.load().byeDPILaunchConfig.args
            let err = await ByeDPI.start(args: args)
            if let safeErr = err {
                PlaybackController.shared.stopPlaySilentAudio()
                return .result(value: false)
            }
        }
        return .result(value: opSuccess)
    }
}
