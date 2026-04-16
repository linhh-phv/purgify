import SwiftUI
import ServiceManagement

/// Settings sheet (320pt wide, height auto-sized to content).
struct SettingsView: View {
    @EnvironmentObject var l10n: LocalizationManager

    @Environment(\.dismiss) var dismiss

    @State private var launchAtLogin = false
    @State private var showAbout = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title bar row
            HStack {
                Text(l10n.t("settings.title"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 20)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                // GENERAL section
                sectionLabel(l10n.t("settings.general"))

                groupBox {
                    // Language row
                    HStack {
                        Text(l10n.t("settings.language"))
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                        Spacer()
                        LanguageToggle()
                    }

                    Divider()

                    // Launch at Login row
                    HStack {
                        Text(l10n.t("settings.launchAtLogin"))
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
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

                // ABOUT section
                sectionLabel(l10n.t("settings.about"))
                    .padding(.top, 8)

                groupBox {
                    // About Purgify row → opens About sheet
                    Button { showAbout = true } label: {
                        HStack(spacing: 10) {
                            miniIcon
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Purgify")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(l10n.t("settings.versionShort"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Divider()

                    linkRow(label: l10n.t("settings.githubRepo")) {
                        NSWorkspace.shared.open(URL(string: "https://github.com/linhh-phv/purgify")!)
                    }

                    Divider()

                    linkRow(label: l10n.t("settings.sendFeedback"), disabled: true) {}
                }
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
        .sheet(isPresented: $showAbout) {
            AboutView()
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

    private var miniIcon: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(red: 0.071, green: 0.392, blue: 0.918))
            .frame(width: 36, height: 36)
            .overlay(
                Text("P")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}
