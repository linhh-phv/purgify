import Foundation

/// Danh sách tất cả cache cần scan. Tách ra đây để dễ thêm/sửa mà không
/// cần đụng vào ViewModel hay Service.
enum CacheDefinitions {
    static let all: [CacheDefinition] = [

        // MARK: Safe — xóa thoải mái, tự rebuild khi cần
        CacheDefinition(nameKey: "cache.npm",       detailKey: "cache.npm.detail",       path: "~/.npm",                                    icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["package-lock.json"]),
        CacheDefinition(nameKey: "cache.yarn",      detailKey: "cache.yarn.detail",      path: "~/Library/Caches/Yarn",                     icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["yarn.lock"]),
        CacheDefinition(nameKey: "cache.yarnBerry", detailKey: "cache.yarnBerry.detail", path: "~/.yarn/berry/cache",                        icon: "shippingbox.fill",        risk: .safe, projectIndicators: [".yarnrc.yml"]),
        CacheDefinition(nameKey: "cache.corepack",  detailKey: "cache.corepack.detail",  path: "~/.cache/node/corepack",                    icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["package.json"]),
        CacheDefinition(nameKey: "cache.bun",       detailKey: "cache.bun.detail",       path: "~/.bun/install/cache",                      icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["bun.lockb"]),
        CacheDefinition(nameKey: "cache.homebrew",  detailKey: "cache.homebrew.detail",  path: "~/Library/Caches/Homebrew",                 icon: "mug.fill",                risk: .safe, subItemMode: .files, subItemsPath: "~/Library/Caches/Homebrew/downloads"),
        CacheDefinition(nameKey: "cache.cocoapods", detailKey: "cache.cocoapods.detail", path: "~/Library/Caches/CocoaPods",                icon: "leaf.fill",               risk: .safe, projectIndicators: ["Podfile"]),
        CacheDefinition(nameKey: "cache.cargo",     detailKey: "cache.cargo.detail",     path: "~/.cargo/registry",                         icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["Cargo.toml"]),
        CacheDefinition(nameKey: "cache.pip",       detailKey: "cache.pip.detail",       path: "~/Library/Caches/pip",                      icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["requirements.txt", "setup.py", "pyproject.toml"]),
        CacheDefinition(nameKey: "cache.flutter",   detailKey: "cache.flutter.detail",   path: "~/.pub-cache",                              icon: "shippingbox.fill",        risk: .safe, projectIndicators: ["pubspec.yaml"]),
        CacheDefinition(nameKey: "cache.simulator",  detailKey: "cache.simulator.detail",  path: "~/Library/Developer/CoreSimulator/Caches", icon: "apps.iphone",          risk: .safe),
        CacheDefinition(nameKey: "cache.spm",        detailKey: "cache.spm.detail",        path: "~/Library/Caches/org.swift.swiftpm",       icon: "shippingbox.fill",     risk: .safe, projectIndicators: ["Package.swift"]),
        CacheDefinition(nameKey: "cache.go",         detailKey: "cache.go.detail",         path: "~/go/pkg/mod/cache",                       icon: "shippingbox.fill",     risk: .safe, projectIndicators: ["go.mod"]),
        CacheDefinition(nameKey: "cache.composer",   detailKey: "cache.composer.detail",   path: "~/.composer/cache",                        icon: "shippingbox.fill",     risk: .safe, projectIndicators: ["composer.json"]),
        CacheDefinition(nameKey: "cache.bundler",    detailKey: "cache.bundler.detail",    path: "~/.bundle/cache",                          icon: "shippingbox.fill",     risk: .safe, projectIndicators: ["Gemfile"]),
        CacheDefinition(nameKey: "cache.cypress",    detailKey: "cache.cypress.detail",    path: "~/Library/Caches/Cypress",                 icon: "checkmark.seal.fill",  risk: .safe, projectIndicators: ["cypress.config.js", "cypress.config.ts"]),
        CacheDefinition(nameKey: "cache.playwright",  detailKey: "cache.playwright.detail",  path: "~/Library/Caches/ms-playwright",    icon: "play.circle.fill",     risk: .safe),
        CacheDefinition(nameKey: "cache.poetry",      detailKey: "cache.poetry.detail",      path: "~/Library/Caches/pypoetry",         icon: "shippingbox.fill",     risk: .safe, projectIndicators: ["pyproject.toml"]),
        CacheDefinition(nameKey: "cache.cocoapodsSpecs", detailKey: "cache.cocoapodsSpecs.detail", path: "~/.cocoapods/repos",           icon: "leaf.fill",            risk: .safe, projectIndicators: ["Podfile"]),
        CacheDefinition(nameKey: "cache.terraform",   detailKey: "cache.terraform.detail",   path: "~/.terraform.d/plugin-cache",       icon: "server.rack",          risk: .safe, projectIndicators: ["main.tf", "terraform.tf"]),
        CacheDefinition(nameKey: "cache.android",     detailKey: "cache.android.detail",     path: "~/.android/cache",                  icon: "smartphone",           risk: .safe),

        // MARK: Moderate — có thể cần rebuild project
        CacheDefinition(nameKey: "cache.xcode",   detailKey: "cache.xcode.detail",   path: "~/Library/Developer/Xcode/DerivedData", icon: "hammer.fill",    risk: .moderate, supportsSubItems: true),
        CacheDefinition(nameKey: "cache.gradle",  detailKey: "cache.gradle.detail",  path: "~/.gradle/caches",                      icon: "gearshape.fill", risk: .moderate, projectIndicators: ["build.gradle", "build.gradle.kts"]),
        CacheDefinition(nameKey: "cache.metro",   detailKey: "cache.metro.detail",   path: "~/.metro",                              icon: "tram.fill",      risk: .moderate, projectIndicators: ["package.json"]),
        CacheDefinition(nameKey: "cache.maven",   detailKey: "cache.maven.detail",   path: "~/.m2/repository",                      icon: "archivebox.fill", risk: .moderate, projectIndicators: ["pom.xml"]),

        // MARK: Caution — nên cân nhắc trước khi xóa
        CacheDefinition(nameKey: "cache.pnpm",   detailKey: "cache.pnpm.detail",   path: "~/.local/share/pnpm/store",                       icon: "shippingbox.fill", risk: .caution, projectIndicators: ["pnpm-lock.yaml"]),
        CacheDefinition(nameKey: "cache.docker", detailKey: "cache.docker.detail", path: "~/Library/Containers/com.docker.docker/Data/vms", icon: "cube.fill",        risk: .caution),
    ]
}
