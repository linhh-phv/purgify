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
            "app.subtitle":       "Clean developer caches and free up disk space",
            "app.totalCache":     "total cache found",
            "app.allClean":       "All clean!",
            "app.allCleanDesc":   "No developer caches found on this system",
            "app.scanning":       "Scanning caches...",
            "app.selected":       "Selected",
            "app.cleanSelected":  "Clean Selected",
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
            "clean.confirm.message": "This action cannot be undone. Caches will be rebuilt automatically when needed.",
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
                "A global download cache built up each time you run bundle install.\n\n" +
                "Your project gems and Gemfile.lock are completely untouched — everything runs normally after cleaning.\n\n" +
                "The only effect: the next bundle install re-downloads gems from RubyGems.org instead of local cache.",

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

            // Sidebar
            "sidebar.scanAgain": "Scan Again",

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
            "detail.searchingProjects":      "Searching for projects...",
            "detail.noProjectsFound":        "No projects found. If you denied file access, tap below to re-enable.",
            "detail.openPrivacySettings":    "Open Privacy & Security",

            // Sub-items
            "subitem.totalSize":      "TOTAL SIZE",
            "subitem.projects":       "RELATED PROJECTS",
            "subitem.files":          "FILES",
            "subitem.selected":       "SELECTED",
            "subitem.cleanProjects":  "Clean %1 Selected Projects · %2",
            "subitem.cleanFiles":     "Clean %1 Selected Files · %2",
            "subitem.nSelected":      "%1 / %2 selected",

            // Scan progress
            "scan.itemCount": "%1 of %2 items",

            // Menu bar
            "menubar.cleanSelected": "Clean Selected · %@",

            // Settings sheet
            "settings.title":         "Settings",
            "settings.general":       "GENERAL",
            "settings.language":      "Language",
            "settings.launchAtLogin": "Launch at Login",
            "settings.about":         "ABOUT",
            "settings.versionShort":  "v1.0.0 · Open Source",
            "settings.githubRepo":    "GitHub Repository",
            "settings.sendFeedback":  "Send Feedback",

            // About sheet
            "about.description":  "Clean developer caches and free up disk space.\nA lightweight macOS menu bar app for developers.",
            "about.madeBy":       "Made with ♥ by",
            "about.author":       "Pham Linh",
            "about.viewOnGitHub": "View on GitHub",
            "about.copyright":    "© 2025 Purgify. Open source under MIT License.",
        ],

        // MARK: Vietnamese

        .vi: [

            // App
            "app.title":          "Purgify",
            "app.subtitle":       "Dọn dẹp bộ nhớ đệm lập trình và giải phóng dung lượng",
            "app.totalCache":     "tổng bộ nhớ đệm",
            "app.allClean":       "Sạch sẽ!",
            "app.allCleanDesc":   "Không tìm thấy bộ nhớ đệm nào trên máy",
            "app.scanning":       "Đang quét...",
            "app.selected":       "Đã chọn",
            "app.cleanSelected":  "Dọn dẹp",
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
            "clean.confirm.message": "Thao tác này không thể hoàn tác. Bộ nhớ đệm sẽ tự tạo lại khi cần.",
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
                "Cache tải gem toàn cục, tích lũy mỗi khi bạn chạy bundle install.\n\n" +
                "Gemfile.lock và các gem trong dự án hoàn toàn không bị ảnh hưởng — mọi thứ vẫn chạy bình thường.\n\n" +
                "Tác động duy nhất: lần bundle install tiếp theo tải lại từ RubyGems.org thay vì cache local.",

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
            "detail.searchingProjects":      "Đang tìm dự án...",
            "detail.noProjectsFound":        "Không tìm thấy dự án. Nếu bạn đã từ chối quyền truy cập file, nhấn bên dưới để bật lại.",
            "detail.openPrivacySettings":    "Mở Privacy & Security",

            // Sub-items
            "subitem.totalSize":     "TỔNG KÍCH THƯỚC",
            "subitem.projects":      "DỰ ÁN LIÊN QUAN",
            "subitem.files":         "TỆP TIN",
            "subitem.selected":      "ĐÃ CHỌN",
            "subitem.cleanProjects": "Dọn %1 dự án đã chọn · %2",
            "subitem.cleanFiles":    "Dọn %1 tệp đã chọn · %2",
            "subitem.nSelected":     "%1 / %2 đã chọn",

            // Scan progress
            "scan.itemCount": "%1 / %2 mục",

            // Menu bar
            "menubar.cleanSelected": "Dọn dẹp · %@",

            // Settings sheet
            "settings.title":         "Cài đặt",
            "settings.general":       "CHUNG",
            "settings.language":      "Ngôn ngữ",
            "settings.launchAtLogin": "Khởi động cùng hệ thống",
            "settings.about":         "THÔNG TIN",
            "settings.versionShort":  "v1.0.0 · Mã nguồn mở",
            "settings.githubRepo":    "GitHub Repository",
            "settings.sendFeedback":  "Gửi phản hồi",

            // About sheet
            "about.description":  "Dọn dẹp bộ nhớ đệm lập trình và giải phóng dung lượng.\nỨng dụng nhẹ trên menu bar macOS dành cho lập trình viên.",
            "about.madeBy":       "Được làm với ♥ bởi",
            "about.author":       "Pham Linh",
            "about.viewOnGitHub": "Xem trên GitHub",
            "about.copyright":    "© 2025 Purgify. Mã nguồn mở theo giấy phép MIT.",
        ]
    ]
}
