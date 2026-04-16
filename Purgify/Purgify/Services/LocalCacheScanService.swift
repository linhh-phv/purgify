import Foundation

/// Implement thật sử dụng FileManager.
/// `nonisolated` để các method chạy được off-main-thread từ Task.detached.
struct LocalCacheScanService: CacheScanService {

    nonisolated func sizeOfDirectory(at path: String) -> Int64 {
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

    nonisolated func itemExists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    nonisolated func removeItem(at path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    nonisolated func subDirectories(at path: String) -> [(name: String, path: String, modifiedDate: Date?)] {
        let url = URL(fileURLWithPath: path)
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents.compactMap { childURL in
            guard let values = try? childURL.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey]),
                  values.isDirectory == true else { return nil }
            return (
                name: childURL.lastPathComponent,
                path: childURL.path,
                modifiedDate: values.contentModificationDate
            )
        }
    }

    nonisolated func findRelatedProjects(indicators: [String]) -> [RelatedApp] {
        guard !indicators.isEmpty else { return [] }

        let fm = FileManager.default
        let home = NSHomeDirectory()
        let roots = ["Developer", "Desktop", "Documents", "Projects", "code", "repos", "work", "Sites"]
            .map { home + "/" + $0 }
            .filter { fm.fileExists(atPath: $0) }

        let indicatorSet = Set(indicators)
        let skipDirs: Set<String> = ["node_modules", ".git", ".build", "Pods", "DerivedData",
                                     "Library", "Applications", ".Trash", "vendor", "dist", "build"]
        var results: [RelatedApp] = []

        for root in roots {
            searchProjects(in: root, indicators: indicatorSet, depth: 0, maxDepth: 3,
                           fm: fm, skip: skipDirs, results: &results)
            if results.count >= 20 { break }
        }
        return results
    }

    private nonisolated func searchProjects(
        in path: String, indicators: Set<String>, depth: Int, maxDepth: Int,
        fm: FileManager, skip: Set<String>, results: inout [RelatedApp]
    ) {
        guard depth <= maxDepth, results.count < 20 else { return }
        guard let contents = try? fm.contentsOfDirectory(atPath: path) else { return }

        // This directory is a project if it contains an indicator (skip root search dirs at depth 0)
        if depth > 0 && indicators.contains(where: { contents.contains($0) }) {
            let name = URL(fileURLWithPath: path).lastPathComponent
            if !results.contains(where: { $0.path == path }) {
                results.append(RelatedApp(name: name, path: path))
            }
        }

        guard depth < maxDepth else { return }

        for item in contents {
            guard !skip.contains(item) && !item.hasPrefix(".") else { continue }
            let sub = path + "/" + item
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: sub, isDirectory: &isDir), isDir.boolValue {
                searchProjects(in: sub, indicators: indicators, depth: depth + 1, maxDepth: maxDepth,
                               fm: fm, skip: skip, results: &results)
            }
        }
    }

    nonisolated func subFiles(at path: String) -> [(name: String, path: String, sizeBytes: Int64, modifiedDate: Date?)] {
        let url = URL(fileURLWithPath: path)
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents.compactMap { fileURL in
            guard let values = try? fileURL.resourceValues(
                forKeys: [.fileSizeKey, .isRegularFileKey, .contentModificationDateKey]
            ), values.isRegularFile == true else { return nil }

            return (
                name: fileURL.lastPathComponent,
                path: fileURL.path,
                sizeBytes: Int64(values.fileSize ?? 0),
                modifiedDate: values.contentModificationDate
            )
        }
    }
}
