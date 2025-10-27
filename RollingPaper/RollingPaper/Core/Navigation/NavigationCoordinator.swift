import Combine
import SwiftUI

final class NavigationCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var presentedPaperRoute: PaperRoute?

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func reset(to route: AppRoute) {
        path = [route]
    }

    func handle(deepLink url: URL) {
        guard let route = DeepLinkParser.parse(url: url) else { return }
        switch route {
        case .launch:
            path = []
        case .auth:
            path = [.auth]
        case .home:
            path = [.home]
        case .paper(let paperRoute):
            path = [.home, .paper(paperRoute)]
        }
    }
}

