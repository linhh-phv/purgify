import Foundation

enum SubItemMode {
    case none           // No sub-items
    case directories    // Scan child directories (Xcode DerivedData)
    case files          // Scan child files recursively (Homebrew downloads)
}

struct CacheDefinition {
    let nameKey: String
    let detailKey: String
    let path: String
    let icon: String
    let risk: RiskLevel
    let subItemMode: SubItemMode
    /// Subfolder to scan for sub-items. Defaults to path itself.
    let subItemsPath: String?
    /// Filenames that indicate a project uses this cache (e.g. "package-lock.json").
    /// Used for related-project discovery in the detail panel.
    let projectIndicators: [String]

    var supportsSubItems: Bool { subItemMode != .none }

    init(nameKey: String, detailKey: String, path: String, icon: String, risk: RiskLevel,
         supportsSubItems: Bool = false, projectIndicators: [String] = []) {
        self.nameKey = nameKey
        self.detailKey = detailKey
        self.path = path
        self.icon = icon
        self.risk = risk
        self.subItemMode = supportsSubItems ? .directories : .none
        self.subItemsPath = nil
        self.projectIndicators = projectIndicators
    }

    init(nameKey: String, detailKey: String, path: String, icon: String, risk: RiskLevel,
         subItemMode: SubItemMode, subItemsPath: String? = nil, projectIndicators: [String] = []) {
        self.nameKey = nameKey
        self.detailKey = detailKey
        self.path = path
        self.icon = icon
        self.risk = risk
        self.subItemMode = subItemMode
        self.subItemsPath = subItemsPath
        self.projectIndicators = projectIndicators
    }
}

struct RelatedApp: Identifiable {
    let id = UUID()
    let name: String
    let path: String
}

struct SubItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    var sizeBytes: Int64 = 0
    var modifiedDate: Date?
    var isSelected: Bool = true

    var sizeFormatted: String {
        ByteFormatter.format(sizeBytes)
    }

    var relativeTimeString: String {
        guard let date = modifiedDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
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
    var subItems: [SubItem]? = nil
    var subItemMode: SubItemMode = .none

    var sizeFormatted: String {
        ByteFormatter.format(sizeBytes)
    }

    var expandedPath: String {
        (path as NSString).expandingTildeInPath
    }

    var hasSubItems: Bool {
        subItems != nil
    }

    var selectedSubItemsBytes: Int64 {
        subItems?.filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes } ?? 0
    }

    var selectedSubItemsCount: Int {
        subItems?.filter(\.isSelected).count ?? 0
    }

    var totalSubItemsCount: Int {
        subItems?.count ?? 0
    }
}
