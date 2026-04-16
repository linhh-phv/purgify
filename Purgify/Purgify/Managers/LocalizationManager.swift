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
            "cache.npm.detail": "Downloaded package tarballs. Rebuilds automatically on next install.",
            "cache.yarn": "Yarn Cache",
            "cache.yarn.detail": "Yarn v1 offline mirror. Rebuilds on next install.",
            "cache.yarnBerry": "Yarn Berry Cache",
            "cache.yarnBerry.detail": "Yarn v2+ package cache. Rebuilds automatically.",
            "cache.corepack": "Corepack Cache",
            "cache.corepack.detail": "Cached package manager binaries (yarn, pnpm). Re-downloads when needed.",
            "cache.bun": "Bun Cache",
            "cache.bun.detail": "Bun package cache. Rebuilds on next install.",
            "cache.homebrew": "Homebrew Cache",
            "cache.homebrew.detail": "Downloaded brew formula files. Safe to remove.",
            "cache.cocoapods": "CocoaPods Cache",
            "cache.cocoapods.detail": "Cached pod specs and downloads. Rebuilds on next pod install.",
            "cache.xcode": "Xcode DerivedData",
            "cache.xcode.detail": "Build artifacts and indexes. Projects will rebuild on next open — may take a while.",
            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail": "Gradle build cache and downloaded dependencies. Rebuilds on next build.",
            "cache.metro": "Metro Bundler Cache",
            "cache.metro.detail": "React Native Metro bundler cache. Rebuilds on next start.",
            "cache.pnpm": "pnpm Store",
            "cache.pnpm.detail": "Content-addressable store. All pnpm projects need reinstall after cleaning.",
            "cache.docker": "Docker Images",
            "cache.docker.detail": "Docker VM disk images. Use 'docker system prune' instead for safer cleanup.",
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
            "cache.npm.detail": "Gói tải về. Tự tạo lại khi cài đặt.",
            "cache.yarn": "Yarn Cache",
            "cache.yarn.detail": "Bộ nhớ đệm Yarn v1. Tự tạo lại khi cài đặt.",
            "cache.yarnBerry": "Yarn Berry Cache",
            "cache.yarnBerry.detail": "Bộ nhớ đệm Yarn v2+. Tự tạo lại.",
            "cache.corepack": "Corepack Cache",
            "cache.corepack.detail": "Package manager binaries (yarn, pnpm). Tự tải lại khi cần.",
            "cache.bun": "Bun Cache",
            "cache.bun.detail": "Bộ nhớ đệm Bun. Tự tạo lại khi cài đặt.",
            "cache.homebrew": "Homebrew Cache",
            "cache.homebrew.detail": "Tệp formula đã tải. An toàn để xóa.",
            "cache.cocoapods": "CocoaPods Cache",
            "cache.cocoapods.detail": "Pod specs và downloads. Tự tạo lại khi pod install.",
            "cache.xcode": "Xcode DerivedData",
            "cache.xcode.detail": "Dữ liệu build và chỉ mục. Dự án sẽ build lại khi mở — có thể mất thời gian.",
            "cache.gradle": "Gradle Cache",
            "cache.gradle.detail": "Build cache và dependencies. Tự tạo lại khi build.",
            "cache.metro": "Metro Bundler Cache",
            "cache.metro.detail": "Cache Metro của React Native. Tự tạo lại khi chạy.",
            "cache.pnpm": "pnpm Store",
            "cache.pnpm.detail": "Kho lưu trữ pnpm. Tất cả dự án pnpm cần cài lại sau khi xóa.",
            "cache.docker": "Docker Images",
            "cache.docker.detail": "Ảnh đĩa Docker VM. Nên dùng 'docker system prune' để dọn an toàn hơn.",
        ]
    ]
}
