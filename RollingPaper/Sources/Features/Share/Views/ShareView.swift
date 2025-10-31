import SwiftUI
import UIKit

struct ShareView: View {
    let paperID: UUID
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isCopied = false

    private enum Layout {
        static let sectionSpacing: CGFloat = 28
        static let contentPadding: CGFloat = 24
        static let cardCornerRadius: CGFloat = 24
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                header
                linkCard
                tipsSection
            }
            .padding(.horizontal, Layout.contentPadding)
            .padding(.vertical, Layout.sectionSpacing)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("공유")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .overlay(alignment: .bottomTrailing) {
            if isCopied {
                Label("링크를 복사했어요", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.regularMaterial)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 12, y: 6)
                    .padding(Layout.contentPadding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("함께 볼 수 있도록 공유하세요")
                .font(.title3.weight(.semibold))

            Text("링크를 복사하거나 공유하여 팀원과 친구들이 이 롤링페이퍼에 바로 참여할 수 있게 하세요.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var linkCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("공유 링크")
                    .font(.headline)
                Text(shareURL.absoluteString)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                Button(action: copyLink) {
                    Text("링크 복사")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                ShareLink(item: shareURL) {
                    Label("공유 시트", systemImage: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Divider()

            HStack(spacing: 24) {
                detailCapsule(title: "초대 코드", value: shortCode)
                detailCapsule(title: "링크 만료", value: "없음")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 20, y: 10)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("공유 팁")
                .font(.headline)
            Text("앱 내의 참여 코드를 안내하거나, 메시지/메일에 링크를 붙여넣어 간편하게 초대할 수 있어요.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, y: 8)
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
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.secondary.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
