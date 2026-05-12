import Sparkle
import Observation

/// Wraps Sparkle's updater controller for SwiftUI environment injection.
@Observable
final class UpdateManager: NSObject {
    private let updaterController: SPUStandardUpdaterController
    // Held strongly because Sparkle keeps only a weak reference to the delegate
    private let feedDelegate = UpdateFeedDelegate()

    override init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: feedDelegate,
            userDriverDelegate: nil
        )
        super.init()
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

private final class UpdateFeedDelegate: NSObject, SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        "https://github.com/linhh-phv/purgify/releases/latest/download/appcast.xml"
    }
}
