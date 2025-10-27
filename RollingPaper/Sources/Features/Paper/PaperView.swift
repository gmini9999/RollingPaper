import SwiftUI

struct PaperView: View {
    let paperID: UUID?
    var onShare: ((UUID) -> Void)?

    @Environment(\.adaptiveLayoutContext) private var layout
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var canvasStore = PaperCanvasStore()
    @StateObject private var gestureManager = GestureCoordinationManager()
    @State private var currentCanvasSize: CGSize = .zero
    @State private var pinchGestureBaseScale: CGFloat?
    @State private var panGestureBaseOffset: CGSize?
    @State private var editingDragLastTranslation: CGSize = .zero
    @State private var editingMagnificationLast: CGFloat = 1
    @State private var editingRotationLast: Angle = .zero
    @State private var isPressingToExit = false

    var body: some View {
        let canvasBounds = CGRect(
            origin: CGPoint(x: -canvasStore.state.canvasSize.width / 2,
                             y: -canvasStore.state.canvasSize.height / 2),
            size: canvasStore.state.canvasSize
        )

        let editingDragGesture = DragGesture(minimumDistance: 5)
            .onChanged { value in
                guard gestureManager.canPerformStickerEditing, let id = canvasStore.activeStickerID else { return }
                isPressingToExit = false  // Cancel background long press during sticker drag
                let scale = canvasStore.canvasTransform.scale
                let translated = CGSize(
                    width: value.translation.width / max(scale, .leastNonzeroMagnitude),
                    height: value.translation.height / max(scale, .leastNonzeroMagnitude)
                )
                let delta = CGSize(
                    width: translated.width - editingDragLastTranslation.width,
                    height: translated.height - editingDragLastTranslation.height
                )
                canvasStore.translateSticker(id, by: delta)
                editingDragLastTranslation = translated
            }
            .onEnded { _ in
                guard let id = canvasStore.activeStickerID else {
                    editingDragLastTranslation = .zero
                    return
                }
                editingDragLastTranslation = .zero
                canvasStore.repositionSticker(id, within: canvasBounds)
            }

        let editingMagnificationGesture = MagnificationGesture()
            .onChanged { value in
                guard gestureManager.canPerformStickerEditing, let id = canvasStore.activeStickerID else { return }
                isPressingToExit = false  // Cancel background long press during sticker scale
                let incremental = value / editingMagnificationLast
                canvasStore.scaleSticker(id, by: incremental)
                editingMagnificationLast = value
            }
            .onEnded { _ in
                guard let id = canvasStore.activeStickerID else {
                    editingMagnificationLast = 1
                    return
                }
                editingMagnificationLast = 1
                canvasStore.repositionSticker(id, within: canvasBounds)
            }

        let editingRotationGesture = RotationGesture()
            .onChanged { value in
                guard gestureManager.canPerformStickerEditing, let id = canvasStore.activeStickerID else { return }
                isPressingToExit = false  // Cancel background long press during sticker rotation
                let delta = value - editingRotationLast
                canvasStore.rotateSticker(id, by: delta)
                editingRotationLast = value
            }
            .onEnded { _ in
                editingRotationLast = .zero
            }

        let editingCompositeGesture = editingRotationGesture
            .simultaneously(with: editingMagnificationGesture)
            .simultaneously(with: editingDragGesture)

        let baseContent = PaperCanvasView(
            store: canvasStore
        )
        .simultaneousGesture(
            gestureManager.canPerformCanvasGestures ? 
                panGesture.simultaneously(with: zoomGesture) : nil
        )
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, .rpSpaceXL)
        .background(canvasSizeReader)
        .frame(maxWidth: layout.breakpoint == .expanded ? 980 : .infinity,
               maxHeight: .infinity,
               alignment: .center)

