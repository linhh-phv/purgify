import SwiftUI

/// Root view of the main window.
/// State machine: Scanning → Empty → 3-column layout.
struct MainWindowView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    @State private var showSettings = false
    @State private var bannerHidden = false

    private var showBanner: Bool {
        !bannerHidden && PostCleanBanner.shouldShow(justCleaned: scanner.justCleaned)
    }

    var body: some View {
        VStack(spacing: 0) {
            if showBanner {
                PostCleanBanner(
                    onEnable: {
                        bannerHidden = true
                        showSettings = true
                    },
                    onDismiss: {
                        PostCleanBanner.recordDismiss()
                        bannerHidden = true
                    }
                )
            }

            Group {
                if scanner.isScanning {
                    ScanningView()
                } else if scanner.isEmptyState {
                    EmptyStateView()
                } else {
                    threeColumnLayout
                }
            }
        }
        .frame(minWidth: 960, minHeight: 700)
        .onAppear { scanner.scanIfNeeded() }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(l10n)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                toolbarActions
            }
        }
    }

    @ViewBuilder
    private var toolbarActions: some View {
        HStack(spacing: 12) {
            if scanner.justCleaned && scanner.lastCleanedBytes > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                    Text("\(l10n.t("app.freed")) \(ByteFormatter.format(scanner.lastCleanedBytes))")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(nsColor: .systemGreen))
            }

            if scanner.selectedBytes > 0 {
                Text("\(ByteFormatter.format(scanner.selectedBytes)) \(l10n.t("app.selected").lowercased())")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Button {
                    scanner.clean()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text(l10n.t("app.cleanSelected"))
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .disabled(scanner.isCleaning)
                .keyboardShortcut(.return, modifiers: [.command])
            }
        }
    }

    private var threeColumnLayout: some View {
        HStack(spacing: 0) {
            SidebarView()
            Divider()
            ContentListView()
            Divider()
            DetailPanelView()
        }
    }
}
