import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var scanner = CacheScanner.shared
    @ObservedObject private var l10n = LocalizationManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "trash.slash.fill")
                    .foregroundColor(.accentColor)
                Text(l10n.t("app.title"))
                    .font(.headline)
                Spacer()
                Button(action: {
                    l10n.language = l10n.language == .en ? .vi : .en
                }) {
                    Text(l10n.language == .en ? "VI" : "EN")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)

                Button(action: { scanner.scan() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .disabled(scanner.isScanning)
            }
            .padding()

            Divider()

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

                    ForEach(scanner.itemsByRisk, id: \.0) { risk, items in
                        HStack(spacing: 8) {
                            Image(systemName: risk.icon)
                                .foregroundColor(riskColor(risk))
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

            Divider()

            HStack {
                Button(action: {
                    openWindow(id: "main")
                    NSApplication.shared.activate()
                }) {
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
        .frame(width: 280)
        .onAppear { scanner.scanIfNeeded() }
    }

    func riskColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .safe: return .green
        case .moderate: return .orange
        case .caution: return .red
        }
    }
}
