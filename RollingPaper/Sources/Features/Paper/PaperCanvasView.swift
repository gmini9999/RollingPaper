import SwiftUI

struct PaperCanvasView: View {
    @ObservedObject var store: PaperCanvasStore
    @EnvironmentObject private var gestureManager: GestureCoordinationManager

    @State private var hasAppliedInitialFit = false
    @State private var cachedCanvasSize: CGSize = .zero
    var body: some View {
        GeometryReader { proxy in
            let viewportSize = proxy.size
            let baseSize = store.state.canvasSize
            let canvasCenter = CGPoint(x: baseSize.width / 2, y: baseSize.height / 2)
            let transform = store.canvasTransform
            let scale = transform.scale
            let offset = transform.offset

            let canvasContent = ZStack {
                canvasBackground()
                    .frame(width: baseSize.width, height: baseSize.height)

                ForEach(store.stickers) { sticker in
                    StickerInteractiveLayer(
                        store: store,
                        sticker: sticker,
                        canvasCenter: canvasCenter
                    )
                }
            }

            Group {
                canvasContent
                    .frame(width: baseSize.width, height: baseSize.height)
                    .scaleEffect(scale, anchor: .center)
                    .offset(offset)
                    .frame(width: viewportSize.width, height: viewportSize.height, alignment: .center)
                    .contentShape(Rectangle())
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: scale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: offset)
            }
            .onAppear {
                applyInitialFitIfNeeded(for: viewportSize)
            }
            .onChange(of: viewportSize) { _, newSize in
                guard newSize != cachedCanvasSize else { return }
                cachedCanvasSize = newSize
                store.fitCanvas(to: newSize)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Paper canvas")
    }

    private func applyInitialFitIfNeeded(for size: CGSize) {
        guard hasAppliedInitialFit == false, size.width > 0, size.height > 0 else { return }
        cachedCanvasSize = size
        store.fitCanvas(to: size)
        hasAppliedInitialFit = true
    }

    private func canvasBackground() -> some View {
        Rectangle()
            .fill(store.state.backgroundColor)
            .overlay(gridPattern().opacity(0.18))
    }

    private func gridPattern() -> some View {
        Canvas { context, size in
            let spacing: CGFloat = 60
            let lineWidth: CGFloat = 0.6
            let verticalCount = Int(ceil(size.width / spacing))
            let horizontalCount = Int(ceil(size.height / spacing))

            for index in 0...verticalCount {
                let x = CGFloat(index) * spacing
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.white.opacity(0.3)), lineWidth: lineWidth)
            }

            for index in 0...horizontalCount {
                let y = CGFloat(index) * spacing
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.white.opacity(0.3)), lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StickerInteractiveLayer: View {
    @ObservedObject var store: PaperCanvasStore
    @EnvironmentObject private var gestureManager: GestureCoordinationManager
    let sticker: PaperSticker
    let canvasCenter: CGPoint

    private let hitPadding: CGFloat = 28
    private let minimumHitDimension: CGFloat = 120

    private var resolvedSticker: PaperSticker {
        store.sticker(with: sticker.id) ?? sticker
    }

    private var absolutePosition: CGPoint {
        let transform = resolvedSticker.transform
        return CGPoint(
            x: canvasCenter.x + transform.position.x,
            y: canvasCenter.y + transform.position.y
        )
    }

    private var isSelected: Bool {
        store.activeStickerID == resolvedSticker.id
    }

    private var isEditing: Bool {
        store.isEditing && isSelected
    }

    var body: some View {
        let stickerSize = resolvedSticker.transform.currentSize

        let interactiveWidth = max(stickerSize.width + hitPadding * 2, minimumHitDimension)
        let interactiveHeight = max(stickerSize.height + hitPadding * 2, minimumHitDimension)

        return ZStack {
            PaperStickerView(
                sticker: resolvedSticker,
                size: stickerSize,
                isSelected: isSelected,
                isEditing: isEditing
            )
            .frame(width: stickerSize.width, height: stickerSize.height)
            .overlay(alignment: .topTrailing) {
                if isEditing {
                    deleteButton
                        .offset(x: 8, y: -8)
                }
            }
        }
        .frame(
            width: interactiveWidth,
            height: interactiveHeight
        )
        .contentShape(Rectangle())
        .rotationEffect(resolvedSticker.transform.rotation)
        .position(absolutePosition)
        .allowsHitTesting(true)
        .zIndex(resolvedSticker.zIndex)
        .highPriorityGesture(
            gestureManager.currentMode == .default ? activationGesture : nil
        )
    }

    private var activationGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.4, maximumDistance: 20)
            .onChanged { isPressing in
                guard isPressing else { return }
                // Prevent sticker gestures from interfering with canvas gestures
                guard !gestureManager.isCanvasInteracting else { return }
            }
            .onEnded { _ in
                // Only trigger in default mode
                guard gestureManager.currentMode == .default else { return }
                
                // Enter edit mode for this sticker
                gestureManager.enterEditMode(for: resolvedSticker.id)
                store.selectSticker(resolvedSticker.id)
                store.beginEditing(sticker: resolvedSticker.id)
            }
    }

    private var deleteButton: some View {
        Button {
            store.deleteSticker(resolvedSticker.id)
        } label: {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.white, Color.rpDanger)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                .padding(4)
        }
        .buttonStyle(.plain)
    }
}
