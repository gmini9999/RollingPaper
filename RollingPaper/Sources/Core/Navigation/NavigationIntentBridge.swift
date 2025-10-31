import Foundation

@MainActor
final class NavigationIntentBridge {
    static let shared = NavigationIntentBridge()

    private weak var navigator: AppNavigator?

    func register(navigator: AppNavigator) {
        self.navigator = navigator
    }

    func clear() {
        navigator = nil
    }

    func openHome() throws {
        guard let navigator else { throw NavigationIntentError.coordinatorUnavailable }
        navigator.reset(to: .home)
    }

    func createPaper() throws {
        guard let navigator else { throw NavigationIntentError.coordinatorUnavailable }
        navigator.reset(to: .home)
        navigator.present(.createPaper)
    }
}

enum NavigationIntentError: Error {
    case coordinatorUnavailable
}

