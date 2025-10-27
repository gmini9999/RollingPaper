import SwiftUI

public enum RPMotionToken {
    case instant
    case fast
    case standard
    case relaxed
}

public extension Animation {
    static func rp(_ token: RPMotionToken, reduceMotion: Bool) -> Animation {
        let configuration: (animation: Animation, duration: Double)

        switch token {
        case .instant:
            configuration = (.linear(duration: 0.09), 0.09)
        case .fast:
            configuration = (.timingCurve(0.33, 0, 0.2, 1, duration: 0.15), 0.15)
        case .standard:
            configuration = (.timingCurve(0.33, 0, 0.2, 1, duration: 0.22), 0.22)
        case .relaxed:
            configuration = (.timingCurve(0.33, 0, 0.2, 1, duration: 0.32), 0.32)
        }

        if reduceMotion {
            return .linear(duration: configuration.duration * 0.4)
        }

        return configuration.animation
    }
}

