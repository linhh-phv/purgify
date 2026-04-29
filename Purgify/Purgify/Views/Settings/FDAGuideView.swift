import SwiftUI
import AppKit

/// Modal sheet shown when user taps "Grant Full Disk Access" in Settings.
/// Explains the 3-step flow to grant FDA in System Settings (macOS does not
/// expose an API to request FDA — user must toggle it manually).
struct FDAGuideView: View {
    @EnvironmentObject var l10n: LocalizationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(l10n.t("fda.title"))
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)

            Divider()

            VStack(spacing: 20) {
                // Hero icon
                Circle()
                    .fill(Color.brand.opacity(0.12))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundColor(.brand)
                    )
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    Text(l10n.t("fda.heading"))
                        .font(.system(size: 20, weight: .bold))
                    Text(l10n.t("fda.subheading"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 3 steps
                VStack(alignment: .leading, spacing: 16) {
                    stepRow(number: 1,
                            title: l10n.t("fda.step1.title"),
                            desc: l10n.t("fda.step1.desc"))
                    stepRow(number: 2,
                            title: l10n.t("fda.step2.title"),
                            desc: l10n.t("fda.step2.desc"))
                    stepRow(number: 3,
                            title: l10n.t("fda.step3.title"),
                            desc: l10n.t("fda.step3.desc"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Primary button
                Button {
                    openFDASettings()
                } label: {
                    Text(l10n.t("fda.primaryButton"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.brand)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Secondary — dismiss
                Button {
                    dismiss()
                } label: {
                    Text(l10n.t("fda.secondaryLink"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 440)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func stepRow(number: Int, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(Color.brand)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    /// Open System Settings → Privacy & Security → Full Disk Access.
    private func openFDASettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }
}
