import Combine
import Foundation

struct MockAuthServiceConfiguration: Sendable {
    let latencyRange: ClosedRange<TimeInterval>
    let failureProbability: Double
    let cancellationProbability: Double
    let simulatedNames: [AuthProvider: [String]]

    static let `standard` = MockAuthServiceConfiguration(
        latencyRange: 0.5...1.2,
        failureProbability: 0.15,
        cancellationProbability: 0.05,
        simulatedNames: [
            .apple: ["Jamie Rivera", "Chris Han", "Minseo Kim", "Alex Garcia"],
            .google: ["Jordan Chen", "Taylor Singh", "Yuna Lee", "Owen Park"]
        ]
    )
}

@MainActor
final class MockAuthService: AuthService {

    @Published private var session: UserSession?

    var currentSession: UserSession? { session }

    var sessionPublisher: AnyPublisher<UserSession?, Never> {
        $session.eraseToAnyPublisher()
    }

    private let configuration: MockAuthServiceConfiguration
    private let persistence: SessionPersistence

    init(configuration: MockAuthServiceConfiguration? = nil,
         persistence: SessionPersistence? = nil) {
        let resolvedConfig = configuration ?? MockAuthServiceConfiguration.standard
        let resolvedPersistence = persistence ?? UserDefaultsSessionPersistence()
        self.configuration = resolvedConfig
        self.persistence = resolvedPersistence
        self._session = Published(initialValue: resolvedPersistence.loadSession())
    }

    @discardableResult
    func signIn(with provider: AuthProvider) async throws -> UserSession {
        try await Task.sleep(nanoseconds: randomLatencyNanoseconds())

        let outcome = Double.random(in: 0...1)

        if outcome < configuration.failureProbability {
            throw AuthError.failed()
        }

        if outcome < configuration.failureProbability + configuration.cancellationProbability {
            throw AuthError.cancelled
        }

        let session = makeSession(for: provider)
        self.session = session
        persistence.save(session: session)
        return session
    }

    func signOut() async {
        session = nil
        persistence.clear()
    }

    private func randomLatencyNanoseconds() -> UInt64 {
        let seconds = Double.random(in: configuration.latencyRange)
        return UInt64(seconds * 1_000_000_000)
    }

    private func makeSession(for provider: AuthProvider) -> UserSession {
        let names = configuration.simulatedNames[provider] ?? []
        let displayName = names.randomElement() ?? "\(provider.displayName) 사용자"
        return UserSession(displayName: displayName, provider: provider)
    }
}

