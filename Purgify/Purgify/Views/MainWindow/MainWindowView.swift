import SwiftUI

/// Cửa sổ chính của app.
///
/// **MVVM role — View:**
/// - Chỉ render UI dựa trên state từ ViewModel
/// - Gọi action trên ViewModel khi user tương tác
/// - KHÔNG chứa business logic hay filesystem calls
struct MainWindowView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    @State private var showCleanConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
            Divider()
            footerView
        }
        .frame(minWidth: 960, minHeight: 700)
        .onAppear { scanner.scanIfNeeded() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(l10n.t("app.title"))
                    .font(.system(size: 28, weight: .bold))
                Text(l10n.t("app.subtitle"))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !scanner.items.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(ByteFormatter.format(scanner.totalBytes))
                        .font(.system(size: 24, weight: .bold).monospacedDigit())
                    Text(l10n.t("app.totalCache"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 8) {
                // Language toggle — gọi action trên l10n (cũng là ObservableObject)
                Button {
                    l10n.language = l10n.language == .en ? .vi : .en
                } label: {
                    Text(l10n.language == .en ? "VI" : "EN")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5))
                }
                .buttonStyle(.plain)

                // Rescan — gọi action trên ViewModel
                Button { scanner.scan() } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13))
                        .frame(width: 32, height: 32)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .disabled(scanner.isScanning)
            }
        }
        .padding(28)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if scanner.isScanning {
            Spacer()
            ScanAnimationView(
                progress: scanner.scanProgress,
                currentItem: scanner.currentScanItem
            )
            Spacer()
        } else if scanner.items.isEmpty {
            Spacer()
            emptyStateView
            Spacer()
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(scanner.itemsByRisk, id: \.0) { risk, items in
                        RiskSectionView(risk: risk, items: items)
                    }
                }
                .padding(28)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 56))
                .foregroundColor(.green)
            Text(l10n.t("app.allClean"))
                .font(.system(size: 20, weight: .semibold))
            Text(l10n.t("app.allCleanDesc"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 16) {
            if scanner.lastCleanedBytes > 0 {
                Label(
                    "\(l10n.t("app.freed")) \(ByteFormatter.format(scanner.lastCleanedBytes))",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.system(size: 14))
                .foregroundColor(.green)
            }

            Spacer()

            if scanner.selectedBytes > 0 {
                Text("\(l10n.t("app.selected")): \(ByteFormatter.format(scanner.selectedBytes))")
                    .font(.system(size: 14).monospacedDigit())
                    .foregroundColor(.secondary)
            }

            // Clean button — gọi action trên ViewModel
            Button { showCleanConfirm = true } label: {
                if scanner.isCleaning {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 100)
                } else {
                    Label(l10n.t("app.cleanSelected"), systemImage: "trash")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(scanner.isCleaning || scanner.selectedBytes == 0)
            .confirmationDialog(
                l10n.t("clean.confirm.title")
                    .replacingOccurrences(of: "%@", with: ByteFormatter.format(scanner.selectedBytes)),
                isPresented: $showCleanConfirm,
                titleVisibility: .visible
            ) {
                Button(l10n.t("clean.confirm.clean"), role: .destructive) {
                    scanner.clean()
                }
                Button(l10n.t("clean.confirm.cancel"), role: .cancel) {}
            } message: {
                Text(l10n.t("clean.confirm.message"))
            }
        }
        .padding(28)
    }
}
