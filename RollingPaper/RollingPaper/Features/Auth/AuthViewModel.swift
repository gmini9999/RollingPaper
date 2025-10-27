import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum State: Equatable {
        case signedOut
        case loading(AuthProvider)
        case authenticated(UserSession)
        case failure(AuthProvider, AuthError)

        var isAuthenticated: Bool {
            if case .authenticated = self { return true }
            return false
        }

        var loadingProvider: AuthProvider? {
            if case .loading(let provider) = self {
                return provider
            }
            return nil
        }
    }

    struct Feedback: Identifiable, Equatable {
        enum Kind { case success, failure }

        let id = UUID()
        let kind: Kind
        let title: String?
        let message: String
        let timestamp: Date
    }

    @Published private(set) var state: State
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var feedback: Feedback?

    var currentSession: UserSession? {
        switch state {
        case .authenticated(let session):
            return session
        default:
            return nil
        }
    }

    var loadingProvider: AuthProvider? {
        state.loadingProvider
    }

    private let service: AuthService
    private let timeoutInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()
    private var timeoutTask: Task<Void, Never>?
    private var currentAttemptID: UUID?
    private var timedOutAttempts = Set<UUID>()
    private var shouldIgnoreNextSessionUpdate = false

    init(service: AuthService, timeoutInterval: TimeInterval = 8) {
        self.service = service
        self.timeoutInterval = timeoutInterval

        if let session = service.currentSession {
            state = .authenticated(session)
        } else {
            state = .signedOut
        }

        observeSessionUpdates()
    }

    func signIn(with provider: AuthProvider) async {
        guard isProcessing == false else { return }

        let attemptID = UUID()
        currentAttemptID = attemptID
        feedback = nil
        state = .loading(provider)
        isProcessing = true

        startTimeout(for: provider, attemptID: attemptID)

        do {
            let session = try await service.signIn(with: provider)

            if timedOutAttempts.contains(attemptID) {
                timedOutAttempts.remove(attemptID)
                cancelTimeout()
                if currentAttemptID == attemptID { currentAttemptID = nil }
                isProcessing = false
                await service.signOut()
                return
            }

            cancelTimeout()
            currentAttemptID = nil
            isProcessing = false
            state = .authenticated(session)
            feedback = Feedback(kind: .success,
                                title: "로그인 성공",
                                message: "\(session.displayName)님, 환영합니다!",
                                timestamp: Date())
        } catch let error as AuthError {
            handleFailure(provider: provider, error: error, attemptID: attemptID)
        } catch {
            let wrapped = AuthError.failed(reason: error.localizedDescription)
            handleFailure(provider: provider, error: wrapped, attemptID: attemptID)
        }
    }

    func signOut() async {
        guard isProcessing == false else { return }
        cancelTimeout()
        currentAttemptID = nil
        isProcessing = true
        await service.signOut()
        isProcessing = false
        state = .signedOut
    }

    func dismissError() {
        if case .failure = state {
            state = .signedOut
        }
        feedback = nil
        shouldIgnoreNextSessionUpdate = false
        cancelTimeout()
        currentAttemptID = nil
    }

    func acknowledgeFeedback() {
        feedback = nil
    }

    private func handleFailure(provider: AuthProvider, error: AuthError, attemptID: UUID) {
        cancelTimeout()
        timedOutAttempts.remove(attemptID)
        currentAttemptID = nil
        isProcessing = false
        state = .failure(provider, error)
        feedback = Feedback(kind: .failure,
                            title: "로그인 실패",
                            message: error.errorDescription ?? "로그인에 실패했습니다. 잠시 후 다시 시도해주세요.",
                            timestamp: Date())
    }

    private func observeSessionUpdates() {
        service.sessionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] session in
                guard let self else { return }

                if let session {
                    if self.shouldIgnoreNextSessionUpdate {
                        self.shouldIgnoreNextSessionUpdate = false
                        return
                    }

                    if case .authenticated(let current) = self.state, current == session {
                        return
                    }
                    self.state = .authenticated(session)
                } else {
                    if case .failure = self.state {
                        return
                    }
                    self.state = .signedOut
                }
            }
            .store(in: &cancellables)
    }

    private func startTimeout(for provider: AuthProvider, attemptID: UUID) {
        cancelTimeout()

        guard self.timeoutInterval > 0 else { return }

        timeoutTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.timeoutInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.timeoutFired(for: provider, attemptID: attemptID)
            }
        }
    }

    private func cancelTimeout() {
        timeoutTask?.cancel()
        timeoutTask = nil
    }

    @MainActor
    private func timeoutFired(for provider: AuthProvider, attemptID: UUID) {
        timedOutAttempts.insert(attemptID)
        cancelTimeout()
        currentAttemptID = nil
        isProcessing = false
        shouldIgnoreNextSessionUpdate = true
        state = .failure(provider, .timedOut)
        feedback = Feedback(kind: .failure,
                            title: "연결 지연",
                            message: AuthError.timedOut.errorDescription ?? "요청이 지연되어 로그인이 취소되었습니다.",
                            timestamp: Date())
    }
}

