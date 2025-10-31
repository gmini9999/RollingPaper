import Foundation
import SwiftUI

/// Centralized navigation state used by the SwiftUI hierarchy.
/// Drives both the `NavigationStack` path and auxiliary presentation state
/// while remaining compliant with Swift 6 concurrency checks.
@MainActor
@Observable
final class AppNavigator {
    var path: [AppRoute] = []

    var currentRoute: AppRoute? {
        path.last
    }

    // MARK: - Navigation

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func replacePath(with routes: [AppRoute]) {
        path = routes
    }

    func reset(to route: AppRoute) {
        replacePath(with: [route])
    }

    func pop() {
        guard path.isEmpty == false else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

