import SwiftUI
import PencilKit

public enum PaperCanvasDefaults {
    public static let baseSize = CGSize(width: 1024, height: 768)
}

// MARK: - Canvas Object Protocol

public protocol CanvasObject: Identifiable, Equatable {
    var id: UUID { get }
    var transform: ObjectTransform { get set }
    var zIndex: Double { get set }
}

public struct ObjectTransform: Equatable {
    public var position: CGPoint
    public var scale: CGFloat
    public var rotation: Angle
    public var size: CGSize
    
    public init(position: CGPoint = .zero,
                scale: CGFloat = 1.0,
                rotation: Angle = .zero,
                size: CGSize) {
        self.position = position
        self.scale = max(scale, 0.1)
        self.rotation = rotation
        self.size = size
    }
    
    public var currentSize: CGSize {
        CGSize(width: size.width * scale, height: size.height * scale)
    }
}

// MARK: - Text Object

public struct TextObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var text: String
    public var fontName: String
    public var fontSize: CGFloat
    public var fontColor: Color
    public var backgroundColor: Color
    public var alignment: TextAlignment
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                text: String,
                fontName: String = "SF Pro",
                fontSize: CGFloat = 20,
                fontColor: Color = .black,
                backgroundColor: Color = .white,
                alignment: TextAlignment = .center) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.alignment = alignment
    }
    
    public static func == (lhs: TextObject, rhs: TextObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Image Object

public struct ImageObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var imageData: Data
    public var cornerRadius: CGFloat
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                imageData: Data,
                cornerRadius: CGFloat = 12) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.imageData = imageData
        self.cornerRadius = cornerRadius
    }
    
    public static func == (lhs: ImageObject, rhs: ImageObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Shape Object

public enum ShapeType: String, CaseIterable, Equatable {
    case rectangle
    case circle
    case triangle
    case star
    case heart
    case arrow
    case hexagon
    case diamond
}

public struct ShapeObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var shapeType: ShapeType
    public var fillColor: Color
    public var strokeColor: Color
    public var strokeWidth: CGFloat
    public var text: String // 도형 내부 텍스트
    public var textColor: Color
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                shapeType: ShapeType,
                fillColor: Color = .blue,
                strokeColor: Color = .blue,
                strokeWidth: CGFloat = 2,
                text: String = "",
                textColor: Color = .black) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.shapeType = shapeType
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.text = text
        self.textColor = textColor
    }
    
    public static func == (lhs: ShapeObject, rhs: ShapeObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sticky Note Object

public struct StickyNoteObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var text: String
    public var noteColor: Color
    public var fontName: String
    public var fontSize: CGFloat
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                text: String = "",
                noteColor: Color = .yellow,
                fontName: String = "SF Pro",
                fontSize: CGFloat = 16) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.text = text
        self.noteColor = noteColor
        self.fontName = fontName
        self.fontSize = fontSize
    }
    
    public static func == (lhs: StickyNoteObject, rhs: StickyNoteObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sticker Object (iOS 스티커)

public struct StickerObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var stickerData: Data
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                stickerData: Data) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.stickerData = stickerData
    }
    
    public static func == (lhs: StickerObject, rhs: StickerObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Voice Object

public struct VoiceObject: CanvasObject {
    public let id: UUID
    public var transform: ObjectTransform
    public var zIndex: Double
    
    public var audioURL: URL
    public var duration: TimeInterval
    
    public init(id: UUID = UUID(),
                transform: ObjectTransform,
                zIndex: Double,
                audioURL: URL,
                duration: TimeInterval) {
        self.id = id
        self.transform = transform
        self.zIndex = zIndex
        self.audioURL = audioURL
        self.duration = duration
    }
    
    public static func == (lhs: VoiceObject, rhs: VoiceObject) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Canvas State (유지 필요 - 기존 코드와의 호환성)

public struct PaperCanvasTransform: Equatable {
    public var scale: CGFloat
    public var offset: CGSize
    public var minimumScale: CGFloat
    public var maximumScale: CGFloat

    public init(scale: CGFloat = 1,
                offset: CGSize = .zero,
                minimumScale: CGFloat = 0.2,
                maximumScale: CGFloat = 2.5) {
        self.scale = scale
        self.offset = offset
        self.minimumScale = minimumScale
        self.maximumScale = maximumScale
    }

    public mutating func clampScale() {
        scale = min(max(scale, minimumScale), maximumScale)
    }
}


public struct PaperCanvasState: Equatable, Sendable {
    public var canvasTransform: PaperCanvasTransform
    public var canvasSize: CGSize
    public var backgroundColor: Color

    public init(canvasTransform: PaperCanvasTransform = .init(),
                backgroundColor: Color = Color(.systemBackground),
                canvasSize: CGSize = PaperCanvasDefaults.baseSize) {
        self.canvasTransform = canvasTransform
        self.backgroundColor = backgroundColor
        self.canvasSize = canvasSize
    }
}

