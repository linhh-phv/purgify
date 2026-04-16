import SwiftUI

/// Pill-style EN/VI language toggle, reused in SidebarView and MenuBarView.
struct LanguageToggle: View {
    @EnvironmentObject var l10n: LocalizationManager

    var compact: Bool = false

    private var height: CGFloat { compact ? 24 : 28 }
    private var pillHeight: CGFloat { compact ? 18 : 22 }
    private var fontSize: CGFloat { compact ? 10 : 12 }
    private var cornerRadius: CGFloat { compact ? 6 : 7 }
    private var pillRadius: CGFloat { compact ? 4 : 5 }

    var body: some View {
        HStack(spacing: 0) {
            languageButton(.en)
            languageButton(.vi)
        }
        .frame(height: height)
        .background(Color(nsColor: .separatorColor).opacity(0.5))
        .cornerRadius(cornerRadius)
    }

    private func languageButton(_ lang: AppLanguage) -> some View {
        let isActive = l10n.language == lang
        let label = lang == .en ? "EN" : "VI"
        return Button {
            l10n.language = lang
        } label: {
            Text(label)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(isActive ? .primary : .secondary)
                .frame(height: pillHeight)
                .padding(.horizontal, compact ? 6 : 8)
                .background(isActive ? Color(nsColor: .controlBackgroundColor) : Color.clear)
                .cornerRadius(pillRadius)
        }
        .buttonStyle(.plain)
    }
}
