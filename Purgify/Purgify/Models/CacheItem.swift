import Foundation
import SwiftUI

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
    let iconColor: Color
    let risk: RiskLevel
    let subItemMode: SubItemMode
    /// Subfolder to scan for sub-items. Defaults to path itself.
    let subItemsPath: String?
    /// Filenames that indicate a project uses this cache (e.g. "package-lock.json").
    /// Used for related-project discovery in the detail panel.
    let projectIndicators: [String]
    /// True for caches in TCC-protected directories (Safari, Mail, etc.) — scanning
    /// triggers a Full Disk Access prompt. Only scanned when Advanced mode is ON.
    let requiresFDA: Bool
    /// When set, this definition surfaces user files (e.g. installers in Downloads)
    /// instead of a tool-managed cache directory. The scan walks `path` plus
    /// `additionalScanRoots`, filters to these extensions, and reports
    /// last-access dates so the user can prune files they haven't touched.
    /// Parent size is the sum of matched files (NOT the size of the root folder).
    let fileExtensions: [String]?
    /// Extra scan roots merged with `path` when `fileExtensions` is set.
    let additionalScanRoots: [String]?

    var supportsSubItems: Bool { subItemMode != .none }

    /// True for definitions that surface user-owned files (installers, archives)
    /// rather than tool-generated caches. Used to drive default selection
    /// (off — user files are riskier) and date-label semantics ("last used"
    /// instead of "modified").
    var isUserFileScan: Bool { fileExtensions != nil }

    init(nameKey: String, detailKey: String, path: String, icon: String, iconColor: Color,
         risk: RiskLevel, supportsSubItems: Bool = false, projectIndicators: [String] = [],
         requiresFDA: Bool = false) {
        self.nameKey = nameKey
        self.detailKey = detailKey
        self.path = path
        self.icon = icon
        self.iconColor = iconColor
        self.risk = risk
        self.subItemMode = supportsSubItems ? .directories : .none
        self.subItemsPath = nil
        self.projectIndicators = projectIndicators
        self.requiresFDA = requiresFDA
        self.fileExtensions = nil
        self.additionalScanRoots = nil
    }

    init(nameKey: String, detailKey: String, path: String, icon: String, iconColor: Color,
         risk: RiskLevel, subItemMode: SubItemMode, subItemsPath: String? = nil,
         projectIndicators: [String] = [], requiresFDA: Bool = false,
         fileExtensions: [String]? = nil, additionalScanRoots: [String]? = nil) {
        self.nameKey = nameKey
        self.detailKey = detailKey
        self.path = path
        self.icon = icon
        self.iconColor = iconColor
        self.risk = risk
        self.subItemMode = subItemMode
        self.subItemsPath = subItemsPath
        self.projectIndicators = projectIndicators
        self.requiresFDA = requiresFDA
        self.fileExtensions = fileExtensions
        self.additionalScanRoots = additionalScanRoots
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
    /// Optional localization key for a date-label prefix (e.g. "subitem.lastUsed"
    /// → "Last used"). When nil, only the relative-time string is shown. Used by
    /// user-file scans (Installers, Archives, Disc images) where the date
    /// represents last access rather than modification.
    var dateLabelKey: String? = nil

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
    let iconColor: Color
    let risk: RiskLevel
    var sizeBytes: Int64 = 0
    var isSelected: Bool = false
    var subItems: [SubItem]? = nil
    var subItemMode: SubItemMode = .none
    /// True while sub-items are being scanned in background — parent size is
    /// already known but the inner list isn't. Drives loading UI in
    /// SubItemsDetailView so the user sees progress instead of an empty list.
    var isLoadingSubItems: Bool = false

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
