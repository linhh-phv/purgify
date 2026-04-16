import SwiftUI

/// Menu bar popover — bản tóm tắt nhỏ gọn của MainWindowView.
/// Dùng chung ViewModel và LocalizationManager qua @EnvironmentObject.
struct MenuBarView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
            Divider()
            footerView
        }
        .frame(width: 280)
        .onAppear { scanner.scanIfNeeded() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "trash.slash.fill")
                .foregroundColor(.accentColor)
            Text(l10n.t("app.title"))
                .font(.headline)
            Spacer()
            Button {
                l10n.language = l10n.language == .en ? .vi : .en
            } label: {
                Text(l10n.language == .en ? "VI" : "EN")
                    .font(.system(size: 10, weight: .semibold))
            }
            .buttonStyle(.plain)

            Button { scanner.scan() } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .disabled(scanner.isScanning)
        }
        .padding()
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if scanner.isScanning {
            VStack(spacing: 8) {
                ProgressView()
                Text(l10n.t("app.scanning"))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
        } else if scanner.items.isEmpty {
            Text(l10n.t("app.noCache"))
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(24)
        } else {
            VStack(spacing: 0) {
                HStack {
                    Text(l10n.t("app.totalCacheLabel"))
                        .font(.subheadline)
                    Spacer()
                    Text(ByteFormatter.format(scanner.totalBytes))
                        .font(.subheadline.bold().monospacedDigit())
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()

                // Dùng risk.color từ Model — không cần method riskColor() riêng
                ForEach(scanner.itemsByRisk, id: \.0) { risk, items in
                    HStack(spacing: 8) {
                        Image(systemName: risk.icon)
                            .foregroundColor(risk.color)
                            .frame(width: 16)
                        Text(risk.localizedName(l10n))
                            .font(.caption)
                        Spacer()
                        Text("\(items.count) \(l10n.t("app.items"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ByteFormatter.format(items.reduce(0) { $0 + $1.sizeBytes }))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Button {
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
        .padding()
    }
}
