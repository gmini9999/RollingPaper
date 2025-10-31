import SwiftUI

struct AuthFlowStatusView: View {
    var viewModel: AuthViewModel
    var onRetry: ((AuthProvider) -> Void)?
    var onDismissError: (() -> Void)?
    var onSuccess: (() -> Void)?

    private let hapticEngine = RPHapticEngine.shared
    @State private var alertContent: AlertContent?

    var body: some View {
        VStack(spacing: 24) {
            if let provider = viewModel.loadingProvider {
                loadingView(for: provider)
            }

            if case .failure(let provider, let error) = viewModel.state {
                failureView(provider: provider, error: error)
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: viewModel.feedback) { oldValue, newValue in
            guard let feedback = newValue else { return }
            present(feedback)
        }
        .alert(item: $alertContent) { content in
            alert(for: content)
        }
    }

    private func present(_ feedback: AuthViewModel.Feedback) {
        triggerHaptic(for: feedback.kind)

        switch feedback.kind {
        case .success:
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 250_000_000)
                viewModel.acknowledgeFeedback()
                onSuccess?()
            }
        case .failure:
            if case .failure(let provider, _) = viewModel.state {
                alertContent = AlertContent(
                    title: feedback.title ?? "",
                    message: feedback.message,
                    retryProvider: provider
                )
            } else {
                alertContent = AlertContent(
                    title: feedback.title ?? "",
                    message: feedback.message,
                    retryProvider: nil
                )
            }
            viewModel.acknowledgeFeedback()
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

    private func alert(for content: AlertContent) -> Alert {
        if let provider = content.retryProvider, let onRetry {
            return Alert(
                title: Text(content.title),
                message: Text(content.message),
                primaryButton: .default(Text("다시 시도")) {
                    onRetry(provider)
                },
                secondaryButton: .cancel(Text("닫기")) {
                    onDismissError?()
                }
            )
        } else {
            return Alert(
                title: Text(content.title),
                message: Text(content.message),
                dismissButton: .default(Text("확인")) {
                    onDismissError?()
                }
            )
        }
    }

    @ViewBuilder
    private func loadingView(for provider: AuthProvider) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)

            Text("\(provider.displayName) 계정 인증 중…")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .accessibilityLabel("\(provider.displayName) 계정으로 로그인 진행 중")
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, y: 8)
        .transition(.opacity)
    }

    @ViewBuilder
    private func failureView(provider: AuthProvider, error: AuthError) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(error.errorDescription ?? "로그인에 실패했습니다. 잠시 후 다시 시도해주세요.")
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Button("다시 시도") {
                onRetry?(provider)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isProcessing)
            .accessibilityHint("로그인을 다시 시도합니다")

            Button("닫기") {
                onDismissError?()
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .disabled(viewModel.isProcessing)
            .accessibilityHint("오류 메시지를 닫습니다")
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, y: 6)
        .transition(.opacity)
    }
}

private struct AlertContent: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let retryProvider: AuthProvider?
}

