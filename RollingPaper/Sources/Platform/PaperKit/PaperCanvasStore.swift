import Combine
import SwiftUI
import PencilKit

@MainActor
public final class PaperCanvasStore: ObservableObject {
    public enum Event: Equatable {
        case selectionChanged(objectIDs: Set<UUID>)
        case objectDeleted(objectID: UUID)
        case canvasTransformChanged(scale: CGFloat, offset: CGSize)
    }

    // MARK: - Published State
    @Published private(set) public var objects: [any CanvasObject] = []
    @Published private(set) public var selectedObjectIDs: Set<UUID> = []
    @Published public var drawing: PKDrawing = PKDrawing()
    @Published private(set) public var state: PaperCanvasState
    
    public let events = PassthroughSubject<Event, Never>()
    
    @Published public var isCanvasInteracting: Bool = false

    private let bounceAllowance: CGFloat = 0
    private let minimumScaleFloor: CGFloat = 0.1
    private var lastCanvasSize: CGSize?

    public init(state: PaperCanvasState) {
        self.state = state
    }

    public convenience init() {
        self.init(state: PaperCanvasState())
    }

    public var canvasTransform: PaperCanvasTransform { state.canvasTransform }

    // MARK: - Object Management
    
    public func addObject(_ object: any CanvasObject) {
        var newObject = object
        newObject.zIndex = Double(objects.count)
        objects.append(newObject)
    }
    
    public func selectObject(_ id: UUID, exclusive: Bool = true) {
        if exclusive {
            selectedObjectIDs = [id]
        } else {
            selectedObjectIDs.insert(id)
        }
        events.send(.selectionChanged(objectIDs: selectedObjectIDs))
    }
    
    public func deselectAll() {
        selectedObjectIDs.removeAll()
        events.send(.selectionChanged(objectIDs: []))
    }
    
    public func deleteSelectedObjects() {
        let idsToDelete = selectedObjectIDs
        objects.removeAll { idsToDelete.contains($0.id) }
        for id in idsToDelete {
            events.send(.objectDeleted(objectID: id))
        }
        selectedObjectIDs.removeAll()
        events.send(.selectionChanged(objectIDs: []))
    }
    
    public func updateTransform(for id: UUID, _ transform: ObjectTransform) {
        guard let index = objects.firstIndex(where: { $0.id == id }) else { return }
        objects[index].transform = transform
    }
    
    public func updateObject<T: CanvasObject>(_ id: UUID, with updatedObject: T) {
        guard let index = objects.firstIndex(where: { $0.id == id }) else { return }
        objects[index] = updatedObject
    }
    
    public func duplicateSelectedObjects() {
        let objectsToDuplicate = objects.filter { selectedObjectIDs.contains($0.id) }
        
        for object in objectsToDuplicate {
            var newObject = object
            newObject.zIndex = Double(objects.count)
            // 약간 오프셋을 주어 복제된 것을 알 수 있게 함
            var newTransform = object.transform
            newTransform.position.x += 20
            newTransform.position.y += 20
            newObject.transform = newTransform
            objects.append(newObject)
        }
    }
    
    // MARK: - Canvas Transform Management
    
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
    
    public func fitCanvas(to canvasSize: CGSize) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }
        lastCanvasSize = canvasSize
        state.canvasTransform.scale = 1
        state.canvasTransform.minimumScale = 1
        state.canvasTransform.offset = .zero
        publishCanvasTransformChanged()
    }

    // MARK: - Private Helpers
    
    private func publishCanvasTransformChanged() {
        events.send(.canvasTransformChanged(scale: state.canvasTransform.scale,
                                            offset: state.canvasTransform.offset))
    }

    private func clampedOffset(_ proposed: CGSize, canvasSize: CGSize) -> CGSize {
        // 간단한 클램핑 - 무한 캔버스 사용 안함
        return proposed
    }
}

public extension PaperCanvasStore {
    @MainActor
    static func preview() -> PaperCanvasStore {
        PaperCanvasStore()
    }
}
