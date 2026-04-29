import SwiftUI

/// A single cache item row in the content list.
struct ContentRowView: View {
    @Binding var item: CacheItem
    let isSelected: Bool

    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        HStack(spacing: 10) {
            // Checkbox — custom draw to enforce brand blue.
            // SwiftUI's native `.checkbox` toggle style uses the system accent,
            // which on macOS is overridden by the user's System Settings accent
            // (green in our case) and ignores the app's Asset Catalog AccentColor.
            RoundedRectangle(cornerRadius: 4)
                .fill(item.isSelected ? Color.brand : Color.divider)
                .frame(width: 16, height: 16)
                .overlay(
                    item.isSelected ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                        : nil
                )
                .onTapGesture { item.isSelected.toggle() }

            // Brand-colored icon
            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(item.iconColor)
                .frame(width: 28, height: 28)

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
                    .foregroundColor(.brand)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.brandSurface)
                    .cornerRadius(9)
            }

            // Size — orange always for >1 GB, else primary/secondary by selection
            Text(item.sizeFormatted)
                .font(.system(size: 13, weight: .semibold).monospacedDigit())
                .foregroundColor(
                    item.sizeBytes > 1_073_741_824 ? .riskModerate
                        : item.isSelected ? .primary
                        : .secondary
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(isSelected ? item.risk.selectionSurface : Color.clear)
        .contentShape(Rectangle())
    }
}
