import SwiftUI

struct StickyNoteObjectView: View {
    let object: StickyNoteObject
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 스티커 메모 배경 with gradient for depth
            LinearGradient(
                gradient: Gradient(colors: [
                    object.noteColor,
                    object.noteColor.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 텍스트 내용
            Text(object.text.isEmpty ? "메모를 입력하세요" : object.text)
                .font(.custom(object.fontName, size: object.fontSize))
                .foregroundColor(object.text.isEmpty ? .gray.opacity(0.6) : .black)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
        }
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(isSelected ? 0.25 : 0.15), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
        .overlay(selectionBorder)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    @ViewBuilder
    private var selectionBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8)
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

