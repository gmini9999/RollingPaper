import Foundation

enum ModalDestination: Identifiable, Equatable, Sendable {
    case createPaper
    case joinPaper

    var id: String {
        switch self {
        case .createPaper:
            return "create-paper"
        case .joinPaper:
            return "join-paper"
        }
    }
}

