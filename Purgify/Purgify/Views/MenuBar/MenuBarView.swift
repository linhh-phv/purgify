import SwiftUI

/// Menu bar popover — compact summary with clean button.
struct MenuBarView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
            Divider()
            cleanButtonSection
            Divider()
            footerView
        }
        .frame(width: 280)
        .onAppear { scanner.scanIfNeeded() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 8) {
            // App icon
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.accentColor)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )

            Text(l10n.t("app.title"))
                .font(.system(size: 14, weight: .semibold))

            Spacer()

            LanguageToggle(compact: true)

            Button { scanner.scan() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .frame(width: 24, height: 24)
                    .background(Color(nsColor: .separatorColor).opacity(0.5))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .disabled(scanner.isScanning)
        }
        .padding(14)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if scanner.isScanning {
            VStack(spacing: 10) {
                Text(l10n.t("app.scanning"))
                    .font(.system(size: 12, weight: .medium))

                if !scanner.currentScanItem.isEmpty {
                    Text(l10n.t(scanner.currentScanItem))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .id(scanner.currentScanItem)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(nsColor: .separatorColor))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: geo.size.width * scanner.scanProgress, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: scanner.scanProgress)
                    }
                }
                .frame(height: 4)

                Text(l10n.t("scan.itemCount")
                    .replacingOccurrences(of: "%1", with: "\(scanner.scanItemIndex)")
                    .replacingOccurrences(of: "%2", with: "\(scanner.scanItemTotal)"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 14)
            .padding(.vertical, 20)
        } else if scanner.items.isEmpty {
            Text(l10n.t("app.noCache"))
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(24)
        } else {
            VStack(spacing: 0) {
                // Total cache row
                HStack {
                    Text(l10n.t("app.totalCacheLabel"))
                        .font(.system(size: 13))
                    Spacer()
                    Text(ByteFormatter.format(scanner.totalBytes))
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Divider()

                // Risk summary rows
                ForEach(scanner.itemsByRisk, id: \.0) { risk, items in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(risk.color)
                            .frame(width: 12, height: 12)
                        Text(risk.localizedName(l10n))
                            .font(.system(size: 12))
                        Spacer()
                        Text("\(items.count) \(l10n.t("app.items"))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(ByteFormatter.format(items.reduce(0) { $0 + $1.sizeBytes }))
                            .font(.system(size: 12, weight: .medium).monospacedDigit())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - Clean Button

    @ViewBuilder
    private var cleanButtonSection: some View {
        if scanner.selectedBytes > 0 {
            Button {
                scanner.clean()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                    Text(l10n.t("menubar.cleanSelected")
                        .replacingOccurrences(of: "%@", with: ByteFormatter.format(scanner.selectedBytes)))
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(scanner.isCleaning)
            .padding(14)

            Divider()
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Button {
                dismiss()
                openWindow(id: "main")
                NSApplication.shared.activate()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                    Text(l10n.t("app.openFull"))
                }
                .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)

            Spacer()

            Button(l10n.t("app.quit")) {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding(14)
    }
}
