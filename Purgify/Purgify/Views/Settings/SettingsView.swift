import SwiftUI
import ServiceManagement

/// Settings sheet (320pt wide, height auto-sized to content).
struct SettingsView: View {
    @EnvironmentObject var l10n: LocalizationManager

    @Environment(\.dismiss) var dismiss

    @State private var launchAtLogin = false
    @AppStorage("advancedScanningEnabled") private var advancedEnabled = false
    @State private var showFDAGuide = false

    /// Name + SF Symbol + color for each FDA-gated cache shown when Advanced is ON.
    private let advancedCaches: [(name: String, icon: String, color: Color)] = [
        ("cache.safari",            "safari.fill",                   Color(red: 0.06, green: 0.71, blue: 0.93)),
        ("cache.mailDownloads",     "envelope.fill",                 Color(red: 0.00, green: 0.48, blue: 1.00)),
        ("cache.appleMusic",        "music.note.house.fill",         Color(red: 0.99, green: 0.24, blue: 0.27)),
        ("cache.diagnosticReports", "exclamationmark.triangle.fill", Color(red: 0.56, green: 0.56, blue: 0.58))
    ]

    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(v) (Build \(b))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title bar
            HStack {
                Text(l10n.t("settings.title"))
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
            .padding(.vertical, 20)

            Divider()

            VStack(alignment: .leading, spacing: 6) {

                // MARK: General
                sectionLabel(l10n.t("settings.general"))

                groupBox {
                    HStack {
                        Text(l10n.t("settings.language"))
                            .font(.system(size: 13))
                        Spacer()
                        LanguageToggle()
                    }

                    Divider()

                    HStack {
                        Text(l10n.t("settings.launchAtLogin"))
                            .font(.system(size: 13))
                        Spacer()
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .onChange(of: launchAtLogin) { newValue in
                                if #available(macOS 13.0, *) {
                                    if newValue {
                                        try? SMAppService.mainApp.register()
                                    } else {
                                        try? SMAppService.mainApp.unregister()
                                    }
                                }
                            }
                    }
                }

                // MARK: Advanced Scanning
                sectionLabel(l10n.t("settings.advanced"))
                    .padding(.top, 8)

                groupBox {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(l10n.t("settings.advanced.toggle"))
                                .font(.system(size: 13))
                            Text(l10n.t("settings.advanced.subtitle"))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $advancedEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }

                if advancedEnabled {
                    groupBox {
                        ForEach(Array(advancedCaches.enumerated()), id: \.offset) { index, cache in
                            HStack(spacing: 10) {
                                Image(systemName: cache.icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(cache.color)
                                    .frame(width: 16)
                                Text(l10n.t(cache.name))
                                    .font(.system(size: 12))
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            if index < advancedCaches.count - 1 {
                                Divider()
                            }
                        }
                    }

                    Button {
                        showFDAGuide = true
                    } label: {
                        Text(l10n.t("settings.advanced.grantButton"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color.accentColor)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }

                // MARK: About
                sectionLabel(l10n.t("settings.about"))
                    .padding(.top, 8)

                // App icon + name + version (centered)
                VStack(spacing: 8) {
                    appIcon
                    Text("Purgify")
                        .font(.system(size: 18, weight: .bold))
                    Text(versionString)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(l10n.t("about.description"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

                // Author + links
                groupBox {
                    HStack(spacing: 8) {
                        Text(l10n.t("about.madeBy"))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(l10n.t("about.author"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.accentColor)
                        Spacer()
                    }

                    Divider()

                    linkRow(label: l10n.t("about.viewOnGitHub")) {
                        NSWorkspace.shared.open(URL(string: "https://github.com/linhh-phv/purgify")!)
                    }

                    Divider()

                    linkRow(label: l10n.t("settings.sendFeedback"), disabled: true) {}
                }

                // Copyright
                Text(l10n.t("about.copyright"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(24)
        }
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            if #available(macOS 13.0, *) {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
        .sheet(isPresented: $showFDAGuide) {
            FDAGuideView()
                .environmentObject(l10n)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
    }

    private func groupBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }

    private func linkRow(label: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(disabled ? .secondary : .accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private var appIcon: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color(red: 0.071, green: 0.392, blue: 0.918))
            .frame(width: 72, height: 72)
            .overlay(
                HStack(spacing: 0) {
                    Text("P")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    Text("✦")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .offset(y: -14)
                }
            )
    }
}
