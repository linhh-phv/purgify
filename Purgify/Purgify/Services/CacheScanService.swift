import Foundation

/// Giao diện trừu tượng cho tầng filesystem.
/// ViewModel gọi protocol này — không gọi FileManager trực tiếp.
/// Lợi ích: trong test, mock protocol này để trả về data giả mà không cần
/// có file thật trên disk.
protocol CacheScanService: Sendable {
    /// Trả về kích thước thư mục tại `path` (bytes). Chạy off-main-thread.
    nonisolated func sizeOfDirectory(at path: String) -> Int64

    /// Kiểm tra path có tồn tại không.
    nonisolated func itemExists(at path: String) -> Bool

    /// Xóa item tại path.
    nonisolated func removeItem(at path: String) throws

    /// Liệt kê các thư mục con trực tiếp (depth 1) tại path.
    /// Dùng cho Xcode DerivedData sub-project scanning.
    nonisolated func subDirectories(at path: String) -> [(name: String, path: String, modifiedDate: Date?)]

    /// Liệt kê các file trực tiếp (depth 1) tại path, bao gồm cả trong subdirectories.
    /// Dùng cho Homebrew cache (downloads/).
    nonisolated func subFiles(at path: String) -> [(name: String, path: String, sizeBytes: Int64, modifiedDate: Date?)]

    /// Tìm các thư mục project có chứa ít nhất một trong các indicator files.
    /// Tìm kiếm trong các thư mục dev thường gặp với độ sâu tối đa 3.
    /// Returns (projects, scannedRoots) — scannedRoots == 0 means no directories were accessible.
    nonisolated func findRelatedProjects(indicators: [String]) -> (projects: [RelatedApp], scannedRoots: Int)

    /// Walk `roots` recursively (depth-limited) and return regular files whose
    /// extension matches one in `extensions` (case-insensitive, no leading dot).
    /// Date returned is `lastAccessDate` (falls back to `modifiedDate` when the
    /// volume is mounted with `noatime` or the OS hasn't recorded an access).
    /// Used for the user-file groups (Installers, Archives, Disc images).
    nonisolated func userFiles(roots: [String], extensions: [String]) -> [(name: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)]

    /// List iOS Simulator device instances from CoreSimulator/Devices/.
    /// Reads device.plist for the display name and runtime identifier.
    /// `lastUsedDate` is the modification date of the device directory.
    nonisolated func iOSSimulators() -> [(name: String, runtime: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)]

    /// List downloaded iOS Simulator runtime bundles (.simruntime) from user-accessible
    /// CoreSimulator locations. Returns empty when no user-level runtimes are present.
    nonisolated func iOSSimulatorRuntimes() -> [(name: String, path: String, sizeBytes: Int64)]

    /// List Android AVD instances from ~/.android/avd/*.avd directories.
    /// Reads config.ini for the display name and API level.
    /// `lastUsedDate` is the modification date of userdata-qemu.img (proxy for last boot).
    nonisolated func androidAVDs() -> [(name: String, apiLevel: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)]

    /// List Android SDK system image directories (3-level: api/variant/abi).
    /// Searches the standard ~/Library/Android/sdk/system-images path.
    nonisolated func androidSystemImages() -> [(name: String, path: String, sizeBytes: Int64)]

    /// List Xcode Archives (.xcarchive bundles) from ~/Library/Developer/Xcode/Archives/.
    /// Walks 2 levels (date folders → .xcarchive), reads Info.plist for name + version.
    /// `createdDate` comes from the archive's Info.plist CreationDate field.
    nonisolated func xcodeArchives() -> [(name: String, version: String, path: String, sizeBytes: Int64, createdDate: Date?)]

    /// List Xcode DerivedData project folders, checking whether the source project
    /// still exists on disk. `projectFound` is false for orphaned entries whose
    /// .xcodeproj / .xcworkspace can no longer be located.
    nonisolated func xcodeDerivedData() -> [(name: String, path: String, sizeBytes: Int64, projectFound: Bool)]

    /// List iOS Simulator runtime bundles, with `inUse` indicating whether
    /// at least one simulator device is registered against that runtime.
    nonisolated func iOSSimulatorRuntimesWithUsage() -> [(name: String, path: String, sizeBytes: Int64, inUse: Bool)]

    /// List Android SDK platform directories (android-XX) from the SDK platforms/ folder.
    /// Scans active projects to flag which API levels are referenced in build.gradle files.
    nonisolated func androidSdkPlatforms() -> [(apiLevel: Int, path: String, sizeBytes: Int64, inUse: Bool)]

    /// List Android SDK build-tools version directories.
    /// Scans active projects to flag which versions are referenced via buildToolsVersion.
    nonisolated func androidSdkBuildTools() -> [(version: String, path: String, sizeBytes: Int64, inUse: Bool)]

    /// List Android NDK version directories from the SDK ndk/ folder.
    /// Scans active projects to flag which NDK versions are referenced via ndkVersion.
    nonisolated func androidSdkNDK() -> [(version: String, path: String, sizeBytes: Int64, inUse: Bool)]
}
