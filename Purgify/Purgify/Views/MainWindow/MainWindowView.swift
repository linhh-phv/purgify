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
            if scanner.isScanning {
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
                // selected) so the toolbar chrome height stays stable.
                Text("\(ByteFormatter.format(scanner.selectedBytes)) \(l10n.t("app.selected").lowercased())")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .opacity(scanner.selectedBytes > 0 ? 1 : 0)

                Button {
                    scanner.clean()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text(l10n.t("app.cleanSelected"))
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
                .opacity(scanner.selectedBytes > 0 ? 1 : 0)
                .allowsHitTesting(scanner.selectedBytes > 0)
                .keyboardShortcut(.return, modifiers: [.command])
                .padding(.trailing, 12)
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
