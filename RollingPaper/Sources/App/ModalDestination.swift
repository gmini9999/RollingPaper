import Foundation

enum ModalDestination: Identifiable, Equatable {
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

