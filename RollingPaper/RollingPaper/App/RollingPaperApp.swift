import SwiftUI

@main
@MainActor
struct RollingPaperApp: App {
    @StateObject private var interfaceProvider: InterfaceProvider
    private let authService: AuthService

    init() {
        self.init(authService: MockAuthService())
    }

    init(authService: AuthService) {
        let provider = InterfaceProvider()
        _interfaceProvider = StateObject(wrappedValue: provider)
        self.authService = authService
    }

    var body: some Scene {
        WindowGroup {
            AppNavigationView(authService: authService)
                .environmentObject(interfaceProvider)
                .interface(interfaceProvider)
        }
    }
}
