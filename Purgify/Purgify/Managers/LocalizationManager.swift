import Foundation
import Combine

enum AppLanguage: String, CaseIterable {
    case en = "en"
    case vi = "vi"

    var displayName: String {
        switch self {
        case .en: return "English"
        case .vi: return "Tiếng Việt"
        }
    }

    var flag: String {
        switch self {
        case .en: return "🇺🇸"
        case .vi: return "🇻🇳"
        }
    }
}

/// Quản lý ngôn ngữ hiển thị của app.
/// Được tạo một lần duy nhất ở PurgifyApp và inject xuống View qua @EnvironmentObject.
@MainActor
class LocalizationManager: ObservableObject {

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: saved) ?? .en
    }

    func t(_ key: String) -> String {
        strings[language]?[key] ?? key
    }

    // MARK: - Localization strings

    private let strings: [AppLanguage: [String: String]] = [

        // MARK: English

        .en: [

            // App
            "app.title":          "Purgify",
            "app.subtitle":       "Clean caches across your Mac and free up disk space",
            "app.totalCache":     "total cache found",
            "app.allClean":       "All Clean!",
            "app.allCleanDesc":   "No caches found on this Mac",
            "app.allCleanFreed":  "You freed %@ of cache",
            "app.scanning":       "Scanning caches...",
            "app.selected":       "Selected",
            "app.cleanSelected":  "Clean Selected",
            "app.cleaning":       "Cleaning…",
            "app.freed":          "Freed",
            "app.openFull":       "Open Full App",
            "app.quit":           "Quit",
            "app.noCache":        "No cache found",
            "app.totalCacheLabel":"Total cache",
            "app.items":          "items",
            "app.scan":           "Scan",

            // Risk levels
            "risk.safe":          "Safe to Clean",
            "risk.safe.desc":     "Safe to delete, no impact on projects",
            "risk.moderate":      "Moderate",
            "risk.moderate.desc": "May need rebuild next time you open a project",
            "risk.caution":       "Caution",
            "risk.caution.desc":  "Review before deleting",
            "risk.selectAll":     "Select All",
            "risk.deselectAll":   "Deselect All",

            // Clean confirmation
            "clean.confirm.title":   "Clean %@ of cache?",
            "clean.confirm.message": "Items will be moved to Trash. Caches will be rebuilt automatically when needed.",
            "clean.confirm.clean":   "Clean",
            "clean.confirm.cancel":  "Cancel",

            // Cache names & descriptions
            "cache.npm":    "npm Cache",
            "cache.npm.detail":
                "A global download cache built up each time you run npm install.\n\n" +
                "Your projects and node_modules folders are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next npm install re-downloads packages from the internet instead of local cache, making it slightly slower.",

            "cache.yarn":   "Yarn Cache",
            "cache.yarn.detail":
                "A global download cache built up each time you run yarn install.\n\n" +
                "Your projects and node_modules folders are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next yarn install re-downloads packages from the internet instead of local cache.",

            "cache.yarnBerry":  "Yarn Berry Cache",
            "cache.yarnBerry.detail":
                "A global download cache used by Yarn v2+ (Berry).\n\n" +
                "Your projects continue to run normally after cleaning.\n\n" +
                "The only effect: the next yarn install re-downloads package archives from the internet instead of local cache.",

            "cache.corepack":   "Corepack Cache",
            "cache.corepack.detail":
                "Stores package manager binaries (Yarn, pnpm) downloaded by Node.js Corepack.\n\n" +
                "Your projects are unaffected.\n\n" +
                "The only effect: the next time you run yarn or pnpm, Corepack re-downloads the correct binary version from the internet.",

            "cache.bun":    "Bun Cache",
            "cache.bun.detail":
                "A global download cache built up each time you run bun install.\n\n" +
                "Your projects and node_modules folders are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next bun install re-downloads packages from the internet.",

            "cache.homebrew":   "Homebrew Cache",
            "cache.homebrew.detail":
                "Stores downloaded formula bottles (.tar.gz) from brew install or brew upgrade.\n\n" +
                "All your currently installed apps and CLI tools are completely unaffected.\n\n" +
                "The only effect: the next brew install re-downloads the formula from the internet.",

            "cache.cocoapods":  "CocoaPods Cache",
            "cache.cocoapods.detail":
                "A global cache of pod specs and source archives built up by pod install.\n\n" +
                "Your Pods/ folder in each project is untouched — projects build and run normally after cleaning.\n\n" +
                "The only effect: the next pod install re-downloads specs and sources from the internet.",

            "cache.xcode":  "Xcode DerivedData",
            "cache.xcode.detail":
                "Build artifacts created by Xcode — compiled objects, indexes, and build logs.\n\n" +
                "Unlike other caches, this directly impacts build speed: clearing it forces a full rebuild " +
                "the next time you open a project in Xcode, which can take 5–15 minutes for large projects.\n\n" +
                "Your source code is never touched.",

            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail":
                "Stores downloaded JARs/AARs and compiled build outputs from Android/Java builds.\n\n" +
                "Your source code is untouched.\n\n" +
                "The only effect: the next Gradle build re-downloads all dependencies and recompiles — expect a slower first build.",

            "cache.metro":  "Metro Bundler Cache",
            "cache.metro.detail":
                "Bundle cache created by React Native's Metro bundler each time you run your app.\n\n" +
                "Your source code is untouched. After cleaning, Metro rebuilds the JS bundle on the next npx react-native start.\n\n" +
                "Useful for clearing stale or corrupted bundles.",

            "cache.pnpm":   "pnpm Store",
            "cache.pnpm.detail":
                "The global store used by pnpm. Unlike npm/yarn, pnpm links node_modules directly to this store via hard links.\n\n" +
                "⚠️ Deleting it BREAKS node_modules in ALL your pnpm projects immediately.\n\n" +
                "You must run pnpm install again in each affected project before they work.",

            "cache.docker": "Docker Images",
            "cache.docker.detail":
                "Docker Desktop VM disk images containing all your containers, images, volumes, and databases.\n\n" +
                "⚠️ Deleting removes ALL Docker data — running containers will be destroyed and databases lost.\n\n" +
                "Use 'docker system prune' in Terminal for selective cleanup instead.",

            "cache.cargo":  "Cargo Cache",
            "cache.cargo.detail":
                "A global registry cache built up each time you run cargo build or cargo install.\n\n" +
                "Your source code and compiled binaries are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next cargo build re-downloads crates from crates.io, making it slightly slower.",

            "cache.pip":    "pip Cache",
            "cache.pip.detail":
                "A global download cache built up each time you install Python packages via pip.\n\n" +
                "Your virtual environments and installed packages are completely untouched — projects run normally after cleaning.\n\n" +
                "The only effect: the next pip install re-downloads packages from PyPI instead of local cache.",

            "cache.flutter": "Flutter Pub Cache",
            "cache.flutter.detail":
                "A global package cache built up each time you run flutter pub get or dart pub get.\n\n" +
                "Your projects are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next flutter pub get re-downloads packages from pub.dev instead of local cache.",

            "cache.simulator": "iOS Simulator Cache",
            "cache.simulator.detail":
                "Temporary caches created by Xcode's iOS Simulator — runtime assets, translation caches, and disk images.\n\n" +
                "Your source code, app data, and simulator devices are completely untouched.\n\n" +
                "The only effect: simulators may take slightly longer to launch the first time after cleaning.",

            "cache.maven":  "Maven Cache",
            "cache.maven.detail":
                "Local repository storing all downloaded JARs, POMs, and plugins from Maven builds.\n\n" +
                "Your source code is untouched.\n\n" +
                "The only effect: the next Maven build re-downloads all dependencies from Maven Central — expect a slower first build.",

            "cache.spm":    "Swift Package Manager Cache",
            "cache.spm.detail":
                "A global download cache built up each time Xcode or swift build resolves Swift packages.\n\n" +
                "Your source code and resolved packages are completely untouched — projects build normally after cleaning.\n\n" +
                "The only effect: the next build re-downloads package sources from their Git repositories.",

            "cache.go":     "Go Modules Cache",
            "cache.go.detail":
                "A global download cache built up each time you run go build, go get, or go mod download.\n\n" +
                "Your source code is completely untouched — projects run normally after cleaning.\n\n" +
                "The only effect: the next go build re-downloads modules from their source repositories.",

            "cache.composer": "Composer Cache",
            "cache.composer.detail":
                "A global download cache built up each time you run composer install or composer update.\n\n" +
                "Your vendor/ folders and projects are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next composer install re-downloads packages from Packagist instead of local cache.",

            "cache.bundler": "Bundler Cache",
            "cache.bundler.detail":
                "A metadata index cache Bundler uses to look up gem versions and dependencies from RubyGems.org.\n\n" +
                "Your installed gems, Gemfile.lock, and projects are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next bundle install re-fetches the compact index from RubyGems.org, adding a few seconds.",

            "cache.cypress": "Cypress Cache",
            "cache.cypress.detail":
                "Stores Cypress browser binaries downloaded for each version of the testing framework.\n\n" +
                "Your test files and project code are completely untouched — this only affects the test runner itself.\n\n" +
                "The only effect: the next cypress run re-downloads the binary, which can be 500 MB–2 GB per version.",

            "cache.playwright": "Playwright Cache",
            "cache.playwright.detail":
                "Stores browser binaries (Chromium, Firefox, WebKit) downloaded by Playwright for testing.\n\n" +
                "Your test files and project code are completely untouched.\n\n" +
                "The only effect: the next npx playwright install re-downloads all browser binaries, which can be 1–3 GB total.",

            "cache.poetry": "Poetry Cache",
            "cache.poetry.detail":
                "A global download cache built up each time you run poetry install or poetry add.\n\n" +
                "Your virtual environments and installed packages are completely untouched — projects run normally after cleaning.\n\n" +
                "The only effect: the next poetry install re-downloads packages from PyPI instead of local cache.",

            "cache.cocoapodsSpecs": "CocoaPods Specs",
            "cache.cocoapodsSpecs.detail":
                "The local clone of the CocoaPods specs repository — a database of all published pod versions and their metadata.\n\n" +
                "Your Pods/ folders and project builds are completely untouched.\n\n" +
                "The only effect: the next pod install re-clones the specs repo from GitHub, which can take a minute or two.",

            "cache.terraform": "Terraform Plugin Cache",
            "cache.terraform.detail":
                "A global cache of Terraform provider plugins downloaded during terraform init.\n\n" +
                "Your infrastructure code and state files are completely untouched.\n\n" +
                "The only effect: the next terraform init re-downloads provider plugins from the Terraform Registry.",

            "cache.android": "Android SDK Cache",
            "cache.android.detail":
                "Temporary caches created by the Android SDK tools — build tool metadata, ADB data, and SDK manager cache.\n\n" +
                "Your Android projects, installed SDKs, and AVD emulators are completely untouched.\n\n" +
                "The only effect: some SDK tools may take slightly longer on their next run.",

            // Browsers

            "cache.chrome": "Google Chrome Cache",
            "cache.chrome.detail":
                "Stores web page data (HTML, images, scripts) so Chrome can load sites faster on revisit.\n\n" +
                "Your bookmarks, history, passwords, extensions, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit while Chrome rebuilds the cache.",

            "cache.arc": "Arc Browser Cache",
            "cache.arc.detail":
                "Stores web page data so Arc can load sites faster on revisit.\n\n" +
                "Your Spaces, pinned tabs, Easels, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            "cache.firefox": "Firefox Cache",
            "cache.firefox.detail":
                "Stores web page data per profile so Firefox can load sites faster on revisit.\n\n" +
                "Your bookmarks, history, passwords, and extensions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            "cache.brave": "Brave Browser Cache",
            "cache.brave.detail":
                "Stores web page data so Brave can load sites faster on revisit.\n\n" +
                "Your bookmarks, history, Brave Rewards, wallet, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            "cache.edge": "Microsoft Edge Cache",
            "cache.edge.detail":
                "Stores web page data so Edge can load sites faster on revisit.\n\n" +
                "Your favorites, history, passwords, Collections, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            // Media apps

            "cache.spotify": "Spotify Cache",
            "cache.spotify.detail":
                "Stores streamed song data so Spotify can play tracks instantly without re-streaming.\n\n" +
                "Your downloaded-for-offline songs, playlists, and library are NOT touched — those live in a separate location.\n\n" +
                "The only effect: frequently played tracks may need to re-buffer the next time you stream them.",

            // System & utilities

            "cache.quicklook": "QuickLook Thumbnails",
            "cache.quicklook.detail":
                "Thumbnail previews generated when you use Space to preview files in Finder.\n\n" +
                "Your files are never touched.\n\n" +
                "The only effect: thumbnails regenerate the first time you preview each file again — normally instant.",

            "cache.appstore": "App Store Cache",
            "cache.appstore.detail":
                "Temporary data used by the Mac App Store app — icons, banners, and download metadata.\n\n" +
                "Your installed apps and purchase history are NOT touched.\n\n" +
                "The only effect: the App Store app may take slightly longer to load on the next launch.",

            "cache.userLogs": "User Logs",
            "cache.userLogs.detail":
                "App and system log files written to ~/Library/Logs by macOS and various apps over time.\n\n" +
                "Log files are informational — deleting them does not affect any running app.\n\n" +
                "The only effect: you lose historical logs that could help debug a past crash. Apps keep logging normally afterward.",

            // IDEs / Editors

            "cache.jetbrains": "JetBrains IDE Cache",
            "cache.jetbrains.detail":
                "Shared cache used by IntelliJ IDEA, WebStorm, PyCharm, Rider, GoLand, and other JetBrains IDEs — indexes, VCS snapshots, and plugin data.\n\n" +
                "Your projects and settings are NOT touched.\n\n" +
                "⚠️ Expect a slower first project open after cleaning — the IDE rebuilds indexes, which can take minutes on large projects.",

            "cache.vscode": "VS Code Cache",
            "cache.vscode.detail":
                "Workspace cache, extension data, and code completion caches used by Visual Studio Code.\n\n" +
                "Your projects, settings, and installed extensions are NOT touched.\n\n" +
                "The only effect: IntelliSense and search may be slightly slower the first time you reopen a workspace.",

            "cache.vscodeData": "VS Code Cached Data",
            "cache.vscodeData.detail":
                "Precompiled JavaScript cache VS Code builds up to speed up startup.\n\n" +
                "Your projects, settings, and extensions are NOT touched.\n\n" +
                "The only effect: VS Code startup may be slightly slower the first time after cleaning — the cache regenerates automatically.",

            // Communication apps

            "cache.slack": "Slack Cache",
            "cache.slack.detail":
                "Cached images, GIFs, and attachments from Slack channels and DMs.\n\n" +
                "Your messages, channels, and workspaces are NOT touched — they live on Slack's servers and re-sync automatically.\n\n" +
                "The only effect: images and files will re-download when you scroll back through channels.",

            "cache.teams": "Microsoft Teams Cache",
            "cache.teams.detail":
                "Cached images, attachments, and chat assets from Microsoft Teams.\n\n" +
                "Your messages, teams, and meetings are NOT touched — they re-sync from Microsoft's servers.\n\n" +
                "The only effect: chat images and files will re-download when viewed again. Often fixes Teams glitches.",

            "cache.discord": "Discord Cache",
            "cache.discord.detail":
                "Cached images, GIFs, and attachments from Discord servers and DMs.\n\n" +
                "Your messages, servers, and friends are NOT touched — they live on Discord's servers.\n\n" +
                "The only effect: images and files will re-download when you scroll back through channels.",

            "cache.zoom": "Zoom Cache",
            "cache.zoom.detail":
                "Temporary data used by the Zoom client — profile pictures, meeting thumbnails, and transient assets.\n\n" +
                "Your recorded meetings, chat history, and account data are NOT touched.\n\n" +
                "The only effect: some UI assets may reload on the next Zoom launch.",

            "cache.telegram": "Telegram Cache",
            "cache.telegram.detail":
                "Cached images, videos, stickers, and voice messages from your Telegram chats.\n\n" +
                "Your messages, contacts, and chats are NOT touched — Telegram re-downloads media on demand.\n\n" +
                "⚠️ Recently-viewed photos/videos in chats will need to re-download when you scroll back to them.",

            // Creative apps

            "cache.adobeMedia": "Adobe Media Cache Files",
            "cache.adobeMedia.detail":
                "Media cache files generated by Premiere Pro, After Effects, and Audition when importing videos/audio — often the BIGGEST cache on a creative Mac.\n\n" +
                "Your project files (.prproj, .aep) and source media are NOT touched.\n\n" +
                "⚠️ Active projects will need to re-generate previews and waveforms on next open — this can take a long time for large timelines.",

            "cache.adobeMediaDB": "Adobe Media Cache Database",
            "cache.adobeMediaDB.detail":
                "Metadata database that tracks the Media Cache Files above.\n\n" +
                "Your Adobe projects are NOT touched.\n\n" +
                "Safe to delete alongside Media Cache Files — Adobe apps rebuild the database automatically.",

            // Caution — non-dev

            "cache.iosDeviceSupport": "iOS Device Support",
            "cache.iosDeviceSupport.detail":
                "Symbol files Xcode downloads the first time you connect an iOS device for debugging — one folder per iOS version (can be 500 MB–2 GB each).\n\n" +
                "Your Xcode projects and devices are NOT touched.\n\n" +
                "⚠️ The next time you connect an iOS device, Xcode must re-download its support files — this can take several minutes and requires an internet connection.",

            // More browsers

            "cache.vivaldi": "Vivaldi Cache",
            "cache.vivaldi.detail":
                "Stores web page data so Vivaldi can load sites faster on revisit.\n\n" +
                "Your bookmarks, history, passwords, notes, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            "cache.opera": "Opera Cache",
            "cache.opera.detail":
                "Stores web page data so Opera can load sites faster on revisit.\n\n" +
                "Your bookmarks, history, passwords, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            "cache.duckduckgo": "DuckDuckGo Browser Cache",
            "cache.duckduckgo.detail":
                "Stores web page data so DuckDuckGo Browser can load sites faster on revisit.\n\n" +
                "Your bookmarks, Fireproof sites, and logged-in sessions are NOT touched — only the disk cache.\n\n" +
                "The only effect: websites load slightly slower on their next visit.",

            // More media

            "cache.vlc": "VLC Cache",
            "cache.vlc.detail":
                "Thumbnails and metadata VLC caches for video files you've opened.\n\n" +
                "Your video files and playlists are NOT touched.\n\n" +
                "The only effect: thumbnails regenerate the first time you preview each file in VLC again.",

            "cache.iina": "IINA Cache",
            "cache.iina.detail":
                "Thumbnails and metadata IINA caches for video files you've opened.\n\n" +
                "Your video files and playback history are NOT touched.\n\n" +
                "The only effect: thumbnails regenerate the first time you preview each file in IINA again.",

            "cache.plex": "Plex Cache",
            "cache.plex.detail":
                "Local cache used by the Plex desktop app — metadata, thumbnails, and UI assets.\n\n" +
                "Your Plex server data, libraries, and watch history are NOT touched.\n\n" +
                "The only effect: Plex may take slightly longer to load thumbnails on next launch.",

            // More system

            "cache.xcodeDeviceLogs": "Xcode iOS Device Logs",
            "cache.xcodeDeviceLogs.detail":
                "Console logs and crash reports from iOS devices that were connected to Xcode for debugging.\n\n" +
                "Your Xcode projects and devices are NOT touched.\n\n" +
                "The only effect: you lose historical device logs — rarely needed unless you're actively debugging a past issue.",

            "cache.nvm": "nvm Download Cache",
            "cache.nvm.detail":
                "Cache of downloaded Node.js binaries that nvm keeps after installing them.\n\n" +
                "Your installed Node.js versions (under ~/.nvm/versions/) are NOT touched — they continue to work.\n\n" +
                "The only effect: installing a previously cached Node.js version again will re-download it from nodejs.org.",

            // More IDEs

            "cache.cursor": "Cursor Cache",
            "cache.cursor.detail":
                "Workspace cache, extension data, and AI context caches used by Cursor.\n\n" +
                "Your projects, settings, and installed extensions are NOT touched.\n\n" +
                "The only effect: IntelliSense and search may be slightly slower the first time you reopen a workspace.",

            "cache.cursorData": "Cursor Cached Data",
            "cache.cursorData.detail":
                "Precompiled JavaScript cache Cursor builds up to speed up startup.\n\n" +
                "Your projects, settings, and extensions are NOT touched.\n\n" +
                "The only effect: Cursor startup may be slightly slower the first time after cleaning.",

            "cache.zed": "Zed Cache",
            "cache.zed.detail":
                "Workspace cache and language-server data used by the Zed editor.\n\n" +
                "Your projects and settings are NOT touched.\n\n" +
                "The only effect: Zed may be slightly slower the first time you reopen a project while it rebuilds language-server indexes.",

            "cache.sublimeText": "Sublime Text Cache",
            "cache.sublimeText.detail":
                "Cache of indexed files, workspace state, and package data used by Sublime Text.\n\n" +
                "Your projects, settings, and installed packages are NOT touched.\n\n" +
                "The only effect: Sublime Text may take slightly longer to index on next project open.",

            "cache.swiftuiPreviews": "SwiftUI Previews",
            "cache.swiftuiPreviews.detail":
                "Preview data Xcode generates for SwiftUI canvas previews — often the LARGEST item in your Xcode folder (can exceed 10 GB).\n\n" +
                "Your Xcode projects and source code are NOT touched.\n\n" +
                "⚠️ The next time you open a SwiftUI file with previews, Xcode must regenerate preview data — expect slower preview rendering for a while.",

            // More creative

            "cache.sketch": "Sketch Cache",
            "cache.sketch.detail":
                "Thumbnails, symbol previews, and autosave data used by Sketch.\n\n" +
                "Your Sketch files (.sketch) are NOT touched.\n\n" +
                "The only effect: thumbnails and symbol previews regenerate when you open files again.",

            // Productivity

            "cache.raycast": "Raycast Cache",
            "cache.raycast.detail":
                "Command cache, extension data, and preview images used by Raycast.\n\n" +
                "Your Raycast settings, extensions, snippets, and quicklinks are NOT touched.\n\n" +
                "The only effect: Raycast may be slightly slower for the first few commands while it rebuilds caches.",

            "cache.notion": "Notion Cache",
            "cache.notion.detail":
                "Cached page content, images, and attachments from your Notion workspaces.\n\n" +
                "Your pages, databases, and workspaces are NOT touched — they live on Notion's servers and re-sync automatically.\n\n" +
                "The only effect: pages may load slightly slower on first open as Notion re-fetches content.",

            "cache.obsidian": "Obsidian Cache",
            "cache.obsidian.detail":
                "Cached renders, search index, and plugin data used by Obsidian.\n\n" +
                "Your notes, vaults, and plugins are NOT touched — only the derived cache.\n\n" +
                "The only effect: Obsidian may take slightly longer to rebuild the search index on next launch.",

            // Games

            "cache.steam": "Steam App Cache",
            "cache.steam.detail":
                "App metadata, icons, and UI cache used by the Steam client — does NOT include installed games.\n\n" +
                "Your installed games, saves, and library are NOT touched.\n\n" +
                "The only effect: Steam may take a moment longer to load app icons and store pages on next launch.",

            // More caution — non-iOS device support

            "cache.watchosDeviceSupport": "watchOS Device Support",
            "cache.watchosDeviceSupport.detail":
                "Symbol files Xcode downloads the first time you connect an Apple Watch for debugging — one folder per watchOS version.\n\n" +
                "Your Xcode projects and devices are NOT touched.\n\n" +
                "⚠️ The next time you connect a watch, Xcode must re-download its support files — this can take several minutes.",

            "cache.tvosDeviceSupport": "tvOS Device Support",
            "cache.tvosDeviceSupport.detail":
                "Symbol files Xcode downloads the first time you connect an Apple TV for debugging — one folder per tvOS version.\n\n" +
                "Your Xcode projects and devices are NOT touched.\n\n" +
                "⚠️ The next time you connect an Apple TV, Xcode must re-download its support files — this can take several minutes.",

            "cache.visionosDeviceSupport": "visionOS Device Support",
            "cache.visionosDeviceSupport.detail":
                "Symbol files Xcode downloads the first time you connect a Vision Pro for debugging — one folder per visionOS version.\n\n" +
                "Your Xcode projects and devices are NOT touched.\n\n" +
                "⚠️ The next time you connect a Vision Pro, Xcode must re-download its support files — this can take several minutes.",

            // Sidebar
            "sidebar.scanAgain": "Rescan",

            // Detail panel
            "detail.totalSize":              "TOTAL SIZE",
            "detail.description":            "DESCRIPTION",
            "detail.location":               "LOCATION",
            "detail.riskLevel":              "RISK LEVEL",
            "detail.openInFinder":           "Open in Finder",
            "detail.clean":                  "Clean %@",
            "detail.selectItem":             "Select an item to view details",
            "detail.relatedProjects":        "RELATED PROJECTS",
            "detail.relatedProjectsCaption": "Source code size only · excludes dependencies (node_modules, Pods…)",
            "detail.relatedProjectsHint":    "Searches Desktop, Documents, and common dev folders. macOS may ask for folder access permission the first time.",
            "detail.findRelatedProjects":    "Find related projects",
            "detail.searchingProjects":      "Searching for projects...",
            "detail.noProjectsFound":        "No projects found in common folders.",
            "detail.openPrivacySettings":    "Grant file access in Privacy & Security",

            // Sub-items
            "subitem.totalSize":      "TOTAL SIZE",
            "subitem.projects":       "RELATED PROJECTS",
            "subitem.files":          "FILES",
            "subitem.devices":        "DEVICES",
            "subitem.selected":       "SELECTED",
            "subitem.cleanProjects":  "Clean %1 Selected Projects · %2",
            "subitem.cleanFiles":     "Clean %1 Selected Files · %2",
            "subitem.cleanDevices":   "Delete %1 Selected Devices · %2",
            "subitem.nSelected":      "%1 / %2 selected",
            "subitem.lastUsed":       "Last used",

            // Scan progress
            "scan.itemCount":         "%1 of %2 items",
            "scan.progressFormat":    "Scanning %1… %2 of %3",
            "scan.progressCount":     "Scanning… %1 of %2",
            "scan.moreItemsScanning": "More items appear as scan completes…",
            "scan.loadingItems":      "Loading items…",
            "scan.loadingItemsHint":  "Scanning sub-items inside this cache.",

            // Menu bar
            "menubar.cleanSelected": "Clean Selected · %@",

            // Settings sheet
            "settings.title":              "Settings",
            "settings.general":            "GENERAL",
            "settings.language":           "Language",
            "settings.launchAtLogin":      "Launch at Login",
            "settings.advanced":           "ADVANCED SCANNING",
            "settings.advanced.toggle":    "Advanced scanning",
            "settings.advanced.subtitle":  "Requires Full Disk Access permission",
            "settings.advanced.grantButton": "Grant Full Disk Access",
            "settings.advanced.granted":   "Full Disk Access granted",
            "settings.advanced.manage":    "Manage…",
            "settings.about":              "ABOUT",
            "settings.sendFeedback":       "Send Feedback",

            // FDA Guide sheet
            "fda.title":           "Grant Full Disk Access",
            "fda.titleGranted":    "Full Disk Access",
            "fda.heading":         "Unlock 4 protected caches",
            "fda.subheading":      "Grant Full Disk Access to scan Safari, Mail, Apple Music, and Diagnostic Reports caches.",
            "fda.step1.title":     "Open System Settings",
            "fda.step1.desc":      "Click the button below to open Privacy & Security.",
            "fda.step2.title":     "Find Purgify in the list",
            "fda.step2.desc":      "Scroll to Full Disk Access, toggle Purgify ON.",
            "fda.step3.title":     "Return to Purgify",
            "fda.step3.desc":      "The 4 protected caches will appear on your next scan.",
            "fda.relaunchHint":    "If the caches don't appear after granting access, quit and reopen Purgify.",
            "fda.primaryButton":   "Open System Settings",
            "fda.secondaryLink":   "Maybe later",
            "fda.grantedHeading":      "You're all set",
            "fda.grantedSubheading":   "Full Disk Access is granted. Safari, Mail, Apple Music, and Diagnostic Reports caches will be included on the next scan.",
            "fda.grantedDoneButton":   "Done",

            // FDA-gated cache display names (used in Settings Advanced list)
            "cache.safari":            "Safari Cache",
            "cache.mailDownloads":     "Mail Downloads",
            "cache.appleMusic":        "Apple Music Cache",
            "cache.diagnosticReports": "Diagnostic Reports",

            // User-file groups (Advanced — Installers, Archives, Disc images)
            "userfile.installers":         "Installers (.dmg / .pkg)",
            "userfile.installers.detail":
                "App installers downloaded to Downloads / Desktop / Documents.\n\n" +
                "Once you've installed the app, the .dmg or .pkg can be deleted safely — " +
                "you can always re-download from the vendor's site.\n\n" +
                "✅ Apps already installed continue to run normally.\n" +
                "⚠️ If you keep installers for offline reinstall (Sketch, Final Cut, " +
                "Adobe…), review the list before cleaning.",
            "userfile.archives":           "Archives (.zip / .tar / .7z)",
            "userfile.archives.detail":
                "Compressed archives in Downloads / Desktop / Documents.\n\n" +
                "Could be source code, photo backups, theme bundles, or installer payloads. " +
                "Open each one before deleting if you're not sure what's inside.\n\n" +
                "⚠️ Some apps ship as .zip — extract first, then the archive is safe to delete.",
            "userfile.discImages":         "Disc images (.iso / .img)",
            "userfile.discImages.detail":
                "Disc and disk images in Downloads / Desktop / Documents.\n\n" +
                "Usually OS installers (Windows ISO, Linux distros) or VM disk images. " +
                "Rarely reused after installation completes — large and easy wins.\n\n" +
                "⚠️ Keep if you reinstall the same OS often.",

            // Xcode Archives
            "xcode.archives":        "Xcode Archives",
            "xcode.archives.detail":
                "Completed, signed app builds saved by Xcode at ~/Library/Developer/Xcode/Archives.\n\n" +
                "Each .xcarchive is a full build artifact used to export an .ipa or .app for distribution. " +
                "Xcode keeps every archive you've ever created, and they can accumulate gigabytes over time.\n\n" +
                "✅ Your installed app is not affected — archives are only needed to re-export or re-sign an old build.\n" +
                "⚠️ Once deleted, you cannot re-export that specific build. If you need an older binary, you must rebuild from source.",
            "subitem.archived":      "Archived",

            // Mobile VM groups (iOS Simulators, Android AVDs, system images)
            "vm.iOSSimulators":         "iOS Simulators",
            "vm.iOSSimulators.detail":
                "iOS Simulator devices created by Xcode — each one stores its own app data, settings, and installed apps.\n\n" +
                "Deleting a simulator removes all data inside it (installed apps, user data, keychain). " +
                "You can re-create simulators for free in Xcode → Window → Devices and Simulators.\n\n" +
                "⚠️ Stale simulators (old iOS versions, rarely used) are shown oldest-used first — safe to prune if you no longer test against those OS versions.",
            "vm.iOSRuntimes":           "iOS Simulator Runtimes",
            "vm.iOSRuntimes.detail":
                "Downloaded iOS Simulator runtime bundles — each runtime is 4–10 GB and is required to run simulators for that iOS version.\n\n" +
                "Deleting a runtime means simulators for that iOS version can no longer launch until you re-download it from Xcode.\n\n" +
                "⚠️ Only delete runtimes for iOS versions you no longer test against. Re-download any time from Xcode → Settings → Platforms.",
            "vm.androidPlatforms":      "Android SDK Platforms",
            "vm.androidPlatforms.detail":
                "Android SDK platform packages installed at ~/Library/Android/sdk/platforms — one per API level (android-35, android-34, …).\n\n" +
                "Each platform is required to compile apps targeting that API level. " +
                "Purgify scans your active projects to flag which API levels are referenced in build.gradle files.\n\n" +
                "✅ Platforms marked 'in use' are needed to build your current projects.\n" +
                "🗑️ Platforms marked 'unused' are not referenced by any project found on this Mac and can be deleted. " +
                "You can re-download any platform any time via Android Studio → SDK Manager.",
            "vm.androidBuildTools":     "Android Build-tools",
            "vm.androidBuildTools.detail":
                "Android SDK build-tools packages at ~/Library/Android/sdk/build-tools — each version contains the compiler, dexer, and packaging tools used during a build.\n\n" +
                "Purgify scans your projects' build.gradle files for the buildToolsVersion field to determine which versions are actively referenced.\n\n" +
                "✅ Versions marked 'in use' are referenced by a project on this Mac — keep at least the latest one.\n" +
                "🗑️ Older versions marked 'unused' can usually be deleted safely. Gradle falls back to the nearest available version.",
            "vm.androidNDK":            "Android NDK",
            "vm.androidNDK.detail":
                "Android NDK (Native Development Kit) versions at ~/Library/Android/sdk/ndk — each version is 2–4 GB and required for projects that compile C/C++ or Rust native code.\n\n" +
                "Purgify scans your projects' build.gradle files for the ndkVersion field to detect which versions are actively pinned.\n\n" +
                "✅ Versions marked 'in use' are pinned by a project — deleting them will break native builds.\n" +
                "🗑️ Versions marked 'unused' are not referenced by any project on this Mac and are safe to remove.",
            "vm.androidAVDs":           "Android Emulators (AVD)",
            "vm.androidAVDs.detail":
                "Android Virtual Devices (AVDs) managed by Android Studio — each one stores its own disk image, app data, and emulator snapshot.\n\n" +
                "Deleting an AVD removes all its data. You can re-create AVDs in Android Studio → Device Manager at any time.\n\n" +
                "⚠️ Stale emulators (old API levels, unused devices) are shown oldest-used first — safe to prune if you no longer test against those Android versions.",
            "vm.androidImages":         "Android System Images",
            "vm.androidImages.detail":
                "Downloaded Android SDK system images — each one is 1–4 GB and is required to create and run AVDs for that API level and variant.\n\n" +
                "Deleting a system image means AVDs using it can no longer launch until you re-download from Android Studio SDK Manager.\n\n" +
                "⚠️ Only delete images for API levels you no longer use. Re-download any time from Android Studio → SDK Manager → SDK Images.",

            // Post-clean upsell banner (legacy — superseded by cleanSuccess.* modal)
            "banner.heading":  "Unlock 4 more caches",
            "banner.subtext":  "Enable Advanced to scan Safari, Mail, Apple Music, and Diagnostic Reports.",
            "banner.button":   "Enable Advanced",

            // Clean Success modal (shown after a successful clean)
            "cleanSuccess.title":           "Cleanup Complete",
            "cleanSuccess.youFreed":        "You freed",
            "cleanSuccess.itemsCleaned":    "%1 items cleaned across %2 categories",
            "cleanSuccess.oneItemCleaned":  "1 item cleaned",
            "cleanSuccess.upsellTitle":     "Unlock 4 more caches",
            "cleanSuccess.upsellSubtitle":  "Safari, Mail Downloads, Apple Music, Reports",
            "cleanSuccess.enable":          "Enable",
            "cleanSuccess.done":            "Done",

            // About sheet
            "about.description":  "Clean every cache on your Mac — developer tools, browsers, apps, and system.",
            "about.madeBy":       "Made with ♥ by",
            "about.author":       "Pham Linh",
            "about.viewOnGitHub": "View on GitHub",
            "about.copyright":    "© 2025 Purgify. Open source under MIT License.",

            // Clean preview sheet
            "cleanPreview.title":           "Review Before Cleaning",
            "cleanPreview.subtitle":        "These items will be moved to Trash. You can restore them from Trash if needed.",
            "cleanPreview.total":           "Total",
            "cleanPreview.cancel":          "Cancel",
            "cleanPreview.confirm":         "Move %@ to Trash",
            "cleanPreview.revealInFinder":  "Reveal in Finder",
        ],

        // MARK: Vietnamese

        .vi: [

            // App
            "app.title":          "Purgify",
            "app.subtitle":       "Dọn dẹp bộ nhớ đệm trên Mac và giải phóng dung lượng",
            "app.totalCache":     "tổng bộ nhớ đệm",
            "app.allClean":       "Sạch sẽ!",
            "app.allCleanDesc":   "Không tìm thấy bộ nhớ đệm nào trên máy",
            "app.allCleanFreed":  "Đã giải phóng %@ bộ nhớ đệm",
            "app.scanning":       "Đang quét...",
            "app.selected":       "Đã chọn",
            "app.cleanSelected":  "Dọn dẹp",
            "app.cleaning":       "Đang dọn…",
            "app.freed":          "Đã giải phóng",
            "app.openFull":       "Mở ứng dụng",
            "app.quit":           "Thoát",
            "app.noCache":        "Không tìm thấy cache",
            "app.totalCacheLabel":"Tổng cache",
            "app.items":          "mục",
            "app.scan":           "Quét",

            // Risk levels
            "risk.safe":          "An toàn",
            "risk.safe.desc":     "Xóa thoải mái, không ảnh hưởng dự án",
            "risk.moderate":      "Trung bình",
            "risk.moderate.desc": "Có thể cần build lại khi mở dự án lần sau",
            "risk.caution":       "Cẩn thận",
            "risk.caution.desc":  "Nên xem xét trước khi xóa",
            "risk.selectAll":     "Chọn tất cả",
            "risk.deselectAll":   "Bỏ chọn tất cả",

            // Clean confirmation
            "clean.confirm.title":   "Dọn %@ bộ nhớ đệm?",
            "clean.confirm.message": "Các mục sẽ được chuyển vào Thùng rác. Bộ nhớ đệm sẽ tự tạo lại khi cần.",
            "clean.confirm.clean":   "Dọn dẹp",
            "clean.confirm.cancel":  "Hủy",

            // Cache names & descriptions
            "cache.npm":    "npm Cache",
            "cache.npm.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn chạy npm install.\n\n" +
                "node_modules và các dự án của bạn hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần npm install tiếp theo sẽ tải lại từ internet thay vì cache local, chậm hơn một chút.",

            "cache.yarn":   "Yarn Cache",
            "cache.yarn.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn chạy yarn install.\n\n" +
                "node_modules và các dự án của bạn hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần yarn install tiếp theo tải lại từ internet.",

            "cache.yarnBerry":  "Yarn Berry Cache",
            "cache.yarnBerry.detail":
                "Cache tải gói toàn cục của Yarn v2+ (Berry).\n\n" +
                "Các dự án của bạn vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần yarn install tiếp theo tải lại package từ internet thay vì cache local.",

            "cache.corepack":   "Corepack Cache",
            "cache.corepack.detail":
                "Lưu các file binary (Yarn, pnpm) do Node.js Corepack tải về.\n\n" +
                "Dự án của bạn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần chạy yarn hoặc pnpm tiếp theo sẽ tải lại đúng phiên bản binary từ internet.",

            "cache.bun":    "Bun Cache",
            "cache.bun.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn chạy bun install.\n\n" +
                "node_modules và các dự án của bạn hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần bun install tiếp theo tải lại từ internet.",

            "cache.homebrew":   "Homebrew Cache",
            "cache.homebrew.detail":
                "Lưu các file bottle (.tar.gz) khi bạn chạy brew install hoặc brew upgrade.\n\n" +
                "Tất cả app và CLI tool đã cài hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần brew install tiếp theo tải lại formula từ internet.",

            "cache.cocoapods":  "CocoaPods Cache",
            "cache.cocoapods.detail":
                "Cache toàn cục lưu pod specs và source archives, tích lũy qua các lần pod install.\n\n" +
                "Thư mục Pods/ trong từng dự án không bị đụng — dự án build và chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần pod install tiếp theo tải lại từ internet.",

            "cache.xcode":  "Xcode DerivedData",
            "cache.xcode.detail":
                "Kết quả build của Xcode — file biên dịch, chỉ mục và build logs.\n\n" +
                "Khác với các cache khác, đây ảnh hưởng trực tiếp đến tốc độ build: " +
                "xóa sẽ buộc build lại toàn bộ lần sau khi mở dự án trong Xcode, có thể mất 5–15 phút với dự án lớn.\n\n" +
                "Mã nguồn không bị đụng.",

            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail":
                "Lưu các file JAR/AAR đã tải và kết quả build từ Android/Java.\n\n" +
                "Mã nguồn của bạn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần Gradle build tiếp theo tải lại toàn bộ dependencies và biên dịch lại — lần đầu sẽ chậm hơn.",

            "cache.metro":  "Metro Bundler Cache",
            "cache.metro.detail":
                "Cache bundle của React Native's Metro bundler, tạo ra mỗi khi bạn chạy app.\n\n" +
                "Mã nguồn không bị đụng. Sau khi xóa, Metro build lại JS bundle ở lần npx react-native start tiếp theo.\n\n" +
                "Hữu ích khi app hiển thị code cũ không cập nhật.",

            "cache.pnpm":   "pnpm Store",
            "cache.pnpm.detail":
                "Kho lưu trữ toàn cục của pnpm. Khác với npm/yarn, pnpm liên kết node_modules trực tiếp đến kho này qua hard links.\n\n" +
                "⚠️ Xóa sẽ LÀM HỎNG node_modules của TẤT CẢ dự án pnpm ngay lập tức.\n\n" +
                "Bạn phải chạy pnpm install lại ở từng dự án trước khi chúng hoạt động được.",

            "cache.docker": "Docker Images",
            "cache.docker.detail":
                "Ảnh đĩa VM của Docker Desktop chứa toàn bộ containers, images, volumes và databases.\n\n" +
                "⚠️ Xóa sẽ mất TOÀN BỘ dữ liệu Docker — containers đang chạy bị hủy, database bị mất.\n\n" +
                "Nên dùng 'docker system prune' trong Terminal để dọn chọn lọc thay thế.",

            "cache.cargo":  "Cargo Cache",
            "cache.cargo.detail":
                "Cache registry toàn cục, tích lũy mỗi khi bạn chạy cargo build hoặc cargo install.\n\n" +
                "Mã nguồn và các binary đã build hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần cargo build tiếp theo tải lại các crate từ crates.io thay vì cache local, chậm hơn một chút.",

            "cache.pip":    "pip Cache",
            "cache.pip.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn cài Python package qua pip.\n\n" +
                "Virtual environment và các package đã cài hoàn toàn không bị ảnh hưởng — dự án vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần pip install tiếp theo tải lại từ PyPI thay vì cache local.",

            "cache.flutter": "Flutter Pub Cache",
            "cache.flutter.detail":
                "Cache package toàn cục, tích lũy mỗi khi bạn chạy flutter pub get hoặc dart pub get.\n\n" +
                "Các dự án của bạn hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần flutter pub get tiếp theo tải lại từ pub.dev thay vì cache local.",

            "cache.simulator": "iOS Simulator Cache",
            "cache.simulator.detail":
                "Cache tạm thời của iOS Simulator trong Xcode — runtime assets, translation cache và disk images.\n\n" +
                "Mã nguồn, dữ liệu app và thiết bị simulator hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: simulator có thể khởi động chậm hơn một chút ở lần đầu sau khi xóa.",

            "cache.maven":  "Maven Cache",
            "cache.maven.detail":
                "Repository local lưu tất cả JAR, POM và plugin đã tải từ các lần Maven build.\n\n" +
                "Mã nguồn của bạn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần Maven build tiếp theo tải lại toàn bộ dependencies từ Maven Central — lần đầu sẽ chậm hơn.",

            "cache.spm":    "Swift Package Manager Cache",
            "cache.spm.detail":
                "Cache tải toàn cục, tích lũy mỗi khi Xcode hoặc swift build phân giải Swift packages.\n\n" +
                "Mã nguồn và các package đã resolved hoàn toàn không bị ảnh hưởng — dự án build bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần build tiếp theo tải lại package sources từ các Git repository.",

            "cache.go":     "Go Modules Cache",
            "cache.go.detail":
                "Cache tải module toàn cục, tích lũy mỗi khi bạn chạy go build, go get hoặc go mod download.\n\n" +
                "Mã nguồn hoàn toàn không bị ảnh hưởng — dự án vẫn chạy bình thường sau khi xóa.\n\n" +
                "Tác động duy nhất: lần go build tiếp theo tải lại module từ source repository.",

            "cache.composer": "Composer Cache",
            "cache.composer.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn chạy composer install hoặc composer update.\n\n" +
                "Thư mục vendor/ và các dự án hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường.\n\n" +
                "Tác động duy nhất: lần composer install tiếp theo tải lại từ Packagist thay vì cache local.",

            "cache.bundler": "Bundler Cache",
            "cache.bundler.detail":
                "Cache metadata index mà Bundler dùng để tra cứu phiên bản và dependencies của gem từ RubyGems.org.\n\n" +
                "Gem đã cài, Gemfile.lock và các dự án hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường.\n\n" +
                "Tác động duy nhất: lần bundle install tiếp theo fetch lại compact index từ RubyGems.org, chậm hơn vài giây.",

            "cache.cypress": "Cypress Cache",
            "cache.cypress.detail":
                "Lưu các browser binary được tải về cho từng phiên bản Cypress testing framework.\n\n" +
                "File test và mã nguồn hoàn toàn không bị ảnh hưởng — chỉ ảnh hưởng đến test runner.\n\n" +
                "Tác động duy nhất: lần cypress run tiếp theo tải lại binary, có thể 500 MB–2 GB mỗi phiên bản.",

            "cache.playwright": "Playwright Cache",
            "cache.playwright.detail":
                "Lưu các browser binary (Chromium, Firefox, WebKit) được Playwright tải về để chạy test.\n\n" +
                "File test và mã nguồn hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần npx playwright install tiếp theo tải lại toàn bộ browser binary, có thể 1–3 GB.",

            "cache.poetry": "Poetry Cache",
            "cache.poetry.detail":
                "Cache tải gói toàn cục, tích lũy mỗi khi bạn chạy poetry install hoặc poetry add.\n\n" +
                "Virtual environment và các package đã cài hoàn toàn không bị ảnh hưởng — dự án vẫn chạy bình thường.\n\n" +
                "Tác động duy nhất: lần poetry install tiếp theo tải lại từ PyPI thay vì cache local.",

            "cache.cocoapodsSpecs": "CocoaPods Specs",
            "cache.cocoapodsSpecs.detail":
                "Bản sao local của CocoaPods specs repository — cơ sở dữ liệu chứa metadata của tất cả pod đã xuất bản.\n\n" +
                "Thư mục Pods/ và các project build hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần pod install tiếp theo clone lại specs repo từ GitHub, có thể mất 1–2 phút.",

            "cache.terraform": "Terraform Plugin Cache",
            "cache.terraform.detail":
                "Cache toàn cục lưu các Terraform provider plugin được tải về khi chạy terraform init.\n\n" +
                "Mã nguồn infrastructure và state file hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: lần terraform init tiếp theo tải lại provider plugin từ Terraform Registry.",

            "cache.android": "Android SDK Cache",
            "cache.android.detail":
                "Cache tạm thời của Android SDK tools — build tool metadata, ADB data và SDK manager cache.\n\n" +
                "Dự án Android, SDK đã cài và AVD emulator hoàn toàn không bị ảnh hưởng.\n\n" +
                "Tác động duy nhất: một số SDK tool có thể chạy chậm hơn một chút ở lần đầu sau khi xóa.",

            // Trình duyệt

            "cache.chrome": "Google Chrome Cache",
            "cache.chrome.detail":
                "Lưu dữ liệu trang web (HTML, ảnh, script) để Chrome tải lại các site nhanh hơn.\n\n" +
                "Bookmark, history, mật khẩu, extension và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp trong khi Chrome build lại cache.",

            "cache.arc": "Arc Browser Cache",
            "cache.arc.detail":
                "Lưu dữ liệu trang web để Arc tải lại các site nhanh hơn.\n\n" +
                "Spaces, pinned tabs, Easels và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            "cache.firefox": "Firefox Cache",
            "cache.firefox.detail":
                "Lưu dữ liệu trang web theo từng profile để Firefox tải lại các site nhanh hơn.\n\n" +
                "Bookmark, history, mật khẩu và extension KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            "cache.brave": "Brave Browser Cache",
            "cache.brave.detail":
                "Lưu dữ liệu trang web để Brave tải lại các site nhanh hơn.\n\n" +
                "Bookmark, history, Brave Rewards, ví và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            "cache.edge": "Microsoft Edge Cache",
            "cache.edge.detail":
                "Lưu dữ liệu trang web để Edge tải lại các site nhanh hơn.\n\n" +
                "Favorites, history, mật khẩu, Collections và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            // Ứng dụng media

            "cache.spotify": "Spotify Cache",
            "cache.spotify.detail":
                "Lưu dữ liệu bài hát đã stream để Spotify phát ngay lập tức mà không cần stream lại.\n\n" +
                "Bài hát tải offline, playlist và thư viện KHÔNG bị đụng — chúng nằm ở vị trí khác.\n\n" +
                "Tác động duy nhất: các bài nghe gần đây có thể phải buffer lại ở lần stream kế tiếp.",

            // Hệ thống & tiện ích

            "cache.quicklook": "QuickLook Thumbnails",
            "cache.quicklook.detail":
                "Thumbnail preview được tạo khi bạn bấm Space xem file trong Finder.\n\n" +
                "Các file của bạn không hề bị đụng.\n\n" +
                "Tác động duy nhất: thumbnail sẽ được tạo lại ở lần preview đầu tiên sau khi xóa — thường là tức thì.",

            "cache.appstore": "App Store Cache",
            "cache.appstore.detail":
                "Dữ liệu tạm của app Mac App Store — icon, banner và metadata tải xuống.\n\n" +
                "Các app đã cài và lịch sử mua hàng KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: App Store có thể mở chậm hơn một chút ở lần khởi động kế tiếp.",

            "cache.userLogs": "User Logs",
            "cache.userLogs.detail":
                "File log của app và hệ thống được ghi vào ~/Library/Logs theo thời gian.\n\n" +
                "Log chỉ mang tính tham khảo — xóa không ảnh hưởng đến app đang chạy.\n\n" +
                "Tác động duy nhất: bạn mất log cũ có thể dùng để debug crash trong quá khứ. App vẫn ghi log bình thường sau đó.",

            // IDE / Editor

            "cache.jetbrains": "JetBrains IDE Cache",
            "cache.jetbrains.detail":
                "Cache dùng chung bởi IntelliJ IDEA, WebStorm, PyCharm, Rider, GoLand và các IDE JetBrains khác — index, VCS snapshot và plugin data.\n\n" +
                "Dự án và cài đặt của bạn KHÔNG bị đụng.\n\n" +
                "⚠️ Lần mở dự án đầu tiên sau khi xóa sẽ chậm — IDE phải build lại index, có thể mất vài phút với dự án lớn.",

            "cache.vscode": "VS Code Cache",
            "cache.vscode.detail":
                "Workspace cache, extension data và code completion cache của Visual Studio Code.\n\n" +
                "Dự án, cài đặt và các extension đã cài KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: IntelliSense và search có thể chậm hơn một chút ở lần mở lại workspace đầu tiên.",

            "cache.vscodeData": "VS Code Cached Data",
            "cache.vscodeData.detail":
                "Cache JavaScript đã biên dịch trước để VS Code khởi động nhanh hơn.\n\n" +
                "Dự án, cài đặt và extension KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: VS Code khởi động chậm hơn một chút ở lần đầu sau khi xóa — cache tự build lại.",

            // Ứng dụng giao tiếp

            "cache.slack": "Slack Cache",
            "cache.slack.detail":
                "Cache ảnh, GIF và attachment từ các kênh Slack và DM.\n\n" +
                "Tin nhắn, kênh và workspace KHÔNG bị đụng — chúng nằm trên server Slack và tự sync lại.\n\n" +
                "Tác động duy nhất: ảnh và file sẽ tải lại khi bạn cuộn lại các kênh cũ.",

            "cache.teams": "Microsoft Teams Cache",
            "cache.teams.detail":
                "Cache ảnh, attachment và asset chat của Microsoft Teams.\n\n" +
                "Tin nhắn, team và meeting KHÔNG bị đụng — chúng sync lại từ server Microsoft.\n\n" +
                "Tác động duy nhất: ảnh và file chat sẽ tải lại khi xem lại. Thường giúp fix các lỗi vặt của Teams.",

            "cache.discord": "Discord Cache",
            "cache.discord.detail":
                "Cache ảnh, GIF và attachment từ các server Discord và DM.\n\n" +
                "Tin nhắn, server và bạn bè KHÔNG bị đụng — chúng nằm trên server Discord.\n\n" +
                "Tác động duy nhất: ảnh và file sẽ tải lại khi bạn cuộn lại các kênh cũ.",

            "cache.zoom": "Zoom Cache",
            "cache.zoom.detail":
                "Dữ liệu tạm của client Zoom — ảnh đại diện, thumbnail meeting và asset tạm.\n\n" +
                "Meeting đã ghi, lịch sử chat và dữ liệu tài khoản KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: một số UI asset có thể tải lại ở lần mở Zoom kế tiếp.",

            "cache.telegram": "Telegram Cache",
            "cache.telegram.detail":
                "Cache ảnh, video, sticker và tin nhắn thoại từ các chat Telegram.\n\n" +
                "Tin nhắn, contact và chat KHÔNG bị đụng — Telegram sẽ tải lại media khi cần.\n\n" +
                "⚠️ Ảnh/video đã xem gần đây trong chat sẽ phải tải lại khi bạn cuộn ngược lên.",

            // Ứng dụng sáng tạo

            "cache.adobeMedia": "Adobe Media Cache Files",
            "cache.adobeMedia.detail":
                "File media cache do Premiere Pro, After Effects, Audition tạo khi import video/audio — thường là cache LỚN NHẤT trên Mac của dân sáng tạo.\n\n" +
                "File dự án (.prproj, .aep) và media gốc KHÔNG bị đụng.\n\n" +
                "⚠️ Các dự án đang làm sẽ phải tạo lại preview và waveform ở lần mở kế tiếp — có thể mất kha khá thời gian với timeline lớn.",

            "cache.adobeMediaDB": "Adobe Media Cache Database",
            "cache.adobeMediaDB.detail":
                "Database metadata quản lý các Media Cache Files ở trên.\n\n" +
                "Dự án Adobe KHÔNG bị đụng.\n\n" +
                "An toàn khi xóa cùng với Media Cache Files — Adobe tự build lại database.",

            // Caution — non-dev

            "cache.iosDeviceSupport": "iOS Device Support",
            "cache.iosDeviceSupport.detail":
                "File symbol mà Xcode tải về lần đầu bạn cắm thiết bị iOS để debug — mỗi phiên bản iOS một thư mục (có thể 500 MB–2 GB mỗi cái).\n\n" +
                "Dự án Xcode và thiết bị KHÔNG bị đụng.\n\n" +
                "⚠️ Lần cắm thiết bị iOS kế tiếp, Xcode sẽ phải tải lại support files — có thể mất vài phút và cần internet.",

            // Trình duyệt (thêm)

            "cache.vivaldi": "Vivaldi Cache",
            "cache.vivaldi.detail":
                "Lưu dữ liệu trang web để Vivaldi tải lại các site nhanh hơn.\n\n" +
                "Bookmark, history, mật khẩu, notes và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            "cache.opera": "Opera Cache",
            "cache.opera.detail":
                "Lưu dữ liệu trang web để Opera tải lại các site nhanh hơn.\n\n" +
                "Bookmark, history, mật khẩu và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            "cache.duckduckgo": "DuckDuckGo Browser Cache",
            "cache.duckduckgo.detail":
                "Lưu dữ liệu trang web để DuckDuckGo Browser tải lại các site nhanh hơn.\n\n" +
                "Bookmark, Fireproof sites và các phiên đăng nhập KHÔNG bị đụng — chỉ xóa cache ổ đĩa.\n\n" +
                "Tác động duy nhất: website tải chậm hơn một chút ở lần truy cập kế tiếp.",

            // Media (thêm)

            "cache.vlc": "VLC Cache",
            "cache.vlc.detail":
                "Thumbnail và metadata mà VLC cache cho các video bạn đã mở.\n\n" +
                "File video và playlist KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: thumbnail sẽ được tạo lại ở lần preview đầu tiên trong VLC.",

            "cache.iina": "IINA Cache",
            "cache.iina.detail":
                "Thumbnail và metadata mà IINA cache cho các video bạn đã mở.\n\n" +
                "File video và lịch sử phát KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: thumbnail sẽ được tạo lại ở lần preview đầu tiên trong IINA.",

            "cache.plex": "Plex Cache",
            "cache.plex.detail":
                "Cache local của app Plex desktop — metadata, thumbnail và UI asset.\n\n" +
                "Dữ liệu Plex server, thư viện và lịch sử xem KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Plex có thể mất một chút thời gian load thumbnail ở lần khởi động kế tiếp.",

            // Hệ thống (thêm)

            "cache.xcodeDeviceLogs": "Xcode iOS Device Logs",
            "cache.xcodeDeviceLogs.detail":
                "Console log và crash report từ các thiết bị iOS đã cắm vào Xcode để debug.\n\n" +
                "Dự án Xcode và thiết bị KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: mất device log cũ — ít khi cần trừ khi bạn đang debug lỗi trong quá khứ.",

            "cache.nvm": "nvm Download Cache",
            "cache.nvm.detail":
                "Cache của các Node.js binary đã tải về mà nvm giữ lại sau khi cài.\n\n" +
                "Các phiên bản Node.js đã cài (ở ~/.nvm/versions/) KHÔNG bị đụng — vẫn hoạt động bình thường.\n\n" +
                "Tác động duy nhất: cài lại phiên bản Node.js đã từng cache sẽ phải tải lại từ nodejs.org.",

            // IDE / Editor (thêm)

            "cache.cursor": "Cursor Cache",
            "cache.cursor.detail":
                "Workspace cache, extension data và AI context cache của Cursor.\n\n" +
                "Dự án, cài đặt và các extension đã cài KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: IntelliSense và search có thể chậm hơn một chút ở lần mở lại workspace đầu tiên.",

            "cache.cursorData": "Cursor Cached Data",
            "cache.cursorData.detail":
                "Cache JavaScript đã biên dịch trước để Cursor khởi động nhanh hơn.\n\n" +
                "Dự án, cài đặt và extension KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Cursor khởi động chậm hơn một chút ở lần đầu sau khi xóa.",

            "cache.zed": "Zed Cache",
            "cache.zed.detail":
                "Workspace cache và dữ liệu language server của editor Zed.\n\n" +
                "Dự án và cài đặt KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Zed có thể chậm hơn một chút khi mở lại dự án trong lúc build lại index language server.",

            "cache.sublimeText": "Sublime Text Cache",
            "cache.sublimeText.detail":
                "Cache index file, workspace state và package data của Sublime Text.\n\n" +
                "Dự án, cài đặt và các package đã cài KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Sublime Text có thể mất thêm thời gian index ở lần mở dự án kế tiếp.",

            "cache.swiftuiPreviews": "SwiftUI Previews",
            "cache.swiftuiPreviews.detail":
                "Dữ liệu preview mà Xcode tạo ra cho SwiftUI canvas — thường là mục LỚN NHẤT trong thư mục Xcode (có thể vượt 10 GB).\n\n" +
                "Dự án Xcode và mã nguồn KHÔNG bị đụng.\n\n" +
                "⚠️ Lần mở file SwiftUI có preview kế tiếp, Xcode phải build lại preview — render sẽ chậm hơn một lúc.",

            // Creative (thêm)

            "cache.sketch": "Sketch Cache",
            "cache.sketch.detail":
                "Thumbnail, symbol preview và autosave data của Sketch.\n\n" +
                "File Sketch (.sketch) KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: thumbnail và symbol preview sẽ tạo lại khi bạn mở file.",

            // Productivity

            "cache.raycast": "Raycast Cache",
            "cache.raycast.detail":
                "Command cache, extension data và preview image của Raycast.\n\n" +
                "Cài đặt Raycast, extension, snippet và quicklink KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Raycast có thể chậm hơn một chút ở vài lệnh đầu tiên trong lúc build lại cache.",

            "cache.notion": "Notion Cache",
            "cache.notion.detail":
                "Cache nội dung page, ảnh và attachment từ các workspace Notion.\n\n" +
                "Page, database và workspace KHÔNG bị đụng — chúng nằm trên server Notion và tự sync lại.\n\n" +
                "Tác động duy nhất: page có thể load chậm hơn ở lần mở đầu tiên khi Notion fetch lại nội dung.",

            "cache.obsidian": "Obsidian Cache",
            "cache.obsidian.detail":
                "Cache render, search index và plugin data của Obsidian.\n\n" +
                "Ghi chú, vault và plugin KHÔNG bị đụng — chỉ xóa cache phát sinh.\n\n" +
                "Tác động duy nhất: Obsidian có thể mất thêm thời gian build lại search index ở lần khởi động kế tiếp.",

            // Games

            "cache.steam": "Steam App Cache",
            "cache.steam.detail":
                "Metadata app, icon và UI cache của Steam client — KHÔNG bao gồm game đã cài.\n\n" +
                "Game đã cài, save file và thư viện KHÔNG bị đụng.\n\n" +
                "Tác động duy nhất: Steam có thể mất thêm chút thời gian load icon và store page ở lần khởi động kế tiếp.",

            // Caution (thêm) — device support cho non-iOS

            "cache.watchosDeviceSupport": "watchOS Device Support",
            "cache.watchosDeviceSupport.detail":
                "File symbol mà Xcode tải về lần đầu bạn cắm Apple Watch để debug — mỗi phiên bản watchOS một thư mục.\n\n" +
                "Dự án Xcode và thiết bị KHÔNG bị đụng.\n\n" +
                "⚠️ Lần cắm Watch kế tiếp, Xcode sẽ phải tải lại support files — có thể mất vài phút.",

            "cache.tvosDeviceSupport": "tvOS Device Support",
            "cache.tvosDeviceSupport.detail":
                "File symbol mà Xcode tải về lần đầu bạn cắm Apple TV để debug — mỗi phiên bản tvOS một thư mục.\n\n" +
                "Dự án Xcode và thiết bị KHÔNG bị đụng.\n\n" +
                "⚠️ Lần cắm Apple TV kế tiếp, Xcode sẽ phải tải lại support files — có thể mất vài phút.",

            "cache.visionosDeviceSupport": "visionOS Device Support",
            "cache.visionosDeviceSupport.detail":
                "File symbol mà Xcode tải về lần đầu bạn cắm Vision Pro để debug — mỗi phiên bản visionOS một thư mục.\n\n" +
                "Dự án Xcode và thiết bị KHÔNG bị đụng.\n\n" +
                "⚠️ Lần cắm Vision Pro kế tiếp, Xcode sẽ phải tải lại support files — có thể mất vài phút.",

            // Sidebar
            "sidebar.scanAgain": "Quét lại",

            // Detail panel
            "detail.totalSize":              "TỔNG KÍCH THƯỚC",
            "detail.description":            "MÔ TẢ",
            "detail.location":               "VỊ TRÍ",
            "detail.riskLevel":              "MỨC ĐỘ RỦI RO",
            "detail.openInFinder":           "Mở trong Finder",
            "detail.clean":                  "Dọn %@",
            "detail.selectItem":             "Chọn một mục để xem chi tiết",
            "detail.relatedProjects":        "DỰ ÁN LIÊN QUAN",
            "detail.relatedProjectsCaption": "Chỉ tính source code · không bao gồm dependencies (node_modules, Pods…)",
            "detail.relatedProjectsHint":    "Tìm trong Desktop, Documents và các thư mục dev thông dụng. macOS có thể hỏi quyền truy cập thư mục lần đầu.",
            "detail.findRelatedProjects":    "Tìm dự án liên quan",
            "detail.searchingProjects":      "Đang tìm dự án...",
            "detail.noProjectsFound":        "Không tìm thấy dự án trong các thư mục thông dụng.",
            "detail.openPrivacySettings":    "Cấp quyền truy cập file trong Privacy & Security",

            // Sub-items
            "subitem.totalSize":     "TỔNG KÍCH THƯỚC",
            "subitem.projects":      "DỰ ÁN LIÊN QUAN",
            "subitem.files":         "TỆP TIN",
            "subitem.devices":       "THIẾT BỊ",
            "subitem.selected":      "ĐÃ CHỌN",
            "subitem.cleanProjects": "Dọn %1 dự án đã chọn · %2",
            "subitem.cleanFiles":    "Dọn %1 tệp đã chọn · %2",
            "subitem.cleanDevices":  "Xóa %1 thiết bị đã chọn · %2",
            "subitem.nSelected":     "%1 / %2 đã chọn",
            "subitem.lastUsed":      "Mở lần cuối",

            // Scan progress
            "scan.itemCount":         "%1 / %2 mục",
            "scan.progressFormat":    "Đang quét %1… %2 / %3",
            "scan.progressCount":     "Đang quét… %1 / %2",
            "scan.moreItemsScanning": "Các mục khác sẽ xuất hiện khi quét xong…",
            "scan.loadingItems":      "Đang tải mục…",
            "scan.loadingItemsHint":  "Đang quét các mục con trong cache này.",

            // Menu bar
            "menubar.cleanSelected": "Dọn dẹp · %@",

            // Settings sheet
            "settings.title":              "Cài đặt",
            "settings.general":            "CHUNG",
            "settings.language":           "Ngôn ngữ",
            "settings.launchAtLogin":      "Khởi động cùng hệ thống",
            "settings.advanced":           "QUÉT NÂNG CAO",
            "settings.advanced.toggle":    "Quét nâng cao",
            "settings.advanced.subtitle":  "Cần cấp quyền Full Disk Access",
            "settings.advanced.grantButton": "Cấp Full Disk Access",
            "settings.advanced.granted":   "Đã cấp Full Disk Access",
            "settings.advanced.manage":    "Quản lý…",
            "settings.about":              "THÔNG TIN",
            "settings.sendFeedback":       "Gửi phản hồi",

            // FDA Guide sheet
            "fda.title":           "Cấp Full Disk Access",
            "fda.titleGranted":    "Full Disk Access",
            "fda.heading":         "Mở khóa 4 cache được bảo vệ",
            "fda.subheading":      "Cấp Full Disk Access để quét cache Safari, Mail, Apple Music và Diagnostic Reports.",
            "fda.step1.title":     "Mở System Settings",
            "fda.step1.desc":      "Bấm nút bên dưới để mở Privacy & Security.",
            "fda.step2.title":     "Tìm Purgify trong danh sách",
            "fda.step2.desc":      "Cuộn đến Full Disk Access, bật toggle Purgify.",
            "fda.step3.title":     "Quay lại Purgify",
            "fda.step3.desc":      "4 cache sẽ xuất hiện ở lần quét tiếp theo.",
            "fda.relaunchHint":    "Nếu các cache không xuất hiện sau khi cấp quyền, hãy thoát và mở lại Purgify.",
            "fda.primaryButton":   "Mở System Settings",
            "fda.secondaryLink":   "Để sau",
            "fda.grantedHeading":      "Đã hoàn tất",
            "fda.grantedSubheading":   "Full Disk Access đã được cấp. Cache Safari, Mail, Apple Music và Diagnostic Reports sẽ xuất hiện ở lần quét tới.",
            "fda.grantedDoneButton":   "Xong",

            // Tên hiển thị cho 4 cache cần FDA (dùng trong Advanced list)
            "cache.safari":            "Safari Cache",
            "cache.mailDownloads":     "Mail Downloads",
            "cache.appleMusic":        "Apple Music Cache",
            "cache.diagnosticReports": "Báo cáo chẩn đoán",

            // Nhóm file người dùng (Advanced — Installers, Archives, Disc images)
            "userfile.installers":         "Bộ cài (.dmg / .pkg)",
            "userfile.installers.detail":
                "Bộ cài app đã tải về Downloads / Desktop / Documents.\n\n" +
                "Sau khi cài xong, file .dmg / .pkg có thể xóa an toàn — cần thì tải lại từ trang chủ.\n\n" +
                "✅ App đã cài vẫn chạy bình thường.\n" +
                "⚠️ Nếu bạn giữ bộ cài để cài lại offline (Sketch, Final Cut, Adobe…), " +
                "kiểm tra danh sách trước khi xóa.",
            "userfile.archives":           "File nén (.zip / .tar / .7z)",
            "userfile.archives.detail":
                "File nén trong Downloads / Desktop / Documents.\n\n" +
                "Có thể là source code, ảnh backup, theme, hoặc payload installer. " +
                "Mở kiểm tra trước khi xóa nếu không chắc nội dung.\n\n" +
                "⚠️ Một số app phát hành dạng .zip — giải nén xong rồi xóa file nén được.",
            "userfile.discImages":         "Disc image (.iso / .img)",
            "userfile.discImages.detail":
                "Disc/disk image trong Downloads / Desktop / Documents.\n\n" +
                "Thường là OS installer (Windows ISO, Linux), VM disk. " +
                "Ít khi dùng lại sau khi cài — file lớn, dọn nhanh ăn dung lượng.\n\n" +
                "⚠️ Giữ lại nếu bạn hay cài lại cùng OS đó.",

            // Xcode Archives
            "xcode.archives":        "Xcode Archives",
            "xcode.archives.detail":
                "Các bản build đã hoàn chỉnh và ký số, được Xcode lưu tại ~/Library/Developer/Xcode/Archives.\n\n" +
                "Mỗi file .xcarchive là artifact build đầy đủ dùng để export .ipa hoặc .app phân phối lên App Store hoặc TestFlight. " +
                "Xcode giữ lại mọi archive từ trước đến nay, và chúng có thể chiếm hàng chục GB theo thời gian.\n\n" +
                "✅ App đang cài trên máy không bị ảnh hưởng — archive chỉ cần khi bạn muốn export lại hoặc ký lại bản build cũ.\n" +
                "⚠️ Sau khi xóa, bạn không thể export lại bản build đó nữa. Muốn có binary cũ thì phải build lại từ source.",
            "subitem.archived":      "Ngày archive",

            // Nhóm VM mobile (iOS Simulators, Android AVDs, system images)
            "vm.iOSSimulators":         "iOS Simulators",
            "vm.iOSSimulators.detail":
                "Các thiết bị iOS Simulator do Xcode tạo ra — mỗi simulator lưu trữ dữ liệu app, cài đặt và app đã cài riêng.\n\n" +
                "Xóa simulator sẽ mất toàn bộ dữ liệu bên trong (app đã cài, dữ liệu người dùng, keychain). " +
                "Bạn có thể tạo lại simulator miễn phí trong Xcode → Window → Devices and Simulators.\n\n" +
                "⚠️ Các simulator cũ (iOS version cũ, ít dùng) hiển thị theo thứ tự mở lần cuối xa nhất — an toàn để xóa nếu bạn không còn test trên iOS version đó nữa.",
            "vm.iOSRuntimes":           "iOS Simulator Runtimes",
            "vm.iOSRuntimes.detail":
                "Các runtime bundle của iOS Simulator đã tải về — mỗi runtime nặng 4–10 GB và cần thiết để chạy simulator cho iOS version đó.\n\n" +
                "Xóa runtime thì simulator của iOS version đó không thể khởi động cho đến khi bạn tải lại từ Xcode.\n\n" +
                "⚠️ Chỉ xóa runtime của iOS version bạn không còn test nữa. Tải lại bất cứ lúc nào từ Xcode → Settings → Platforms.",
            "vm.androidPlatforms":      "Android SDK Platforms",
            "vm.androidPlatforms.detail":
                "Các gói platform Android SDK tại ~/Library/Android/sdk/platforms — mỗi API level có một thư mục riêng (android-35, android-34, …).\n\n" +
                "Mỗi platform cần thiết để build app nhắm đến API level đó. " +
                "Purgify quét các project đang active để xác định API level nào được dùng trong build.gradle.\n\n" +
                "✅ Các platform 'in use' đang được dùng để build project — không xóa.\n" +
                "🗑️ Các platform 'unused' không được dùng bởi project nào trên máy — có thể xóa. " +
                "Tải lại bất cứ lúc nào từ Android Studio → SDK Manager.",
            "vm.androidBuildTools":     "Android Build-tools",
            "vm.androidBuildTools.detail":
                "Các gói build-tools Android SDK tại ~/Library/Android/sdk/build-tools — mỗi version chứa compiler, dexer và công cụ packaging dùng khi build.\n\n" +
                "Purgify quét file build.gradle của các project để xác định version nào được chỉ định qua buildToolsVersion.\n\n" +
                "✅ Versions 'in use' đang được project tham chiếu — giữ ít nhất version mới nhất.\n" +
                "🗑️ Versions cũ 'unused' thường có thể xóa an toàn — Gradle tự fallback sang version gần nhất.",
            "vm.androidNDK":            "Android NDK",
            "vm.androidNDK.detail":
                "Các version Android NDK (Native Development Kit) tại ~/Library/Android/sdk/ndk — mỗi version nặng 2–4 GB, cần thiết cho project có code C/C++ hoặc Rust native.\n\n" +
                "Purgify quét file build.gradle để xác định version nào được pin qua ndkVersion.\n\n" +
                "✅ Versions 'in use' đang được project pin — xóa sẽ làm native build thất bại.\n" +
                "🗑️ Versions 'unused' không được dùng bởi project nào trên máy — an toàn để xóa.",
            "vm.androidAVDs":           "Android Emulators (AVD)",
            "vm.androidAVDs.detail":
                "Các Android Virtual Device (AVD) được quản lý bởi Android Studio — mỗi AVD lưu disk image, dữ liệu app và snapshot riêng.\n\n" +
                "Xóa AVD sẽ mất toàn bộ dữ liệu. Bạn có thể tạo lại trong Android Studio → Device Manager bất cứ lúc nào.\n\n" +
                "⚠️ Các emulator cũ (API level cũ, ít dùng) hiển thị theo thứ tự mở lần cuối xa nhất — an toàn để xóa nếu bạn không còn test trên Android version đó nữa.",
            "vm.androidImages":         "Android System Images",
            "vm.androidImages.detail":
                "Các Android SDK system image đã tải về — mỗi image nặng 1–4 GB và cần thiết để tạo và chạy AVD cho API level và variant đó.\n\n" +
                "Xóa system image thì AVD dùng nó không thể khởi động cho đến khi bạn tải lại từ Android Studio SDK Manager.\n\n" +
                "⚠️ Chỉ xóa image của API level bạn không còn dùng nữa. Tải lại bất cứ lúc nào từ Android Studio → SDK Manager → SDK Images.",

            // Banner nhắc bật Advanced sau khi clean (legacy — modal cleanSuccess thay thế)
            "banner.heading":  "Mở khóa thêm 4 cache",
            "banner.subtext":  "Bật Advanced để quét Safari, Mail, Apple Music và Diagnostic Reports.",
            "banner.button":   "Bật Advanced",

            // Modal hiển thị sau khi dọn xong
            "cleanSuccess.title":           "Đã dọn xong",
            "cleanSuccess.youFreed":        "Đã giải phóng",
            "cleanSuccess.itemsCleaned":    "Đã dọn %1 mục từ %2 danh mục",
            "cleanSuccess.oneItemCleaned":  "Đã dọn 1 mục",
            "cleanSuccess.upsellTitle":     "Mở khóa thêm 4 cache",
            "cleanSuccess.upsellSubtitle":  "Safari, Mail Downloads, Apple Music, Reports",
            "cleanSuccess.enable":          "Bật",
            "cleanSuccess.done":            "Xong",

            // About sheet
            "about.description":  "Dọn dẹp mọi bộ nhớ đệm trên Mac — developer tools, trình duyệt, ứng dụng và hệ thống.",
            "about.madeBy":       "Được làm với ♥ bởi",
            "about.author":       "Pham Linh",
            "about.viewOnGitHub": "Xem trên GitHub",
            "about.copyright":    "© 2025 Purgify. Mã nguồn mở theo giấy phép MIT.",

            // Clean preview sheet
            "cleanPreview.title":           "Xem lại trước khi dọn",
            "cleanPreview.subtitle":        "Các mục này sẽ được chuyển vào Thùng rác. Bạn có thể khôi phục nếu cần.",
            "cleanPreview.total":           "Tổng cộng",
            "cleanPreview.cancel":          "Hủy",
            "cleanPreview.confirm":         "Chuyển %@ vào Thùng rác",
            "cleanPreview.revealInFinder":  "Hiện trong Finder",
        ]
    ]
}
