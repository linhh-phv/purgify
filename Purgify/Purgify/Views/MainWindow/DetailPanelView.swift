import SwiftUI

/// Right column (460px): shows detail of the selected cache item.
struct DetailPanelView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        Group {
            if let item = scanner.selectedItem {
                // Route on subItemMode (declared intent) rather than
                // hasSubItems (subItems != nil), because during the streaming
                // scan a sub-item-bearing parent appears with subItems == nil
                // until the background scan finishes. We still want
                // SubItemsDetailView so it can render its loading state.
                if item.subItemMode != .none {
                    SubItemsDetailView(item: item)
                } else {
                    itemDetail(item)
                }
            } else {
                // Nothing selected
                VStack {
                    Spacer()
                    Text(l10n.t("detail.selectItem"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgDetail)
    }

    // MARK: - Normal item detail

    @ViewBuilder
    private func itemDetail(_ item: CacheItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: name + size + badge
            VStack(alignment: .leading, spacing: 4) {
                Text(l10n.t(item.nameKey))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.sizeFormatted)
                            .font(.system(size: 34, weight: .bold).monospacedDigit())
                            .foregroundColor(item.sizeBytes > 1_073_741_824 ? .riskModerate : .primary)
                        Text(l10n.t("detail.totalSize"))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    riskBadge(item.risk)
                }
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    groupBox(label: l10n.t("detail.description")) {
                        Text(l10n.t(item.detailKey))
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    groupBox(label: l10n.t("detail.location")) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.brand)
                            Text(item.path)
                                .font(.system(size: 13))
                                .foregroundColor(.brand)
                            Spacer()
                            Button {
                                scanner.openInFinder(item.path)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    groupBox(label: l10n.t("detail.riskLevel")) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(item.risk.color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: item.risk.icon)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.risk.localizedName(l10n))
                                    .font(.system(size: 13, weight: .medium))
                                Text(item.risk.localizedDesc(l10n))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if scanner.selectedItemHasProjectIndicators {
                        groupBox(label: l10n.t("detail.relatedProjects")) {
                            relatedProjectsContent
                        }
                    }
                }
                .padding(16)
            }

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
                        : l10n.t("detail.clean").replacingOccurrences(of: "%@", with: l10n.t(item.nameKey)))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.brand)
                .cornerRadius(9)
            }
            .buttonStyle(.plain)
            .disabled(scanner.isCleaning)
            .padding(16)
        }
    }

    // MARK: - Related projects subview

    /// Four states:
    /// 1. Searching → spinner
    /// 2. Searched + has results → list
    /// 3. Searched + empty + access OK → "No projects found"
    /// 4. Searched + empty + no folder access → grant-access link
    /// 5. Not yet searched → opt-in button (default — avoids triggering the
    ///    Documents/Desktop TCC prompt before the user asks for the result).
    @ViewBuilder
    private var relatedProjectsContent: some View {
        if scanner.isLoadingRelatedApps {
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.7)
                Text(l10n.t("detail.searchingProjects"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        } else if scanner.hasSearchedRelatedAppsForSelected {
            if scanner.relatedApps.isEmpty {
                if scanner.hasProjectDirAccess {
                    Text(l10n.t("detail.noProjectsFound"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(l10n.t("detail.noProjectsFound"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Button {
                            NSWorkspace.shared.open(
                                URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders")!
                            )
                        } label: {
                            Text(l10n.t("detail.openPrivacySettings"))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(scanner.relatedApps) { app in
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.brand)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(app.name)
                                    .font(.system(size: 12, weight: .medium))
                                Text(app.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                            Button {
                                scanner.openInFinder(app.path)
                            } label: {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        if app.id != scanner.relatedApps.last?.id {
                            Divider().padding(.leading, 23)
                        }
                    }
                }
            }
        } else {
            // Default: opt-in button. Hint explains the TCC prompt up front
            // so the user knows clicking will ask for folder access.
            VStack(alignment: .leading, spacing: 8) {
                Text(l10n.t("detail.relatedProjectsHint"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    scanner.searchRelatedProjects()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11, weight: .medium))
                        Text(l10n.t("detail.findRelatedProjects"))
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
        }
    }

    // MARK: - Helpers

    private func riskBadge(_ risk: RiskLevel) -> some View {
        Text(risk.localizedName(l10n))
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(badgeTextColor(risk))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeBgColor(risk))
            .cornerRadius(12)
    }

    private func badgeTextColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .safe:     return .riskSafeBadgeText
        case .moderate: return .riskModerate
        case .caution:  return .riskCaution
        }
    }

    private func badgeBgColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .safe:     return .riskSafeBadgeBg
        case .moderate: return Color.riskModerate.opacity(0.15)
        case .caution:  return Color.riskCaution.opacity(0.15)
        }
    }

    private func groupBox<Content: View>(label: String, caption: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                if let caption {
                    Text(caption)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
            }
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgCard)
        .cornerRadius(10)
    }
}
