import Foundation
import SwiftUI

enum SubItemMode {
    case none           // No sub-items
    case directories    // Scan child directories (Xcode DerivedData)
    case files          // Scan child files recursively (Homebrew downloads)
    case vms            // iOS Simulators / Android AVDs / system images
}

enum VMScanType {
    case iOSSimulators
    case iOSRuntimes
    case androidAVDs
    case androidSystemImages
    case xcodeArchives
    case xcodeDerivedData
    case deviceSupport
    case iOSBackups
    case androidSdkPlatforms
    case androidSdkBuildTools
    case androidSdkNDK
    case reactNativeBuild
    case rustProject
    case flutterProject
    case webFrontendProject
    case iosPodsProject
    case androidNativeProject
    case pythonProject
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
    /// When set, this definition uses platform-specific VM scanning (iOS Simulators,
    /// Android AVDs, etc.) instead of generic directory/file walking.
    let vmScanType: VMScanType?

    var supportsSubItems: Bool { subItemMode != .none }

    /// True for definitions that surface user-owned files (installers, archives)
    /// rather than tool-generated caches.
    var isUserFileScan: Bool { fileExtensions != nil }

    /// True for definitions that surface mobile VM data (iOS Simulators, Android AVDs).
    var isVMScan: Bool { vmScanType != nil }

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
        self.vmScanType = nil
    }

    init(nameKey: String, detailKey: String, path: String, icon: String, iconColor: Color,
         risk: RiskLevel, subItemMode: SubItemMode, subItemsPath: String? = nil,
         projectIndicators: [String] = [], requiresFDA: Bool = false,
         fileExtensions: [String]? = nil, additionalScanRoots: [String]? = nil,
         vmScanType: VMScanType? = nil) {
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
        self.vmScanType = vmScanType
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
    /// Additional paths to delete alongside `path` (e.g. the `.ini` pointer
    /// file that accompanies each Android `.avd` directory). Deleted with
    /// `try?` so missing files are silently ignored.
    var associatedPaths: [String] = []
    /// Optional secondary text shown under the name (e.g. project location
    /// for React Native build entries). Truncated with middle-ellipsis when long.
    var subtitle: String? = nil
    /// Path that the "Reveal in Finder" button opens. Defaults to `path` when
    /// nil. For RN builds this is the project root rather than the build folder.
    var revealPath: String? = nil

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
    /// When true, the clean operation deletes sub-items individually rather than
    /// removing the parent directory. Required for user-file and VM groups where
    /// the parent path (e.g. ~/Downloads, ~/.android/avd) must never be deleted.
    var deleteSubsOnly: Bool = false

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
