import Foundation

enum AuthProvider: String, Codable, CaseIterable, Sendable {
    case apple
    case google

    var displayName: String {
        switch self {
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        }
    }
}

struct UserSession: Codable, Equatable, Sendable {
    let id: UUID
    let displayName: String
    let provider: AuthProvider
    let createdAt: Date

    init(id: UUID = UUID(), displayName: String, provider: AuthProvider, createdAt: Date = Date()) {
        self.id = id
        self.displayName = displayName
        self.provider = provider
        self.createdAt = createdAt
    }

    static let preview = UserSession(displayName: "Jamie Rivera", provider: .apple)
}

enum AuthError: Error, Equatable, LocalizedError, Sendable {
    case cancelled
    case failed(reason: String? = nil)
    case timedOut

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "사용자가 로그인을 취소했습니다."
        case .failed(let reason):
            if let reason, reason.isEmpty == false {
                return "로그인에 실패했습니다: \(reason)"
            }
            return "로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
        case .timedOut:
            return "요청이 지연되어 로그인이 만료되었습니다."
        }
    }
}

