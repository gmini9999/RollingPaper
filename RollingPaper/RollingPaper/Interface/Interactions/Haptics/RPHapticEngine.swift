import Combine
import UIKit

public protocol RPHapticTriggering {
    func trigger(_ feedback: RPHapticFeedback)
    func prepare()
}

public final class RPHapticEngine: RPHapticTriggering {
    public static let shared = RPHapticEngine()

    public var isEnabled: Bool = true
    public var allowStrongFeedback: Bool = !UIAccessibility.isReduceMotionEnabled

    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private var cancellables = Set<AnyCancellable>()

    private init() {
        observeReduceMotion()
    }

    public func prepare() {
        guard isEnabled else { return }
        impactGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    public func trigger(_ feedback: RPHapticFeedback) {
        guard isEnabled else { return }

        switch feedback {
        case .impact(let style):
            playImpact(style: resolvedImpactStyle(style))
        case .notification(let type):
            guard allowStrongFeedback || !feedback.requiresStrongFeedback else { return }
            notificationGenerator.notificationOccurred(type)
        case .selection:
            selectionGenerator.selectionChanged()
        case .custom(let intensity):
            guard allowStrongFeedback || intensity < 1 else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: max(0, min(1, intensity)))
        }
    }

    private func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private func resolvedImpactStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator.FeedbackStyle {
        guard allowStrongFeedback else {
            switch style {
            case .heavy: return .medium
            default: return style
            }
        }
        return style
    }

    private func observeReduceMotion() {
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .map { _ in UIAccessibility.isReduceMotionEnabled }
            .sink { [weak self] isReduced in
                self?.allowStrongFeedback = !isReduced
            }
            .store(in: &cancellables)
    }
}
