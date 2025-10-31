import Foundation
import PaperKit

/// Actor responsible for mediating access to the underlying `PaperMarkupViewController`.
/// It guarantees all controller mutations happen on the main actor while remaining
/// detachable when the SwiftUI hierarchy is torn down.
public actor PaperCanvasControllerActor {
    public enum ControllerError: Swift.Error {
        case controllerUnavailable
    }

    public nonisolated let id = UUID()

    private weak var controller: PaperMarkupViewController?

    public func attach(_ controller: PaperMarkupViewController) {
        self.controller = controller
    }

    public func detach() {
        controller = nil
    }

    /// Executes a closure with the controller on the main actor, throwing if
    /// the controller is no longer available.
    public func withController<T>(
        _ operation: @MainActor (PaperMarkupViewController) throws -> T
    ) async throws -> T {
        guard let controller else { throw ControllerError.controllerUnavailable }
        return try await MainActor.run { try operation(controller) }
    }

    /// Variant that ignores any thrown error, primarily for fire-and-forget UI mutations.
    public func withController(
        _ operation: @MainActor (PaperMarkupViewController) -> Void
    ) async {
        guard let controller else { return }
        await MainActor.run { operation(controller) }
    }
}

