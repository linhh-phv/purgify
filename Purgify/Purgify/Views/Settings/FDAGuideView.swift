import SwiftUI
import AppKit

/// Modal sheet shown when user taps "Grant Full Disk Access" in Settings.
/// Explains the 3-step flow to grant FDA in System Settings (macOS does not
/// expose an API to request FDA — user must toggle it manually).
struct FDAGuideView: View {
    @EnvironmentObject var l10n: LocalizationManager
    @EnvironmentObject var fdaStatus: FDAStatus
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(l10n.t(fdaStatus.isGranted ? "fda.titleGranted" : "fda.title"))
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

            if fdaStatus.isGranted {
                grantedBody
            } else {
                guideBody
            }
        }
        .frame(width: 440)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Subviews

    private var guideBody: some View {
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

            // macOS sometimes requires a relaunch for TCC to take effect for
            // already-running processes. Mention it so the user knows what to
            // do if the UI doesn't update automatically after granting.
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(l10n.t("fda.relaunchHint"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)

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
            .padding(.top, 4)

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

    /// Shown when the user lands here after FDA is already granted (e.g. they
    /// returned from System Settings and the observer flipped the state).
    private var grantedBody: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Color(nsColor: .systemGreen).opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(nsColor: .systemGreen))
                )
                .padding(.top, 28)

            VStack(spacing: 8) {
                Text(l10n.t("fda.grantedHeading"))
                    .font(.system(size: 20, weight: .bold))
                Text(l10n.t("fda.grantedSubheading"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }

            Button {
                dismiss()
            } label: {
                Text(l10n.t("fda.grantedDoneButton"))
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
            .padding(.top, 4)
            .padding(.bottom, 28)
        }
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
