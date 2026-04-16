import Foundation

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
