import SwiftUI

@main
struct RollingPaperApp: App {
    @MainActor
    private let authService: AuthService = MockAuthService()

    var body: some Scene {
        WindowGroup {
            AppNavigationView(authService: authService)
        }
    }
}
