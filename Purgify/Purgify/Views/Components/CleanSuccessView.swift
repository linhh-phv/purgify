import SwiftUI

/// Modal sheet shown after a successful clean.
/// Conveys the freed amount, the items-cleaned count, and (conditionally) upsells
/// Advanced scanning if the user hasn't enabled it yet.
struct CleanSuccessView: View {
    @EnvironmentObject var l10n: LocalizationManager
    @EnvironmentObject var fdaStatus: FDAStatus
    @Environment(\.dismiss) var dismiss

    let freedBytes: Int64
    let itemCount: Int
    let categoryCount: Int

    /// Called when user taps "Enable" in the upsell — parent is expected to
    /// flip `advancedScanningEnabled` and open the FDA guide.
    let onEnableAdvanced: () -> Void

    @AppStorage("advancedScanningEnabled") private var advancedEnabled = false

    /// Hide the upsell once the user already has the toggle ON *and* FDA
    /// granted — at that point there's nothing left to unlock.
    private var showUpsell: Bool { !(advancedEnabled && fdaStatus.isGranted) }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(l10n.t("cleanSuccess.title"))
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)

            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)

            // Hero + amount
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.riskSafeBadgeBg)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.riskSafe)
                    )
                    .padding(.top, 32)
                    .padding(.bottom, 20)

                Text(l10n.t("cleanSuccess.youFreed"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Text(ByteFormatter.format(freedBytes))
                    .font(.system(size: 42, weight: .bold).monospacedDigit())
                    .foregroundColor(.primary)
                    .padding(.top, 2)

                Text(itemsCleanedText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.top, 6)
            }

            // Upsell card (conditional)
            if showUpsell {
                upsellCard
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
            }

            // Primary button
            Button {
                dismiss()
            } label: {
                Text(l10n.t("cleanSuccess.done"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.brand)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
            .padding(.horizontal, 24)
            .padding(.top, showUpsell ? 20 : 32)
            .padding(.bottom, 24)
        }
        .frame(width: 440)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Subviews

    private var upsellCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 16))
                .foregroundColor(.brand)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.t("cleanSuccess.upsellTitle"))
                    .font(.system(size: 13, weight: .medium))
                Text(l10n.t("cleanSuccess.upsellSubtitle"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            Button {
                onEnableAdvanced()
            } label: {
                Text(l10n.t("cleanSuccess.enable"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 28)
                    .background(Color.brand)
                    .cornerRadius(7)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.brandSurface)
        .cornerRadius(10)
    }

    private var itemsCleanedText: String {
        if itemCount == 1 {
            return l10n.t("cleanSuccess.oneItemCleaned")
        }
        return l10n.t("cleanSuccess.itemsCleaned")
            .replacingOccurrences(of: "%1", with: "\(itemCount)")
            .replacingOccurrences(of: "%2", with: "\(categoryCount)")
    }
}
