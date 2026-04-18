import Foundation
import Combine
import AppKit

@MainActor
class CacheScannerViewModel: ObservableObject {

    // MARK: - Published State

    @Published var items: [CacheItem] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var lastCleanedBytes: Int64 = 0
    @Published var scanProgress: Double = 0
    @Published var currentScanItem: String = ""
    @Published var scanItemIndex: Int = 0
    @Published var scanItemTotal: Int = 0

    /// True when the most recent scan followed a successful clean — drives
    /// "You freed X GB" text in the empty state and post-clean upsell banner.
    @Published var justCleaned: Bool = false

    // Selection state for 3-column layout
    @Published var selectedRisk: RiskLevel = .safe
    @Published var selectedItemID: UUID? = nil {
        didSet { loadRelatedAppsIfNeeded() }
    }

    // Related projects for the selected item (lazy-loaded)
    @Published var relatedApps: [RelatedApp] = []
    @Published var isLoadingRelatedApps = false
    @Published var hasProjectDirAccess = true

    var selectedItemHasProjectIndicators: Bool {
        guard let item = selectedItem else { return false }
        return !(definitions.first { $0.nameKey == item.nameKey }?.projectIndicators ?? []).isEmpty
    }

    // MARK: - Private

    private var hasScanned = false
    private let service: any CacheScanService
    private let definitions: [CacheDefinition]
    private var relatedAppsTask: Task<Void, Never>?
    private var relatedAppsCache: [String: [RelatedApp]] = [:]

    // MARK: - Init

    init(
        service: any CacheScanService = LocalCacheScanService(),
        definitions: [CacheDefinition] = CacheDefinitions.all
    ) {
        self.service = service
        self.definitions = definitions
    }

    // MARK: - Computed Properties

