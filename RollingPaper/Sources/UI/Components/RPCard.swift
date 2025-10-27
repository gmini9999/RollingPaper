import SwiftUI

public struct RPCard<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat
    private let configuration: RPCardStyleConfiguration

    public init(spacing: CGFloat = .rpSpaceM,
                configuration: RPCardStyleConfiguration = .default,
                @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.configuration = configuration
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .rpCardStyle(configuration: configuration)
    }
}
