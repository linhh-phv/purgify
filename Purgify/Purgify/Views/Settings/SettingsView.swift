import SwiftUI
import ServiceManagement

/// Compact Settings sheet (320pt wide). Three sections: General, Advanced, About.
/// About is deliberately minimal — just version + author + links — so the sheet
/// stays short enough to not scroll on typical screens.
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
        return "v\(v) (\(b))"
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            VStack(alignment: .leading, spacing: 4) {

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
                    .padding(.top, 10)

                groupBox {
                    HStack(alignment: .center) {
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
                            .frame(height: 34)
                            .background(Color.brand)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                }

                // MARK: About (compact)
                sectionLabel(l10n.t("settings.about"))
                    .padding(.top, 10)

                groupBox {
                    HStack(spacing: 0) {
                        Text("Purgify")
                            .font(.system(size: 13, weight: .semibold))
                        Text(" · \(versionString)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(l10n.t("about.author"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.brand)
                    }

                    Divider()

                    linkRow(label: l10n.t("settings.sendFeedback"), disabled: true) {}
                }

                Text(l10n.t("about.copyright"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
            .padding(.leading, 4)
            .padding(.bottom, 4)
    }

    private func groupBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgCard)
        .cornerRadius(10)
    }

    private func linkRow(label: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(disabled ? .secondary : .brand)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