    var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    var selectedBytes: Int64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes }
    }

    var selectedItem: CacheItem? {
        guard let id = selectedItemID else { return nil }
        return items.first { $0.id == id }
    }

    var filteredItems: [CacheItem] {
        items.filter { $0.risk == selectedRisk }
    }

    /// (risk, itemCount, totalBytes) for sidebar display
    var riskSummary: [(RiskLevel, Int, Int64)] {
        RiskLevel.allCases.compactMap { risk in
            let filtered = items.filter { $0.risk == risk }
            guard !filtered.isEmpty else { return nil }
            let total = filtered.reduce(0 as Int64) { $0 + $1.sizeBytes }
            return (risk, filtered.count, total)
        }
    }

    var isEmptyState: Bool {
        !isScanning && items.isEmpty && hasScanned
    }

    /// Items nhóm theo RiskLevel (kept for MenuBarView)
    var itemsByRisk: [(RiskLevel, [CacheItem])] {
        RiskLevel.allCases.compactMap { risk in
            let filtered = items.filter { $0.risk == risk }
            return filtered.isEmpty ? nil : (risk, filtered)
        }
    }

    // MARK: - Scan

    func scanIfNeeded() {
        guard !hasScanned else { return }
        scan()
    }

    func scan(keepCleanedFlag: Bool = false) {
        hasScanned = true
        isScanning = true
        scanProgress = 0
        currentScanItem = ""
        selectedItemID = nil

        if !keepCleanedFlag {
            justCleaned = false
            lastCleanedBytes = 0
        }

        let advancedEnabled = UserDefaults.standard.bool(forKey: "advancedScanningEnabled")
        let defs = definitions.filter { !$0.requiresFDA || advancedEnabled }
        let svc = service

        scanItemTotal = defs.count
        scanItemIndex = 0

        Task.detached(priority: .userInitiated) { [weak self] in
            var scanned: [CacheItem] = []
            let total = Double(defs.count)

            for (index, def) in defs.enumerated() {
                await MainActor.run { [weak self] in
                    self?.currentScanItem = def.nameKey
                    self?.scanProgress = Double(index) / total
                    self?.scanItemIndex = index + 1
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
                    iconColor: def.iconColor,
                    risk: def.risk,
                    sizeBytes: size
                )
                if def.risk == .safe { item.isSelected = true }
                item.subItemMode = def.subItemMode

                // Scan sub-items based on mode
                switch def.subItemMode {
                case .directories:
                    let scanPath = def.subItemsPath.map { ($0 as NSString).expandingTildeInPath } ?? expanded
                    let subDirs = svc.subDirectories(at: scanPath)
                    var subItems: [SubItem] = subDirs.map { dir in
                        SubItem(
                            name: dir.name,
                            path: dir.path,
                            sizeBytes: svc.sizeOfDirectory(at: dir.path),
                            modifiedDate: dir.modifiedDate,
                            isSelected: true
                        )
                    }
                    subItems.sort { $0.sizeBytes > $1.sizeBytes }
                    item.subItems = subItems

                case .files:
                    let scanPath = def.subItemsPath.map { ($0 as NSString).expandingTildeInPath } ?? expanded
                    let files = svc.subFiles(at: scanPath)
                    var subItems: [SubItem] = files.map { file in
                        // Strip hash prefix from Homebrew filenames (e.g. "abc123--node-20.tar.gz" → "node-20.tar.gz")
                        let displayName = Self.cleanFileName(file.name)
                        return SubItem(
                            name: displayName,
                            path: file.path,
                            sizeBytes: file.sizeBytes,
                            modifiedDate: file.modifiedDate,
                            isSelected: true
                        )
                    }
                    subItems.sort { $0.sizeBytes > $1.sizeBytes }
                    item.subItems = subItems

                case .none:
                    break
                }

                scanned.append(item)
            }

            scanned.sort { $0.sizeBytes > $1.sizeBytes }

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.items = scanned
                self.isScanning = false
                self.scanProgress = 1.0
                self.currentScanItem = ""
                // Auto-select first available risk that has items
                if let firstRisk = self.riskSummary.first?.0 {
                    self.selectedRisk = firstRisk
                }
                // Auto-select first item in that risk category for detail panel
                if let firstItem = self.filteredItems.first {
                    self.selectedItemID = firstItem.id
                }
            }
        }
    }

    // MARK: - Clean

    func clean() {
        let toClean = items.filter(\.isSelected)
        isCleaning = true
        lastCleanedBytes = 0
        let svc = service

        Task.detached(priority: .userInitiated) { [weak self] in
            var freed: Int64 = 0
            for item in toClean {
                if item.hasSubItems, let subItems = item.subItems {
                    // Clean only selected sub-items
                    let selectedSubs = subItems.filter(\.isSelected)
                    if selectedSubs.count == subItems.count {
                        // All selected → remove parent
                        freed += item.sizeBytes
                        try? svc.removeItem(at: item.expandedPath)
                    } else {
                        for sub in selectedSubs {
                            freed += sub.sizeBytes
                            try? svc.removeItem(at: sub.path)
                        }
                    }
                } else {
                    freed += item.sizeBytes
                    try? svc.removeItem(at: item.expandedPath)
                }
            }
            await MainActor.run { [weak self] in
                self?.lastCleanedBytes = freed
                self?.isCleaning = false
                self?.justCleaned = freed > 0
                self?.scan(keepCleanedFlag: true)
            }
        }
    }

    func cleanItem(_ id: UUID) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        isCleaning = true
        let svc = service

        Task.detached(priority: .userInitiated) { [weak self] in
            var freed: Int64 = 0
            if item.hasSubItems, let subItems = item.subItems {
                let selectedSubs = subItems.filter(\.isSelected)
                if selectedSubs.count == subItems.count {
                    freed = item.sizeBytes
                    try? svc.removeItem(at: item.expandedPath)
                } else {
                    for sub in selectedSubs {
                        freed += sub.sizeBytes
                        try? svc.removeItem(at: sub.path)
                    }
                }
            } else {
                freed = item.sizeBytes
                try? svc.removeItem(at: item.expandedPath)
            }
            await MainActor.run { [weak self] in
                self?.lastCleanedBytes = freed
                self?.isCleaning = false
                self?.justCleaned = freed > 0
                self?.scan(keepCleanedFlag: true)
            }
        }
    }

    // MARK: - Selection (risk categories)

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

    func selectAllInCurrentRisk() {
        selectAll(risk: selectedRisk)
    }

    func deselectAllInCurrentRisk() {
        deselectAll(risk: selectedRisk)
    }

    // MARK: - Sub-item management

    func toggleSubItem(itemID: UUID, subItemID: UUID) {
        guard let itemIdx = items.firstIndex(where: { $0.id == itemID }),
              let subIdx = items[itemIdx].subItems?.firstIndex(where: { $0.id == subItemID })
        else { return }
        items[itemIdx].subItems?[subIdx].isSelected.toggle()
    }

    func selectAllSubItems(itemID: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        for i in (items[idx].subItems?.indices ?? 0..<0) {
            items[idx].subItems?[i].isSelected = true
        }
    }

    func deselectAllSubItems(itemID: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        for i in (items[idx].subItems?.indices ?? 0..<0) {
            items[idx].subItems?[i].isSelected = false
        }
    }

    // MARK: - Related Projects

    private func loadRelatedAppsIfNeeded() {
        relatedAppsTask?.cancel()
        relatedApps = []

        guard let item = selectedItem else { return }
        let indicators = definitions.first { $0.nameKey == item.nameKey }?.projectIndicators ?? []
        guard !indicators.isEmpty else { return }

        // Return cached result instantly
        if let cached = relatedAppsCache[item.nameKey] {
            relatedApps = cached
            return
        }

        isLoadingRelatedApps = true
        let svc = service

        relatedAppsTask = Task.detached(priority: .background) { [weak self] in
            let result = svc.findRelatedProjects(indicators: indicators)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.relatedAppsCache[item.nameKey] = result.projects
                // Only apply if user still has same item selected
                if self.selectedItem?.nameKey == item.nameKey {
                    self.relatedApps = result.projects
                    self.hasProjectDirAccess = result.scannedRoots > 0
                }
                self.isLoadingRelatedApps = false
            }
        }
    }

    // MARK: - Utilities

    func openInFinder(_ path: String) {
        let expanded = (path as NSString).expandingTildeInPath
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: expanded)
    }

    /// Strip Homebrew hash prefix from filenames.
    /// "abc123--node-20.11.0.tar.gz" → "node-20.11.0.tar.gz"
    /// "abc123--Cask--docker.dmg"    → "docker.dmg"
    private nonisolated static func cleanFileName(_ name: String) -> String {
        if let range = name.range(of: "--") {
            var cleaned = String(name[range.upperBound...])
            // Strip "Cask--" prefix if present
            if cleaned.hasPrefix("Cask--") {
                cleaned = String(cleaned.dropFirst(6))
            }
            return cleaned
        }
        return name
    }
}
