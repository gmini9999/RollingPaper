import SwiftUI

struct StickyNoteObjectView: View {
    let object: StickyNoteObject
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                gradient: Gradient(colors: [
                    object.noteColor,
                    object.noteColor.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Text(object.text.isEmpty ? "메모를 입력하세요" : object.text)
                .font(.custom(object.fontName, size: object.fontSize))
                .foregroundColor(object.text.isEmpty ? .gray.opacity(0.6) : .black)
                .padding(.rpSpaceM)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
        }
        .cornerRadius(.rpCornerS)
        .shadow(color: ShadowTokens.small.color.opacity(isSelected ? 2.0 : 1.0), 
                radius: isSelected ? ShadowTokens.small.radius * 2 : ShadowTokens.small.radius,
                x: 0,
                y: isSelected ? ShadowTokens.small.y * 2 : ShadowTokens.small.y)
        .overlay(selectionBorder)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    @ViewBuilder
    private var selectionBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: .rpCornerS)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        }
    }
}

