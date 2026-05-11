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

    /// Number of items removed by the most recent clean (used in success modal).
    @Published var lastCleanedCount: Int = 0

    /// Number of distinct risk categories touched by the most recent clean.
    @Published var lastCleanedCategoryCount: Int = 0

    /// Drives the Clean Success modal sheet presentation.
    @Published var showCleanSuccess: Bool = false

    // Selection state for 3-column layout
    @Published var selectedRisk: RiskLevel = .safe
    @Published var selectedItemID: UUID? = nil {
        didSet { applyCachedRelatedApps() }
    }

    // Related projects for the selected item.
    // Search is user-initiated via `searchRelatedProjects()` — selecting an
    // item does NOT auto-trigger the scan, because that scan reads the user's
    // Documents/Desktop/Downloads folders and macOS shows a TCC permission
    // prompt. Auto-firing it right after the cache scan ambushes the user
    // with a permission dialog they didn't ask for.
    @Published var relatedApps: [RelatedApp] = []
    @Published var isLoadingRelatedApps = false
    @Published var hasProjectDirAccess = true

    var selectedItemHasProjectIndicators: Bool {
        guard let item = selectedItem else { return false }
        return !(definitions.first { $0.nameKey == item.nameKey }?.projectIndicators ?? []).isEmpty
    }

    /// True once the user has triggered a related-projects search for the
    /// currently selected item in this session. Drives whether the detail
    /// panel shows the "Find related projects" button or the result list.
    var hasSearchedRelatedAppsForSelected: Bool {
        guard let item = selectedItem else { return false }
        return relatedAppsCache[item.nameKey] != nil
    }

    // MARK: - Private

    private var hasScanned = false
    private let service: any CacheScanService
    private let definitions: [CacheDefinition]
    private var relatedAppsTask: Task<Void, Never>?
    private var relatedAppsCache: [String: [RelatedApp]] = [:]
    private let fdaStatus: FDAStatus?
    private var fdaGrantSubscription: AnyCancellable?

    // MARK: - Init

    init(
        service: any CacheScanService = LocalCacheScanService(),
        definitions: [CacheDefinition] = CacheDefinitions.all,
        fdaStatus: FDAStatus? = nil
    ) {
        self.service = service
        self.definitions = definitions
        self.fdaStatus = fdaStatus

        // Auto re-scan when the user grants FDA in System Settings and the
        // app returns to the foreground — surfaces the newly-readable caches
        // without requiring the user to re-trigger a scan manually.
        if let fdaStatus {
            fdaGrantSubscription = fdaStatus.didGrantPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else { return }
                    let advancedEnabled = UserDefaults.standard.bool(forKey: "advancedScanningEnabled")
                    // Skip auto-rescan during a clean — clearing `items` mid-clean
                    // races with the in-flight task and pops the success modal
                    // on top of a fresh scan. User can re-scan manually after.
                    guard advancedEnabled, self.hasScanned, !self.isScanning, !self.isCleaning else { return }
                    self.scan()
                }
        }
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
        // Block scans while a clean is in flight — `items = []` here would
        // race with `applyCleanResultLocally` and leave the success modal
        // popping on top of a fresh scan. UI buttons should already be
        // disabled; this guards programmatic callers (FDA subscription).
        guard !isCleaning else { return }
        hasScanned = true
        isScanning = true
        scanProgress = 0
        currentScanItem = ""
        selectedItemID = nil
        items = []

        if !keepCleanedFlag {
            justCleaned = false
            lastCleanedBytes = 0
        }

        // Only include FDA-gated caches when both the toggle is ON *and* the
        // permission is actually granted. Without the FDA check, scans would
        // silently return 0 bytes for those paths — confusing the user.
        let advancedEnabled = UserDefaults.standard.bool(forKey: "advancedScanningEnabled")
        let fdaGranted = fdaStatus?.isGranted ?? false
        let defs = definitions.filter { !$0.requiresFDA || (advancedEnabled && fdaGranted) }
        let svc = service

        scanItemTotal = defs.count
        scanItemIndex = 0

        Task.detached(priority: .userInitiated) { [weak self] in
            let total = Double(defs.count)

            for (index, def) in defs.enumerated() {
                await MainActor.run { [weak self] in
                    self?.currentScanItem = def.nameKey
                    self?.scanProgress = Double(index) / total
                    self?.scanItemIndex = index + 1
                }

                // User-file scan branch (Installers, Archives, Disc images):
                // walk multiple roots, filter by extension, surface last-used
                // dates. Parent row is built with sub-items inline — no follow-up
                // background task — because the walk IS the sub-item scan.
                if def.isUserFileScan {
                    let userFileItem = Self.scanUserFiles(def: def, service: svc)
                    if let userFileItem {
                        await MainActor.run { [weak self] in
                            self?.appendStreamedItem(userFileItem)
                        }
                    }
                    continue
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
                item.isLoadingSubItems = (def.subItemMode != .none)

                // Stream parent into the UI immediately so the row appears
                // while sub-items (which can be slow for Xcode/Homebrew) keep
                // scanning in the background.
                let parentItem = item
                await MainActor.run { [weak self] in
                    self?.appendStreamedItem(parentItem)
                }

                // Fork sub-item scan as a child task so the main loop can
                // proceed to the next def without waiting.
                if def.subItemMode != .none {
                    Task.detached(priority: .utility) { [weak self] in
                        let subItems = Self.scanSubItems(def: def, expandedPath: expanded, service: svc)
                        await MainActor.run { [weak self] in
                            self?.applySubItems(itemID: parentItem.id, subItems: subItems)
                        }
                    }
                }
            }

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isScanning = false
                self.scanProgress = 1.0
                self.currentScanItem = ""
            }
        }
    }

    /// Append a freshly-scanned parent item to the visible list. Auto-select
    /// the first risk + first item once when the first item arrives so the
    /// detail panel populates without further user action.
    private func appendStreamedItem(_ item: CacheItem) {
        items.append(item)
        if selectedItemID == nil {
            if let firstRisk = riskSummary.first?.0 {
                selectedRisk = firstRisk
            }
            if let firstItem = filteredItems.first {
                selectedItemID = firstItem.id
            }
        }
    }

    /// Replace placeholder sub-items on a parent item once the background scan
    /// finishes. No-op if the parent has been cleaned away in the meantime.
    private func applySubItems(itemID: UUID, subItems: [SubItem]) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].subItems = subItems
        items[idx].isLoadingSubItems = false
    }

    /// Build a CacheItem for a user-file definition (Installers / Archives /
    /// Disc images). Walks every configured scan root, filters by extension,
    /// and returns nil if no files match — caller skips empty groups so the
    /// list doesn't show empty rows. Sub-items are sorted oldest-first so the
    /// most stale entries surface at the top for review.
    private nonisolated static func scanUserFiles(def: CacheDefinition, service: any CacheScanService) -> CacheItem? {
        let roots = ([def.path] + (def.additionalScanRoots ?? []))
            .map { ($0 as NSString).expandingTildeInPath }
        let exts = def.fileExtensions ?? []
        let files = service.userFiles(roots: roots, extensions: exts)
        guard !files.isEmpty else { return nil }

        let totalSize = files.reduce(0 as Int64) { $0 + $1.sizeBytes }
        var subItems: [SubItem] = files.map { f in
            SubItem(
                name: f.name,
                path: f.path,
                sizeBytes: f.sizeBytes,
                modifiedDate: f.lastUsedDate,
                isSelected: false,
                dateLabelKey: "subitem.lastUsed"
            )
        }
        // Oldest last-used first; tie-break by largest size so the most
        // valuable cleanup candidates surface together at the top.
        subItems.sort { lhs, rhs in
            let l = lhs.modifiedDate ?? .distantPast
            let r = rhs.modifiedDate ?? .distantPast
            if l != r { return l < r }
            return lhs.sizeBytes > rhs.sizeBytes
        }

        var item = CacheItem(
            nameKey: def.nameKey,
            detailKey: def.detailKey,
            path: def.path,
            icon: def.icon,
            iconColor: def.iconColor,
            risk: def.risk,
            sizeBytes: totalSize
        )
        item.isSelected = false   // user files: never auto-tick the parent
        item.subItemMode = .files
        item.isLoadingSubItems = false
        item.subItems = subItems
        return item
    }

    private nonisolated static func scanSubItems(def: CacheDefinition, expandedPath: String, service: any CacheScanService) -> [SubItem] {
        let scanPath = def.subItemsPath.map { ($0 as NSString).expandingTildeInPath } ?? expandedPath
        switch def.subItemMode {
        case .directories:
            let subDirs = service.subDirectories(at: scanPath)
            var subItems: [SubItem] = subDirs.map { dir in
                SubItem(
                    name: dir.name,
                    path: dir.path,
                    sizeBytes: service.sizeOfDirectory(at: dir.path),
                    modifiedDate: dir.modifiedDate,
                    isSelected: true
                )
            }
            subItems.sort { $0.sizeBytes > $1.sizeBytes }
            return subItems
        case .files:
            let files = service.subFiles(at: scanPath)
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
            return subItems
        case .none:
            return []
        }
    }

    // MARK: - Clean

    func clean() {
        // Re-entrancy guard: Cmd+Return shortcut + .disabled() can race when a
        // user spams the key faster than SwiftUI propagates the disabled state.
        guard !isCleaning else { return }
        let toClean = items.filter(\.isSelected)
        guard !toClean.isEmpty else { return }
        let touchedRisks = Set(toClean.map(\.risk))
        let itemCount = toClean.count
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
                guard let self else { return }
                self.lastCleanedBytes = freed
                self.lastCleanedCount = itemCount
                self.lastCleanedCategoryCount = touchedRisks.count
                self.isCleaning = false
                self.justCleaned = freed > 0
                self.applyCleanResultLocally(itemIDs: toClean.map(\.id))
                self.showCleanSuccess = freed > 0
            }
        }
    }

    func cleanItem(_ id: UUID) {
        guard !isCleaning else { return }
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
                guard let self else { return }
                self.lastCleanedBytes = freed
                self.lastCleanedCount = 1
                self.lastCleanedCategoryCount = 1
                self.isCleaning = false
                self.justCleaned = freed > 0
                self.applyCleanResultLocally(itemIDs: [id])
                self.showCleanSuccess = freed > 0
            }
        }
    }

    /// Update `items` in place after a clean — avoids a full rescan.
    /// Fully-cleaned items are removed; partially-cleaned items (sub-items with
    /// only some selected) stay in the list with their selected sub-items removed
    /// and `sizeBytes` recomputed.
    private func applyCleanResultLocally(itemIDs: [UUID]) {
        for id in itemIDs {
            guard let idx = items.firstIndex(where: { $0.id == id }) else { continue }
            if let subs = items[idx].subItems {
                let remaining = subs.filter { !$0.isSelected }
                if remaining.isEmpty {
                    items.remove(at: idx)
                } else {
                    items[idx].subItems = remaining
                    items[idx].sizeBytes = remaining.reduce(0) { $0 + $1.sizeBytes }
                }
            } else {
                items.remove(at: idx)
            }
        }

        // Re-anchor selection — current selection may have been removed.
        if selectedItemID != nil && !items.contains(where: { $0.id == selectedItemID }) {
            selectedItemID = filteredItems.first?.id
        }
        if !riskSummary.contains(where: { $0.0 == selectedRisk }) {
            if let firstRisk = riskSummary.first?.0 {
                selectedRisk = firstRisk
                selectedItemID = filteredItems.first?.id
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

    /// Called from `selectedItemID.didSet`. Surfaces a previously-searched
    /// result if there is one, otherwise leaves `relatedApps` empty so the
    /// detail panel renders the "Find related projects" button. Never spawns
    /// a new search — that's `searchRelatedProjects()`'s job.
    private func applyCachedRelatedApps() {
        relatedAppsTask?.cancel()
        isLoadingRelatedApps = false

        guard let item = selectedItem else {
            relatedApps = []
            return
        }
        relatedApps = relatedAppsCache[item.nameKey] ?? []
    }

    /// Trigger the related-projects search for the currently selected item.
    /// User-initiated: a button in the detail panel calls this so the TCC
    /// folder-access prompt (Documents/Desktop) only fires when the user is
    /// actively asking for the result.
    func searchRelatedProjects() {
        guard let item = selectedItem else { return }
        let indicators = definitions.first { $0.nameKey == item.nameKey }?.projectIndicators ?? []
        guard !indicators.isEmpty else { return }

        // Cache hit — show immediately, no need to re-scan.
        if let cached = relatedAppsCache[item.nameKey] {
            relatedApps = cached
            return
        }

        // Don't start a second search if one is already running for the same item.
        guard !isLoadingRelatedApps else { return }

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
