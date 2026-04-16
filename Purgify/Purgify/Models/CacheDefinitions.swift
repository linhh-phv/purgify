import Foundation
import SwiftUI

/// Danh sách tất cả cache cần scan. Tách ra đây để dễ thêm/sửa mà không
/// cần đụng vào ViewModel hay Service.
enum CacheDefinitions {
    static let all: [CacheDefinition] = [

        // MARK: Safe — xóa thoải mái, tự rebuild khi cần
        CacheDefinition(nameKey: "cache.npm",            detailKey: "cache.npm.detail",            path: "~/.npm",                                   icon: "shippingbox.fill",       iconColor: Color(red: 0.80, green: 0.22, blue: 0.22), risk: .safe, projectIndicators: ["package-lock.json"]),
        CacheDefinition(nameKey: "cache.yarn",           detailKey: "cache.yarn.detail",           path: "~/Library/Caches/Yarn",                    icon: "shippingbox.fill",       iconColor: Color(red: 0.17, green: 0.56, blue: 0.73), risk: .safe, projectIndicators: ["yarn.lock"]),
        CacheDefinition(nameKey: "cache.yarnBerry",      detailKey: "cache.yarnBerry.detail",      path: "~/.yarn/berry/cache",                       icon: "shippingbox.fill",       iconColor: Color(red: 0.17, green: 0.56, blue: 0.73), risk: .safe, projectIndicators: [".yarnrc.yml"]),
        CacheDefinition(nameKey: "cache.corepack",       detailKey: "cache.corepack.detail",       path: "~/.cache/node/corepack",                   icon: "shippingbox.fill",       iconColor: Color(red: 0.26, green: 0.65, blue: 0.28), risk: .safe, projectIndicators: ["package.json"]),
        CacheDefinition(nameKey: "cache.bun",            detailKey: "cache.bun.detail",            path: "~/.bun/install/cache",                     icon: "bolt.fill",              iconColor: Color(red: 0.96, green: 0.56, blue: 0.13), risk: .safe, projectIndicators: ["bun.lockb"]),
        CacheDefinition(nameKey: "cache.homebrew",       detailKey: "cache.homebrew.detail",       path: "~/Library/Caches/Homebrew",                icon: "mug.fill",               iconColor: Color(red: 0.98, green: 0.69, blue: 0.25), risk: .safe, subItemMode: .files, subItemsPath: "~/Library/Caches/Homebrew/downloads"),
        CacheDefinition(nameKey: "cache.cocoapods",      detailKey: "cache.cocoapods.detail",      path: "~/Library/Caches/CocoaPods",               icon: "leaf.fill",              iconColor: Color(red: 0.93, green: 0.20, blue: 0.13), risk: .safe, projectIndicators: ["Podfile"]),
        CacheDefinition(nameKey: "cache.cocoapodsSpecs", detailKey: "cache.cocoapodsSpecs.detail", path: "~/.cocoapods/repos",                       icon: "doc.text.fill",          iconColor: Color(red: 0.93, green: 0.20, blue: 0.13), risk: .safe, projectIndicators: ["Podfile"]),
        CacheDefinition(nameKey: "cache.cargo",          detailKey: "cache.cargo.detail",          path: "~/.cargo/registry",                        icon: "wrench.adjustable.fill", iconColor: Color(red: 0.81, green: 0.26, blue: 0.17), risk: .safe, projectIndicators: ["Cargo.toml"]),
        CacheDefinition(nameKey: "cache.pip",            detailKey: "cache.pip.detail",            path: "~/Library/Caches/pip",                     icon: "terminal.fill",          iconColor: Color(red: 0.22, green: 0.47, blue: 0.67), risk: .safe, projectIndicators: ["requirements.txt", "setup.py", "pyproject.toml"]),
        CacheDefinition(nameKey: "cache.poetry",         detailKey: "cache.poetry.detail",         path: "~/Library/Caches/pypoetry",                icon: "books.vertical.fill",    iconColor: Color(red: 0.07, green: 0.44, blue: 0.78), risk: .safe, projectIndicators: ["pyproject.toml"]),
        CacheDefinition(nameKey: "cache.flutter",        detailKey: "cache.flutter.detail",        path: "~/.pub-cache",                             icon: "wind",                   iconColor: Color(red: 0.33, green: 0.77, blue: 0.97), risk: .safe, projectIndicators: ["pubspec.yaml"]),
        CacheDefinition(nameKey: "cache.composer",       detailKey: "cache.composer.detail",       path: "~/.composer/cache",                        icon: "shippingbox.fill",       iconColor: Color(red: 0.53, green: 0.34, blue: 0.19), risk: .safe, projectIndicators: ["composer.json"]),
        CacheDefinition(nameKey: "cache.bundler",        detailKey: "cache.bundler.detail",        path: "~/.bundle/cache",                          icon: "shippingbox.fill",       iconColor: Color(red: 0.80, green: 0.20, blue: 0.18), risk: .safe, projectIndicators: ["Gemfile"]),
        CacheDefinition(nameKey: "cache.spm",            detailKey: "cache.spm.detail",            path: "~/Library/Caches/org.swift.swiftpm",       icon: "swift",                  iconColor: Color(red: 0.98, green: 0.45, blue: 0.26), risk: .safe, projectIndicators: ["Package.swift"]),
        CacheDefinition(nameKey: "cache.go",             detailKey: "cache.go.detail",             path: "~/go/pkg/mod/cache",                       icon: "shippingbox.fill",       iconColor: Color(red: 0.00, green: 0.68, blue: 0.85), risk: .safe, projectIndicators: ["go.mod"]),
        CacheDefinition(nameKey: "cache.simulator",      detailKey: "cache.simulator.detail",      path: "~/Library/Developer/CoreSimulator/Caches", icon: "apps.iphone",            iconColor: Color(red: 0.00, green: 0.48, blue: 1.00), risk: .safe),
        CacheDefinition(nameKey: "cache.cypress",        detailKey: "cache.cypress.detail",        path: "~/Library/Caches/Cypress",                 icon: "checkmark.seal.fill",    iconColor: Color(red: 0.41, green: 0.83, blue: 0.65), risk: .safe, projectIndicators: ["cypress.config.js", "cypress.config.ts"]),
        CacheDefinition(nameKey: "cache.playwright",     detailKey: "cache.playwright.detail",     path: "~/Library/Caches/ms-playwright",           icon: "theatermasks.fill",      iconColor: Color(red: 0.18, green: 0.68, blue: 0.20), risk: .safe),
        CacheDefinition(nameKey: "cache.terraform",      detailKey: "cache.terraform.detail",      path: "~/.terraform.d/plugin-cache",              icon: "server.rack",            iconColor: Color(red: 0.48, green: 0.26, blue: 0.74), risk: .safe, projectIndicators: ["main.tf", "terraform.tf"]),
        CacheDefinition(nameKey: "cache.android",        detailKey: "cache.android.detail",        path: "~/.android/cache",                         icon: "candybarphone",          iconColor: Color(red: 0.24, green: 0.86, blue: 0.52), risk: .safe),

        // MARK: Moderate — có thể cần rebuild project
        CacheDefinition(nameKey: "cache.xcode",  detailKey: "cache.xcode.detail",  path: "~/Library/Developer/Xcode/DerivedData", icon: "hammer.fill",      iconColor: Color(red: 0.08, green: 0.46, blue: 0.98), risk: .moderate, supportsSubItems: true),
        CacheDefinition(nameKey: "cache.gradle", detailKey: "cache.gradle.detail", path: "~/.gradle/caches",                      icon: "gearshape.fill",   iconColor: Color(red: 0.01, green: 0.55, blue: 0.46), risk: .moderate, projectIndicators: ["build.gradle", "build.gradle.kts"]),
        CacheDefinition(nameKey: "cache.metro",  detailKey: "cache.metro.detail",  path: "~/.metro",                              icon: "tram.fill",        iconColor: Color(red: 0.94, green: 0.31, blue: 0.13), risk: .moderate, projectIndicators: ["package.json"]),
        CacheDefinition(nameKey: "cache.maven",  detailKey: "cache.maven.detail",  path: "~/.m2/repository",                      icon: "archivebox.fill",  iconColor: Color(red: 0.78, green: 0.10, blue: 0.21), risk: .moderate, projectIndicators: ["pom.xml"]),

        // MARK: Caution — nên cân nhắc trước khi xóa
        CacheDefinition(nameKey: "cache.pnpm",   detailKey: "cache.pnpm.detail",   path: "~/Library/pnpm/store",                            icon: "shippingbox.fill", iconColor: Color(red: 0.97, green: 0.57, blue: 0.13), risk: .caution, projectIndicators: ["pnpm-lock.yaml"]),
        CacheDefinition(nameKey: "cache.docker", detailKey: "cache.docker.detail", path: "~/Library/Containers/com.docker.docker/Data/vms", icon: "cube.fill",        iconColor: Color(red: 0.14, green: 0.59, blue: 0.93), risk: .caution),
    ]
}
