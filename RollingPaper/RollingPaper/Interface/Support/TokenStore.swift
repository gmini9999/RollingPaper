import Foundation

public final class TokenStore {
    public static let shared = TokenStore()

    private var cache: [String: Any] = [:]
    private let lock = NSLock()

    public func set<Value>(_ value: Value, for key: String) {
        lock.lock(); defer { lock.unlock() }
        cache[key] = value
    }

    public func value<Value>(for key: String) -> Value? {
        lock.lock(); defer { lock.unlock() }
        return cache[key] as? Value
    }
}

