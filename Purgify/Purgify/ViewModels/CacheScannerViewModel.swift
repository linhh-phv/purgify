import Foundation
import Combine

/// ViewModel trung tâm của app.
///
/// **MVVM role:**
/// - Giữ toàn bộ UI state (@Published)
/// - Điều phối logic (scan, clean) thông qua CacheScanService
/// - KHÔNG biết gì về SwiftUI View — chỉ expose data + actions
///
/// **Dependency Injection:**
/// `service` được inject qua init → dễ thay bằng mock khi viết test.
@MainActor
class CacheScannerViewModel: ObservableObject {

    // MARK: - Published State (View lắng nghe các property này)

    @Published var items: [CacheItem] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var lastCleanedBytes: Int64 = 0
    @Published var scanProgress: Double = 0
    @Published var currentScanItem: String = ""

    // MARK: - Private

    private var hasScanned = false
    private let service: any CacheScanService
    private let definitions: [CacheDefinition]

    // MARK: - Init (Dependency Injection)

    /// - Parameters:
    ///   - service: tầng filesystem. Mặc định là LocalCacheScanService.
    ///              Thay bằng mock trong unit test.
    ///   - definitions: danh sách cache cần scan. Mặc định là CacheDefinitions.all.
    init(
        service: any CacheScanService = LocalCacheScanService(),
        definitions: [CacheDefinition] = CacheDefinitions.all
    ) {
        self.service = service
        self.definitions = definitions
    }

    // MARK: - Computed Properties (View dùng để render)

    var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    var selectedBytes: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.sizeBytes }
    }

    /// Items nhóm theo RiskLevel để render từng section
    var itemsByRisk: [(RiskLevel, [CacheItem])] {
        RiskLevel.allCases.compactMap { risk in
            let filtered = items.filter { $0.risk == risk }
            return filtered.isEmpty ? nil : (risk, filtered)
        }
    }

    // MARK: - Actions (View gọi các method này)

    func scanIfNeeded() {
        guard !hasScanned else { return }
        scan()
    }

    func scan() {
        hasScanned = true
        isScanning = true
        scanProgress = 0
        currentScanItem = ""

        let defs = definitions
        let total = Double(defs.count)
        let svc = service

        // Task.detached để filesystem I/O chạy off-main-thread
        Task.detached(priority: .userInitiated) { [weak self] in
            var scanned: [CacheItem] = []

            for (index, def) in defs.enumerated() {
                // Cập nhật progress trên MainActor
                await MainActor.run { [weak self] in
                    self?.currentScanItem = def.nameKey
                    self?.scanProgress = Double(index) / total
                }

                let expanded = (def.path as NSString).expandingTildeInPath
                guard svc.itemExists(at: expanded) else { continue }

                let size = svc.sizeOfDirectory(at: expanded)
                guard size > 0 else { continue }

                var item = CacheItem(
                    nameKey: def.nameKey,
                    detailKey: def.detailKey,
                    path: def.path,
                    icon: def.icon,
                    risk: def.risk,
                    sizeBytes: size
                )
                if def.risk == .safe { item.isSelected = true }
                scanned.append(item)
            }

            scanned.sort { $0.sizeBytes > $1.sizeBytes }

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.items = scanned
                self.isScanning = false
                self.scanProgress = 1.0
                self.currentScanItem = ""
            }
        }
    }

    func clean() {
        let toClean = items.filter { $0.isSelected }
        isCleaning = true
        lastCleanedBytes = 0
        let svc = service

        Task.detached(priority: .userInitiated) { [weak self] in
            var freed: Int64 = 0
            for item in toClean {
                freed += item.sizeBytes
                try? svc.removeItem(at: item.expandedPath)
            }
            await MainActor.run { [weak self] in
                self?.lastCleanedBytes = freed
                self?.isCleaning = false
                self?.scan()
            }
        }
    }

    func selectAll(risk: RiskLevel) {
        for i in items.indices where items[i].risk == risk {
            items[i].isSelected = true
        }
    }

    func deselectAll(risk: RiskLevel) {
        for i in items.indices where items[i].risk == risk {
            items[i].isSelected = false
        }
    }
}
