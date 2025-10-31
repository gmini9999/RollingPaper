import SwiftUI
import PaperKit
import PencilKit
import UIKit
import Combine

@MainActor
final class PaperKitState: ObservableObject {
    @Published var isDrawingToolActive: Bool = false
    @Published var hasSelection: Bool = false
    private(set) weak var controller: PaperMarkupViewController?
    let canvasController = PaperCanvasControllerActor()

    func bind(controller: PaperMarkupViewController) {
        self.controller = controller
        Task { await canvasController.attach(controller) }
    }

    func unbindController() {
        controller = nil
        isDrawingToolActive = false
        hasSelection = false
        Task { await canvasController.detach() }
    }

    func withMarkupController<T>(_ operation: @MainActor (PaperMarkupViewController) throws -> T) async throws -> T {
        try await canvasController.withController(operation)
    }

    func withMarkupController(_ operation: @MainActor (PaperMarkupViewController) -> Void) async {
        await canvasController.withController(operation)
    }
}

struct PaperKitContainerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PaperMarkupViewController
    @ObservedObject var state: PaperKitState
    
    func makeUIViewController(context: Context) -> PaperMarkupViewController {
        let markupVC = PaperMarkupViewController(supportedFeatureSet: .latest)
        markupVC.delegate = context.coordinator
        state.bind(controller: markupVC)
        context.coordinator.attach(markupVC)
        return markupVC
    }
    
    func updateUIViewController(_ uiViewController: PaperMarkupViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    static func dismantleUIViewController(_ uiViewController: PaperMarkupViewController, coordinator: Coordinator) {
        coordinator.detach()
    }
    
    @MainActor
    final class Coordinator: NSObject, PaperMarkupViewController.Delegate {
        private weak var markupVC: PaperMarkupViewController?
        private weak var state: PaperKitState?

        init(state: PaperKitState) {
            self.state = state
        }

        func attach(_ controller: PaperMarkupViewController) {
            markupVC = controller
        }

        func detach() {
            markupVC = nil
            state?.unbindController()
        }

        // MARK: - PaperMarkupViewController.Delegate
        func paperMarkupViewControllerDidChangeMarkup(_ controller: PaperMarkupViewController) {
            updateSelectionState(from: controller)
        }
        
        func paperMarkupViewControllerDidChangeSelection(_ controller: PaperMarkupViewController) {
            updateSelectionState(from: controller)
        }
        
        func paperMarkupViewControllerDidBeginDrawing(_ controller: PaperMarkupViewController) {
            state?.isDrawingToolActive = true
        }
        
        func paperMarkupViewControllerDidChangeContentVisibleFrame(_ controller: PaperMarkupViewController) {}

        private func updateSelectionState(from controller: PaperMarkupViewController) {
            // PaperKit does not currently expose a public selection API; rely on KVC until available.
            Task { [weak state] in
                guard let state else { return }
                let hasSelection = (try? await state.withMarkupController { controller in
                    (controller.value(forKey: "hasSelection") as? Bool) ?? false
                }) ?? false

                await MainActor.run {
                    state.hasSelection = hasSelection
                }
            }
        }
    }
}

