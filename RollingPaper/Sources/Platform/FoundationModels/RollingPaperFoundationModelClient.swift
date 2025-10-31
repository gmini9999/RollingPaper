import Foundation

/// Prompt container passed to the Foundation Models client.
public struct FoundationModelPrompt: Sendable {
    public var system: String?
    public var user: String
    public var temperature: Double
    public var maxOutputTokens: Int

    public init(system: String? = nil, user: String, temperature: Double = 0.2, maxOutputTokens: Int = 512) {
        self.system = system
        self.user = user
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
    }
}

public enum FoundationModelClientError: Error, Sendable {
    case notAvailable
    case remoteNotConfigured
    case remoteFailure(statusCode: Int)
    case decodingFailure
}

public protocol FoundationModelGenerating {
    func generateResponse(for prompt: FoundationModelPrompt) async throws -> String
}

/// Concrete client that prefers Apple’s on-device Foundation Models and falls back to a remote endpoint.
public final class RollingPaperFoundationModelClient: FoundationModelGenerating, Sendable {
    private let onDeviceProvider: FoundationModelProvider
    private let remoteProvider: FoundationModelProvider

    public init(
        onDeviceProvider: FoundationModelProvider = OnDeviceFoundationModelProvider(),
        remoteProvider: FoundationModelProvider = RemoteFoundationModelProvider()
    ) {
        self.onDeviceProvider = onDeviceProvider
        self.remoteProvider = remoteProvider
    }

    public func generateResponse(for prompt: FoundationModelPrompt) async throws -> String {
        if let onDevice = try await onDeviceProvider.generateResponse(for: prompt) {
            return onDevice
        }

        if let remote = try await remoteProvider.generateResponse(for: prompt) {
            return remote
        }

        throw FoundationModelClientError.notAvailable
    }
}

// MARK: - Providers

public protocol FoundationModelProvider: Sendable {
    /// Returns a response when the provider can fulfil the request; otherwise `nil` to allow fallback.
    func generateResponse(for prompt: FoundationModelPrompt) async throws -> String?
}

public struct OnDeviceFoundationModelProvider: FoundationModelProvider {
    public init() {}

    public func generateResponse(for prompt: FoundationModelPrompt) async throws -> String? {
        guard #available(iOS 26.0, *) else { return nil }

        #if canImport(FoundationModels)
        // Integrate with the real FoundationModels framework when the public API is available.
        return nil
        #else
        return nil
        #endif
    }
}

public struct RemoteFoundationModelProvider: FoundationModelProvider {
    private let endpoint: URL?
    private let session: URLSession

    public init(endpoint: URL? = URL(string: ProcessInfo.processInfo.environment["ROLLINGPAPER_FM_ENDPOINT" ] ?? ""), session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    public func generateResponse(for prompt: FoundationModelPrompt) async throws -> String? {
        guard let endpoint else { throw FoundationModelClientError.remoteNotConfigured }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = RemoteRequestPayload(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FoundationModelClientError.remoteFailure(statusCode: -1)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw FoundationModelClientError.remoteFailure(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(RemoteResponsePayload.self, from: data)
        guard let text = decoded.output.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
            throw FoundationModelClientError.decodingFailure
        }
        return text
    }

    private struct RemoteRequestPayload: Encodable {
        let prompt: FoundationModelPrompt

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(prompt.user, forKey: .user)
            try container.encodeIfPresent(prompt.system, forKey: .system)
            try container.encode(prompt.temperature, forKey: .temperature)
            try container.encode(prompt.maxOutputTokens, forKey: .maxTokens)
        }

        enum CodingKeys: String, CodingKey {
            case user
            case system
            case temperature
            case maxTokens = "max_tokens"
        }
    }

    private struct RemoteResponsePayload: Decodable {
        let output: String
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

