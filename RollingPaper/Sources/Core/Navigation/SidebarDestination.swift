import Foundation

enum SidebarDestination: String, CaseIterable, Identifiable, Hashable, Sendable {
    case launch
    case auth
    case home
    case paperCreate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .launch:
            return L10n.Navigation.Sidebar.launch
        case .auth:
            return L10n.Navigation.Sidebar.auth
        case .home:
            return L10n.Navigation.Sidebar.home
        case .paperCreate:
            return L10n.Navigation.Sidebar.newPaper
        }
    }

    var systemImage: String {
        switch self {
        case .launch:
            return "sparkles"
        case .auth:
            return "person.badge.key"
        case .home:
            return "house.fill"
        case .paperCreate:
            return "plus.rectangle.on.rectangle"
        }
    }

    var isActionOnly: Bool {
        self == .paperCreate
    }

    static var primaryDestinations: [SidebarDestination] {
        [.launch, .home, .auth]
    }

    static var actionDestinations: [SidebarDestination] {
        [.paperCreate]
    }

    static func selection(for route: AppRoute?) -> SidebarDestination {
        guard let route else { return .launch }

        switch route {
        case .launch:
            return .launch
        case .auth:
            return .auth
        case .home, .paper:
            return .home
        }
    }
}


