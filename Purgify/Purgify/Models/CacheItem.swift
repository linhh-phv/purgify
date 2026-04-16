import Foundation

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

    var expandedPath: String {
        (path as NSString).expandingTildeInPath
    }
}
