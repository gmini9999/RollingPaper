import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onAuthenticated: (() -> Void)?
    @Environment(\.adaptiveLayoutContext) private var layout
    @Environment(\.colorScheme) private var colorScheme
    @State private var hasNavigatedAfterAuth = false

    var body: some View {
        RPToastContainer {
            ScrollView {
                VStack(spacing: layout.breakpoint == .expanded ? .rpSpaceXXL : .rpSpaceXL) {
                    header
                    statusView
                    providerButtons
                    footer
                }
                .adaptiveContentContainer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .onAppear {
            guard viewModel.state.isAuthenticated, hasNavigatedAfterAuth == false else { return }
            handleSuccessfulAuth()
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState.isAuthenticated, hasNavigatedAfterAuth == false {
                if viewModel.feedback == nil {
                    handleSuccessfulAuth()
                }
            }

            if case .signedOut = newState {
                hasNavigatedAfterAuth = false
            }
        }
    }

    private var header: some View {
        VStack(spacing: .rpSpaceS) {
            Text("Sign in to continue")
                .font(layout.breakpoint == .expanded ? .rpHeadingL : .rpHeadingM)
                .multilineTextAlignment(.center)
                .foregroundColor(primaryTextColor)

            Text("Choose a social account to create or access your Rolling Papers.")
                .font(.rpBodyM)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var statusView: some View {
        AuthFlowStatusView(
            viewModel: viewModel,
            onRetry: { provider in retrySignIn(provider: provider) },
            onDismissError: { viewModel.dismissError() },
            onSuccess: { handleSuccessfulAuth(triggerHaptic: false) }
        )
    }

    private var providerButtons: some View {
        VStack(spacing: .rpSpaceM) {
            SocialLoginButton(
                style: .apple,
                isLoading: viewModel.loadingProvider == .apple,
                isEnabled: canInteract
            ) {
                handleSignIn(provider: .apple)
            }
            .accessibilityHint("Apple 계정으로 로그인")

            SocialLoginButton(
                style: .google,
                isLoading: viewModel.loadingProvider == .google,
                isEnabled: canInteract
            ) {
                handleSignIn(provider: .google)
            }
            .accessibilityHint("Google 계정으로 로그인")
        }
    }

    private var footer: some View {
        Text("We use your social profile only to personalize your experience. You can revoke access anytime from settings.")
            .font(.rpCaption)
            .foregroundColor(secondaryTextColor)
            .multilineTextAlignment(.center)
            .padding(.top, .rpSpaceS)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .rpSurface : .rpSurfaceAlt
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .rpTextInverse : .rpTextPrimary
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? .rpTextInverse.opacity(0.8) : .rpTextPrimary.opacity(0.75)
    }

    private var canInteract: Bool {
        return viewModel.loadingProvider == nil && !viewModel.isProcessing
    }

    private func handleSignIn(provider: AuthProvider) {
        Task {
            await viewModel.signIn(with: provider)
        }
    }

    private func retrySignIn(provider: AuthProvider) {
        viewModel.dismissError()
        handleSignIn(provider: provider)
    }

    private func handleSuccessfulAuth(triggerHaptic: Bool = true) {
        guard hasNavigatedAfterAuth == false else { return }
        hasNavigatedAfterAuth = true
        if triggerHaptic {
            RPHapticEngine.shared.trigger(.notification(type: .success))
        }
        onAuthenticated?()
    }
}

#Preview("Auth – Compact") {
    let provider = InterfaceProvider()
    let configuration = MockAuthServiceConfiguration(
        latencyRange: 0...0,
        failureProbability: 0,
        cancellationProbability: 0,
        simulatedNames: [:]
    )
    return AuthView(viewModel: AuthViewModel(service: MockAuthService(configuration: configuration)))
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Auth – Expanded") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1366,
        height: 1024
    )
    let configuration = MockAuthServiceConfiguration(
        latencyRange: 0...0,
        failureProbability: 0,
        cancellationProbability: 0,
        simulatedNames: [:]
    )
    return AuthView(viewModel: AuthViewModel(service: MockAuthService(configuration: configuration)))
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interface(provider)
}
