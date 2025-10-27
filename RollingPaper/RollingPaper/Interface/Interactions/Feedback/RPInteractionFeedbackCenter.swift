import Combine
import SwiftUI

public final class RPInteractionFeedbackCenter: ObservableObject {
    public static let shared = RPInteractionFeedbackCenter()

    public var hapticEngine: RPHapticTriggering
    public var soundPlayer: RPSoundPlayer

    @Published public var preferences: RPFeedbackPreferences

    private init(hapticEngine: RPHapticTriggering = RPHapticEngine.shared,
                 soundPlayer: RPSoundPlayer = .shared,
                 preferences: RPFeedbackPreferences = .init()) {
        self.hapticEngine = hapticEngine
        self.soundPlayer = soundPlayer
        self.preferences = preferences
    }

    public func trigger(haptic: RPHapticFeedback? = nil,
                        sound: RPSoundFeedback? = nil,
                        animation: RPInteractionAnimation? = nil,
                        reduceMotion: Bool) {
        if preferences.allowHaptics, let haptic {
            hapticEngine.trigger(haptic)
        }

        if preferences.allowSound, let sound {
            soundPlayer.play(sound)
        }

        if preferences.allowAnimations, let animation {
            withInteractionAnimation(animation, reduceMotion: reduceMotion, {})
        }
    }
}

private struct FeedbackCenterKey: EnvironmentKey {
    static let defaultValue: RPInteractionFeedbackCenter = .shared
}

public extension EnvironmentValues {
    var interactionFeedbackCenter: RPInteractionFeedbackCenter {
        get { self[FeedbackCenterKey.self] }
        set { self[FeedbackCenterKey.self] = newValue }
    }
}

public extension View {
    func interactionFeedbackCenter(_ center: RPInteractionFeedbackCenter) -> some View {
        environment(\.interactionFeedbackCenter, center)
    }
}
