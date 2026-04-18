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
