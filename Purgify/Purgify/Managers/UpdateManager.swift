import Sparkle
import SwiftUI

/// Wraps Sparkle's updater controller for SwiftUI environment injection.
final class UpdateManager {
    private let updaterController: SPUStandardUpdaterController
    private let feedDelegate = UpdateFeedDelegate()

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: feedDelegate,
            userDriverDelegate: nil
        )
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

// MARK: - SwiftUI Environment

private struct UpdateManagerKey: EnvironmentKey {
    static let defaultValue = UpdateManager()
}

extension EnvironmentValues {
    var updateManager: UpdateManager {
        get { self[UpdateManagerKey.self] }
        set { self[UpdateManagerKey.self] = newValue }
    }
}
