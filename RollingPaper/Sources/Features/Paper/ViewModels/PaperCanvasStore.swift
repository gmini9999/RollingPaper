import Combine
import SwiftUI

@MainActor
public final class PaperCanvasStore: ObservableObject {
    public enum Event: Equatable {
        case selectionChanged(stickerID: UUID?)
        case editModeChanged(stickerID: UUID?, isEditing: Bool)
        case stickerDeleted(stickerID: UUID)
        case canvasTransformChanged(scale: CGFloat, offset: CGSize)
    }

    @Published private(set) public var state: PaperCanvasState
    public let events = PassthroughSubject<Event, Never>()

    @Published public var isCanvasInteracting: Bool = false

    private let bounceAllowance: CGFloat = 0
    private let minimumScaleFloor: CGFloat = 0.1
    private var lastCanvasSize: CGSize?

    public init(state: PaperCanvasState) {
        self.state = state
    }

    @MainActor
    public convenience init() {
        self.init(state: .mock())
    }

    public var stickers: [PaperSticker] { state.stickers }
    public var selection: PaperCanvasSelection { state.selection }
    public var canvasTransform: PaperCanvasTransform { state.canvasTransform }
    public var activeStickerID: UUID? { state.selection.activeStickerID }
    public var isEditing: Bool { state.selection.isEditing }

    public func setCanvasScale(_ scale: CGFloat, canvasSize: CGSize? = nil) {
        state.canvasTransform.scale = scale
        state.canvasTransform.clampScale()
        if let size = canvasSize {
            lastCanvasSize = size
        }
        let targetSize = canvasSize ?? lastCanvasSize
        if let size = targetSize {
            state.canvasTransform.offset = clampedOffset(state.canvasTransform.offset, canvasSize: size)
        }
        publishCanvasTransformChanged()
    }

    public func updateCanvasScale(by delta: CGFloat, canvasSize: CGSize? = nil) {
        guard delta.isFinite else { return }
        setCanvasScale(state.canvasTransform.scale * delta, canvasSize: canvasSize)
    }

    public func setCanvasOffset(_ offset: CGSize, canvasSize: CGSize? = nil) {
        if let size = canvasSize {
            lastCanvasSize = size
        }
        let targetSize = canvasSize ?? lastCanvasSize
        if let size = targetSize {
            state.canvasTransform.offset = clampedOffset(offset, canvasSize: size)
            publishCanvasTransformChanged()
        }
    }

    public func updateCanvasOffset(by delta: CGSize, canvasSize: CGSize? = nil) {
        if let size = canvasSize {
            lastCanvasSize = size
        }
        let targetSize = canvasSize ?? lastCanvasSize
        guard let size = targetSize else { return }

        var next = state.canvasTransform.offset
        next.width += delta.width
        next.height += delta.height
        state.canvasTransform.offset = clampedOffset(next, canvasSize: size)
        publishCanvasTransformChanged()
    }

    public func resetCanvasTransform(canvasSize: CGSize? = nil) {
        if let size = canvasSize {
            fitCanvas(to: size)
        } else if let size = lastCanvasSize {
            fitCanvas(to: size)
        } else {
            state.canvasTransform.scale = state.canvasTransform.minimumScale
            state.canvasTransform.offset = .zero
            publishCanvasTransformChanged()
        }
    }

    public func selectSticker(_ id: UUID?) {
        if selection.activeStickerID == id, selection.isEditing == false { return }
        state.selection.select(stickerID: id)
        events.send(.selectionChanged(stickerID: id))
    }

    public func beginEditing(sticker id: UUID) {
        guard index(for: id) != nil else { return }
        state.selection.beginEditing(stickerID: id)
        bringStickerToFront(id)
        events.send(.editModeChanged(stickerID: id, isEditing: true))
    }

    public func endEditing() {
        guard selection.isEditing else { return }
        let id = selection.activeStickerID
        state.selection.select(stickerID: id)
        events.send(.editModeChanged(stickerID: id, isEditing: false))
    }

    public func clearSelection() {
        guard selection.activeStickerID != nil || selection.isEditing else { return }
        state.selection.clear()
        events.send(.selectionChanged(stickerID: nil))
    }

    public func sticker(with id: UUID) -> PaperSticker? {
        state.stickers.first { $0.id == id }
    }

    public func canEditSticker(_ id: UUID) -> Bool {
        return index(for: id) != nil
    }

    public func addSticker(_ stickerKind: PaperStickerKind) {
        let transform = PaperStickerTransform(
            position: CGPoint(x: 0, y: 0),
            baseSize: CGSize(width: 200, height: 100),
            scale: 1.0,
            rotation: .zero
        )
        let zIndex = Double(state.stickers.count)
        let sticker = PaperSticker(
            kind: stickerKind,
            transform: transform,
            zIndex: zIndex
        )
        state.stickers.append(sticker)
        selectSticker(sticker.id)
    }

    public func updateStickerTransform(_ id: UUID, _ transformMutation: (inout PaperStickerTransform) -> Void) {
        guard let index = index(for: id), state.stickers.indices.contains(index) else { return }
        transformMutation(&state.stickers[index].transform)
    }

