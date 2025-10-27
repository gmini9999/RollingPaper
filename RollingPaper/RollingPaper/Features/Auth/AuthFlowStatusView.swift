import SwiftUI

struct AuthFlowStatusView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onRetry: ((AuthProvider) -> Void)?
    var onDismissError: (() -> Void)?
    var onSuccess: (() -> Void)?

    @Environment(\.rpToastCenter) private var toastCenter
    private let hapticEngine = RPHapticEngine.shared

    var body: some View {
        VStack(spacing: .rpSpaceM) {
            if let provider = viewModel.loadingProvider {
                loadingView(for: provider)
            }

            if case .failure(let provider, let error) = viewModel.state {
                failureView(provider: provider, error: error)
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: viewModel.feedback) { _, feedback in
            guard let feedback else { return }
            present(feedback)
        }
    }

    private func present(_ feedback: AuthViewModel.Feedback) {
        let toastStyle: RPToast.Style = feedback.kind == .success ? .success : .critical
        var toastAction: RPToast.Action?

        if feedback.kind == .failure,
           case .failure(let provider, _) = viewModel.state,
           let onRetry {
            toastAction = RPToast.Action(title: "다시 시도") {
                Task { @MainActor in
                    onRetry(provider)
                }
            }
        }

        let toast = RPToast(
            title: feedback.title,
            message: feedback.message,
            style: toastStyle,
            action: toastAction
        )

        toastCenter.show(toast, duration: 3)

        triggerHaptic(for: feedback.kind)

        switch feedback.kind {
        case .success:
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 250_000_000)
                viewModel.acknowledgeFeedback()
                onSuccess?()
            }
        case .failure:
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 50_000_000)
                viewModel.acknowledgeFeedback()
            }
        }
    }

    private func triggerHaptic(for kind: AuthViewModel.Feedback.Kind) {
        switch kind {
        case .success:
            hapticEngine.trigger(.notification(type: .success))
        case .failure:
            hapticEngine.trigger(.notification(type: .error))
        }
    }

    @ViewBuilder
    private func loadingView(for provider: AuthProvider) -> some View {
        RPCard {
            RPLoadingIndicator(style: .spinner, message: "\(provider.displayName) 계정 인증 중…")
                .accessibilityLabel("\(provider.displayName) 계정으로 로그인 진행 중")
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private func failureView(provider: AuthProvider, error: AuthError) -> some View {
        RPCard(spacing: .rpSpaceS) {
            Text(error.errorDescription ?? "로그인에 실패했습니다. 잠시 후 다시 시도해주세요.")
                .font(.rpBodyM)
                .foregroundColor(.rpTextPrimary)
                .multilineTextAlignment(.leading)

            RPButton("다시 시도", variant: .secondary, size: .medium, isEnabled: !viewModel.isProcessing) {
                onRetry?(provider)
            }
            .accessibilityHint("로그인을 다시 시도합니다")

            RPButton("닫기", variant: .link, size: .medium, isEnabled: !viewModel.isProcessing) {
                onDismissError?()
            }
            .accessibilityHint("오류 메시지를 닫습니다")
        }
        .transition(.opacity)
    }
}

