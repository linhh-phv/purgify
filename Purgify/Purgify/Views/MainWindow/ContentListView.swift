import SwiftUI

/// Middle column (400px): toolbar + filtered item list.
struct ContentListView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text(scanner.selectedRisk.localizedName(l10n))
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                if allSelectedInCurrentRisk {
                    Button(l10n.t("risk.deselectAll")) {
                        scanner.deselectAllInCurrentRisk()
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                } else {
                    Button(l10n.t("risk.selectAll")) {
                        scanner.selectAllInCurrentRisk()
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color(nsColor: .textBackgroundColor))

            Divider()

            // Item list
            if scanner.filteredItems.isEmpty {
                Spacer()
                Text(l10n.t("app.noCache"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(scanner.filteredItems) { item in
                            ContentRowView(
                                item: binding(for: item),
                                isSelected: scanner.selectedItemID == item.id
                            )
                            .onTapGesture {
                                scanner.selectedItemID = item.id
                            }

                            if item.id != scanner.filteredItems.last?.id {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 400)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var allSelectedInCurrentRisk: Bool {
        let filtered = scanner.filteredItems
        return !filtered.isEmpty && filtered.allSatisfy(\.isSelected)
    }

    private func binding(for item: CacheItem) -> Binding<CacheItem> {
        guard let index = scanner.items.firstIndex(where: { $0.id == item.id }) else {
            return .constant(item)
        }
        return $scanner.items[index]
    }
}
