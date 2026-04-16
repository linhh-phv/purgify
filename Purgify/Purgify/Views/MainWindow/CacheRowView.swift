import SwiftUI

/// Một dòng cache trong danh sách.
/// Nhận Binding<CacheItem> để toggle isSelected trực tiếp trên ViewModel.
struct CacheRowView: View {
    @Binding var item: CacheItem
    let riskColor: Color

    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        HStack(spacing: 14) {
            Toggle("", isOn: $item.isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()

            Image(systemName: item.icon)
                .font(.system(size: 20))
                .foregroundColor(riskColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(l10n.t(item.nameKey))
                    .font(.system(size: 14, weight: .medium))
                Text(l10n.t(item.detailKey))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(item.sizeFormatted)
                .font(.system(size: 15, weight: .bold).monospacedDigit())
                .foregroundColor(item.sizeBytes > 1_073_741_824 ? .orange : .primary)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}
