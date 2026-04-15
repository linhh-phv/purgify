import Foundation
import Combine

enum RiskLevel: String, CaseIterable {
    case safe
    case moderate
    case caution

    var icon: String {
        switch self {
        case .safe: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .caution: return "xmark.shield.fill"
        }
    }

    func localizedName(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe: return l10n.t("risk.safe")
        case .moderate: return l10n.t("risk.moderate")
        case .caution: return l10n.t("risk.caution")
        }
    }

    func localizedDesc(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe: return l10n.t("risk.safe.desc")
        case .moderate: return l10n.t("risk.moderate.desc")
        case .caution: return l10n.t("risk.caution.desc")
        }
    }
}

struct CacheDefinition {
    let nameKey: String
    let detailKey: String
    let path: String
    let icon: String
    let risk: RiskLevel
}

struct CacheItem: Identifiable {
    let id = UUID()
    let nameKey: String
    let detailKey: String
    let path: String
    let icon: String
    let risk: RiskLevel
    var sizeBytes: Int64 = 0
    var isSelected: Bool = false

    var sizeFormatted: String {
        ByteFormatter.format(sizeBytes)
    }

    var exists: Bool {
        FileManager.default.fileExists(atPath: expandedPath)
    }

    var expandedPath: String {
        (path as NSString).expandingTildeInPath
    }
}

enum ByteFormatter {
    static func format(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(bytes) / 1_048_576
        if mb >= 1 { return String(format: "%.1f MB", mb) }
        let kb = Double(bytes) / 1_024
        if kb >= 1 { return String(format: "%.1f KB", kb) }
        return "0 KB"
    }
}

@MainActor
class CacheScanner: ObservableObject {
    static let shared = CacheScanner()

    @Published var items: [CacheItem] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var lastCleanedBytes: Int64 = 0
    @Published var scanProgress: Double = 0
    @Published var currentScanItem: String = ""
    private var hasScanned = false

    private let definitions: [CacheDefinition] = [
        // Safe
        CacheDefinition(nameKey: "cache.npm",       detailKey: "cache.npm.detail",       path: "~/.npm",                      icon: "shippingbox.fill",  risk: .safe),
        CacheDefinition(nameKey: "cache.yarn",       detailKey: "cache.yarn.detail",      path: "~/Library/Caches/Yarn",       icon: "shippingbox.fill",  risk: .safe),
        CacheDefinition(nameKey: "cache.yarnBerry",  detailKey: "cache.yarnBerry.detail", path: "~/.yarn/berry/cache",         icon: "shippingbox.fill",  risk: .safe),
        CacheDefinition(nameKey: "cache.corepack",   detailKey: "cache.corepack.detail",  path: "~/.cache/node/corepack",      icon: "shippingbox.fill",  risk: .safe),
        CacheDefinition(nameKey: "cache.bun",        detailKey: "cache.bun.detail",       path: "~/.bun/install/cache",        icon: "shippingbox.fill",  risk: .safe),
        CacheDefinition(nameKey: "cache.homebrew",   detailKey: "cache.homebrew.detail",  path: "~/Library/Caches/Homebrew",   icon: "mug.fill",          risk: .safe),
        CacheDefinition(nameKey: "cache.cocoapods",  detailKey: "cache.cocoapods.detail", path: "~/Library/Caches/CocoaPods",  icon: "leaf.fill",         risk: .safe),

        // Moderate
        CacheDefinition(nameKey: "cache.xcode",  detailKey: "cache.xcode.detail",  path: "~/Library/Developer/Xcode/DerivedData", icon: "hammer.fill",   risk: .moderate),
        CacheDefinition(nameKey: "cache.gradle",  detailKey: "cache.gradle.detail", path: "~/.gradle/caches",                      icon: "gearshape.fill", risk: .moderate),
        CacheDefinition(nameKey: "cache.metro",   detailKey: "cache.metro.detail",  path: "~/.metro",                              icon: "tram.fill",      risk: .moderate),

        // Caution
        CacheDefinition(nameKey: "cache.pnpm",   detailKey: "cache.pnpm.detail",   path: "~/.local/share/pnpm/store",                              icon: "shippingbox.fill", risk: .caution),
        CacheDefinition(nameKey: "cache.docker",  detailKey: "cache.docker.detail", path: "~/Library/Containers/com.docker.docker/Data/vms",        icon: "cube.fill",        risk: .caution),
    ]

    var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    var selectedBytes: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.sizeBytes }
    }

    var itemsByRisk: [(RiskLevel, [CacheItem])] {
        RiskLevel.allCases.compactMap { risk in
            let filtered = items.filter { $0.risk == risk }
            return filtered.isEmpty ? nil : (risk, filtered)
        }
    }

    func scanIfNeeded() {
        guard !hasScanned else { return }
        scan()
    }

    func scan() {
        hasScanned = true
        isScanning = true
        scanProgress = 0
        let defs = definitions
        let total = Double(defs.count)

        Task.detached(priority: .userInitiated) {
            var scanned: [CacheItem] = []
            for (index, def) in defs.enumerated() {
                await MainActor.run {
                    self.currentScanItem = def.nameKey
                    self.scanProgress = Double(index) / total
                }

                let expanded = (def.path as NSString).expandingTildeInPath
                let exists = FileManager.default.fileExists(atPath: expanded)

                if exists {
                    let size = Self.directorySize(path: expanded)
                    if size > 0 {
                        var item = CacheItem(
                            nameKey: def.nameKey,
                            detailKey: def.detailKey,
                            path: def.path,
                            icon: def.icon,
                            risk: def.risk,
                            sizeBytes: size
                        )
                        if def.risk == .safe {
                            item.isSelected = true
                        }
                        scanned.append(item)
                    }
                }
            }
            scanned.sort { $0.sizeBytes > $1.sizeBytes }
            await MainActor.run {
                self.items = scanned
                self.isScanning = false
                self.scanProgress = 1.0
                self.currentScanItem = ""
            }
        }
    }

    func clean() {
        isCleaning = true
        lastCleanedBytes = 0
        let toClean = items.filter { $0.isSelected }
        Task.detached(priority: .userInitiated) {
            var freed: Int64 = 0
            for item in toClean {
                freed += item.sizeBytes
                try? FileManager.default.removeItem(atPath: item.expandedPath)
            }
            await MainActor.run {
                self.lastCleanedBytes = freed
                self.isCleaning = false
                self.scan()
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

    private nonisolated static func directorySize(path: String) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: Int64 = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  values.isRegularFile == true else { continue }
            total += Int64(values.fileSize ?? 0)
        }
        return total
    }
}
