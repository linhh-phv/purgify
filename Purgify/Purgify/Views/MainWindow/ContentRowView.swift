import SwiftUI

/// A single cache item row in the content list.
struct ContentRowView: View {
    @Binding var item: CacheItem
    let isSelected: Bool

    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        HStack(spacing: 10) {
            // Checkbox
            Toggle("", isOn: $item.isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()

            // Colored icon background
            RoundedRectangle(cornerRadius: 7)
                .fill(item.risk.color)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                )

            // Name + path
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.t(item.nameKey))
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(item.path)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Sub-items badge (e.g. "3/5")
            if item.hasSubItems, let subs = item.subItems {
                let selCount = subs.filter(\.isSelected).count
                Text("\(selCount)/\(subs.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.08))
                    .cornerRadius(9)
            }

            // Size
            Text(item.sizeFormatted)
                .font(.system(size: 13, weight: .semibold).monospacedDigit())
                .foregroundColor(item.isSelected ? item.risk.color : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
    }
}
