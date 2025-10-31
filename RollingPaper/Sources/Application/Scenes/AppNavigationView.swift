import SwiftUI

struct AppNavigationView: View {
    @StateObject private var navigator = AppNavigator()
    @StateObject private var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    
    private var sidebarSelectionBinding: Binding<SidebarDestination?> {
        Binding(
            get: { navigator.sidebarSelection },
            set: { navigator.sidebarSelection = $0 }
        )
    }
    
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
                .toolbarBackground(.regularMaterial, for: .navigationBar)
                .background(Color(.systemGroupedBackground))
                .environment(\.adaptiveLayoutContext, layoutContext)
                .onAppear {
                    syncColumnVisibility(with: layoutContext.columnVisibilityPreference, animated: false)
                    NavigationIntentBridge.shared.register(navigator: navigator)
                    DispatchQueue.main.async {
                        routeAccordingToCurrentAuthState(animated: false)
                    }
                }
                .onDisappear {
                    NavigationIntentBridge.shared.clear()
                }
                .onChange(of: layoutContext) { _, newContext in
                    syncColumnVisibility(with: newContext.columnVisibilityPreference)
                }
                .animation(.easeInOut(duration: 0.2), value: layoutContext.breakpoint)
        }
        .onChange(of: authViewModel.state) { oldState, newState in
            handleAuthStateChange(from: oldState, to: newState)
        }
        .onOpenURL { url in
            navigator.handle(deepLink: url)
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
            AppNavigationSidebarView(selection: sidebarSelectionBinding, onSelect: handleSidebarSelection)
        } detail: {
            detailContainer(for: context)
        }
    }
    
    private var navigationStack: some View {
        NavigationStack(path: $navigator.path) {
            LaunchView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .toolbarRole(.navigationStack)
        .environmentObject(authViewModel)
        .environmentObject(navigator)
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
    
    @ViewBuilder
    private func detailContainer(for context: AdaptiveLayoutContext) -> some View {
        if context.breakpoint == .expanded {
            HStack(alignment: .top, spacing: .rpSpaceM) {
                navigationStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                AppNavigationSupplementaryColumnView(
                    context: context,
                    paperRoute: currentPaperRoute,
                    onOpenShare: { id in
                        navigator.navigate(to: .paper(.share(id: id)))
                    }
                )
                .frame(maxWidth: 360)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        } else {
            navigationStack
        }
    }
    
    private var currentPaperRoute: PaperRoute? {
        guard case .paper(let route) = navigator.currentRoute else { return nil }
        return route
    }
    
    private func handleSidebarSelection(_ destination: SidebarDestination) {
        withAnimation(fastNavigationAnimation) {
            navigator.sidebarSelection = destination
        }
        
        if destination.isActionOnly {
            navigator.triggerSidebarDestination(destination)
        }
    }
    
    private func syncColumnVisibility(with target: NavigationSplitViewVisibility, animated: Bool = true) {
        guard columnVisibility != target else { return }
        
        let update = {
            columnVisibility = target
        }
        
        if animated {
            withAnimation(fastNavigationAnimation) {
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
    
    private var fastNavigationAnimation: Animation {
        .rp(.fast, reduceMotion: accessibilityReduceMotion)
    }
    
    private var standardNavigationAnimation: Animation {
        .rp(.standard, reduceMotion: accessibilityReduceMotion)
    }
}

#Preview("App Navigation View") {
    let provider = InterfaceProvider()
    return AppNavigationView(authService: MockAuthService())
        .environmentObject(provider)
        .interface(provider)
}

