import SwiftUI

public struct RPListRow<Leading: View, Content: View, Trailing: View>: View {
    private let leading: Leading
    private let content: Content
    private let trailing: Trailing
    private let isInteractive: Bool

    public init(isInteractive: Bool = true,
                @ViewBuilder leading: () -> Leading = { EmptyView() },
                @ViewBuilder content: () -> Content,
                @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.leading = leading()
        self.content = content()
        self.trailing = trailing()
        self.isInteractive = isInteractive
    }

    public var body: some View {
        HStack(spacing: .rpSpaceM) {
            leadingView
            content
                .font(.rpBodyM)
                .foregroundColor(.rpTextPrimary)
            Spacer(minLength: .rpSpaceS)
            trailingView
        }
        .padding(.horizontal, .rpSpaceM)
        .padding(.vertical, .rpSpaceS)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.rpSurfaceAlt.opacity(0.7), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .accessibilityAddTraits(isInteractive ? .isButton : .isStaticText)
    }

    @ViewBuilder
    private var leadingView: some View {
        if Leading.self != EmptyView.self {
            leading
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        if Trailing.self != EmptyView.self {
            trailing
        }
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.rpSurface)
            .shadow(color: Color.rpShadow.opacity(0.08), radius: 4, y: 2)
    }
}
