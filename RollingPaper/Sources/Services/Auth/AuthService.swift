import Foundation

protocol AuthService: AnyObject {
    var currentSession: UserSession? { get async }

    @discardableResult
    func signIn(with provider: AuthProvider) async throws -> UserSession
    func signOut() async
}

protocol SessionPersistence {
    func loadSession() -> UserSession?
    func save(session: UserSession?)
    func clear()
}

final class UserDefaultsSessionPersistence: SessionPersistence {
    private enum Constants {
        static let storageKey = "auth.mock.session"
    }

    private let userDefaults: UserDefaults
    private let key: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userDefaults: UserDefaults = .standard, key: String = Constants.storageKey) {
        self.userDefaults = userDefaults
        self.key = key
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func loadSession() -> UserSession? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(UserSession.self, from: data)
    }

    func save(session: UserSession?) {
        guard let session else {
            userDefaults.removeObject(forKey: key)
            return
        }

        guard let data = try? encoder.encode(session) else {
            assertionFailure("Failed to encode UserSession for persistence")
            return
        }

        userDefaults.set(data, forKey: key)
    }

    func clear() {
        userDefaults.removeObject(forKey: key)
    }
}

