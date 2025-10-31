import SwiftUI
import UIKit

struct HomePaperCard: View, Sendable {
    let summary: HomePaperSummary

    private enum Layout {
        static let containerCornerRadius: CGFloat = 24
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 20
        static let textSpacing: CGFloat = 6
        static let sectionSpacing: CGFloat = 20
        static let footerSpacing: CGFloat = 16
        static let badgePadding: CGFloat = 14
    }

    private static let updatedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            preview

            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                VStack(alignment: .leading, spacing: Layout.textSpacing) {
                    Text(summary.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(summary.description)
                        .font(.body)
                        .foregroundStyle(.primary.opacity(0.8))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                footer
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: Layout.containerCornerRadius, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Layout.containerCornerRadius, style: .continuous)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 16)
        .contentShape(RoundedRectangle(cornerRadius: Layout.containerCornerRadius, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("탭하여 롤링페이퍼를 엽니다")
    }

    private var preview: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if let assetName = summary.thumbnailAssetName, !assetName.isEmpty {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.18), Color.accentColor.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedCornerShape(radius: Layout.containerCornerRadius, corners: [.topLeft, .topRight]))
            .overlay(
                LinearGradient(
                    colors: [Color.black.opacity(0.08), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedCornerShape(radius: Layout.containerCornerRadius, corners: [.topLeft, .topRight]))
            )

            Image(systemName: summary.status.systemImageName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(statusColor)
                .padding(Layout.badgePadding)
                .accessibilityLabel(summary.status.displayName)
        }
    }

    private var footer: some View {
        HStack(alignment: .center, spacing: Layout.footerSpacing) {
            Label {
                Text("\(summary.participantCount)명 참여")
            } icon: {
                Image(systemName: "person.2.fill")
            }
            .font(.caption)
            .foregroundStyle(.primary.opacity(0.7))

            Label {
                Text("Updated \(Self.updatedDateFormatter.string(from: summary.updatedAt))")
            } icon: {
                Image(systemName: "calendar")
            }
            .font(.caption)
            .foregroundStyle(.primary.opacity(0.7))
        }
    }

    private var statusColor: Color {
        switch summary.status {
        case .inProgress:
            return Color.orange
        case .completed:
            return Color.accentColor
        }
    }

    private var accessibilityDescription: String {
        [
            summary.title,
            summary.description,
            "참여자 \(summary.participantCount)명",
            "Updated \(Self.updatedDateFormatter.string(from: summary.updatedAt))",
            summary.status.displayName
        ].joined(separator: ", ")
    }
}

private struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview("HomePaperCard – Light") {
    HomePaperCard(summary: .preview.first!)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("HomePaperCard – Dark") {
    HomePaperCard(summary: .preview[1])
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(\.colorScheme, .dark)
}
