import SwiftUI

@main
@MainActor
struct RollingPaperApp: App {
    private let authService: AuthService

    init(authService: AuthService = MockAuthService()) {
        self.authService = authService
    }

    var body: some Scene {
        WindowGroup {
            AppNavigationView(authService: authService)
        }
    }
}
