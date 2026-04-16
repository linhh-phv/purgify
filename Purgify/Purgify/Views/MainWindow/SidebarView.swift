import SwiftUI

/// Left column (220px): risk category navigation, total cache, scan button, language toggle.
struct SidebarView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header — app icon + title
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.accentColor)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
                Text(l10n.t("app.title"))
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Risk categories
            VStack(spacing: 4) {
                ForEach(RiskLevel.allCases, id: \.self) { risk in
                    let summary = scanner.riskSummary.first { $0.0 == risk }
                    SidebarRiskRow(
                        risk: risk,
                        count: summary?.1 ?? 0,
                        totalBytes: summary?.2 ?? 0,
                        isSelected: scanner.selectedRisk == risk
                    )
                    .onTapGesture {
                        scanner.selectedRisk = risk
                        // Auto-select first item in this category
                        scanner.selectedItemID = scanner.items.first { $0.risk == risk }?.id
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Spacer()

            // Footer
            Divider()

            VStack(spacing: 8) {
                // Total cache
                HStack {
                    Text(l10n.t("app.totalCacheLabel"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(ByteFormatter.format(scanner.totalBytes))
                        .font(.system(size: 12, weight: .semibold))
                }

                HStack(spacing: 8) {
                    // Scan Again button
                    Button {
                        scanner.scan()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11))
                            Text(l10n.t("sidebar.scanAgain"))
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(Color(nsColor: .separatorColor).opacity(0.5))
                        .cornerRadius(7)
                    }
                    .buttonStyle(.plain)
                    .disabled(scanner.isScanning)

                    LanguageToggle()

                    // Settings gear button
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color(nsColor: .separatorColor).opacity(0.5))
                            .cornerRadius(7)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                            .environmentObject(l10n)
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 220)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Sidebar Risk Row

private struct SidebarRiskRow: View {
    let risk: RiskLevel
    let count: Int
    let totalBytes: Int64
    let isSelected: Bool

    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.white : risk.color)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: risk.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isSelected ? risk.color : .white)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(risk.localizedName(l10n))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                if count > 0 {
                    Text("\(ByteFormatter.format(totalBytes)) · \(count) \(l10n.t("app.items"))")
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? risk.color : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
