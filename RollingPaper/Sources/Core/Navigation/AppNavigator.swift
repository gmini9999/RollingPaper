import Combine
import Foundation
import SwiftUI

/// Centralized navigation state used by the SwiftUI hierarchy.
/// Drives both the `NavigationStack` path and auxiliary presentation state
/// while remaining compliant with Swift 6 concurrency checks.
@MainActor
final class AppNavigator: ObservableObject {
    @Published var path: [AppRoute] = [] {
        didSet { syncSidebarSelectionFromPath() }
    }

    @Published var activeModal: ModalDestination?

    /// Sidebar selection is exposed so the split view can bind directly to it.
    /// Mutations from the UI are routed back into navigation helpers.
    @Published var sidebarSelection: SidebarDestination? = .launch {
        didSet {
            guard sidebarSelection != oldValue,
                  let selection = sidebarSelection,
                  sidebarUpdateGuard == false else { return }
            applySidebarSelection(selection)
        }
    }

    private var sidebarUpdateGuard = false

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

    func triggerSidebarDestination(_ destination: SidebarDestination) {
        applySidebarSelection(destination)
        syncSidebarSelectionFromPath()
    }

    // MARK: - Sidebar coordination

    private func applySidebarSelection(_ destination: SidebarDestination) {
        switch destination {
        case .launch:
            path.removeAll()
        case .auth:
            path = [.auth]
        case .home:
            path = [.home]
        case .paperCreate:
            path = [.home]
            present(.createPaper)
        }
    }

    private func syncSidebarSelectionFromPath() {
        let newSelection = SidebarDestination.selection(for: currentRoute)
        guard sidebarSelection != newSelection else { return }

        sidebarUpdateGuard = true
        sidebarSelection = newSelection
        sidebarUpdateGuard = false
    }

    // MARK: - Deep links

    func handle(deepLink url: URL) {
        guard let result = DeepLinkParser.parse(url: url) else {
            RPLogger.warning("Failed to parse deep link: \(url)", category: .navigation)
            return
        }

        RPLogger.info("Handling deep link: \(url.absoluteString)", category: .navigation)
        applyDeepLinkResult(result)
    }

    private func applyDeepLinkResult(_ result: DeepLinkResult) {
        switch result.route {
        case .launch:
            path.removeAll()
        case .auth:
            path = [.auth]
        case .home:
            path = [.home]
        case .paper(let paperRoute):
            path = [.home, .paper(paperRoute)]
        }

        activeModal = result.modal
    }

    // MARK: - Modal Management

    func present(_ modal: ModalDestination) {
        activeModal = modal
    }

    func dismissModal() {
        activeModal = nil
    }
}

