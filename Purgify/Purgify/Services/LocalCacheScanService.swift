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
        try FileManager.default.trashItem(
            at: URL(fileURLWithPath: path),
            resultingItemURL: nil
        )
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

    // MARK: - iOS Simulator scanning

    nonisolated func iOSSimulators() -> [(name: String, runtime: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] {
        let devicesPath = NSHomeDirectory() + "/Library/Developer/CoreSimulator/Devices"
        let fm = FileManager.default
        guard let uuids = try? fm.contentsOfDirectory(atPath: devicesPath) else { return [] }

        var results: [(name: String, runtime: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] = []
        for uuid in uuids {
            let devicePath = devicesPath + "/" + uuid
            let plistPath = devicePath + "/device.plist"
            guard let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else { continue }

            let displayName = dict["name"] as? String ?? uuid
            let runtimeStr = dict["runtime"] as? String ?? ""
            let runtime = Self.parseSimRuntime(runtimeStr)

            let size = sizeOfDirectory(at: devicePath)
            guard size > 0 else { continue }

            let lastUsed = (try? URL(fileURLWithPath: devicePath)
                .resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

            results.append((name: displayName, runtime: runtime, path: devicePath,
                            sizeBytes: size, lastUsedDate: lastUsed))
        }
        return results
    }

    nonisolated func iOSSimulatorRuntimes() -> [(name: String, path: String, sizeBytes: Int64)] {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        let searchPaths = [
            home + "/Library/Developer/CoreSimulator/Profiles/Runtimes",
            home + "/Library/Developer/CoreSimulator/Volumes"
        ]

        var results: [(name: String, path: String, sizeBytes: Int64)] = []
        var seen = Set<String>()
        for searchPath in searchPaths {
            guard let contents = try? fm.contentsOfDirectory(atPath: searchPath) else { continue }
            for item in contents {
                let itemPath = searchPath + "/" + item
                guard !seen.contains(itemPath) else { continue }
                seen.insert(itemPath)

                let size = sizeOfDirectory(at: itemPath)
                guard size > 0 else { continue }

                let displayName = item
                    .replacingOccurrences(of: ".simruntime", with: "")
                    .replacingOccurrences(of: "_", with: " ")
                results.append((name: displayName, path: itemPath, sizeBytes: size))
            }
        }
        return results
    }

    private nonisolated static func parseSimRuntime(_ runtime: String) -> String {
        // "com.apple.CoreSimulator.SimRuntime.iOS-17-0" → "iOS 17.0"
        guard let lastDot = runtime.lastIndex(of: ".") else { return runtime }
        let suffix = String(runtime[runtime.index(after: lastDot)...])
        let parts = suffix.components(separatedBy: "-")
        guard parts.count >= 2 else { return suffix }
        let platform = parts[0]
        let version = parts[1...].joined(separator: ".")
        return "\(platform) \(version)"
    }

    // MARK: - Android AVD scanning

    nonisolated func androidAVDs() -> [(name: String, apiLevel: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] {
        let fm = FileManager.default
        let avdDir = NSHomeDirectory() + "/.android/avd"
        guard let contents = try? fm.contentsOfDirectory(atPath: avdDir) else { return [] }

        var results: [(name: String, apiLevel: String, path: String, sizeBytes: Int64, lastUsedDate: Date?)] = []
        for item in contents {
            guard item.hasSuffix(".avd") else { continue }
            let avdPath = avdDir + "/" + item
            let ini = Self.parseIniFile(avdPath + "/config.ini")

            let displayName = ini["avd.name"] ?? String(item.dropLast(4))
            let apiLevel = Self.extractAndroidAPILevel(from: ini)

            let size = sizeOfDirectory(at: avdPath)
            guard size > 0 else { continue }

            let userdataPath = avdPath + "/userdata-qemu.img"
            let lastUsed = (try? URL(fileURLWithPath: userdataPath)
                .resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
                ?? (try? URL(fileURLWithPath: avdPath)
                    .resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

            results.append((name: displayName, apiLevel: apiLevel, path: avdPath,
                            sizeBytes: size, lastUsedDate: lastUsed))
        }
        return results
    }

    nonisolated func androidSystemImages() -> [(name: String, path: String, sizeBytes: Int64)] {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        let searchPaths = [
            home + "/Library/Android/sdk/system-images",
            home + "/Android/sdk/system-images"
        ]

        var results: [(name: String, path: String, sizeBytes: Int64)] = []
        for basePath in searchPaths {
            guard let apiLevels = try? fm.contentsOfDirectory(atPath: basePath) else { continue }
            for apiLevel in apiLevels.sorted() {
                let apiPath = basePath + "/" + apiLevel
                guard let variants = try? fm.contentsOfDirectory(atPath: apiPath) else { continue }
                for variant in variants.sorted() {
                    let variantPath = apiPath + "/" + variant
                    guard let abis = try? fm.contentsOfDirectory(atPath: variantPath) else { continue }
                    for abi in abis.sorted() {
                        let imagePath = variantPath + "/" + abi
                        var isDir: ObjCBool = false
                        guard fm.fileExists(atPath: imagePath, isDirectory: &isDir),
                              isDir.boolValue else { continue }
                        let size = sizeOfDirectory(at: imagePath)
                        guard size > 0 else { continue }
                        let apiDisplay = apiLevel.hasPrefix("android-")
                            ? "API \(apiLevel.dropFirst(8))" : apiLevel
                        let displayName = "\(apiDisplay) · \(variant) · \(abi)"
                        results.append((name: displayName, path: imagePath, sizeBytes: size))
                    }
                }
            }
        }
        return results
    }

    private nonisolated static func parseIniFile(_ path: String) -> [String: String] {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return [:] }
        var result: [String: String] = [:]
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.hasPrefix("#"), !trimmed.hasPrefix(";"),
                  let eqIdx = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[..<eqIdx]).trimmingCharacters(in: .whitespaces)
            let value = String(trimmed[trimmed.index(after: eqIdx)...]).trimmingCharacters(in: .whitespaces)
            result[key] = value
        }
        return result
    }

    private nonisolated static func extractAndroidAPILevel(from ini: [String: String]) -> String {
        // "image.sysdir.1" = "system-images/android-34/google_apis/arm64-v8a/"
        if let sysdir = ini["image.sysdir.1"] {
            let parts = sysdir.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                .components(separatedBy: "/")
            if parts.count >= 2 {
                let apiPart = parts[1]
                if apiPart.hasPrefix("android-") {
                    return "API \(apiPart.dropFirst(8))"
                }
            }
        }
        if let target = ini["target"], target.hasPrefix("android-") {
            return "API \(target.dropFirst(8))"
        }
        return ini["target"] ?? ""
    }

    // MARK: - User-file walk

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
