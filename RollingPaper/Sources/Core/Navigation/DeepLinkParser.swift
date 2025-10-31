import Foundation

struct DeepLinkResult {
    let route: AppRoute
    let modal: ModalDestination?
}

enum DeepLinkParser {
    private static let scheme = "rollingpaper"

    static func parse(url: URL) -> DeepLinkResult? {
        guard url.scheme == scheme else { return nil }
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let first = pathComponents.first else {
            return DeepLinkResult(route: .launch, modal: nil)
        }

        switch first {
        case "auth":
            return DeepLinkResult(route: .auth, modal: nil)
        case "home":
            return DeepLinkResult(route: .home, modal: nil)
        case "paper":
            return parsePaperRoute(pathComponents: Array(pathComponents.dropFirst()))
        default:
            return DeepLinkResult(route: .launch, modal: nil)
        }
    }

    private static func parsePaperRoute(pathComponents: [String]) -> DeepLinkResult? {
        guard let subPath = pathComponents.first else {
            return DeepLinkResult(route: .home, modal: .createPaper)
        }

        switch subPath {
        case "new":
            return DeepLinkResult(route: .home, modal: .createPaper)
        default:
            if let uuid = UUID(uuidString: subPath) {
                if pathComponents.dropFirst().first == "share" {
                    return DeepLinkResult(route: .paper(.share(id: uuid)), modal: nil)
                }
                return DeepLinkResult(route: .paper(.detail(id: uuid)), modal: nil)
            }
            return nil
        }
    }
}

