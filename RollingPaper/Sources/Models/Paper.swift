import SwiftUI

public enum PaperCanvasDefaults {
    public static let baseSize = CGSize(width: 1024, height: 768)
}

// MARK: - Sticker Content Models

public enum PaperStickerKind: Equatable {
    case text(PaperStickerTextContent)
    case photo(PaperStickerImageContent)
    case doodle(PaperStickerDoodleContent)

    public var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .photo:
            return "Photo"
        case .doodle:
            return "Doodle"
        }
    }
}

public struct PaperStickerTextContent: Equatable {
    public enum Style: String, Equatable {
        case title
        case subtitle
        case body
        case caption
    }

    public var text: String
    public var style: Style
    public var foregroundColor: Color
    public var backgroundColor: Color

    public init(text: String,
                style: Style = .body,
                foregroundColor: Color = .rpTextPrimary,
                backgroundColor: Color = .rpSurfaceAlt) {
        self.text = text
        self.style = style
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

public struct PaperStickerImageContent: Equatable {
    public enum Source: Equatable {
        case asset(name: String)
        case system(name: String)
    }

    public var source: Source
    public var tint: Color?
    public var allowsTiling: Bool

    public init(source: Source, tint: Color? = nil, allowsTiling: Bool = false) {
        self.source = source
        self.tint = tint
        self.allowsTiling = allowsTiling
    }
}

public struct PaperStickerDoodleContent: Equatable {
    public var pathAssetName: String
    public var strokeColor: Color
    public var lineWidth: CGFloat

    public init(pathAssetName: String,
                strokeColor: Color = .rpAccent,
                lineWidth: CGFloat = 4) {
        self.pathAssetName = pathAssetName
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
}

// MARK: - Sticker Transform & Model

public struct PaperStickerTransform: Equatable {
    public var position: CGPoint
    public var baseSize: CGSize
    public var scale: CGFloat
    public var rotation: Angle

    public init(position: CGPoint = .zero,
                baseSize: CGSize,
                scale: CGFloat = 1,
                rotation: Angle = .degrees(0)) {
        self.position = position
        self.baseSize = baseSize
        self.scale = max(scale, 0.1)
        self.rotation = rotation
    }

    public var currentSize: CGSize {
        CGSize(width: baseSize.width * scale, height: baseSize.height * scale)
    }
}

public struct PaperStickerMetadata: Equatable {
    public var createdAt: Date
    public var author: String?

    public init(createdAt: Date = .now, author: String? = nil) {
        self.createdAt = createdAt
        self.author = author
    }
}

public struct PaperSticker: Identifiable, Equatable {
    public let id: UUID
    public var kind: PaperStickerKind
    public var transform: PaperStickerTransform
    public var zIndex: Double
    public var isLocked: Bool
    public var metadata: PaperStickerMetadata

    public init(id: UUID = UUID(),
                kind: PaperStickerKind,
                transform: PaperStickerTransform,
                zIndex: Double,
                isLocked: Bool = false,
                metadata: PaperStickerMetadata = .init()) {
        self.id = id
        self.kind = kind
        self.transform = transform
        self.zIndex = zIndex
        self.isLocked = isLocked
        self.metadata = metadata
    }
}

// MARK: - Canvas State

public struct PaperCanvasSelection: Equatable {
    public var activeStickerID: UUID?
    public var isEditing: Bool

    public init(activeStickerID: UUID? = nil, isEditing: Bool = false) {
        self.activeStickerID = activeStickerID
        self.isEditing = isEditing
    }

    public mutating func beginEditing(stickerID: UUID) {
        activeStickerID = stickerID
        isEditing = true
    }

    public mutating func select(stickerID: UUID?) {
        activeStickerID = stickerID
        isEditing = false
    }

    public mutating func clear() {
        activeStickerID = nil
        isEditing = false
    }
}

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

public struct PaperCanvasState: Equatable {
    public var stickers: [PaperSticker]
    public var canvasTransform: PaperCanvasTransform
    public var selection: PaperCanvasSelection
    public var canvasSize: CGSize
    public var backgroundColor: Color

    public init(stickers: [PaperSticker] = [],
                canvasTransform: PaperCanvasTransform = .init(),
                selection: PaperCanvasSelection = .init(),
                backgroundColor: Color = .rpSurface,
                canvasSize: CGSize = PaperCanvasDefaults.baseSize) {
        self.stickers = stickers
        self.canvasTransform = canvasTransform
        self.selection = selection
        self.backgroundColor = backgroundColor
        self.canvasSize = canvasSize
    }

    public var highestZIndex: Double {
        stickers.map(\.zIndex).max() ?? 0
    }

    public var contentBounds: CGRect {
        let baseRect = CGRect(
            x: -canvasSize.width / 2,
            y: -canvasSize.height / 2,
            width: canvasSize.width,
            height: canvasSize.height
        )

        let stickerBounds = stickers.reduce(baseRect) { partial, sticker in
            let size = sticker.transform.currentSize
            let origin = CGPoint(
                x: sticker.transform.position.x - size.width / 2,
                y: sticker.transform.position.y - size.height / 2
            )
            let rect = CGRect(origin: origin, size: size)
            return partial.union(rect)
        }

        return stickerBounds
    }
}

// MARK: - Mock Fixtures

public extension PaperCanvasState {
    @MainActor
    static func mock() -> PaperCanvasState {
        let stickers: [PaperSticker] = [
            PaperSticker(
                kind: .text(PaperStickerTextContent(
                    text: "Welcome to the party!",
                    style: .title,
                    foregroundColor: .white,
                    backgroundColor: Color.rpAccent.opacity(0.8)
                )),
                transform: .init(
                    position: CGPoint(x: 40, y: -120),
                    baseSize: CGSize(width: 220, height: 100),
                    scale: 1,
                    rotation: .degrees(-4)
                ),
                zIndex: 1
            ),
            PaperSticker(
                kind: .photo(PaperStickerImageContent(
                    source: .asset(name: "SampleStickerConfetti"),
                    tint: nil,
                    allowsTiling: true
                )),
                transform: .init(
                    position: CGPoint(x: -120, y: 60),
                    baseSize: CGSize(width: 180, height: 180),
                    scale: 1.1,
                    rotation: .degrees(8)
                ),
                zIndex: 2
            ),
            PaperSticker(
                kind: .doodle(PaperStickerDoodleContent(
                    pathAssetName: "SampleHandDrawnHeart",
                    strokeColor: Color.rpPrimaryAlt,
                    lineWidth: 6
                )),
                transform: .init(
                    position: CGPoint(x: 160, y: 140),
                    baseSize: CGSize(width: 140, height: 120),
                    scale: 0.9,
                    rotation: .degrees(12)
                ),
                zIndex: 3,
                isLocked: true
            ),
            PaperSticker(
                kind: .text(PaperStickerTextContent(
                    text: "Remember to sign the card",
                    style: .body,
                    foregroundColor: .rpTextPrimary,
                    backgroundColor: Color.rpSurface
                )),
                transform: .init(
                    position: CGPoint(x: -40, y: -10),
                    baseSize: CGSize(width: 260, height: 120),
                    scale: 0.95,
                    rotation: .degrees(-2)
                ),
                zIndex: 4
            )
        ]

        return PaperCanvasState(
            stickers: stickers,
            canvasTransform: .init(scale: 1, offset: .zero, minimumScale: 0.2, maximumScale: 2.4),
            selection: .init(),
            backgroundColor: .red.opacity(0.35),
            canvasSize: PaperCanvasDefaults.baseSize
        )
    }
}

