import SwiftUI

public enum InteractionAnimationPreset {
    case tap
    case spring
    case emphasize
    case subtle

    fileprivate func animation(reduceMotion: Bool) -> Animation {
        switch self {
        case .tap:
            return reduceMotion ? .linear(duration: 0.1) : .easeOut(duration: 0.15)
        case .spring:
            return reduceMotion ? .linear(duration: 0.18) : .interpolatingSpring(stiffness: 240, damping: 22)
        case .emphasize:
            return reduceMotion ? .linear(duration: 0.2) : .easeInOut(duration: 0.25)
        case .subtle:
            return reduceMotion ? .linear(duration: 0.12) : .easeOut(duration: 0.18)
        }
    }
}

@discardableResult
public func withInteractionAnimation<T>(_ preset: InteractionAnimationPreset,
                                        reduceMotion: Bool,
                                        _ body: () throws -> T) rethrows -> T {
    try withAnimation(preset.animation(reduceMotion: reduceMotion)) {
        try body()
    }
}
