import SwiftUI

/// Detail view for items with sub-items.
/// Adapts labels based on subItemMode: .directories (Xcode) vs .files (Homebrew).
struct SubItemsDetailView: View {
    let item: CacheItem

    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    private var subItems: [SubItem] {
        item.subItems ?? []
    }

    private var selectedCount: Int {
        subItems.filter(\.isSelected).count
    }

    private var selectedBytes: Int64 {
        subItems.filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes }
    }

    private var allSubItemsSelected: Bool {
        !subItems.isEmpty && subItems.allSatisfy(\.isSelected)
    }

    private var isFileMode: Bool {
        item.subItemMode == .files
    }

    /// "PROJECTS" or "FILES"
    private var countLabel: String {
        l10n.t(isFileMode ? "subitem.files" : "subitem.projects")
    }

    /// Clean button text key
    private var cleanButtonKey: String {
        isFileMode ? "subitem.cleanFiles" : "subitem.cleanProjects"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: name + total size
            VStack(alignment: .leading, spacing: 4) {
                Text(l10n.t(item.nameKey))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(item.sizeFormatted)
                    .font(.system(size: 34, weight: .bold).monospacedDigit())
                    .foregroundColor(item.sizeBytes > 1_073_741_824 ? .riskModerate : .primary)
            }
            .padding(20)

            // Stats row
            HStack(spacing: 0) {
                statCell(value: item.sizeFormatted, label: l10n.t("subitem.totalSize"))
                Divider().frame(height: 34)
                statCell(value: "\(subItems.count)", label: countLabel)
                Divider().frame(height: 34)
                statCell(
                    value: "\(selectedCount)",
                    label: l10n.t("subitem.selected"),
                    accent: true
                )
            }
            .padding(.vertical, 8)
            .background(Color.bgCard)
            .cornerRadius(10)
            .padding(.horizontal, 16)

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text(l10n.t("detail.description"))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Text(l10n.t(item.detailKey))
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bgCard)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Items section
            VStack(alignment: .leading, spacing: 8) {
                // Section header
                VStack(alignment: .leading, spacing: 4) {
                    Text(countLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack {
                        Text(l10n.t("subitem.nSelected")
                            .replacingOccurrences(of: "%1", with: "\(selectedCount)")
                            .replacingOccurrences(of: "%2", with: "\(subItems.count)"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Spacer()
                        if allSubItemsSelected {
                            Button(l10n.t("risk.deselectAll")) {
                                scanner.deselectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.brand)
                        } else if selectedCount == 0 {
                            Button(l10n.t("risk.selectAll")) {
                                scanner.selectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.brand)
                        } else {
                            Button(l10n.t("risk.selectAll")) {
                                scanner.selectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.secondary)
                            Button(l10n.t("risk.deselectAll")) {
                                scanner.deselectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.brand)
                        }
                    }
                }

                Divider()

                // Sub-item rows
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(subItems) { sub in
                            subItemRow(sub)
                            if sub.id != subItems.last?.id {
                                Divider().padding(.leading, 30)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.bgCard)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            // Clean button
            Button {
                scanner.cleanItem(item.id)
            } label: {
                Text(l10n.t(cleanButtonKey)
                    .replacingOccurrences(of: "%1", with: "\(selectedCount)")
                    .replacingOccurrences(of: "%2", with: ByteFormatter.format(selectedBytes)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(selectedCount > 0 ? Color.brand : Color.gray)
                    .cornerRadius(9)
            }
            .buttonStyle(.plain)
            .disabled(scanner.isCleaning || selectedCount == 0)
            .padding(16)
        }
    }

    // MARK: - Helpers

    private func statCell(value: String, label: String, accent: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .semibold).monospacedDigit())
                .foregroundColor(accent ? .brand : .primary)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(accent ? .brand : .secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func subItemRow(_ sub: SubItem) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(sub.isSelected ? Color.brand : Color.divider)
                .frame(width: 14, height: 14)
                .overlay(
                    sub.isSelected ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                        : nil
                )
                .onTapGesture {
                    scanner.toggleSubItem(itemID: item.id, subItemID: sub.id)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(sub.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(sub.isSelected ? .primary : .secondary)
                    .lineLimit(1)
                if !sub.relativeTimeString.isEmpty {
                    Text(sub.relativeTimeString)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(sub.sizeFormatted)
                .font(.system(size: 13, weight: .medium).monospacedDigit())
                .foregroundColor(sub.isSelected ? (sub.sizeBytes > 1_073_741_824 ? .riskModerate : .primary) : .secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            scanner.toggleSubItem(itemID: item.id, subItemID: sub.id)
        }
    }
}
