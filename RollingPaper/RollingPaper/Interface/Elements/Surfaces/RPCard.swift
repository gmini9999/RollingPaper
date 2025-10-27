import SwiftUI

public struct RPCard<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat

    public init(spacing: CGFloat = .rpSpaceM,
                @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .rpCardStyle()
    }
}
