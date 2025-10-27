import AudioToolbox
import AVFoundation
import Combine
import UIKit

public final class RPSoundPlayer {
    public static let shared = RPSoundPlayer()

    public var configuration = RPSoundConfiguration()

    private var cancellables = Set<AnyCancellable>()

    private init() {
        observeAccessibility()
    }

    public func play(_ feedback: RPSoundFeedback) {
        guard configuration.isEnabled else { return }

        DispatchQueue.main.async {
            AudioServicesPlaySystemSoundWithCompletion(feedback.systemSoundID, nil)
        }
    }

    private func observeAccessibility() {
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .map { _ in UIAccessibility.isReduceMotionEnabled }
            .sink { [weak self] isReduced in
                guard let self else { return }
                if isReduced {
                    self.configuration.volume = min(self.configuration.volume, 0.6)
                }
            }
            .store(in: &cancellables)
    }
}
