import Foundation

enum AppRoute: Hashable, Identifiable {
    case launch
    case auth
    case home
    case paper(PaperRoute)

    var id: String {
        switch self {
        case .launch: return "launch"
        case .auth: return "auth"
        case .home: return "home"
        case .paper(let route): return "paper-\(route.id)"
        }
    }
}

enum PaperRoute: Hashable, Identifiable {
    case detail(id: UUID)
    case share(id: UUID)

    var id: String {
        switch self {
        case .detail(let id):
            return "detail-\(id.uuidString)"
        case .share(let id):
            return "share-\(id.uuidString)"
        }
    }
}