        let editingOverlay = Color.clear
            .contentShape(Rectangle())
            .simultaneousGesture(
                gestureManager.canPerformStickerEditing ? 
                    editingCompositeGesture : nil
            )
            .onLongPressGesture(
                minimumDuration: 0.6,
                maximumDistance: 10,
                perform: {
                    guard gestureManager.currentMode == .editing else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        gestureManager.exitEditMode()
                        canvasStore.endEditing()
                        canvasStore.clearSelection()
                        resetEditingGestureState()
                    }
                },
                onPressingChanged: { isPressing in
                    guard gestureManager.currentMode == .editing else { return }
                    isPressingToExit = isPressing
                }
            )
            .allowsHitTesting(gestureManager.currentMode == .editing)

        let content = ZStack {
            baseContent
            if gestureManager.currentMode == .editing {
                editingOverlay
            }
        }

        content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .navigationTitle(editorTitle)
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(gestureManager)
        .onAppear {
            gestureManager.prepareHapticEngine()
        }
        .onReceive(canvasStore.events) { event in
            handleEvent(event)
        }
        .onChange(of: gestureManager.currentMode) { _, _ in
            resetEditingGestureState()
        }
        .onChange(of: isPressingToExit) { _, isPressing in
            guard isPressing, gestureManager.currentMode == .editing else { return }
            withAnimation(.spring(response: 0.3)) {
                gestureManager.exitEditMode()
                canvasStore.endEditing()
                canvasStore.clearSelection()
                resetEditingGestureState()
            }
        }
    }

    private var canvasSizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { currentCanvasSize = proxy.size }
                .onChange(of: proxy.size) { _, newValue in currentCanvasSize = newValue }
        }
        .allowsHitTesting(false)
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                guard gestureManager.canPerformCanvasGestures else { return }
                
                if panGestureBaseOffset == nil {
                    panGestureBaseOffset = canvasStore.canvasTransform.offset
                    gestureManager.beginCanvasGesture()
                }

                guard let base = panGestureBaseOffset else { return }

                let proposed = CGSize(
                    width: base.width + value.translation.width,
                    height: base.height + value.translation.height
                )

                if currentCanvasSize != .zero {
                    canvasStore.setCanvasOffset(proposed, canvasSize: currentCanvasSize)
                } else {
                    canvasStore.setCanvasOffset(proposed)
                }
            }
            .onEnded { _ in
                guard gestureManager.canPerformCanvasGestures else {
                    panGestureBaseOffset = nil
                    gestureManager.endCanvasGesture()
                    return
                }
                panGestureBaseOffset = nil
                gestureManager.endCanvasGesture()
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard gestureManager.canPerformCanvasGestures else { return }
                
                if pinchGestureBaseScale == nil {
                    pinchGestureBaseScale = canvasStore.canvasTransform.scale
                    gestureManager.beginCanvasGesture()
                }

                guard let base = pinchGestureBaseScale else { return }

                let targetScale = base * value

                if currentCanvasSize != .zero {
                    canvasStore.setCanvasScale(targetScale, canvasSize: currentCanvasSize)
                } else {
                    canvasStore.setCanvasScale(targetScale)
                }
            }
            .onEnded { _ in
                guard gestureManager.canPerformCanvasGestures else {
                    pinchGestureBaseScale = nil
                    gestureManager.endCanvasGesture()
                    return
                }
                pinchGestureBaseScale = nil
                gestureManager.endCanvasGesture()
            }
    }

    private var editorTitle: String {
        guard let id = paperID else {
            return "Paper"
        }
        return "Paper #\(id.uuidString.prefix(6))"
    }

    private var horizontalPadding: CGFloat {
        switch layout.breakpoint {
        case .compact:
            return .rpSpaceM
        case .medium:
            return layout.isPad ? .rpSpaceXL : .rpSpaceL
        case .expanded:
            return .rpSpaceXXL
        }
    }

    private func handleEvent(_ event: PaperCanvasStore.Event) {
        switch event {
        case .selectionChanged:
            feedbackCenter.trigger(haptic: .selection,
                                   animation: .subtle,
                                   reduceMotion: reduceMotion)
        case .editModeChanged:
            feedbackCenter.trigger(haptic: .impact(style: .light),
                                   animation: .emphasize,
                                   reduceMotion: reduceMotion)
        case .stickerDeleted:
            feedbackCenter.trigger(haptic: .notification(type: .success),
                                   animation: .spring,
                                   reduceMotion: reduceMotion)
        case .canvasTransformChanged:
            break
        }
    }

    private func resetEditingGestureState() {
        editingDragLastTranslation = .zero
        editingMagnificationLast = 1
        editingRotationLast = .zero
    }
}

#Preview("Paper Editor – Create") {
    let provider = InterfaceProvider()
    return PaperView(paperID: nil)
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interactionFeedbackCenter(.shared)
        .interface(provider)
}

#Preview("Paper Editor – Expanded Detail") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1180,
        height: 820
    )
    return PaperView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interactionFeedbackCenter(.shared)
        .interface(provider)
}
