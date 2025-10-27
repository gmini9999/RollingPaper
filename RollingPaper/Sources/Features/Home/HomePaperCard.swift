import SwiftUI
import UIKit

struct HomePaperCard: View, Sendable {
    let summary: HomePaperSummary

    private static let updatedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            preview

            VStack(alignment: .leading, spacing: .rpSpaceL) {
                VStack(alignment: .leading, spacing: .rpSpaceXS) {
                    Text(summary.title)
                        .font(.rpHeadingM)
                        .foregroundStyle(Color.rpTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(summary.description)
                        .font(.rpBodyM)
                        .foregroundStyle(Color.rpTextPrimary.opacity(0.8))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                footer
            }
            .padding(.horizontal, .rpSpaceL)
            .padding(.vertical, .rpSpaceL)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.rpSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.rpSurfaceAlt.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: Color.rpShadow.opacity(0.08), radius: 24, x: 0, y: 16)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
                        colors: [Color.rpPrimary.opacity(0.18), Color.rpPrimary.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedCornerShape(radius: 24, corners: [.topLeft, .topRight]))
            .overlay(
                LinearGradient(
                    colors: [Color.black.opacity(0.08), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedCornerShape(radius: 24, corners: [.topLeft, .topRight]))
            )

            Image(systemName: summary.status.systemImageName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(statusColor)
                .padding(.rpSpaceM)
                .accessibilityLabel(summary.status.displayName)
        }
    }

    private var footer: some View {
        HStack(alignment: .center, spacing: .rpSpaceM) {
            Label {
                Text("\(summary.participantCount)명 참여")
            } icon: {
                Image(systemName: "person.2.fill")
            }
            .font(.rpCaption)
            .foregroundStyle(Color.rpTextPrimary.opacity(0.7))

            Label {
                Text("Updated \(Self.updatedDateFormatter.string(from: summary.updatedAt))")
            } icon: {
                Image(systemName: "calendar")
            }
            .font(.rpCaption)
            .foregroundStyle(Color.rpTextPrimary.opacity(0.7))
        }
    }

    private var statusColor: Color {
        switch summary.status {
        case .inProgress:
            return Color.orange
        case .completed:
            return Color.rpPrimary
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
        .background(Color.rpSurfaceAlt)
}

#Preview("HomePaperCard – Dark") {
    HomePaperCard(summary: .preview[1])
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
}
