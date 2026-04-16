import SwiftUI

/// About Purgify sheet (360×420).
struct AboutView: View {
    @EnvironmentObject var l10n: LocalizationManager

    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(v) (Build \(b))"
    }

    var body: some View {
        VStack(spacing: 0) {
            // App icon + name + version
            VStack(spacing: 8) {
                appIcon
                Text("Purgify")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Text(versionString)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 32)
            .padding(.bottom, 20)

            Divider().padding(.horizontal, 24)

            // Description
            Text(l10n.t("about.description"))
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.vertical, 20)

            Divider().padding(.horizontal, 24)

            // Author
            VStack(spacing: 4) {
                Text(l10n.t("about.madeBy"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(l10n.t("about.author"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 16)

            // GitHub button
            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/linhh-phv/purgify")!)
            } label: {
                Text("⭐  \(l10n.t("about.viewOnGitHub"))")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .frame(width: 200, height: 34)
                    .background(Color(nsColor: .separatorColor).opacity(0.5))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Spacer()

            // Copyright
            Text(l10n.t("about.copyright"))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .frame(width: 360, height: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - App Icon

    private var appIcon: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color(red: 0.071, green: 0.392, blue: 0.918))
            .frame(width: 80, height: 80)
            .overlay(
                HStack(spacing: 0) {
                    Text("P")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    Text("✦")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .offset(y: -16)
                }
            )
    }
}
