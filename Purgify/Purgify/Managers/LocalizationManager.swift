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
