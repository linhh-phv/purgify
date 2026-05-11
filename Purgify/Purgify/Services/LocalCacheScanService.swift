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

    nonisolated func findRelatedProjects(indicators: [String]) -> (projects: [RelatedApp], scannedRoots: Int) {
        guard !indicators.isEmpty else { return ([], 0) }

        let fm = FileManager.default
        let home = NSHomeDirectory()
        let roots = ["Developer", "Desktop", "Documents", "Projects", "code", "repos", "work", "Sites"]
            .map { home + "/" + $0 }
            .filter { fm.fileExists(atPath: $0) }

        // Count how many roots are actually readable
        let scannedRoots = roots.filter { (try? fm.contentsOfDirectory(atPath: $0)) != nil }.count

        let indicatorSet = Set(indicators)
        let skipDirs: Set<String> = ["node_modules", ".git", ".build", "Pods", "DerivedData",
                                     "Library", "Applications", ".Trash", "vendor", "dist", "build"]
        var results: [RelatedApp] = []

        for root in roots {
            searchProjects(in: root, indicators: indicatorSet, depth: 0, maxDepth: 3,
                           fm: fm, skip: skipDirs, results: &results)
            if results.count >= 20 { break }
        }
        return (results, scannedRoots)
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

    nonisolated func userFiles(roots: [String], extensions: [String]) -> [(name: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] {
        guard !roots.isEmpty, !extensions.isEmpty else { return [] }

        let fm = FileManager.default
        // Multi-extension match handles compound suffixes like ".tar.gz" by
        // checking the lowercased filename ends with any provided extension.
        let normalized = extensions.map { $0.lowercased() }
        // Skip directories that almost never contain installers and would
        // explode the walk (project trees, library data, system noise).
        let skipDirs: Set<String> = [
            "node_modules", ".git", ".build", "Pods", "DerivedData",
            "Library", ".Trash", "vendor", "dist", "build", ".cache",
            ".npm", ".yarn", ".cargo", ".gradle", ".m2", ".pub-cache"
        ]
        let resourceKeys: Set<URLResourceKey> = [
            .fileSizeKey, .isRegularFileKey, .isDirectoryKey,
            .contentAccessDateKey, .contentModificationDateKey
        ]
        let maxDepth = 3
        let perRootCap = 5_000
        var results: [(name: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] = []

        for root in roots {
            guard fm.fileExists(atPath: root) else { continue }
            let rootURL = URL(fileURLWithPath: root)
            var visited = 0
            walk(
                url: rootURL, depth: 0, maxDepth: maxDepth,
                fm: fm, skip: skipDirs, exts: normalized,
                resourceKeys: Array(resourceKeys),
                visited: &visited, cap: perRootCap,
                results: &results
            )
        }
        return results
    }

    /// Depth-limited recursive walk — collects regular files whose name ends
    /// with one of `exts`. Caps per-root visits to avoid worst-case blowup
    /// (Documents folders with hundreds of thousands of unrelated files).
    private nonisolated func walk(
        url: URL, depth: Int, maxDepth: Int,
        fm: FileManager, skip: Set<String>, exts: [String],
        resourceKeys: [URLResourceKey],
        visited: inout Int, cap: Int,
        results: inout [(name: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)]
    ) {
        guard visited < cap else { return }
        guard let contents = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles]
        ) else { return }

        for child in contents {
            visited += 1
            guard visited < cap else { return }
            guard let values = try? child.resourceValues(forKeys: Set(resourceKeys)) else { continue }

            if values.isDirectory == true {
                let name = child.lastPathComponent
                if skip.contains(name) || name.hasPrefix(".") { continue }
                if depth + 1 <= maxDepth {
                    walk(url: child, depth: depth + 1, maxDepth: maxDepth,
                         fm: fm, skip: skip, exts: exts,
                         resourceKeys: resourceKeys,
                         visited: &visited, cap: cap, results: &results)
                }
            } else if values.isRegularFile == true {
                let lower = child.lastPathComponent.lowercased()
                guard exts.contains(where: { lower.hasSuffix($0) }) else { continue }
                results.append((
                    name: child.lastPathComponent,
                    path: child.path,
                    sizeBytes: Int64(values.fileSize ?? 0),
                    lastUsedDate: values.contentAccessDate ?? values.contentModificationDate
                ))
            }
        }
    }
}
