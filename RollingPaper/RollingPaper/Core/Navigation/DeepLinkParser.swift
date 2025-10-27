import Foundation

enum DeepLinkParser {
    private static let scheme = "rollingpaper"

    static func parse(url: URL) -> AppRoute? {
        guard url.scheme == scheme else { return nil }
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let first = pathComponents.first else {
            return .launch
        }

        switch first {
        case "auth":
            return .auth
        case "home":
            return .home
        case "paper":
            return parsePaperRoute(pathComponents: Array(pathComponents.dropFirst()))
        default:
            return .launch
        }
    }

    private static func parsePaperRoute(pathComponents: [String]) -> AppRoute? {
        guard let subPath = pathComponents.first else {
            return .paper(.create)
        }

        switch subPath {
        case "new":
            return .paper(.create)
        default:
            if let uuid = UUID(uuidString: subPath) {
                if pathComponents.dropFirst().first == "share" {
                    return .paper(.share(id: uuid))
                }
                return .paper(.detail(id: uuid))
            }
            return nil
        }
    }
}

