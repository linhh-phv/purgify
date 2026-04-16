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
        case .safe:     return .green
        case .moderate: return .orange
        case .caution:  return .red
        }
    }

    func localizedName(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe:     return l10n.t("risk.safe")
        case .moderate: return l10n.t("risk.moderate")
        case .caution:  return l10n.t("risk.caution")
        }
    }

    func localizedDesc(_ l10n: LocalizationManager) -> String {
        switch self {
        case .safe:     return l10n.t("risk.safe.desc")
        case .moderate: return l10n.t("risk.moderate.desc")
        case .caution:  return l10n.t("risk.caution.desc")
        }
    }
}
