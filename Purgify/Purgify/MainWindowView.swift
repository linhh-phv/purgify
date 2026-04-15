import SwiftUI

struct MainWindowView: View {
    @ObservedObject private var scanner = CacheScanner.shared
    @ObservedObject private var l10n = LocalizationManager.shared
    @State private var showCleanConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                    // Language toggle
                    Button(action: {
                        l10n.language = l10n.language == .en ? .vi : .en
                    }) {
                        Text(l10n.language == .en ? "VI" : "EN")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    // Rescan
                    Button(action: { scanner.scan() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13))
                            .frame(width: 32, height: 32)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(scanner.isScanning)
                }
            }
            .padding(28)

            Divider()

            // Content
            if scanner.isScanning {
                Spacer()
                ScanAnimationView(
                    progress: scanner.scanProgress,
                    currentItem: scanner.currentScanItem,
                    l10n: l10n
                )
                Spacer()
            } else if scanner.items.isEmpty {
                Spacer()
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
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(scanner.itemsByRisk, id: \.0) { risk, items in
                            RiskSection(risk: risk, items: items, scanner: scanner, l10n: l10n)
                        }
                    }
                    .padding(28)
                }
            }

            Divider()

            // Footer
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

                Button(action: { showCleanConfirm = true }) {
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
                    l10n.t("clean.confirm.title").replacingOccurrences(of: "%@", with: ByteFormatter.format(scanner.selectedBytes)),
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
        .frame(minWidth: 960, minHeight: 700)
        .onAppear { scanner.scanIfNeeded() }
    }
}

// MARK: - Scan Animation

struct ScanAnimationView: View {
    let progress: Double
    let currentItem: String
    let l10n: LocalizationManager

    @State private var rotation: Double = 0
    @State private var outerPulse: CGFloat = 1.0
    @State private var innerPulse: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var activeDot: Int = 0

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(glowOpacity),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(outerPulse)

                // Track ring
                Circle()
                    .stroke(Color.accentColor.opacity(0.12), lineWidth: 5)
                    .frame(width: 110, height: 110)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(0.4),
                                Color.accentColor
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))

                // Spinning orbit dot
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .offset(y: -55)
                    .rotationEffect(.degrees(rotation))

                // Inner circle
                Circle()
                    .fill(Color.accentColor.opacity(0.06))
                    .frame(width: 88, height: 88)
                    .scaleEffect(innerPulse)

                // Icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 10) {
                Text(l10n.t("app.scanning"))
                    .font(.system(size: 16, weight: .medium))

                if !currentItem.isEmpty {
                    Text(l10n.t(currentItem))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id(currentItem)
                        .animation(.easeInOut(duration: 0.3), value: currentItem)
                }

                // Animated dots
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 6)
                            .scaleEffect(activeDot == i ? 1.4 : 0.8)
                            .opacity(activeDot == i ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 0.3), value: activeDot)
                    }
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                outerPulse = 1.1
                glowOpacity = 0.5
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                innerPulse = 1.06
            }
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                DispatchQueue.main.async {
                    activeDot = (activeDot + 1) % 3
                }
            }
        }
    }
}

// MARK: - Risk Section

struct RiskSection: View {
    let risk: RiskLevel
    let items: [CacheItem]
    @ObservedObject var scanner: CacheScanner
    @ObservedObject var l10n: LocalizationManager

    private var riskColor: Color {
        switch risk {
        case .safe: return .green
        case .moderate: return .orange
        case .caution: return .red
        }
    }

    private var sectionBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeBytes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: risk.icon)
                    .font(.system(size: 18))
                    .foregroundColor(riskColor)
                Text(risk.localizedName(l10n))
                    .font(.system(size: 16, weight: .semibold))
                Text("(\(ByteFormatter.format(sectionBytes)))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                Spacer()
                Button(risk == .safe ? l10n.t("risk.selectAll") : l10n.t("risk.deselectAll")) {
                    if risk == .safe {
                        scanner.selectAll(risk: risk)
                    } else {
                        scanner.deselectAll(risk: risk)
                    }
                }
                .font(.system(size: 12))
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }

            Text(risk.localizedDesc(l10n))
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    CacheRowLarge(item: binding(for: item), riskColor: riskColor, l10n: l10n)
                    if item.id != items.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }

    private func binding(for item: CacheItem) -> Binding<CacheItem> {
        guard let index = scanner.items.firstIndex(where: { $0.id == item.id }) else {
            return .constant(item)
        }
        return $scanner.items[index]
    }
}

// MARK: - Cache Row

struct CacheRowLarge: View {
    @Binding var item: CacheItem
    let riskColor: Color
    @ObservedObject var l10n: LocalizationManager

    var body: some View {
        HStack(spacing: 14) {
            Toggle("", isOn: $item.isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()

            Image(systemName: item.icon)
                .font(.system(size: 20))
                .foregroundColor(riskColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(l10n.t(item.nameKey))
                    .font(.system(size: 14, weight: .medium))
                Text(l10n.t(item.detailKey))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(item.sizeFormatted)
                .font(.system(size: 15, weight: .bold).monospacedDigit())
                .foregroundColor(item.sizeBytes > 1_073_741_824 ? .orange : .primary)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}
