import Combine
import SwiftUI

/// Centralized interaction feedback coordinator
/// Manages haptics, sounds, and animations for user interactions
/// - Thread Safety: Safe for concurrent access as it only coordinates other systems
public final class InteractionFeedbackCenter: ObservableObject {
    /// Shared singleton instance
    public static let shared = InteractionFeedbackCenter()

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
                        animation: InteractionAnimationPreset? = nil,
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
    static let defaultValue: InteractionFeedbackCenter = .shared
}

public extension EnvironmentValues {
    var interactionFeedbackCenter: InteractionFeedbackCenter {
        get { self[FeedbackCenterKey.self] }
        set { self[FeedbackCenterKey.self] = newValue }
    }
}

public extension View {
    func interactionFeedbackCenter(_ center: InteractionFeedbackCenter) -> some View {
        environment(\.interactionFeedbackCenter, center)
    }
}

