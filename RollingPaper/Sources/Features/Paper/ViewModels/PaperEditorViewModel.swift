import SwiftUI
import PhotosUI
import PaperKit
import UIKit

@MainActor
@Observable
final class PaperEditorViewModel {
    var paperID: UUID?
    var paperKitState: PaperKitState
    var canvasStore: PaperCanvasStore
    var gestureManager: GestureCoordinationManager

    var selectedPhotoItem: PhotosPickerItem?
    var isStickerPickerPresented = false
    var isPhotoPickerPresented = false
    var isAudioRecorderPresented = false
    var isStickyNotePresented = false

    init(paperID: UUID? = nil,
         paperKitState: PaperKitState? = nil,
         canvasStore: PaperCanvasStore? = nil,
         gestureManager: GestureCoordinationManager? = nil) {
        self.paperID = paperID
        self.paperKitState = paperKitState ?? PaperKitState()
        self.canvasStore = canvasStore ?? PaperCanvasStore()
        self.gestureManager = gestureManager ?? GestureCoordinationManager()
    }

    var editorTitle: String {
        guard let paperID else { return "Paper" }
        return "Paper #\(paperID.uuidString.prefix(6))"
    }

    func onAppear() {
        gestureManager.prepareHapticEngine()
    }

    @discardableResult
    func toggleDrawingTool() -> Bool {
        guard paperKitState.controller != nil else { return false }
        paperKitState.isDrawingToolActive.toggle()
        return true
    }

    func presentStickerPickerIfAvailable() {
        if #available(iOS 17.0, *) {
            isStickerPickerPresented = true
        }
    }

    func presentPhotoPicker() {
        isPhotoPickerPresented = true
    }

    func presentStickyNoteSheet() {
        isStickyNotePresented = true
    }

    func presentAudioRecorder() {
        isAudioRecorderPresented = true
    }

    func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task(priority: .userInitiated) { [weak self] in
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                UIImage(data: data) != nil,
                let self
            else { return }

            await MainActor.run {
                self.addImageObject(imageData: data)
                self.selectedPhotoItem = nil
                self.isPhotoPickerPresented = false
            }
        }
    }

    func addStickyNote(text: String, noteColor: Color) {
        let stickyNote = StickyNoteObject(
            transform: defaultTransform(for: Defaults.stickyNoteSize),
            zIndex: nextZIndex(),
            text: text,
            noteColor: noteColor,
            fontName: Defaults.stickyNoteFontName,
            fontSize: Defaults.stickyNoteFontSize
        )

        canvasStore.addObject(stickyNote)
    }

    func addVoiceObject(audioURL: URL, duration: TimeInterval) {
        let voiceObject = VoiceObject(
            transform: defaultTransform(for: Defaults.voiceObjectSize),
            zIndex: nextZIndex(),
            audioURL: audioURL,
            duration: duration
        )

        canvasStore.addObject(voiceObject)
    }

    private func addImageObject(imageData: Data) {
        let imageObject = ImageObject(
            transform: defaultTransform(for: Defaults.imageObjectSize),
            zIndex: nextZIndex(),
            imageData: imageData,
            cornerRadius: .rpCornerM
        )

        canvasStore.addObject(imageObject)
    }

    private func defaultTransform(for size: CGSize) -> ObjectTransform {
        ObjectTransform(position: .zero, scale: 1.0, rotation: .zero, size: size)
    }

    private func nextZIndex() -> Double {
        Double(canvasStore.objects.count)
    }
}

private enum Defaults {
    static let imageObjectSize = CGSize(width: 200, height: 200)
    static let stickyNoteSize = CGSize(width: 200, height: 150)
    static let stickyNoteFontName = "SF Pro"
    static let stickyNoteFontSize: CGFloat = 16
    static let voiceObjectSize = CGSize(width: 100, height: 100)
}

extension PaperEditorViewModel {
    static let preview = PaperEditorViewModel()
}

