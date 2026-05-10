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
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                if allSelectedInCurrentRisk {
                    Button(l10n.t("risk.deselectAll")) {
                        scanner.deselectAllInCurrentRisk()
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .foregroundColor(.brand)
                } else {
                    Button(l10n.t("risk.selectAll")) {
                        scanner.selectAllInCurrentRisk()
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .foregroundColor(.brand)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.bgDetail)

            Divider()

            // Progressive scan progress strip — only while scanning and at
            // least one item has streamed in (initial empty state is handled
            // by ScanningView in MainWindowView).
            if scanner.isScanning && scanner.scanItemTotal > 0 {
                progressStrip
                Divider()
            }

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

                        // Hint at bottom of list while still scanning.
                        if scanner.isScanning {
                            HStack(spacing: 6) {
                                ProgressView().scaleEffect(0.5)
                                Text(l10n.t("scan.moreItemsScanning"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
        }
        .frame(width: 400)
        .background(Color.bgContent)
    }

    private var progressStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(progressStatusText)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.divider)
                        .frame(height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.brand)
                        .frame(
                            width: max(0, geo.size.width * scanner.scanProgress),
                            height: 2
                        )
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2),
                                   value: scanner.scanProgress)
                }
            }
            .frame(height: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressStatusText)
    }

    private var progressStatusText: String {
        let current = scanner.currentScanItem.isEmpty ? "" : l10n.t(scanner.currentScanItem)
        let template = l10n.t("scan.progressFormat")
        if current.isEmpty {
            // No current item name yet — fall back to count-only template.
            return l10n.t("scan.progressCount")
                .replacingOccurrences(of: "%1", with: "\(scanner.scanItemIndex)")
                .replacingOccurrences(of: "%2", with: "\(scanner.scanItemTotal)")
        }
        return template
            .replacingOccurrences(of: "%1", with: current)
            .replacingOccurrences(of: "%2", with: "\(scanner.scanItemIndex)")
            .replacingOccurrences(of: "%3", with: "\(scanner.scanItemTotal)")
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