    public func translateSticker(_ id: UUID, by translation: CGSize) {
        updateStickerTransform(id) { transform in
            transform.position.x += translation.width
            transform.position.y += translation.height
        }
    }

    public func scaleSticker(_ id: UUID, by scale: CGFloat) {
        guard scale.isFinite else { return }
        updateStickerTransform(id) { transform in
            let newScale = transform.scale * scale
            transform.scale = max(newScale, 0.2)
        }
    }

    public func rotateSticker(_ id: UUID, by angle: Angle) {
        updateStickerTransform(id) { transform in
            transform.rotation += angle
        }
    }

    public func setStickerTransform(_ id: UUID, transform: PaperStickerTransform) {
        guard let index = index(for: id) else { return }
        state.stickers[index].transform = transform
    }

    public func bringStickerToFront(_ id: UUID) {
        guard let index = index(for: id) else { return }
        let nextZ = state.highestZIndex + 1
        state.stickers[index].zIndex = nextZ
    }

    public func deleteSticker(_ id: UUID) {
        guard let index = index(for: id) else { return }
        state.stickers.remove(at: index)
        if selection.activeStickerID == id {
            state.selection.clear()
            events.send(.selectionChanged(stickerID: nil))
        }
        events.send(.stickerDeleted(stickerID: id))
    }

    public func repositionSticker(_ id: UUID, within bounds: CGRect) {
        updateStickerTransform(id) { transform in
            let halfWidth = transform.currentSize.width / 2
            let halfHeight = transform.currentSize.height / 2
            let minX = bounds.minX + halfWidth
            let maxX = bounds.maxX - halfWidth
            let minY = bounds.minY + halfHeight
            let maxY = bounds.maxY - halfHeight

            transform.position.x = min(max(transform.position.x, minX), maxX)
            transform.position.y = min(max(transform.position.y, minY), maxY)
        }
    }

    public func fitCanvas(to canvasSize: CGSize) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }

        lastCanvasSize = canvasSize

        let bounds = state.contentBounds
        guard bounds.width > 0, bounds.height > 0 else {
            state.canvasTransform.scale = 1
            state.canvasTransform.minimumScale = 1
            state.canvasTransform.offset = .zero
            publishCanvasTransformChanged()
            return
        }

        let fitScale = computeFitScale(for: bounds, in: canvasSize)
        let sanitizedScale = min(state.canvasTransform.maximumScale,
                                 max(fitScale, minimumScaleFloor))

        state.canvasTransform.scale = sanitizedScale
        state.canvasTransform.minimumScale = sanitizedScale

        let centeredOffset = computeCenteredOffset(for: bounds,
                                                   scale: sanitizedScale)

        state.canvasTransform.offset = clampedOffset(centeredOffset, canvasSize: canvasSize)
        publishCanvasTransformChanged()
    }

    private func index(for id: UUID) -> Int? {
        state.stickers.firstIndex { $0.id == id }
    }

    private func publishCanvasTransformChanged() {
        events.send(.canvasTransformChanged(scale: state.canvasTransform.scale,
                                            offset: state.canvasTransform.offset))
    }

    private func clampedOffset(_ proposed: CGSize, canvasSize: CGSize) -> CGSize {
        let bounds = state.contentBounds
        guard canvasSize.width > 0, canvasSize.height > 0 else { return proposed }

        let scale = state.canvasTransform.scale
        let halfWidth = canvasSize.width / 2
        let halfHeight = canvasSize.height / 2

        let scaledMinX = bounds.minX * scale
        let scaledMaxX = bounds.maxX * scale
        let scaledMinY = bounds.minY * scale
        let scaledMaxY = bounds.maxY * scale

        let horizontalRange = allowableOffsetRange(minEdge: scaledMinX,
                                                   maxEdge: scaledMaxX,
                                                   viewportHalfExtent: halfWidth)
        let verticalRange = allowableOffsetRange(minEdge: scaledMinY,
                                                 maxEdge: scaledMaxY,
                                                 viewportHalfExtent: halfHeight)

        let clampedX = proposed.width.clamped(to: horizontalRange)
        let clampedY = proposed.height.clamped(to: verticalRange)

        return CGSize(width: clampedX, height: clampedY)
    }

    private func allowableOffsetRange(minEdge: CGFloat, maxEdge: CGFloat, viewportHalfExtent: CGFloat) -> ClosedRange<CGFloat> {
        let lower = viewportHalfExtent - maxEdge - bounceAllowance
        let upper = -viewportHalfExtent - minEdge + bounceAllowance

        if lower <= upper {
            return lower...upper
        } else {
            return 0...0
        }
    }

    private func computeFitScale(for bounds: CGRect, in viewport: CGSize) -> CGFloat {
        guard bounds.width > 0, bounds.height > 0 else { return 1 }

        let widthScale = viewport.width / bounds.width
        let heightScale = viewport.height / bounds.height

        if bounds.width >= bounds.height {
            return widthScale
        } else {
            return heightScale
        }
    }

    private func computeCenteredOffset(for bounds: CGRect, scale: CGFloat) -> CGSize {
        CGSize(
            width: -scale * bounds.midX,
            height: -scale * bounds.midY
        )
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

public extension PaperCanvasStore {
    @MainActor
    static func preview() -> PaperCanvasStore {
        PaperCanvasStore()
    }
}
