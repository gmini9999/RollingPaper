import Combine
import SwiftUI

final class NavigationCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var activeModal: ModalDestination?

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func reset(to route: AppRoute) {
        path = [route]
    }

    func handle(deepLink url: URL) {
        guard let result = DeepLinkParser.parse(url: url) else { return }

        switch result.route {
        case .launch:
            path = []
        case .auth:
            path = [.auth]
        case .home:
            path = [.home]
        case .paper(let paperRoute):
            path = [.home, .paper(paperRoute)]
        }

        if let modal = result.modal {
            present(modal)
        }
    }

    func present(_ modal: ModalDestination) {
        activeModal = modal
    }

    func dismissModal() {
        activeModal = nil
    }
}

