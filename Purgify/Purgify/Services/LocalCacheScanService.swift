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

    // MARK: - iOS Backups

    nonisolated func iOSBackups() -> [(name: String, iOSVersion: String, path: String, sizeBytes: Int64, backupDate: Date?)] {
        let fm = FileManager.default
        let backupRoot = NSHomeDirectory() + "/Library/Application Support/MobileSync/Backup"
        guard let entries = try? fm.contentsOfDirectory(atPath: backupRoot) else { return [] }

        var results: [(name: String, iOSVersion: String, path: String, sizeBytes: Int64, backupDate: Date?)] = []
        for entry in entries {
            let backupPath = backupRoot + "/" + entry
            let plistPath = backupPath + "/Info.plist"
            guard let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else { continue }
            let deviceName = dict["Device Name"] as? String
                ?? dict["Display Name"] as? String
                ?? entry
            let iOSVersion = dict["Product Version"] as? String ?? ""
            let backupDate = dict["Last Backup Date"] as? Date
            let size = sizeOfDirectory(at: backupPath)
            guard size > 0 else { continue }
            results.append((name: deviceName, iOSVersion: iOSVersion, path: backupPath,
                            sizeBytes: size, backupDate: backupDate))
        }
        return results.sorted { ($0.backupDate ?? .distantPast) > ($1.backupDate ?? .distantPast) }
    }

    // MARK: - Device Support folders (iOS / watchOS / tvOS / visionOS)

    nonisolated func deviceSupportFolders(at path: String) -> [(name: String, path: String, sizeBytes: Int64, isLatest: Bool)] {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: path) else { return [] }

        // Parse "iPhone11,6 18.7.8 (22H352)" → (device: "iPhone11,6", version: [18,7,8])
        var parsed: [(entry: String, device: String, version: [Int])] = []
        let versionRegex = try? NSRegularExpression(pattern: #"\s(\d+\.\d+(?:\.\d+)?)\s"#)

        for entry in entries {
            var device = entry
            var version: [Int] = []
            if let regex = versionRegex,
               let match = regex.firstMatch(in: entry, range: NSRange(entry.startIndex..., in: entry)),
               let range = Range(match.range(at: 1), in: entry) {
                let verStr = String(entry[range])
                version = verStr.split(separator: ".").compactMap { Int($0) }
                device = String(entry[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
            parsed.append((entry: entry, device: device, version: version))
        }

        // Find the latest version per device
        var latestVersion: [String: [Int]] = [:]
        for item in parsed {
            let current = latestVersion[item.device] ?? []
            if Self.versionGreaterThan(item.version, current) {
                latestVersion[item.device] = item.version
            }
        }

        var results: [(name: String, path: String, sizeBytes: Int64, isLatest: Bool)] = []
        for item in parsed {
            let fullPath = path + "/" + item.entry
            let size = sizeOfDirectory(at: fullPath)
            guard size > 0 else { continue }
            let isLatest = latestVersion[item.device] == item.version
            results.append((name: item.entry, path: fullPath, sizeBytes: size, isLatest: isLatest))
        }
        // Oldest versions first — prime cleanup candidates at top
        return results.sorted { lhs, rhs in
            if lhs.isLatest != rhs.isLatest { return !lhs.isLatest }
            return lhs.sizeBytes > rhs.sizeBytes
        }
    }

    private nonisolated static func versionGreaterThan(_ a: [Int], _ b: [Int]) -> Bool {
        let maxLen = max(a.count, b.count)
        for i in 0..<maxLen {
            let av = i < a.count ? a[i] : 0
            let bv = i < b.count ? b[i] : 0
            if av != bv { return av > bv }
        }
        return false
    }

    // MARK: - Xcode DerivedData with project existence check

    nonisolated func xcodeDerivedData() -> [(name: String, path: String, sizeBytes: Int64, projectFound: Bool)] {
        let derivedDataPath = NSHomeDirectory() + "/Library/Developer/Xcode/DerivedData"
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: derivedDataPath) else { return [] }

        let projectLocations = Self.findXcodeProjectNames()

        var results: [(name: String, path: String, sizeBytes: Int64, projectFound: Bool)] = []
        for entry in entries {
            guard entry != "ModuleCache.noindex", entry != "SDKStatCaches.noindex" else { continue }
            let dirPath = derivedDataPath + "/" + entry
            let projectName = Self.extractDerivedDataProjectName(entry)
            let size = sizeOfDirectory(at: dirPath)
            guard size > 0 else { continue }
            let found = projectLocations.contains(projectName.lowercased())
            results.append((name: projectName, path: dirPath, sizeBytes: size, projectFound: found))
        }
        return results.sorted { $0.sizeBytes > $1.sizeBytes }
    }

    private nonisolated static func extractDerivedDataProjectName(_ folderName: String) -> String {
        // "Purgify-godzljblebpmyvhcahwqbrowctpc" → "Purgify"
        // Strip trailing "-<hash>" where hash is alphanumeric
        guard let dashRange = folderName.range(of: "-[a-z0-9]{10,}$",
                                                options: .regularExpression) else {
            return folderName
        }
        return String(folderName[..<dashRange.lowerBound])
    }

    private nonisolated static func findXcodeProjectNames() -> Set<String> {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        let roots = ["Desktop", "Documents", "Developer", "code", "repos", "work", "Projects", "Sites"]
            .map { home + "/" + $0 }
            .filter { fm.fileExists(atPath: $0) }

        let skipDirs: Set<String> = [
            "node_modules", ".git", "build", "DerivedData", "Library",
            ".Trash", "Pods", ".pub-cache", ".cargo", ".npm", "dist"
        ]

        var names = Set<String>()
        for root in roots {
            Self.findProjectNames(in: root, depth: 0, maxDepth: 5,
                                  fm: fm, skip: skipDirs, results: &names)
            if names.count >= 200 { break }
        }
        return names
    }

    private nonisolated static func findProjectNames(
        in path: String, depth: Int, maxDepth: Int,
        fm: FileManager, skip: Set<String>, results: inout Set<String>
    ) {
        guard depth <= maxDepth else { return }
        guard let contents = try? fm.contentsOfDirectory(atPath: path) else { return }
        for item in contents {
            if item.hasSuffix(".xcodeproj") || item.hasSuffix(".xcworkspace") {
                let name = item
                    .replacingOccurrences(of: ".xcodeproj", with: "")
                    .replacingOccurrences(of: ".xcworkspace", with: "")
                results.insert(name.lowercased())
            }
        }
        guard depth < maxDepth else { return }
        for item in contents {
            guard !skip.contains(item), !item.hasPrefix("."),
                  !item.hasSuffix(".xcodeproj"), !item.hasSuffix(".xcworkspace") else { continue }
            let sub = path + "/" + item
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: sub, isDirectory: &isDir), isDir.boolValue {
                findProjectNames(in: sub, depth: depth + 1, maxDepth: maxDepth,
                                 fm: fm, skip: skip, results: &results)
            }
        }
    }

    // MARK: - iOS Simulator Runtimes with usage detection

    nonisolated func iOSSimulatorRuntimesWithUsage() -> [(name: String, path: String, sizeBytes: Int64, inUse: Bool)] {
        let usedRuntimes = Self.collectUsedSimulatorRuntimes()
        return iOSSimulatorRuntimes().map { r in
            // Match folder display name back to a runtime identifier fragment.
            // "iOS 17.0" → "iOS-17-0", "watchOS 10.0" → "watchOS-10-0"
            let key = r.name.replacingOccurrences(of: " ", with: "-")
                            .replacingOccurrences(of: ".", with: "-")
            let inUse = usedRuntimes.contains { $0.contains(key) }
            return (name: r.name, path: r.path, sizeBytes: r.sizeBytes, inUse: inUse)
        }
    }

    private nonisolated static func collectUsedSimulatorRuntimes() -> Set<String> {
        let fm = FileManager.default
        let devicesPath = NSHomeDirectory() + "/Library/Developer/CoreSimulator/Devices"
        guard let uuids = try? fm.contentsOfDirectory(atPath: devicesPath) else { return [] }
        var runtimes = Set<String>()
        for uuid in uuids {
            let plistPath = devicesPath + "/" + uuid + "/device.plist"
            if let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
               let runtime = dict["runtime"] as? String {
                runtimes.insert(runtime)
            }
        }
        return runtimes
    }

    // MARK: - Android SDK component scanning

    nonisolated func androidSdkPlatforms() -> [(apiLevel: Int, path: String, sizeBytes: Int64, inUse: Bool)] {
        let sdkRoot = Self.androidSdkRoot()
        let platformsPath = sdkRoot + "/platforms"
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: platformsPath) else { return [] }

        let usedVersions = Self.scanAndroidProjectVersions()
        var results: [(apiLevel: Int, path: String, sizeBytes: Int64, inUse: Bool)] = []

        for entry in entries {
            guard entry.hasPrefix("android-"),
                  let level = Int(entry.dropFirst("android-".count)) else { continue }
            let dirPath = platformsPath + "/" + entry
            let size = sizeOfDirectory(at: dirPath)
            guard size > 0 else { continue }
            let inUse = usedVersions.sdkLevels.contains(level)
            results.append((apiLevel: level, path: dirPath, sizeBytes: size, inUse: inUse))
        }
        return results.sorted { $0.apiLevel > $1.apiLevel }
    }

    nonisolated func androidSdkBuildTools() -> [(version: String, path: String, sizeBytes: Int64, inUse: Bool)] {
        let sdkRoot = Self.androidSdkRoot()
        let buildToolsPath = sdkRoot + "/build-tools"
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: buildToolsPath) else { return [] }

        let usedVersions = Self.scanAndroidProjectVersions()
        var results: [(version: String, path: String, sizeBytes: Int64, inUse: Bool)] = []

        for entry in entries {
            let dirPath = buildToolsPath + "/" + entry
            let size = sizeOfDirectory(at: dirPath)
            guard size > 0 else { continue }
            let inUse = usedVersions.buildToolsVersions.contains(entry)
            results.append((version: entry, path: dirPath, sizeBytes: size, inUse: inUse))
        }
        return results.sorted { Self.compareVersionStrings($0.version, $1.version) > 0 }
    }

    nonisolated func androidSdkNDK() -> [(version: String, path: String, sizeBytes: Int64, inUse: Bool)] {
        let sdkRoot = Self.androidSdkRoot()
        let ndkPath = sdkRoot + "/ndk"
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: ndkPath) else { return [] }

        let usedVersions = Self.scanAndroidProjectVersions()
        var results: [(version: String, path: String, sizeBytes: Int64, inUse: Bool)] = []

        for entry in entries {
            let dirPath = ndkPath + "/" + entry
            let size = sizeOfDirectory(at: dirPath)
            guard size > 0 else { continue }
            let inUse = usedVersions.ndkVersions.contains(entry)
            results.append((version: entry, path: dirPath, sizeBytes: size, inUse: inUse))
        }
        return results.sorted { Self.compareVersionStrings($0.version, $1.version) > 0 }
    }

    private nonisolated static func androidSdkRoot() -> String {
        let home = NSHomeDirectory()
        let candidates = [
            home + "/Library/Android/sdk",
            home + "/Android/sdk",
        ]
        return candidates.first { FileManager.default.fileExists(atPath: $0) }
            ?? (home + "/Library/Android/sdk")
    }

    private struct AndroidUsedVersions {
        var sdkLevels: Set<Int> = []
        var buildToolsVersions: Set<String> = []
        var ndkVersions: Set<String> = []
    }

    private nonisolated static func scanAndroidProjectVersions() -> AndroidUsedVersions {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        let roots = ["Desktop", "Documents", "Developer", "code", "repos", "work", "Projects", "Sites"]
            .map { home + "/" + $0 }
            .filter { fm.fileExists(atPath: $0) }

        let skipDirs: Set<String> = [
            "node_modules", ".git", ".gradle", "build", "DerivedData",
            "Library", ".Trash", "vendor", "dist", "Pods", ".pub-cache",
            ".cargo", ".npm", ".yarn"
        ]

        var gradleFiles: [String] = []
        for root in roots {
            Self.findGradleFiles(in: root, depth: 0, maxDepth: 6, fm: fm,
                                 skip: skipDirs, results: &gradleFiles)
            if gradleFiles.count >= 100 { break }
        }

        var versions = AndroidUsedVersions()
        let sdkPattern = #"(?:compileSdk(?:Version)?)\s*[=(]\s*(\d+)"#
        let buildToolsPattern = #"buildToolsVersion\s*[=:]\s*["']([0-9.]+)["']"#
        let ndkPattern = #"ndkVersion\s*[=:]\s*["']([0-9.]+)["']"#

        for path in gradleFiles {
            guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { continue }
            if let regex = try? NSRegularExpression(pattern: sdkPattern) {
                for match in regex.matches(in: content, range: NSRange(content.startIndex..., in: content)) {
                    if let range = Range(match.range(at: 1), in: content),
                       let level = Int(content[range]) {
                        versions.sdkLevels.insert(level)
                    }
                }
            }
            if let regex = try? NSRegularExpression(pattern: buildToolsPattern) {
                for match in regex.matches(in: content, range: NSRange(content.startIndex..., in: content)) {
                    if let range = Range(match.range(at: 1), in: content) {
                        versions.buildToolsVersions.insert(String(content[range]))
                    }
                }
            }
            if let regex = try? NSRegularExpression(pattern: ndkPattern) {
                for match in regex.matches(in: content, range: NSRange(content.startIndex..., in: content)) {
                    if let range = Range(match.range(at: 1), in: content) {
                        versions.ndkVersions.insert(String(content[range]))
                    }
                }
            }
        }
        return versions
    }

    private nonisolated static func findGradleFiles(
        in path: String, depth: Int, maxDepth: Int,
        fm: FileManager, skip: Set<String>,
        results: inout [String]
    ) {
        guard depth <= maxDepth, results.count < 100 else { return }
        guard let contents = try? fm.contentsOfDirectory(atPath: path) else { return }

        for item in contents {
            if item.hasSuffix(".gradle") || item.hasSuffix(".gradle.kts") {
                results.append(path + "/" + item)
            }
        }
        guard depth < maxDepth else { return }
        for item in contents {
            guard !skip.contains(item), !item.hasPrefix(".") else { continue }
            let sub = path + "/" + item
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: sub, isDirectory: &isDir), isDir.boolValue {
                findGradleFiles(in: sub, depth: depth + 1, maxDepth: maxDepth,
                                fm: fm, skip: skip, results: &results)
            }
        }
    }

    private nonisolated static func compareVersionStrings(_ a: String, _ b: String) -> Int {
        let aParts = a.split(separator: ".").compactMap { Int($0) }
        let bParts = b.split(separator: ".").compactMap { Int($0) }
        let maxLen = max(aParts.count, bParts.count)
        for i in 0..<maxLen {
            let av = i < aParts.count ? aParts[i] : 0
            let bv = i < bParts.count ? bParts[i] : 0
            if av != bv { return av - bv }
        }
        return 0
    }

    // MARK: - Xcode Archives

    nonisolated func xcodeArchives() -> [(name: String, version: String, path: String, sizeBytes: Int64, createdDate: Date?)] {
        let fm = FileManager.default
        let archivesRoot = NSHomeDirectory() + "/Library/Developer/Xcode/Archives"
        guard let dateFolders = try? fm.contentsOfDirectory(atPath: archivesRoot) else { return [] }

        var results: [(name: String, version: String, path: String, sizeBytes: Int64, createdDate: Date?)] = []

        for dateFolder in dateFolders.sorted() {
            let datePath = archivesRoot + "/" + dateFolder
            guard let entries = try? fm.contentsOfDirectory(atPath: datePath) else { continue }
            for entry in entries {
                guard entry.hasSuffix(".xcarchive") else { continue }
                let archivePath = datePath + "/" + entry
                let plistPath = archivePath + "/Info.plist"
                let (name, version, createdDate) = Self.parseArchiveInfo(at: plistPath, fallbackName: entry)
                let size = sizeOfDirectory(at: archivePath)
                guard size > 0 else { continue }
                results.append((name: name, version: version, path: archivePath, sizeBytes: size, createdDate: createdDate))
            }
        }
        return results
    }

    private nonisolated static func parseArchiveInfo(at plistPath: String, fallbackName: String) -> (name: String, version: String, createdDate: Date?) {
        guard let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
            let name = fallbackName.replacingOccurrences(of: ".xcarchive", with: "")
            return (name, "", nil)
        }
        let name = dict["Name"] as? String
            ?? fallbackName.replacingOccurrences(of: ".xcarchive", with: "")
        let createdDate = dict["CreationDate"] as? Date
        let appProps = dict["ApplicationProperties"] as? [String: Any]
        let shortVersion = appProps?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = appProps?["CFBundleVersion"] as? String ?? ""
        let version: String
        if shortVersion.isEmpty && buildNumber.isEmpty {
            version = ""
        } else if buildNumber.isEmpty {
            version = shortVersion
        } else {
            version = "\(shortVersion) (\(buildNumber))"
        }
        return (name, version, createdDate)
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
