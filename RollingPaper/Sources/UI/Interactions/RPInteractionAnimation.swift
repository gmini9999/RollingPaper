import SwiftUI

public enum RPInteractionAnimation {
    case tap
    case spring
    case emphasize
    case subtle

    func animation(reduceMotion: Bool) -> Animation {
        switch self {
        case .tap:
            return .rp(.fast, reduceMotion: reduceMotion)
        case .spring:
            return reduceMotion ? .linear(duration: 0.12) : .interpolatingSpring(stiffness: 240, damping: 24)
        case .emphasize:
            return .rp(.standard, reduceMotion: reduceMotion)
        case .subtle:
            return .rp(.instant, reduceMotion: reduceMotion)
        }
    }
}

@discardableResult
public func withInteractionAnimation<T>(_ animation: RPInteractionAnimation,
                                        reduceMotion: Bool,
                                        _ body: () throws -> T) rethrows -> T {
    try withAnimation(animation.animation(reduceMotion: reduceMotion)) {
        try body()
    }
}
