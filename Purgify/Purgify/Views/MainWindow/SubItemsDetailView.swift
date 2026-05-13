import SwiftUI
import AppKit

/// Detail view for items with sub-items.
/// Adapts labels based on subItemMode: .directories (Xcode) vs .files (Homebrew).
struct SubItemsDetailView: View {
    let item: CacheItem

    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager
    @EnvironmentObject var projectFolderAccess: ProjectFolderAccess

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

    private var isFileMode: Bool { item.subItemMode == .files }
    private var isVMMode: Bool   { item.subItemMode == .vms }

    /// "PROJECTS", "FILES", or "DEVICES"
    private var countLabel: String {
        if isFileMode { return l10n.t("subitem.files") }
        if isVMMode   { return l10n.t("subitem.devices") }
        return l10n.t("subitem.projects")
    }

    /// Clean button text key
    private var cleanButtonKey: String {
        if isFileMode { return "subitem.cleanFiles" }
        if isVMMode   { return "subitem.cleanDevices" }
        return "subitem.cleanProjects"
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

            // Stats row — show "—" placeholders for count/selected while
            // sub-items are still loading so the user doesn't see stale "0".
            HStack(spacing: 0) {
                statCell(value: item.sizeFormatted, label: l10n.t("subitem.totalSize"))
                Divider().frame(height: 34)
                statCell(value: item.isLoadingSubItems ? "—" : "\(subItems.count)", label: countLabel)
                Divider().frame(height: 34)
                statCell(
                    value: item.isLoadingSubItems ? "—" : "\(selectedCount)",
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
                        if item.isProjectFolderGated {
                            // "Select all / 0 of 0" is meaningless when the
                            // category is gated — banner below carries the
                            // user-facing copy.
                            Text(l10n.t("detail.projectScan.bannerTitle"))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                        } else if item.isLoadingSubItems {
                            Text(l10n.t("scan.loadingItems"))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                        } else {
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
                            .disabled(scanner.isCleaning)
                        } else if selectedCount == 0 {
                            Button(l10n.t("risk.selectAll")) {
                                scanner.selectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.brand)
                            .disabled(scanner.isCleaning)
                        } else {
                            Button(l10n.t("risk.selectAll")) {
                                scanner.selectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.secondary)
                            .disabled(scanner.isCleaning)
                            Button(l10n.t("risk.deselectAll")) {
                                scanner.deselectAllSubItems(itemID: item.id)
                            }
                            .font(.system(size: 11))
                            .buttonStyle(.plain)
                            .foregroundColor(.brand)
                            .disabled(scanner.isCleaning)
                        }
                        }
                    }
                }

                Divider()

                // Sub-item rows — or loading state while sub-items are still
                // being scanned in the background. Parent size is already
                // known and shown in the header above; this just waits for the
                // detailed list to populate.
                if item.isProjectFolderGated {
                    projectFolderGatedBanner
                } else if item.isLoadingSubItems {
                    VStack(spacing: 6) {
                        Spacer().frame(height: 8)
                        ProgressView().scaleEffect(0.7)
                        Text(l10n.t("scan.loadingItems"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(l10n.t("scan.loadingItemsHint"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer().frame(height: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                } else {
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
            }
            .padding(12)
            .background(Color.bgCard)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            if item.isProjectFolderGated {
                // No Clean button — there's nothing to clean until the user
                // enables scanning. Show the enable CTA instead.
                Button {
                    projectFolderAccess.isEnabled = true
                } label: {
                    Text(l10n.t("detail.projectScan.enableButton"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.brand)
                        .cornerRadius(9)
                }
                .buttonStyle(.plain)
                .padding(16)
            } else {

            // Clean button
            Button {
                scanner.cleanItem(item.id)
            } label: {
                HStack(spacing: 8) {
                    if scanner.isCleaning {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text(scanner.isCleaning
                        ? l10n.t("app.cleaning")
                        : l10n.t(cleanButtonKey)
                            .replacingOccurrences(of: "%1", with: "\(selectedCount)")
                            .replacingOccurrences(of: "%2", with: ByteFormatter.format(selectedBytes)))
                        .font(.system(size: 14, weight: .semibold))
                }
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
    }

    // MARK: - Helpers

    /// Inline CTA shown when this category needs home-folder access but the
    /// user hasn't opted in yet. Click → flips `ProjectFolderAccess.isEnabled`
    /// → the VM observes the change → re-runs the scan → macOS prompts for
    /// folder access in context.
    private var projectFolderGatedBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.brand)
                Text(l10n.t("detail.projectScan.bannerTitle"))
                    .font(.system(size: 13, weight: .semibold))
            }
            Text(l10n.t("detail.projectScan.bannerBody"))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                projectFolderAccess.isEnabled = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11, weight: .medium))
                    Text(l10n.t("detail.projectScan.enableButton"))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.brand)
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(Color.brand.opacity(0.12))
                .cornerRadius(7)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dateDisplay(for sub: SubItem) -> String {
        guard let key = sub.dateLabelKey else { return sub.relativeTimeString }
        return "\(l10n.t(key)) · \(sub.relativeTimeString)"
    }

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
                    guard !scanner.isCleaning else { return }
                    scanner.toggleSubItem(itemID: item.id, subItemID: sub.id)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(sub.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(sub.isSelected ? .primary : .secondary)
                    .lineLimit(1)
                if let subtitle = sub.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                if !sub.relativeTimeString.isEmpty {
                    Text(dateDisplay(for: sub))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(sub.sizeFormatted)
                .font(.system(size: 13, weight: .medium).monospacedDigit())
                .foregroundColor(sub.isSelected ? (sub.sizeBytes > 1_073_741_824 ? .riskModerate : .primary) : .secondary)

            Button {
                revealInFinder(path: sub.revealPath ?? sub.path)
            } label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(l10n.t("subitem.revealInFinder"))
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !scanner.isCleaning else { return }
            scanner.toggleSubItem(itemID: item.id, subItemID: sub.id)
        }
    }

    private func revealInFinder(path: String) {
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            // Fallback: open parent directory if the path itself was already deleted.
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
    }
}
