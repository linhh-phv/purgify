import SwiftUI

/// Full-window scanning animation with progress circle and bar.
struct ScanningView: View {
    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    @State private var rotation: Double = 0
    @State private var glowPulse: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Glow circle + progress ring
            ZStack {
                // Glow background (#ebf5ff in Figma)
                Circle()
                    .fill(Color.brand.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .scaleEffect(glowPulse)

                // Track ring (#d9eeff in Figma)
                Circle()
                    .fill(Color.brand.opacity(0.15))
                    .frame(width: 130, height: 130)

                // Inner white disc (#ffffff in Figma — gives the donut effect)
                Circle()
                    .fill(Color.bgScanInner)
                    .frame(width: 104, height: 104)

                // Orbiting dot
                Circle()
                    .fill(Color.brand.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(y: -65)
                    .rotationEffect(.degrees(rotation))

                // Center icon — blue magnifying glass on white disc
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.brand)
            }

            // Text
            Text(l10n.t("app.scanning"))
                .font(.system(size: 18, weight: .semibold))

            if !scanner.currentScanItem.isEmpty {
                Text(l10n.t(scanner.currentScanItem))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .transition(.opacity)
                    .id(scanner.currentScanItem)
                    .animation(.easeInOut(duration: 0.3), value: scanner.currentScanItem)
            }

            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.divider)
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.brand)
                            .frame(width: geo.size.width * scanner.scanProgress, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: scanner.scanProgress)
                    }
                }
                .frame(width: 280, height: 4)

                Text(l10n.t("scan.itemCount")
                    .replacingOccurrences(of: "%1", with: "\(scanner.scanItemIndex)")
                    .replacingOccurrences(of: "%2", with: "\(scanner.scanItemTotal)"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgContent)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = 1.08
            }
        }
    }
}
