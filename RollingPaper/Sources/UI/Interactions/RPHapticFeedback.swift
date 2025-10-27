import UIKit

public enum RPHapticFeedback: Equatable {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
    case custom(intensity: CGFloat)

    var requiresStrongFeedback: Bool {
        switch self {
        case .impact(let style):
            return style == .heavy
        case .notification(let type):
            return type == .error
        case .custom(let intensity):
            return intensity >= 1
        case .selection:
            return false
        }
    }
}
