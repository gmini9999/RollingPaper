import SwiftUI

struct AppNavigationView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var interfaceProvider: InterfaceProvider
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    init(authService: AuthService) {
        _authViewModel = StateObject(wrappedValue: AuthViewModel(service: authService))
    }

    init() {
        self.init(authService: MockAuthService())
    }

    var body: some View {
        GeometryReader { proxy in
            let layoutContext = AdaptiveLayoutContext.resolve(
                proxy: proxy,
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass
            )

            adaptiveContainer(for: layoutContext)
                .environment(\.adaptiveLayoutContext, layoutContext)
                .onAppear {
                    syncColumnVisibility(with: layoutContext.columnVisibilityPreference, animated: false)
                    DispatchQueue.main.async {
                        routeAccordingToCurrentAuthState(animated: false)
                    }
                    syncInterfaceProvider()
                }
                .onChange(of: layoutContext) { _, newContext in
                    syncColumnVisibility(with: newContext.columnVisibilityPreference)
                }
                .animation(.easeInOut(duration: 0.2), value: layoutContext.breakpoint)
        }
        .onChange(of: authViewModel.state) { oldState, newState in
            handleAuthStateChange(from: oldState, to: newState)
        }
        .onChange(of: colorScheme) { _, newScheme in
            interfaceProvider.set(colorScheme: newScheme)
        }
        .onChange(of: accessibilityReduceMotion) { _, newValue in
            interfaceProvider.set(reduceMotion: newValue)
        }
        .onChange(of: dynamicTypeSize) { _, newValue in
            interfaceProvider.set(dynamicType: newValue)
        }
    }

    @ViewBuilder
    private func adaptiveContainer(for context: AdaptiveLayoutContext) -> some View {
        switch context.breakpoint {
        case .compact:
            navigationStack
        case .medium:
            if context.isPad {
                splitView(context: context)
            } else {
                navigationStack
            }
        case .expanded:
            splitView(context: context)
        }
    }

    private func splitView(context: AdaptiveLayoutContext) -> some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar(for: context)
        } detail: {
            detailContainer(for: context)
        }
    }

    private var navigationStack: some View {
        NavigationStack(path: $coordinator.path) {
            LaunchView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .environmentObject(authViewModel)
        .environmentObject(coordinator)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .launch:
            LaunchView()
        case .auth:
            AuthView(viewModel: authViewModel) {
                coordinator.reset(to: .home)
            }
        case .home:
            HomeView(onOpenPaper: { id in
                coordinator.navigate(to: .paper(.detail(id: id)))
            })
        case .paper(let paperRoute):
            paperDestination(for: paperRoute)
        }
    }

    @ViewBuilder
    private func paperDestination(for route: PaperRoute) -> some View {
        switch route {
        case .detail(let id):
            PaperView(paperID: id) { shareID in
                coordinator.navigate(to: .paper(.share(id: shareID)))
            }
        case .share(let id):
            ShareView(paperID: id)
        }
    }

    private func syncInterfaceProvider() {
        interfaceProvider.set(colorScheme: colorScheme)
        interfaceProvider.set(reduceMotion: accessibilityReduceMotion)
        interfaceProvider.set(dynamicType: dynamicTypeSize)
    }

    @ViewBuilder
    private func sidebar(for context: AdaptiveLayoutContext) -> some View {
        List {
            Section("Main") {
                sidebarButton(.launch)
                sidebarButton(.auth)
                sidebarButton(.home)
            }

            Section("Paper") {
                sidebarButton(.paperCreate)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Navigation")
        .background(Color.clear)
    }

    private func sidebarButton(_ destination: SidebarDestination) -> some View {
        let isActive = currentSidebarDestination == destination

        return Button {
            performSidebarNavigation(for: destination)
        } label: {
            Label(destination.title, systemImage: destination.systemImage)
                .font(isActive ? .rpHeadingM : .rpBodyM)
                .foregroundColor(isActive ? .rpPrimary : .rpTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        .listRowBackground(isActive ? Color.rpSurfaceAlt.opacity(0.6) : Color.clear)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    @ViewBuilder
    private func supplementaryColumn(for context: AdaptiveLayoutContext) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .rpSpaceM) {
                Text("Layout Overview")
                    .font(.rpHeadingM)

                switch currentPaperRoute {
                case .detail(let id):
                    Text("Editing #\(id.uuidString.prefix(6))")
                        .font(.rpHeadingM)
                    Text("Review comments and share once the content is complete.")
                        .font(.rpBodyM)
                        .foregroundColor(Color.rpTextPrimary.opacity(0.8))
                    RPButton("Open Share") {
                        coordinator.navigate(to: .paper(.share(id: id)))
                    }
                case .share(let id):
                    Text("Sharing #\(id.uuidString.prefix(6))")
                        .font(.rpHeadingM)
                    Text("Distribute the generated link or invite collaborators directly from this column.")
                        .font(.rpBodyM)
                        .foregroundColor(Color.rpTextPrimary.opacity(0.8))
                case .none:
                    Text("Select a destination or open a modal action to see contextual tips and quick actions.")
                        .font(.rpBodyM)
                        .foregroundColor(Color.rpTextPrimary.opacity(0.8))
                }

                Divider()

                Text("Device Context")
                    .font(.rpHeadingM)
                Text(deviceSummary(for: context))
                    .font(.rpBodyM)
                    .foregroundColor(Color.rpTextPrimary.opacity(0.8))
            }
            .adaptiveContentContainer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.rpSurfaceAlt)
    }

    @ViewBuilder
    private func detailContainer(for context: AdaptiveLayoutContext) -> some View {
        if context.breakpoint == .expanded {
            HStack(alignment: .top, spacing: .rpSpaceM) {
                navigationStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                supplementaryColumn(for: context)
                    .frame(maxWidth: 360)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        } else {
            navigationStack
        }
    }

    private func deviceSummary(for context: AdaptiveLayoutContext) -> String {
        let breakpointDescription: String
        switch context.breakpoint {
        case .compact:
            breakpointDescription = "compact width"
        case .medium:
            breakpointDescription = "medium width"
        case .expanded:
            breakpointDescription = "expanded width"
        }

        let orientation = context.isLandscape ? "landscape" : "portrait"
        let device = context.isPad ? "iPad" : "iPhone"
        return "Currently in \(breakpointDescription) on \(device) (\(Int(context.width))×\(Int(context.height))pt, \(orientation))."
    }

    private func performSidebarNavigation(for destination: SidebarDestination) {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch destination {
            case .launch:
                coordinator.path = []
            case .auth:
                coordinator.reset(to: .auth)
            case .home:
                coordinator.reset(to: .home)
            case .paperCreate:
                coordinator.reset(to: .home)
                coordinator.present(.createPaper)
            }
        }
    }

    private var currentSidebarDestination: SidebarDestination {
        guard let last = coordinator.path.last else {
            return .launch
        }

        switch last {
        case .launch:
            return .launch
        case .auth:
            return .auth
        case .home:
            return .home
        case .paper:
            return .paperCreate
        }
    }

    private var currentPaperRoute: PaperRoute? {
        guard case .paper(let route) = coordinator.path.last else { return nil }
        return route
    }

    private func syncColumnVisibility(with target: NavigationSplitViewVisibility, animated: Bool = true) {
        guard columnVisibility != target else { return }

        let update = {
            columnVisibility = target
        }

        if animated {
            withAnimation(.easeInOut(duration: 0.2)) {
                update()
            }
        } else {
            update()
        }
    }

    private func handleAuthStateChange(from oldState: AuthViewModel.State, to newState: AuthViewModel.State) {
        if newState.isAuthenticated {
            if oldState.isAuthenticated { return }
            routeToHome(animated: true)
            return
        }

        if case .signedOut = newState {
            routeToAuth(animated: true)
            return
        }

        if case .failure = newState {
            routeToAuth(animated: false)
        }
    }

    private func routeAccordingToCurrentAuthState(animated: Bool) {
        switch authViewModel.state {
        case .authenticated:
            routeToHome(animated: animated)
        case .signedOut, .failure:
            routeToAuth(animated: animated)
        case .loading:
            break
        }
    }

    private func routeToHome(animated: Bool) {
        guard coordinator.path.last != .home else { return }
        applyNavigation(animated: animated) {
            coordinator.reset(to: .home)
        }
    }

    private func routeToAuth(animated: Bool) {
        let isAuthActive = coordinator.path.count == 1 && coordinator.path.last == .auth
        guard isAuthActive == false else { return }
        applyNavigation(animated: animated) {
            coordinator.reset(to: .auth)
        }
    }

    private func applyNavigation(animated: Bool, _ updates: @escaping () -> Void) {
        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                updates()
            }
        } else {
            updates()
        }
    }
}

private enum SidebarDestination: Hashable {
    case launch
    case auth
    case home
    case paperCreate

    var title: String {
        switch self {
        case .launch:
            return "Launch"
        case .auth:
            return "Auth"
        case .home:
            return "Home"
        case .paperCreate:
            return "New Paper"
        }
    }

    var systemImage: String {
        switch self {
        case .launch:
            return "sparkles"
        case .auth:
            return "person.crop.circle"
        case .home:
            return "house"
        case .paperCreate:
            return "square.and.pencil"
        }
    }
}

#Preview("App Navigation View") {
    let provider = InterfaceProvider()
    return AppNavigationView(authService: MockAuthService())
        .environmentObject(provider)
        .interface(provider)
}

