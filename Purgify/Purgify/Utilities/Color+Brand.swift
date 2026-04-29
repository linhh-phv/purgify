import SwiftUI
import AppKit

/// Design tokens derived from the Figma file.
///
/// **Approach (option B — Figma-exact light mode):**
/// Light-mode values are hardcoded to the exact hex in Figma so the app matches
/// the design 1:1. Dark-mode variants fall back to macOS semantic colors — they
/// will adapt reasonably but are not pixel-matched (Figma has no dark mode yet).
extension Color {

    // MARK: - Brand

    /// Literal brand accent read from Asset Catalog.
    /// Used instead of `Color.accentColor` — on macOS, `accentColor` is overridden
    /// by the user's system-wide accent setting (System Settings → Appearance).
    static let brand = Color("AccentColor")

    /// Light-blue surface for selected content rows (#ebf5ff in Figma).
    static let brandSurface = Color.dynamic(
        light: NSColor(hex: "#ebf5ff"),
        dark: NSColor(named: "AccentColor")?.withAlphaComponent(0.18) ?? .controlAccentColor.withAlphaComponent(0.18)
    )

    /// Lightened brand tone for subtitles inside selected sidebar rows (#c8dfff in Figma).
    static let brandSubtitle = Color.dynamic(
        light: NSColor(hex: "#c8dfff"),
        dark: NSColor.white.withAlphaComponent(0.7)
    )

    // MARK: - Risk selection surfaces
    //
    // Figma uses risk-themed selection highlights: Safe → brand blue (trust),
    // Moderate → orange, Caution → red. Each risk also has a tinted "surface"
    // (for selected row bg) and "subtitle" (for selected label's sub-line).

    /// Selected content-row bg for Moderate items (#fff4e6 in Figma Xcode frame).
    static let moderateSurface = Color.dynamic(
        light: NSColor(hex: "#fff4e6"),
        dark: NSColor.systemOrange.withAlphaComponent(0.18)
    )

    /// Selected content-row bg for Caution items (inferred: soft red).
    static let cautionSurface = Color.dynamic(
        light: NSColor(hex: "#ffe8e6"),
        dark: NSColor.systemRed.withAlphaComponent(0.18)
    )

    /// Selected sidebar subtitle for Moderate (#ffe0b0 in Figma Xcode frame).
    static let moderateSubtitle = Color.dynamic(
        light: NSColor(hex: "#ffe0b0"),
        dark: NSColor.white.withAlphaComponent(0.7)
    )

    /// Selected sidebar subtitle for Caution (inferred: soft red).
    static let cautionSubtitle = Color.dynamic(
        light: NSColor(hex: "#ffd1ce"),
        dark: NSColor.white.withAlphaComponent(0.7)
    )

    /// Solid white center disc for the scanning progress ring (#ffffff in Figma).
    /// Light: pure white. Dark: faint white overlay so the disc stays visible.
    static let bgScanInner = Color.dynamic(
        light: .white,
        dark: NSColor(white: 1, alpha: 0.08)
    )

    // MARK: - Backgrounds

    /// Title-bar background (#f5f5f5 in Figma). Only used where we draw a custom
    /// bar ourselves — the native `.titleBar` window style manages its own material.
    static let bgTitleBar = Color.dynamic(
        light: NSColor(hex: "#f5f5f5"),
        dark: .windowBackgroundColor
    )

    /// Sidebar / left column background (#f2f2f7 in Figma).
    static let bgSidebar = Color.dynamic(
        light: NSColor(hex: "#f2f2f7"),
        dark: .controlBackgroundColor
    )

    /// Content-list body background (#ffffff in Figma).
    static let bgContent = Color.dynamic(
        light: NSColor(hex: "#ffffff"),
        dark: .textBackgroundColor
    )

    /// Content-list toolbar / detail-panel body (#fafafa in Figma).
    static let bgDetail = Color.dynamic(
        light: NSColor(hex: "#fafafa"),
        dark: .windowBackgroundColor
    )

    /// Group-box / card background inside detail + settings (#f2f2f7 in Figma).
    static let bgCard = Color.dynamic(
        light: NSColor(hex: "#f2f2f7"),
        dark: .controlBackgroundColor
    )

    /// Pill / mini-button background — scan button, lang toggle, settings gear (#e5e5ea in Figma).
    /// Dark mode uses a translucent white overlay for better contrast against the
    /// dark sidebar bg (separatorColor at 0.5 alpha was too faint).
    static let bgPill = Color.dynamic(
        light: NSColor(hex: "#e5e5ea"),
        dark: NSColor(white: 1, alpha: 0.1)
    )

    /// Active pill segment background — language toggle "EN" cell (#ffffff in Figma).
    /// Dark mode uses a translucent white overlay so the active segment stays
    /// visually distinct from the darker pill track behind it.
    static let bgPillActive = Color.dynamic(
        light: NSColor.white,
        dark: NSColor(white: 1, alpha: 0.22)
    )

    // MARK: - Dividers

    /// Window / column divider (#e5e5ea in Figma).
    static let divider = Color.dynamic(
        light: NSColor(hex: "#e5e5ea"),
        dark: .separatorColor
    )

    /// Row separator inside a list (#f0f0f0 in Figma).
    static let rowDivider = Color.dynamic(
        light: NSColor(hex: "#f0f0f0"),
        dark: NSColor.separatorColor.withAlphaComponent(0.5)
    )

    // MARK: - Risk

    static let riskSafe = Color.dynamic(
        light: NSColor(hex: "#34c759"),
        dark: .systemGreen
    )

    static let riskModerate = Color.dynamic(
        light: NSColor(hex: "#ff9500"),
        dark: .systemOrange
    )

    static let riskCaution = Color.dynamic(
        light: NSColor(hex: "#ff3b30"),
        dark: .systemRed
    )

    // MARK: - Risk badge

    /// Soft mint bg for the "Safe to Clean" badge (#d4f5e1 in Figma).
    static let riskSafeBadgeBg = Color.dynamic(
        light: NSColor(hex: "#d4f5e1"),
        dark: NSColor.systemGreen.withAlphaComponent(0.18)
    )

    /// Dark-green text for the "Safe to Clean" badge (#1a7f3c in Figma).
    static let riskSafeBadgeText = Color.dynamic(
        light: NSColor(hex: "#1a7f3c"),
        dark: .systemGreen
    )

    // MARK: - Helpers

    /// Dynamic color that resolves to `light` in Aqua / `dark` in DarkAqua.
    static func dynamic(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }
}

extension NSColor {
    /// `NSColor(hex: "#007aff")` — 6-digit RGB, optional `#` prefix, alpha = 1.
    convenience init(hex: String) {
        let trimmed = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var rgb: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&rgb)
        self.init(
            srgbRed: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
