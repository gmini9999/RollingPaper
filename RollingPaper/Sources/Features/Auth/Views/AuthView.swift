import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onAuthenticated: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var hasNavigatedAfterAuth = false

    private var isExpanded: Bool { horizontalSizeClass == .regular }
    private var contentSpacing: CGFloat { isExpanded ? 40 : 28 }

    var body: some View {
        ScrollView {
            VStack(spacing: contentSpacing) {
                header
                statusView
                providerButtons
                footer
            }
            .padding(.horizontal, contentSpacing)
            .padding(.vertical, contentSpacing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
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
        VStack(spacing: 12) {
            Text("Sign in to continue")
                .font(isExpanded ? .largeTitle.weight(.semibold) : .title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("Choose a social account to create or access your Rolling Papers.")
                .font(.body)
                .foregroundStyle(.secondary)
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
        VStack(spacing: 20) {
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
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 12)
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
    let configuration = MockAuthServiceConfiguration(
        latencyRange: 0...0,
        failureProbability: 0,
        cancellationProbability: 0,
        simulatedNames: [:]
    )
    NavigationStack {
        AuthView(viewModel: AuthViewModel(service: MockAuthService(configuration: configuration)))
    }
}

#Preview("Auth – Expanded") {
    let configuration = MockAuthServiceConfiguration(
        latencyRange: 0...0,
        failureProbability: 0,
        cancellationProbability: 0,
        simulatedNames: [:]
    )
    NavigationStack {
        AuthView(viewModel: AuthViewModel(service: MockAuthService(configuration: configuration)))
    }
    .previewInterfaceOrientation(.landscapeLeft)
}
