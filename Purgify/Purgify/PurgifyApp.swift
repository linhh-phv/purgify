import SwiftUI

/// App entry point.
///
/// **MVVM — Dependency Injection:**
/// ViewModel và Manager được tạo ở đây với @StateObject (SwiftUI quản lý lifecycle),
/// sau đó inject xuống toàn bộ View tree qua .environmentObject().
/// View không tự tạo ViewModel — chỉ nhận qua @EnvironmentObject.
@main
struct PurgifyApp: App {
    @StateObject private var scanner = CacheScannerViewModel()
    @StateObject private var l10n = LocalizationManager()

    var body: some Scene {
        MenuBarExtra("Purgify", systemImage: "sparkles") {
            MenuBarView()
                .environmentObject(scanner)
                .environmentObject(l10n)
        }
        .menuBarExtraStyle(.window)

        Window("Purgify", id: "main") {
            MainWindowView()
                .environmentObject(scanner)
                .environmentObject(l10n)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1080, height: 760)
    }
}
