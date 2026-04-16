import SwiftUI

/// Animation hiển thị trong khi đang scan filesystem.
struct ScanAnimationView: View {
    let progress: Double
    let currentItem: String

    @EnvironmentObject var l10n: LocalizationManager

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
