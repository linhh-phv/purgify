import Foundation
import Combine

/// Gate for any scan that walks the user's home folders (Desktop, Documents,
/// Projects, code…). Off by default so a fresh launch never triggers a macOS
/// folder-access prompt unrequested. The user opts in via the per-category
/// banner or the Settings toggle; the TCC dialog then appears in context.
///
/// The flag is also read directly from `UserDefaults` inside the (nonisolated)
/// service layer — keep `defaultsKey` in sync with that lookup.
@MainActor
final class ProjectFolderAccess: ObservableObject {

    static let defaultsKey = "projectFolderScanEnabled"

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.defaultsKey)
        }
    }

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: Self.defaultsKey)
    }

    /// Service-safe read used from nonisolated scan code that can't touch the
    /// MainActor-bound `isEnabled`. Reads the same UserDefaults key.
    nonisolated static var isEnabledFromDefaults: Bool {
        UserDefaults.standard.bool(forKey: defaultsKey)
    }
}
