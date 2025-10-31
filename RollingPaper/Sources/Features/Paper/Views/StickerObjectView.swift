import SwiftUI

struct StickerObjectView: View {
    let object: StickerObject
    let isSelected: Bool
    
    var body: some View {
        Group {
            if let uiImage = UIImage(data: object.stickerData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "face.smiling")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: .rpCornerS)
                .stroke(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: isSelected ? 3 : 0
                )
        )
        .shadow(color: ShadowTokens.small.color.opacity(isSelected ? 1.5 : 1.0),
                radius: isSelected ? ShadowTokens.small.radius * 2 : ShadowTokens.small.radius,
                y: isSelected ? ShadowTokens.small.y * 2 : ShadowTokens.small.y)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
