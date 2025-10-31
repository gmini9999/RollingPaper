import SwiftUI
import PaperKit
import PhotosUI

struct BottomToolbarView: View {
    var paperKitState: PaperKitState
    var canvasStore: PaperCanvasStore
    
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
            return AppConstants.Spacing.xxl + 4
        case .medium:
            return AppConstants.Spacing.xl + 2
        case .compact:
            return AppConstants.Spacing.m + 6
        }
    }

    private var containerPadding: CGFloat {
        switch layout.breakpoint {
        case .expanded:
            return AppConstants.Spacing.m + 6
        case .medium:
            return AppConstants.Spacing.l
        case .compact:
            return AppConstants.Spacing.m + 2
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
        .padding(.vertical, .rpSpaceM)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerXL, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: ShadowTokens.medium.color, radius: ShadowTokens.medium.radius, x: ShadowTokens.medium.x, y: ShadowTokens.medium.y)
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
            cornerRadius: .rpCornerM
        )
        
        canvasStore.addObject(imageObject)
    }

    private func toolbarButton(systemName: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(Typography.title3)
                .frame(width: 44, height: 44)
                .foregroundStyle(isActive ? Color.white : Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: .rpCornerL, style: .continuous)
                        .fill(isActive ? Color.accentColor : Color.secondary.opacity(OpacityTokens.subtle))
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func toolbarLabel(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(Typography.title3)
            .frame(width: 44, height: 44)
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: .rpCornerL, style: .continuous)
                    .fill(Color.secondary.opacity(OpacityTokens.subtle))
            )
    }
}

