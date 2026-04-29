import Foundation
import AppKit
import Combine

/// Detects whether the app currently has Full Disk Access.
///
/// macOS does not expose an API to query TCC directly. We probe by attempting
/// to read a known FDA-protected location — if `contentsOfDirectory` succeeds,
/// the app is granted; if it throws an EPERM/operation-not-permitted error,
/// it isn't. Probes use stable, OS-shipped paths so the result reflects FDA
/// rather than a missing user file.
///
/// State is re-evaluated whenever the app returns to the foreground (the user
/// just toggled the grant in System Settings) and is published so views update
/// reactively without a manual rescan.
@MainActor
final class FDAStatus: ObservableObject {

    /// True when at least one FDA-protected probe path is readable.
    @Published private(set) var isGranted: Bool = false

    /// Fires the first time `isGranted` flips from false → true within a
    /// session. Listeners (e.g. CacheScannerViewModel) use this to trigger a
    /// rescan that includes the now-unlocked caches.
    let didGrantPublisher = PassthroughSubject<Void, Never>()

    private var observer: NSObjectProtocol?

    /// FDA-protected paths that ship with macOS. We probe `contentsOfDirectory`
    /// — succeeds → FDA is on; throws EPERM → not granted.
    /// `~/Library/Safari` is the most reliable signal; fall back to Mail in
    /// case Safari has never been launched.
    private let probePaths: [String] = [
        ("~/Library/Safari" as NSString).expandingTildeInPath,
        ("~/Library/Mail" as NSString).expandingTildeInPath,
        ("~/Library/Containers/com.apple.mail/Data/Library/Mail Downloads" as NSString).expandingTildeInPath
    ]

    init() {
        refresh()
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    /// Re-probe FDA. Call after the user returns from System Settings.
    func refresh() {
        let granted = probePaths.contains { canRead($0) }
        let wasGranted = isGranted
        if granted != isGranted {
            isGranted = granted
        }
        if !wasGranted && granted {
            didGrantPublisher.send()
        }
    }

    /// True if the path exists and we can list its contents. A `false` here
    /// for an OS-shipped path means TCC blocked us.
    private func canRead(_ path: String) -> Bool {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else { return false }
        do {
            _ = try fm.contentsOfDirectory(atPath: path)
            return true
        } catch {
            return false
        }
    }
}
