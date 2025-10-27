import SwiftUI
import UIKit

struct PaperStickerView: View {
    let sticker: PaperSticker
    let size: CGSize
    var isSelected: Bool = false
    var isEditing: Bool = false

    var body: some View {
        content
            .frame(width: size.width, height: size.height)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(selectionOverlay)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.15), value: isEditing)
    }

    private var content: some View {
        Group {
            switch sticker.kind {
            case .text(let content):
                textSticker(content)
            case .photo(let content):
                photoSticker(content)
            case .doodle(let content):
                doodleSticker(content)
            }
        }
    }

    private var cornerRadius: CGFloat {
        switch sticker.kind {
        case .text:
            return 24
        case .photo:
            return 32
        case .doodle:
            return 0
        }
    }

    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected || isEditing {
            let strokeColor: Color = isEditing ? Color.rpAccent : Color.rpPrimary.opacity(0.7)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(strokeColor, style: StrokeStyle(lineWidth: isEditing ? 4 : 2, dash: isEditing ? [10, 6] : []))
                .padding(isEditing ? -6 : -4)
                .shadow(color: strokeColor.opacity(0.12), radius: isEditing ? 10 : 6, x: 0, y: 4)
        }
    }

    private func textSticker(_ content: PaperStickerTextContent) -> some View {
        Text(content.text)
            .font(font(for: content.style))
            .foregroundStyle(content.foregroundColor)
            .multilineTextAlignment(.center)
            .padding(.vertical, 18)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(content.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }

    private func photoSticker(_ content: PaperStickerImageContent) -> some View {
        let image = makeImage(for: content)
        return Group {
            if let image {
                image
                    .renderingMode(content.tint == nil ? .original : .template)
                    .resizable(resizingMode: content.allowsTiling ? .tile : .stretch)
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(content.tint ?? .primary)
                    .background(Color.rpSurface)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
            } else {
                fallbackPhotoPlaceholder
            }
        }
    }

    private func doodleSticker(_ content: PaperStickerDoodleContent) -> some View {
        Group {
            if let image = UIImage(named: content.pathAssetName) {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(content.strokeColor)
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(content.strokeColor, lineWidth: content.lineWidth)
                    .background(Color.clear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
    }

    private func font(for style: PaperStickerTextContent.Style) -> Font {
        switch style {
        case .title:
            return .rpHeadingL
        case .subtitle:
            return .rpHeadingM
        case .body:
            return .rpBodyM
        case .caption:
            return .rpCaption
        }
    }

    private func makeImage(for content: PaperStickerImageContent) -> Image? {
        switch content.source {
        case .asset(let name):
            if let uiImage = UIImage(named: name) {
                return Image(uiImage: uiImage)
            }
            return nil
        case .system(let name):
            return Image(systemName: name)
        }
    }

    private var fallbackPhotoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.rpSurface, Color.rpSurfaceAlt],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "photo")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.rpPrimary.opacity(0.6))
        }
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 10)
    }
}
