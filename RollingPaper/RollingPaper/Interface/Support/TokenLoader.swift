import Foundation

enum TokenLoaderError: Error {
    case fileNotFound(String)
    case invalidFormat(String)
}

struct TokenLoader {
    static func load(fileName: String, bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw TokenLoaderError.fileNotFound(fileName)
        }
        let data = try Data(contentsOf: url)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: String] else {
            throw TokenLoaderError.invalidFormat(fileName)
        }
        dictionary.forEach { TokenStore.shared.set($0.value, for: $0.key) }
    }
}

