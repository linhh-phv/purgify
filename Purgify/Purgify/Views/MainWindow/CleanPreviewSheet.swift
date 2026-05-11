import SwiftUI

/// "Review Before Cleaning" sheet — lists every item that will be deleted,
/// with icon, name, and size. User confirms with "Delete" or cancels.
struct CleanPreviewSheet: View {
    let preview: CleanPreview

    @EnvironmentObject var scanner: CacheScannerViewModel
    @EnvironmentObject var l10n: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.riskCaution.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.riskCaution)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.t("cleanPreview.title"))
                        .font(.system(size: 15, weight: .semibold))
                    Text(l10n.t("cleanPreview.subtitle"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(20)

            Divider()

            // Scrollable item list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(preview.rows) { row in
                        rowView(row)
                        if row.id != preview.rows.last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
            .frame(maxHeight: 280)

            Divider()

            // Footer: total + cancel + delete
            HStack(spacing: 12) {
                Text("\(l10n.t("cleanPreview.total")): \(ByteFormatter.format(preview.totalBytes))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    scanner.cancelClean()
                } label: {
                    Text(l10n.t("cleanPreview.cancel"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button {
                    scanner.confirmClean()
                } label: {
                    Text(l10n.t("cleanPreview.confirm")
                        .replacingOccurrences(of: "%@", with: ByteFormatter.format(preview.totalBytes)))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 30)
                        .background(Color.riskCaution)
                        .cornerRadius(7)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 420)
    }

    // MARK: - Row View

    private func rowView(_ row: CleanPreview.Row) -> some View {
        HStack(spacing: 10) {
            // Icon in a rounded rect background
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(row.iconColor.opacity(0.15))
                    .frame(width: 24, height: 24)
                Image(systemName: row.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(row.iconColor)
            }

            Text(l10n.t(row.name))
                .font(.system(size: 13))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Text(ByteFormatter.format(row.sizeBytes))
                .font(.system(size: 13, weight: .medium).monospacedDigit())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
    }
}
