import SwiftUI

public struct RPBadge: View {
    public enum Style {
        case neutral
        case info
        case success
        case warning
        case critical

        var foregroundColor: Color {
            switch self {
            case .neutral:
                return .rpTextPrimary
            case .info, .success, .warning, .critical:
                return .rpTextInverse
            }
        }

        var backgroundColor: Color {
            switch self {
            case .neutral:
                return Color.rpSurfaceAlt
            case .info:
                return .rpPrimary
            case .success:
                return .rpAccent
            case .warning:
                return Color.orange
            case .critical:
                return .rpDanger
            }
        }
    }

    private let text: String
    private let style: Style

    public init(_ text: String, style: Style = .neutral) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(.rpBodyM)
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, .rpSpaceS)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(style.backgroundColor.opacity(0.9))
            )
            .accessibilityLabel("배지: \(text)")
    }
}
