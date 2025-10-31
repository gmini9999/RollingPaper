import SwiftUI
import UIKit

struct ShareView: View {
    let paperID: UUID
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isCopied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .rpSpaceXXXL - 4) {
                header
                linkCard
                tipsSection
            }
            .padding(.horizontal, .rpSpaceXXL)
            .padding(.vertical, .rpSpaceXXXL - 4)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("공유")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .overlay(alignment: .bottomTrailing) {
            if isCopied {
                Label("링크를 복사했어요", systemImage: "checkmark.circle.fill")
                    .font(Typography.caption)
                    .padding(.horizontal, .rpSpaceL)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: .rpCornerM + 6, style: .continuous)
                            .fill(.regularMaterial)
                    )
                    .shadow(color: ShadowTokens.medium.color, radius: ShadowTokens.medium.radius, y: ShadowTokens.medium.y)
                    .padding(.rpSpaceXXL)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            Text("함께 볼 수 있도록 공유하세요")
                .font(Typography.title3)

            Text("링크를 복사하거나 공유하여 팀원과 친구들이 이 롤링페이퍼에 바로 참여할 수 있게 하세요.")
                .font(Typography.body)
                .foregroundStyle(.secondary)
        }
    }

    private var linkCard: some View {
        VStack(alignment: .leading, spacing: .rpSpaceXL) {
            VStack(alignment: .leading, spacing: 4) {
                Text("공유 링크")
                    .font(Typography.headline)
                Text(shareURL.absoluteString)
                    .font(Typography.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)
            }

            HStack(spacing: .rpSpaceL) {
                Button(action: copyLink) {
                    Text("링크 복사")
                        .font(Typography.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                ShareLink(item: shareURL) {
                    Label("공유 시트", systemImage: "square.and.arrow.up")
                        .font(Typography.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Divider()

            HStack(spacing: .rpSpaceXXL) {
                detailCapsule(title: "초대 코드", value: shortCode)
                detailCapsule(title: "링크 만료", value: "없음")
            }
        }
        .padding(.rpSpaceXXL)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerXL, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: ShadowTokens.large.color, radius: ShadowTokens.large.radius, y: ShadowTokens.large.y)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            Text("공유 팁")
                .font(Typography.headline)
            Text("앱 내의 참여 코드를 안내하거나, 메시지/메일에 링크를 붙여넣어 간편하게 초대할 수 있어요.")
                .font(Typography.body)
                .foregroundStyle(.secondary)
        }
        .padding(.rpSpaceXXL)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerXL, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: ShadowTokens.medium.color, radius: ShadowTokens.medium.radius, y: ShadowTokens.medium.y)
    }

    private var shareURL: URL {
        URL(string: "https://rollingpaper.app/p/\(paperID.uuidString)")!
    }

    private var shortCode: String {
        String(paperID.uuidString.prefix(8)).uppercased()
    }

    private func copyLink() {
        UIPasteboard.general.string = shareURL.absoluteString
        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)

        withAnimation(.easeInOut(duration: 0.25)) {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 0.25)) {
                isCopied = false
            }
        }
    }

    private func detailCapsule(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(Typography.body.weight(.semibold))
        }
        .padding(.horizontal, .rpSpaceL)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerL, style: .continuous)
                .fill(Color.secondary.opacity(OpacityTokens.light - 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: .rpCornerL, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        )
    }
}

#Preview("Share – Compact") {
    ShareView(paperID: UUID())
}

#Preview("Share – Expanded") {
    ShareView(paperID: UUID())
}
