import SwiftUI

/// Blue-tinted banner shown at the top of the main window after a successful
/// clean, upselling the user to enable Advanced scanning (+4 FDA-gated caches).
///
/// Visibility rules (handled by `shouldShow`):
///   - Hide if user has already enabled Advanced (nothing to upsell)
///   - Hide if dismissed ≥ 3 times (user clearly not interested)
///   - Hide for 7 days after each dismiss (breathing room)
///   - Hide if no successful clean just happened (needs the success moment)
struct PostCleanBanner: View {
    @EnvironmentObject var l10n: LocalizationManager

    let onEnable: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            // BG
            Color.accentColor.opacity(0.08)

            // Left accent stripe
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 4)

            HStack(spacing: 12) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
                    .padding(.leading, 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.t("banner.heading"))
                        .font(.system(size: 13, weight: .medium))
                    Text(l10n.t("banner.subtext"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: onEnable) {
                    Text(l10n.t("banner.button"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 28)
                        .background(Color.accentColor)
                        .cornerRadius(7)
                }
                .buttonStyle(.plain)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
            }
        }
        .frame(height: 52)
        .overlay(
            Rectangle()
                .fill(Color.accentColor.opacity(0.25))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    /// Global helper — whether the banner should be shown right now.
    /// Reads AppStorage keys directly so both MainWindow + EmptyState can check.
    static func shouldShow(justCleaned: Bool) -> Bool {
        guard justCleaned else { return false }

        let advancedEnabled = UserDefaults.standard.bool(forKey: "advancedScanningEnabled")
        guard !advancedEnabled else { return false }

        let dismissCount = UserDefaults.standard.integer(forKey: "postCleanBannerDismissCount")
        guard dismissCount < 3 else { return false }

        if let lastDismiss = UserDefaults.standard.object(forKey: "postCleanBannerDismissDate") as? Date {
            let daysSince = Date().timeIntervalSince(lastDismiss) / 86_400
            guard daysSince >= 7 else { return false }
        }

        return true
    }

    /// Record a dismiss — call from the view's onDismiss handler.
    static func recordDismiss() {
        let current = UserDefaults.standard.integer(forKey: "postCleanBannerDismissCount")
        UserDefaults.standard.set(current + 1, forKey: "postCleanBannerDismissCount")
        UserDefaults.standard.set(Date(), forKey: "postCleanBannerDismissDate")
    }
}
