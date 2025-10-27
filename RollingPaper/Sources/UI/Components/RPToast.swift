import SwiftUI

public struct RPToast: Identifiable {
    public struct Action {
        public let title: String
        private let handler: () -> Void

        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }

        public func perform() {
            handler()
        }
    }

    public enum Style {
        case neutral
        case success
        case warning
        case critical

        var backgroundColor: Color {
            switch self {
            case .neutral:
                return Color.rpSurface
            case .success:
                return .rpAccent
            case .warning:
                return Color.orange
            case .critical:
                return .rpDanger
            }
        }

        var foregroundColor: Color {
            switch self {
            case .neutral:
                return .rpTextPrimary
            default:
                return .rpTextInverse
            }
        }
    }

    public let id: UUID
    public let title: String?
    public let message: String
    public let style: Style
    public let action: Action?

    public init(id: UUID = UUID(),
                title: String? = nil,
                message: String,
                style: Style = .neutral,
                action: Action? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.style = style
        self.action = action
    }
}
