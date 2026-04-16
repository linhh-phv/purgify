import SwiftUI

/// Right column (460px): shows detail of the selected cache item.
struct DetailPanelView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        Group {
            if let item = scanner.selectedItem {
                if item.hasSubItems {
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
        .background(Color(nsColor: .textBackgroundColor))
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

            // Fixed info sections
            VStack(spacing: 12) {
                groupBox(label: l10n.t("detail.description")) {
                    Text(l10n.t(item.detailKey))
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                }

                groupBox(label: l10n.t("detail.location")) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                        Text(item.path)
                            .font(.system(size: 13))
                            .foregroundColor(.accentColor)
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
            }
            .padding(16)

            // Related Projects — scrollable list, only visible for relevant caches
            if scanner.selectedItemHasProjectIndicators {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t("detail.relatedProjects"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)

                    Divider()

                    if scanner.isLoadingRelatedApps {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.7)
                            Text(l10n.t("detail.searchingProjects"))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else if scanner.relatedApps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(l10n.t("detail.noProjectsFound"))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Button {
                                NSWorkspace.shared.open(
                                    URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders")!
                                )
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.shield")
                                        .font(.system(size: 11))
                                    Text(l10n.t("detail.openPrivacySettings"))
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(scanner.relatedApps) { app in
                                    HStack(spacing: 6) {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.accentColor)
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
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(10)
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 0)

            // Clean button
            Button {
                scanner.cleanItem(item.id)
            } label: {
                Text(l10n.t("detail.clean").replacingOccurrences(of: "%@", with: l10n.t(item.nameKey)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.accentColor)
                    .cornerRadius(9)
            }
            .buttonStyle(.plain)
            .disabled(scanner.isCleaning)
            .padding(16)
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
        case .safe:     return Color(nsColor: .systemGreen)
        case .moderate: return Color(nsColor: .systemOrange)
        case .caution:  return Color(nsColor: .systemRed)
        }
    }

    private func badgeBgColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .safe:     return Color(nsColor: .systemGreen).opacity(0.15)
        case .moderate: return Color(nsColor: .systemOrange).opacity(0.15)
        case .caution:  return Color(nsColor: .systemRed).opacity(0.15)
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
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
