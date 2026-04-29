import SwiftUI

enum RiskLevel: String, CaseIterable {
    case safe
    case moderate
    case caution

    var icon: String {
        switch self {
        case .safe:     return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .caution:  return "xmark.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .safe:     return .riskSafe
        case .moderate: return .riskModerate
        case .caution:  return .riskCaution
        }
    }

    /// Sidebar-selection bg: Safe uses brand blue (trust), others use risk color.
    /// Matches Figma Main Window Normal (Safe→blue) + Xcode frame (Moderate→orange).
    var selectionColor: Color {
        switch self {
        case .safe:     return .brand
        case .moderate: return .riskModerate
        case .caution:  return .riskCaution
        }
    }

    /// Lightened tint for selected content-row bg.
    var selectionSurface: Color {
        switch self {
        case .safe:     return .brandSurface
        case .moderate: return .moderateSurface
        case .caution:  return .cautionSurface
        }
    }

    /// Subtitle color inside a selected sidebar row (white-with-tint).
    var selectionSubtitle: Color {
        switch self {
        case .safe:     return .brandSubtitle
        case .moderate: return .moderateSubtitle
        case .caution:  return .cautionSubtitle
        }
    }

    @MainActor func localizedName(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe:     return l10n.t("risk.safe")
        case .moderate: return l10n.t("risk.moderate")
        case .caution:  return l10n.t("risk.caution")
        }
    }

    @MainActor func localizedDesc(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe:     return l10n.t("risk.safe.desc")
        case .moderate: return l10n.t("risk.moderate.desc")
        case .caution:  return l10n.t("risk.caution.desc")
        }
    }
}
