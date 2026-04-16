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
}
