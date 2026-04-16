import SwiftUI

/// Root view of the main window.
/// State machine: Scanning → Empty → 3-column layout.
struct MainWindowView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

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
