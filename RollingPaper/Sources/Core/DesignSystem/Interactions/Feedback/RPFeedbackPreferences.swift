import SwiftUI

public struct RPFeedbackPreferences: Equatable {
    public var allowHaptics: Bool
    public var allowSound: Bool
    public var allowAnimations: Bool

    public init(allowHaptics: Bool = true,
                allowSound: Bool = true,
                allowAnimations: Bool = true) {
        self.allowHaptics = allowHaptics
        self.allowSound = allowSound
        self.allowAnimations = allowAnimations
    }
}

private struct RPFeedbackPreferencesKey: EnvironmentKey {
    static let defaultValue = RPFeedbackPreferences()
}

public extension EnvironmentValues {
    var feedbackPreferences: RPFeedbackPreferences {
        get { self[RPFeedbackPreferencesKey.self] }
        set { self[RPFeedbackPreferencesKey.self] = newValue }
    }
}

public extension View {
    func feedbackPreferences(_ preferences: RPFeedbackPreferences) -> some View {
        environment(\.feedbackPreferences, preferences)
    }
}
