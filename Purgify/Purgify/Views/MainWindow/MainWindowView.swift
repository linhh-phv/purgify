import SwiftUI

/// Root view of the main window.
/// State machine: Scanning → Empty → 3-column layout.
struct MainWindowView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    @State private var showSettings = false
    @State private var showFDAGuide = false
    @AppStorage("advancedScanningEnabled") private var advancedEnabled = false

    var body: some View {
        Group {
            // Show full-screen ScanningView only on the very first moments of
            // a fresh scan when no items have streamed in yet. As soon as the
            // first item appears, transition to the 3-column layout — even if
            // scanning is still running for the rest. This gives the user
            // visible feedback within ~100ms instead of blocking the entire UI
            // for the duration of the scan.
            if scanner.isScanning && scanner.items.isEmpty {
                ScanningView()
            } else if scanner.isEmptyState {
                EmptyStateView()
            } else {
                threeColumnLayout
            }
        }
        .frame(minWidth: 960, minHeight: 700)
        .onAppear { scanner.scanIfNeeded() }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(l10n)
        }
        .sheet(isPresented: $scanner.showCleanSuccess) {
            CleanSuccessView(
                freedBytes: scanner.lastCleanedBytes,
                itemCount: scanner.lastCleanedCount,
                categoryCount: scanner.lastCleanedCategoryCount,
                onEnableAdvanced: {
                    advancedEnabled = true
                    scanner.showCleanSuccess = false
                    // Defer FDA guide to next runloop so the sheet transition
                    // completes before the new sheet tries to present.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showFDAGuide = true
                    }
                }
            )
            .environmentObject(l10n)
        }
        .sheet(isPresented: $showFDAGuide) {
            FDAGuideView()
                .environmentObject(l10n)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Selection UI — always mounted (opacity hides when nothing
                // selected) so the toolbar chrome height stays stable. Also
                // hidden during a scan: items aren't cleared while a re-scan
                // runs, so selectedBytes can still be > 0 and would otherwise
                // render the Clean button on top of ScanningView.
                Text("\(ByteFormatter.format(scanner.selectedBytes)) \(l10n.t("app.selected").lowercased())")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .opacity(toolbarVisible ? 1 : 0)

                Button {
                    scanner.clean()
                } label: {
                    HStack(spacing: 7) {
                        if scanner.isCleaning {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                        }
                        Text(l10n.t(scanner.isCleaning ? "app.cleaning" : "app.cleanSelected"))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .frame(height: 28)
                    .frame(minWidth: 132)
                    .background(Color.brand)
                    .cornerRadius(7)
                }
                .buttonStyle(.plain)
                .disabled(scanner.isCleaning || scanner.selectedBytes == 0)
                .opacity(toolbarVisible ? 1 : 0)
                .allowsHitTesting(toolbarVisible)
                .keyboardShortcut(.return, modifiers: [.command])
                .padding(.trailing, 12)
            }
        }
    }

    /// Toolbar selection UI is only relevant on the 3-column layout. Allow it
    /// during a streaming scan (items.isEmpty=false guards the layout switch)
    /// — user can clean already-discovered caches without waiting for the
    /// scan to finish.
    private var toolbarVisible: Bool {
        !scanner.items.isEmpty && !scanner.isEmptyState && scanner.selectedBytes > 0
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
