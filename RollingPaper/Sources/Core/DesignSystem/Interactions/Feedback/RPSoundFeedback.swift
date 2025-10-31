import AudioToolbox
import AVFoundation

public enum RPSoundFeedback: Equatable {
    case success
    case warning
    case error
    case custom(id: SystemSoundID)

    var systemSoundID: SystemSoundID {
        switch self {
        case .success:
            return 1108
        case .warning:
            return 1110
        case .error:
            return 1102
        case .custom(let id):
            return id
        }
    }
}

public struct RPSoundConfiguration {
    public var isEnabled: Bool
    public var useHapticCoupling: Bool
    public var volume: Float

    public init(isEnabled: Bool = true,
                useHapticCoupling: Bool = true,
                volume: Float = 1.0) {
        self.isEnabled = isEnabled
        self.useHapticCoupling = useHapticCoupling
        self.volume = volume
    }
}
