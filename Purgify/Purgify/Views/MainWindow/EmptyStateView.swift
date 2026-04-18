import SwiftUI

/// Full-window "All Clean!" empty state.
struct EmptyStateView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Green circle with checkmark
            Circle()
                .fill(Color(nsColor: .systemGreen).opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color(nsColor: .systemGreen))
                )

            Text(l10n.t("app.allClean"))
                .font(.system(size: 22, weight: .bold))

            Text(subheadingText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            // Scan Again button
            Button {
                scanner.scan()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                    Text(l10n.t("sidebar.scanAgain"))
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var subheadingText: String {
        if scanner.justCleaned {
            let freed = ByteFormatter.format(scanner.lastCleanedBytes)
            return l10n.t("app.allCleanFreed").replacingOccurrences(of: "%@", with: freed)
        }
        return l10n.t("app.allCleanDesc")
    }
}
