import SwiftUI

public struct RPCardStyleConfiguration {
    public struct Border {
        public let color: Color
        public let lineWidth: CGFloat

        public init(color: Color, lineWidth: CGFloat) {
            self.color = color
            self.lineWidth = lineWidth
        }
    }

    public struct Shadow {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat

        public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }

    public let padding: EdgeInsets
    public let background: Color
    public let cornerRadius: CGFloat
    public let border: Border?
    public let shadow: Shadow?

    public init(padding: EdgeInsets = EdgeInsets(top: .rpSpaceM, leading: .rpSpaceM, bottom: .rpSpaceM, trailing: .rpSpaceM),
                background: Color = .rpSurfaceAlt,
                cornerRadius: CGFloat = 16,
                border: Border? = nil,
                shadow: Shadow? = Shadow(color: Color.rpShadow.opacity(0.15), radius: 12, x: 0, y: 6)) {
        self.padding = padding
        self.background = background
        self.cornerRadius = cornerRadius
        self.border = border
        self.shadow = shadow
    }

    public static let `default` = RPCardStyleConfiguration()
    public static let outline = RPCardStyleConfiguration(shadow: nil)
    public static let elevatedSurface = RPCardStyleConfiguration(
        background: .rpSurface,
        cornerRadius: 20,
        border: Border(color: Color.rpSurfaceAlt.opacity(0.65), lineWidth: 1),
        shadow: nil
    )
}

public struct RPCardStyle: ViewModifier {
    private let configuration: RPCardStyleConfiguration

    public init(configuration: RPCardStyleConfiguration = .default) {
        self.configuration = configuration
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)

        return content
            .padding(configuration.padding)
            .background(configuration.background)
            .clipShape(shape)
            .overlay {
                if let border = configuration.border {
                    shape.stroke(border.color, lineWidth: border.lineWidth)
                }
            }
            .shadow(color: configuration.shadow?.color ?? .clear,
                    radius: configuration.shadow?.radius ?? 0,
                    x: configuration.shadow?.x ?? 0,
                    y: configuration.shadow?.y ?? 0)
    }
}

public extension View {
    func rpCardStyle(configuration: RPCardStyleConfiguration = .default) -> some View {
        modifier(RPCardStyle(configuration: configuration))
    }
}

