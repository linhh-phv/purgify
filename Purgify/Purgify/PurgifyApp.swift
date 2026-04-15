import SwiftUI
import Combine

@main
struct PurgifyApp: App {
    var body: some Scene {
        MenuBarExtra("Purgify", systemImage: "trash.slash.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)

        Window("Purgify", id: "main") {
            MainWindowView()
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1080, height: 760)
    }

    init() {
        CacheScanner.shared.scan()
    }
}
