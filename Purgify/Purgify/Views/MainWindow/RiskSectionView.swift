import SwiftUI

/// Một section nhóm các cache item theo mức độ rủi ro.
/// Dùng @EnvironmentObject để lấy scanner và l10n — không cần truyền qua param.
struct RiskSectionView: View {
    let risk: RiskLevel
    let items: [CacheItem]

    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    private var sectionBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack {
                Image(systemName: risk.icon)
                    .font(.system(size: 18))
                    .foregroundColor(risk.color)
                Text(risk.localizedName(l10n))
                    .font(.system(size: 16, weight: .semibold))
                Text("(\(ByteFormatter.format(sectionBytes)))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                Spacer()
                Button(risk == .safe ? l10n.t("risk.selectAll") : l10n.t("risk.deselectAll")) {
                    if risk == .safe {
                        scanner.selectAll(risk: risk)
                    } else {
                        scanner.deselectAll(risk: risk)
                    }
                }
                .font(.system(size: 12))
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }

            Text(risk.localizedDesc(l10n))
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            // Item rows
            VStack(spacing: 0) {
                ForEach(items) { item in
                    CacheRowView(item: binding(for: item), riskColor: risk.color)
                    if item.id != items.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }

    /// Lấy Binding<CacheItem> từ scanner.items để CacheRowView
    /// có thể toggle isSelected trực tiếp trên ViewModel.
    private func binding(for item: CacheItem) -> Binding<CacheItem> {
        guard let index = scanner.items.firstIndex(where: { $0.id == item.id }) else {
            return .constant(item)
        }
        return $scanner.items[index]
    }
}
