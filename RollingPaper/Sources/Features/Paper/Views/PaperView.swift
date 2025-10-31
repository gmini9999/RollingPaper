import SwiftUI
import PhotosUI
import PaperKit

struct PaperView: View {
    var onShare: ((UUID) -> Void)?

    @Environment(\.adaptiveLayoutContext) private var layout
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var model: PaperEditorViewModel

    init(paperID: UUID?,
         viewModel: PaperEditorViewModel? = nil,
         onShare: ((UUID) -> Void)? = nil) {
        self.onShare = onShare
        _model = State(initialValue: viewModel ?? PaperEditorViewModel(paperID: paperID))
    }

    var body: some View {
        @Bindable var model = model

        ZStack(alignment: .bottom) {
            PaperKitContainerView(state: model.paperKitState)
                .ignoresSafeArea()

            CustomObjectsOverlay(objects: model.canvasStore.objects)
                .environment(model.canvasStore)
                .environment(model.gestureManager)
                .ignoresSafeArea()
        }
        .navigationTitle(model.editorTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let id = model.paperID {
                    Button(action: { onShare?(id) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(Typography.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .accessibilityLabel("공유")
                }
            }

            ToolbarItem(placement: .bottomBar) { drawingToolButton }
            ToolbarItem(placement: .bottomBar) { textToolButton }
            ToolbarItem(placement: .bottomBar) { shapeToolButton }
            ToolbarItem(placement: .bottomBar) { attachmentsMenu }
        }
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .toolbarBackground(.hidden, for: .bottomBar)
        .environment(model.gestureManager)
        .photosPicker(isPresented: $model.isPhotoPickerPresented, selection: $model.selectedPhotoItem, matching: .images)
        .onChange(of: model.selectedPhotoItem) { _, item in
            model.handlePhotoSelection(item)
        }
        .sheet(isPresented: $model.isStickerPickerPresented) {
            Text(L10n.Placeholder.comingSoon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        }
        .sheet(isPresented: $model.isAudioRecorderPresented) {
            AudioRecorderSheet(model: model)
        }
        .sheet(isPresented: $model.isStickyNotePresented) {
            StickyNoteSheet(model: model)
        }
        .onAppear {
            model.onAppear()
        }
    }
}

private extension PaperView {
    var drawingToolButton: some View {
        Button(action: handleDrawingToolTapped) {
            Image(systemName: "pencil.tip")
                .font(Typography.title3)
                .symbolVariant(model.paperKitState.isDrawingToolActive ? .fill : .none)
        }
        .buttonStyle(.plain)
        .foregroundStyle(model.paperKitState.isDrawingToolActive ? Color.accentColor : .primary)
        .accessibilityLabel("펜")
    }

    var textToolButton: some View {
        Button(action: handleTextToolTapped) {
            Image(systemName: "textformat")
                .font(Typography.title3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("텍스트")
    }

    var shapeToolButton: some View {
        Button(action: handleShapeToolTapped) {
            Image(systemName: "square.on.circle")
                .font(Typography.title3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("도형")
    }

    func handleDrawingToolTapped() {
        guard model.toggleDrawingTool() else { return }
        triggerSelectionFeedback()
    }

    func handleTextToolTapped() {
        triggerSelectionFeedback()
        model.presentStickyNoteSheet()
    }

    func handleShapeToolTapped() {
        feedbackCenter.trigger(
            haptic: .impact(style: .light),
            animation: .subtle,
            reduceMotion: reduceMotion
        )
    }

    func triggerSelectionFeedback() {
        feedbackCenter.trigger(
            haptic: .selection,
            animation: .subtle,
            reduceMotion: reduceMotion
        )
    }

    var attachmentsMenu: some View {
        Menu {
            Button {
                triggerSelectionFeedback()
                model.presentStickerPickerIfAvailable()
            } label: {
                Label(L10n.Paper.Clip.sticker, systemImage: "face.smiling")
            }

            Button {
                triggerSelectionFeedback()
                model.presentPhotoPicker()
            } label: {
                Label(L10n.Paper.Clip.photo, systemImage: "photo")
            }

            Button {
                triggerSelectionFeedback()
                model.presentStickyNoteSheet()
            } label: {
                Label(L10n.Paper.Clip.stickyNote, systemImage: "note.text")
            }

            Button {
                triggerSelectionFeedback()
                model.presentAudioRecorder()
            } label: {
                Label(L10n.Paper.Clip.voiceMemo, systemImage: "mic.fill")
            }
        } label: {
            Image(systemName: "paperclip")
                .font(Typography.title3)
                .foregroundStyle(.primary)
        }
        .menuStyle(.button)
        .accessibilityLabel("첨부")
    }
}

#Preview("Paper Editor – Create") {
    PaperView(paperID: nil)
        .environment(\.adaptiveLayoutContext, .fallback)
        .environment(AppNavigator())
        .interactionFeedbackCenter(InteractionFeedbackCenter.shared)
}

#Preview("Paper Editor – Expanded Detail") {
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1180,
        height: 820
    )
    PaperView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environment(AppNavigator())
        .interactionFeedbackCenter(InteractionFeedbackCenter.shared)
}
