import SwiftUI

public enum RPFieldState: Equatable {
    case normal
    case focused
    case success
    case error
    case disabled

    var backgroundColor: Color {
        switch self {
        case .normal:
            return .rpSurface
        case .focused:
            return Color.rpSurfaceAlt.opacity(0.7)
        case .success:
            return Color.rpSurfaceAlt.opacity(0.8)
        case .error:
            return Color.rpSurfaceAlt.opacity(0.9)
        case .disabled:
            return Color.rpSurface.opacity(0.6)
        }
    }

    func borderColor(isFocused: Bool) -> Color {
        switch self {
        case .normal:
            return isFocused ? .rpPrimary : Color.rpSurfaceAlt.opacity(0.8)
        case .focused:
            return .rpPrimary
        case .success:
            return .rpAccent
        case .error:
            return .rpDanger
        case .disabled:
            return Color.rpSurfaceAlt.opacity(0.4)
        }
    }

    var helperColor: Color {
        switch self {
        case .normal, .focused:
            return Color.rpTextPrimary.opacity(0.7)
        case .success:
            return .rpAccent
        case .error:
            return .rpDanger
        case .disabled:
            return Color.rpTextPrimary.opacity(0.4)
        }
    }

    var textColor: Color {
        switch self {
        case .disabled:
            return Color.rpTextPrimary.opacity(0.5)
        default:
            return .rpTextPrimary
        }
    }

    var allowsInteraction: Bool {
        self != .disabled
    }
}
