import Foundation

/// Danh sách tất cả cache cần scan. Tách ra đây để dễ thêm/sửa mà không
/// cần đụng vào ViewModel hay Service.
enum CacheDefinitions {
    static let all: [CacheDefinition] = [

        // MARK: Safe — xóa thoải mái, tự rebuild khi cần
        CacheDefinition(nameKey: "cache.npm",      detailKey: "cache.npm.detail",      path: "~/.npm",                      icon: "shippingbox.fill", risk: .safe,     projectIndicators: ["package-lock.json"]),
        CacheDefinition(nameKey: "cache.yarn",     detailKey: "cache.yarn.detail",     path: "~/Library/Caches/Yarn",       icon: "shippingbox.fill", risk: .safe,     projectIndicators: ["yarn.lock"]),
        CacheDefinition(nameKey: "cache.yarnBerry",detailKey: "cache.yarnBerry.detail",path: "~/.yarn/berry/cache",         icon: "shippingbox.fill", risk: .safe,     projectIndicators: [".yarnrc.yml"]),
        CacheDefinition(nameKey: "cache.corepack", detailKey: "cache.corepack.detail", path: "~/.cache/node/corepack",      icon: "shippingbox.fill", risk: .safe,     projectIndicators: ["package.json"]),
        CacheDefinition(nameKey: "cache.bun",      detailKey: "cache.bun.detail",      path: "~/.bun/install/cache",        icon: "shippingbox.fill", risk: .safe,     projectIndicators: ["bun.lockb"]),
        CacheDefinition(nameKey: "cache.homebrew", detailKey: "cache.homebrew.detail", path: "~/Library/Caches/Homebrew",   icon: "mug.fill",         risk: .safe,     subItemMode: .files, subItemsPath: "~/Library/Caches/Homebrew/downloads"),
        CacheDefinition(nameKey: "cache.cocoapods",detailKey: "cache.cocoapods.detail",path: "~/Library/Caches/CocoaPods", icon: "leaf.fill",        risk: .safe,     projectIndicators: ["Podfile"]),

        // MARK: Moderate — có thể cần rebuild project
        CacheDefinition(nameKey: "cache.xcode",  detailKey: "cache.xcode.detail",  path: "~/Library/Developer/Xcode/DerivedData", icon: "hammer.fill",    risk: .moderate, supportsSubItems: true),
        CacheDefinition(nameKey: "cache.gradle", detailKey: "cache.gradle.detail", path: "~/.gradle/caches",                      icon: "gearshape.fill", risk: .moderate, projectIndicators: ["build.gradle", "build.gradle.kts"]),
        CacheDefinition(nameKey: "cache.metro",  detailKey: "cache.metro.detail",  path: "~/.metro",                              icon: "tram.fill",      risk: .moderate, projectIndicators: ["package.json"]),

        // MARK: Caution — nên cân nhắc trước khi xóa
        CacheDefinition(nameKey: "cache.pnpm",  detailKey: "cache.pnpm.detail",  path: "~/.local/share/pnpm/store",                       icon: "shippingbox.fill", risk: .caution, projectIndicators: ["pnpm-lock.yaml"]),
        CacheDefinition(nameKey: "cache.docker",detailKey: "cache.docker.detail",path: "~/Library/Containers/com.docker.docker/Data/vms", icon: "cube.fill",        risk: .caution),
    ]
}
