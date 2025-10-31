import SwiftUI
import PaperKit
import PhotosUI

struct BottomToolbarView: View {
    @ObservedObject var paperKitState: PaperKitState
    @ObservedObject var canvasStore: PaperCanvasStore
    
    @Environment(\.adaptiveLayoutContext) private var layout
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showStickerPicker = false
    @State private var showAudioRecorder = false
    @State private var showStickyNoteSheet = false
    @State private var isPhotoPickerPresented = false

    private var buttonSpacing: CGFloat {
        switch layout.breakpoint {
        case .expanded:
            return 28
        case .medium:
            return 22
        case .compact:
            return 18
        }
    }

    private var containerPadding: CGFloat {
        switch layout.breakpoint {
        case .expanded:
            return 18
        case .medium:
            return 16
        case .compact:
            return 14
        }
    }

    var body: some View {
        HStack(spacing: buttonSpacing) {
            toolbarButton(systemName: "pencil.tip", isActive: paperKitState.isDrawingToolActive) {
                activateDrawingTool()
            }

            toolbarButton(systemName: "textformat", action: insertTextBox)

            toolbarButton(systemName: "square.on.circle", action: insertShape)

            Menu {
                Button {
                    if #available(iOS 17.0, *) {
                        showStickerPicker = true
                    }
                } label: {
                    Label(L10n.Paper.Clip.sticker, systemImage: "face.smiling")
                }

                Button { isPhotoPickerPresented = true } label: {
                    Label(L10n.Paper.Clip.photo, systemImage: "photo")
                }

                Button { showStickyNoteSheet = true } label: {
                    Label(L10n.Paper.Clip.stickyNote, systemImage: "note.text")
                }

                Button { showAudioRecorder = true } label: {
                    Label(L10n.Paper.Clip.voiceMemo, systemImage: "mic.fill")
                }
            } label: {
                toolbarLabel(systemName: "paperclip")
            }
            .menuStyle(.button)
        }
        .padding(.horizontal, containerPadding)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 4)
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            loadPhoto(from: item)
        }
        .sheet(isPresented: $showStickerPicker) {
            Text(L10n.Placeholder.comingSoon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderSheet(store: canvasStore)
        }
        .sheet(isPresented: $showStickyNoteSheet) {
            StickyNoteSheet(store: canvasStore)
        }
    }
    
    // MARK: - PaperKit Tool Actions
    
    private func activateDrawingTool() {
        guard paperKitState.controller != nil else { return }
        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
        paperKitState.isDrawingToolActive.toggle()
    }
    
    private func insertTextBox() {
        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
        showStickyNoteSheet = true
    }
    
    private func insertShape() {
        feedbackCenter.trigger(haptic: .impact(style: .light), animation: .subtle, reduceMotion: reduceMotion)
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), UIImage(data: data) != nil {
                await MainActor.run {
                    addImageObject(imageData: data)
                }
            }
        }
    }
    
    private func addImageObject(imageData: Data) {
        let defaultSize = CGSize(width: 200, height: 200)
        let transform = ObjectTransform(
            position: .zero,
            scale: 1.0,
            rotation: .zero,
            size: defaultSize
        )
        
        let imageObject = ImageObject(
            transform: transform,
            zIndex: Double(canvasStore.objects.count),
            imageData: imageData,
            cornerRadius: 12
        )
        
        canvasStore.addObject(imageObject)
    }

    private func toolbarButton(systemName: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .foregroundStyle(isActive ? Color.white : Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func toolbarLabel(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title3.weight(.semibold))
            .frame(width: 44, height: 44)
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
            )
    }
}

