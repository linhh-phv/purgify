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
        .en: [
            "app.title": "Purgify",
            "app.subtitle": "Clean developer caches and free up disk space",
            "app.totalCache": "total cache found",
            "app.allClean": "All clean!",
            "app.allCleanDesc": "No developer caches found on this system",
            "app.scanning": "Scanning caches...",
            "app.selected": "Selected",
            "app.cleanSelected": "Clean Selected",
            "app.freed": "Freed",
            "app.openFull": "Open Full App",
            "app.quit": "Quit",
            "app.noCache": "No cache found",
            "app.totalCacheLabel": "Total cache",
            "app.items": "items",
            "app.scan": "Scan",

            "risk.safe": "Safe to Clean",
            "risk.safe.desc": "Safe to delete, no impact on projects",
            "risk.moderate": "Moderate",
            "risk.moderate.desc": "May need rebuild next time you open a project",
            "risk.caution": "Caution",
            "risk.caution.desc": "Review before deleting",
            "risk.selectAll": "Select All",
            "risk.deselectAll": "Deselect All",

            "clean.confirm.title": "Clean %@ of cache?",
            "clean.confirm.message": "This action cannot be undone. Caches will be rebuilt automatically when needed.",
            "clean.confirm.clean": "Clean",
            "clean.confirm.cancel": "Cancel",

            "cache.npm": "npm Cache",
            "cache.npm.detail": "Created when you run npm install. Stores downloaded package tarballs so future installs are faster. Deleting is safe — npm will re-download packages as needed. No impact on existing node_modules or running projects.",
            "cache.yarn": "Yarn Cache",
            "cache.yarn.detail": "Created by Yarn v1 when installing packages. Acts as an offline mirror to speed up installs. Deleting is safe — Yarn will re-download on next install. Existing node_modules in your projects are untouched.",
            "cache.yarnBerry": "Yarn Berry Cache",
            "cache.yarnBerry.detail": "Created by Yarn v2+ (Berry) during package installs. Stores compressed package archives. Deleting is safe — Yarn will re-fetch packages when needed. Existing .yarn/cache in projects is separate.",
            "cache.corepack": "Corepack Cache",
            "cache.corepack.detail": "Created by Node.js Corepack to cache package manager binaries (Yarn, pnpm). Deleting is safe — Corepack will re-download the correct version when you run yarn or pnpm. No impact on your projects.",
            "cache.bun": "Bun Cache",
            "cache.bun.detail": "Created by Bun when installing packages. Stores downloaded modules for faster future installs. Deleting is safe — Bun will re-download on next bun install. Existing node_modules in your projects are untouched.",
            "cache.homebrew": "Homebrew Cache",
            "cache.homebrew.detail": "Created when you run brew install or brew upgrade. Stores downloaded formula bottles (.tar.gz). Deleting is safe — Homebrew will re-download when needed. Already-installed apps are not affected.",
            "cache.cocoapods": "CocoaPods Cache",
            "cache.cocoapods.detail": "Created by pod install. Stores downloaded pod specs and source files. Deleting is safe — CocoaPods will re-download on next pod install. Your Pods/ folder in projects is separate.",
            "cache.xcode": "Xcode DerivedData",
            "cache.xcode.detail": "Created by Xcode when building projects. Stores compiled objects, indexes, and logs. Deleting forces a full rebuild next time you open a project, which may take several minutes for large projects. Does NOT delete source code.",
            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail": "Created during Android/Java builds. Stores downloaded dependencies and build outputs. Deleting is safe but the next build will be slower as Gradle re-downloads all dependencies. Your project source code and local build.gradle files are untouched.",
            "cache.metro": "Metro Bundler Cache",
            "cache.metro.detail": "Created by React Native's Metro bundler when running your app. Stores transformed JavaScript bundles. Deleting is safe — Metro will rebuild the bundle on next npx react-native start. Useful when you see stale code.",
            "cache.pnpm": "pnpm Store",
            "cache.pnpm.detail": "Created by pnpm as a global content-addressable store. All pnpm projects share this store via hard links. Deleting BREAKS existing node_modules — ALL pnpm projects will need pnpm install again. Consider carefully if you have many projects.",
            "cache.docker": "Docker Images",
            "cache.docker.detail": "Docker Desktop VM disk images containing all your containers, images, and volumes. Deleting removes ALL Docker data including running containers and databases. Recommended: use 'docker system prune' from Terminal instead for selective cleanup.",

            // Sidebar
            "sidebar.scanAgain": "Scan Again",

            // Detail panel
            "detail.totalSize": "TOTAL SIZE",
            "detail.description": "DESCRIPTION",
            "detail.location": "LOCATION",
            "detail.riskLevel": "RISK LEVEL",
            "detail.openInFinder": "Open in Finder",
            "detail.clean": "Clean %@",
            "detail.selectItem": "Select an item to view details",

            // Sub-items
            "subitem.totalSize": "TOTAL SIZE",
            "subitem.projects": "PROJECTS",
            "subitem.files": "FILES",
            "subitem.selected": "SELECTED",
            "subitem.cleanProjects": "Clean %1 Selected Projects · %2",
            "subitem.cleanFiles": "Clean %1 Selected Files · %2",
            "subitem.nSelected": "%1 / %2 selected",

            // Scan progress
            "scan.itemCount": "%1 of %2 items",

            // Menu bar
            "menubar.cleanSelected": "Clean Selected · %@",
        ],
        .vi: [
            "app.title": "Purgify",
            "app.subtitle": "Dọn dẹp bộ nhớ đệm lập trình và giải phóng dung lượng",
            "app.totalCache": "tổng bộ nhớ đệm",
            "app.allClean": "Sạch sẽ!",
            "app.allCleanDesc": "Không tìm thấy bộ nhớ đệm nào trên máy",
            "app.scanning": "Đang quét...",
            "app.selected": "Đã chọn",
            "app.cleanSelected": "Dọn dẹp",
            "app.freed": "Đã giải phóng",
            "app.openFull": "Mở ứng dụng",
            "app.quit": "Thoát",
            "app.noCache": "Không tìm thấy cache",
            "app.totalCacheLabel": "Tổng cache",
            "app.items": "mục",
            "app.scan": "Quét",

            "risk.safe": "An toàn",
            "risk.safe.desc": "Xóa thoải mái, không ảnh hưởng dự án",
            "risk.moderate": "Trung bình",
            "risk.moderate.desc": "Có thể cần build lại khi mở dự án lần sau",
            "risk.caution": "Cẩn thận",
            "risk.caution.desc": "Nên xem xét trước khi xóa",
            "risk.selectAll": "Chọn tất cả",
            "risk.deselectAll": "Bỏ chọn tất cả",

            "clean.confirm.title": "Dọn %@ bộ nhớ đệm?",
            "clean.confirm.message": "Thao tác này không thể hoàn tác. Bộ nhớ đệm sẽ tự tạo lại khi cần.",
            "clean.confirm.clean": "Dọn dẹp",
            "clean.confirm.cancel": "Hủy",

            "cache.npm": "npm Cache",
            "cache.npm.detail": "Được tạo khi chạy npm install. Lưu các gói đã tải để cài đặt lần sau nhanh hơn. Xóa an toàn — npm sẽ tải lại khi cần. Không ảnh hưởng đến node_modules hay dự án đang chạy.",
            "cache.yarn": "Yarn Cache",
            "cache.yarn.detail": "Được tạo bởi Yarn v1 khi cài đặt gói. Dùng làm bản sao offline để tăng tốc cài đặt. Xóa an toàn — Yarn sẽ tải lại khi cần. node_modules trong dự án không bị ảnh hưởng.",
            "cache.yarnBerry": "Yarn Berry Cache",
            "cache.yarnBerry.detail": "Được tạo bởi Yarn v2+ (Berry) khi cài gói. Lưu trữ gói nén. Xóa an toàn — Yarn sẽ tải lại khi cần. Thư mục .yarn/cache trong dự án là riêng biệt.",
            "cache.corepack": "Corepack Cache",
            "cache.corepack.detail": "Được tạo bởi Node.js Corepack để lưu trữ binaries của Yarn và pnpm. Xóa an toàn — Corepack sẽ tải lại phiên bản đúng khi bạn chạy yarn hoặc pnpm. Dự án hiện có không bị ảnh hưởng.",
            "cache.bun": "Bun Cache",
            "cache.bun.detail": "Được tạo bởi Bun khi cài đặt gói. Lưu module đã tải để cài nhanh hơn. Xóa an toàn — Bun sẽ tải lại khi chạy bun install lần sau. node_modules trong dự án không bị ảnh hưởng.",
            "cache.homebrew": "Homebrew Cache",
            "cache.homebrew.detail": "Được tạo khi chạy brew install hoặc brew upgrade. Lưu các file bottle (.tar.gz). Xóa an toàn — Homebrew sẽ tải lại khi cần. Ứng dụng đã cài không bị ảnh hưởng.",
            "cache.cocoapods": "CocoaPods Cache",
            "cache.cocoapods.detail": "Được tạo khi chạy pod install. Lưu pod specs và source files. Xóa an toàn — CocoaPods sẽ tải lại khi pod install. Thư mục Pods/ trong dự án là riêng biệt.",
            "cache.xcode": "Xcode DerivedData",
            "cache.xcode.detail": "Được Xcode tạo khi build dự án. Lưu file biên dịch, chỉ mục và logs. Xóa sẽ buộc build lại toàn bộ khi mở dự án — có thể mất vài phút với dự án lớn. KHÔNG xóa mã nguồn.",
            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail": "Được tạo khi build Android/Java. Lưu dependencies và kết quả build. Xóa an toàn nhưng lần build tiếp theo sẽ chậm hơn vì Gradle cần tải lại dependencies. Mã nguồn và file build.gradle trong dự án không bị ảnh hưởng.",
            "cache.metro": "Metro Bundler Cache",
            "cache.metro.detail": "Được tạo bởi Metro bundler của React Native khi chạy app. Lưu các bundle JavaScript đã chuyển đổi. Xóa an toàn — Metro sẽ build lại khi chạy lần sau. Mã nguồn dự án không bị ảnh hưởng. Hữu ích khi thấy code cũ.",
            "cache.pnpm": "pnpm Store",
            "cache.pnpm.detail": "Kho lưu trữ chung của pnpm, tất cả dự án chia sẻ qua hard links. Xóa sẽ LÀM HỎNG node_modules của tất cả dự án pnpm — cần chạy pnpm install lại cho từng dự án. Cân nhắc kỹ nếu bạn có nhiều dự án.",
            "cache.docker": "Docker Images",
            "cache.docker.detail": "Ảnh đĩa VM của Docker Desktop chứa tất cả containers, images và volumes. Xóa sẽ mất TOÀN BỘ dữ liệu Docker bao gồm containers đang chạy và databases. Khuyến nghị: dùng 'docker system prune' trong Terminal để dọn chọn lọc hơn.",

            // Sidebar
            "sidebar.scanAgain": "Quét lại",

            // Detail panel
            "detail.totalSize": "TỔNG KÍCH THƯỚC",
            "detail.description": "MÔ TẢ",
            "detail.location": "VỊ TRÍ",
            "detail.riskLevel": "MỨC ĐỘ RỦI RO",
            "detail.openInFinder": "Mở trong Finder",
            "detail.clean": "Dọn %@",
            "detail.selectItem": "Chọn một mục để xem chi tiết",

            // Sub-items (Xcode)
            "subitem.totalSize": "TỔNG KÍCH THƯỚC",
            "subitem.projects": "DỰ ÁN",
            "subitem.files": "TỆP TIN",
            "subitem.selected": "ĐÃ CHỌN",
            "subitem.cleanProjects": "Dọn %1 dự án đã chọn · %2",
            "subitem.cleanFiles": "Dọn %1 tệp đã chọn · %2",
            "subitem.nSelected": "%1 / %2 đã chọn",

            // Scan progress
            "scan.itemCount": "%1 / %2 mục",

            // Menu bar
            "menubar.cleanSelected": "Dọn dẹp · %@",
        ]
    ]
}
