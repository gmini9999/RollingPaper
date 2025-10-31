import Foundation

/// Top-level application routes for type-safe navigation
/// - Conformance: Hashable for NavigationStack, Identifiable for animations, Sendable for Swift 6
enum AppRoute: Hashable, Identifiable, Sendable {
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

/// Paper-specific routes for canvas and sharing workflows
/// - Conformance: Hashable for NavigationStack, Identifiable for animations, Sendable for Swift 6
enum PaperRoute: Hashable, Identifiable, Sendable {
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

