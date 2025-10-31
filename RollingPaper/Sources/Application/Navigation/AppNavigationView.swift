import SwiftUI

struct AppNavigationView: View {
    @State private var navigator = AppNavigator()
    @State private var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(authService: AuthService) {
        _authViewModel = State(wrappedValue: AuthViewModel(service: authService))
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

            NavigationStack(path: $navigator.path) {
                LaunchView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
            .toolbarRole(.navigationStack)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .background(Color(.systemGroupedBackground))
            .environment(authViewModel)
            .environment(navigator)
            .environment(\.adaptiveLayoutContext, layoutContext)
            .task {
                routeAccordingToCurrentAuthState(animated: false)
            }
        }
        .onChange(of: authViewModel.state) { oldState, newState in
            handleAuthStateChange(from: oldState, to: newState)
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .launch:
            LaunchView()
        case .auth:
            AuthView(viewModel: authViewModel) {
                navigator.reset(to: .home)
            }
        case .home:
            HomeView(onOpenPaper: { id in
                navigator.navigate(to: .paper(.detail(id: id)))
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
                navigator.navigate(to: .paper(.share(id: shareID)))
            }
        case .share(let id):
            ShareView(paperID: id)
        }
    }

    private func handleAuthStateChange(from oldState: AuthViewModel.State, to newState: AuthViewModel.State) {
        if newState.isAuthenticated {
            guard oldState.isAuthenticated == false else { return }
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
        guard navigator.path.last != .home else { return }
        applyNavigation(animated: animated) {
            navigator.reset(to: .home)
        }
    }

    private func routeToAuth(animated: Bool) {
        let isAuthActive = navigator.path.count == 1 && navigator.path.last == .auth
        guard isAuthActive == false else { return }
        applyNavigation(animated: animated) {
            navigator.reset(to: .auth)
        }
    }

    private func applyNavigation(animated: Bool, _ updates: @escaping () -> Void) {
        if animated {
            withAnimation(standardNavigationAnimation) {
                updates()
            }
        } else {
            updates()
        }
    }

    private var standardNavigationAnimation: Animation {
        reduceMotion ? .default : .easeInOut(duration: AppConstants.AnimationDuration.standard)
    }
}

#Preview("App Navigation View") {
    AppNavigationView(authService: MockAuthService())
}

