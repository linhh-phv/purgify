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
    nonisolated func findRelatedProjects(indicators: [String]) -> [RelatedApp]
}
