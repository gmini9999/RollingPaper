import SwiftUI

struct TextInputSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @State private var isDirty: Bool = false
    @FocusState private var isFocused: Bool
    var onComplete: (PaperStickerKind) -> Void
    
    var body: some View {
        ZStack {
            Color.rpSurface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.rpTextSecondary)
                    
                    Spacer()
                    
                    Text("텍스트 추가")
                        .font(.headline)
                        .foregroundColor(.rpTextPrimary)
                    
                    Spacer()
                    
                    Button("완료") {
                        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let textContent = PaperStickerTextContent(
                            text: text,
                            style: .body,
                            foregroundColor: .rpTextPrimary,
                            backgroundColor: .rpSurfaceAlt
                        )
                        onComplete(.text(textContent))
                    }
                    .disabled(!isDirty)
                    .fontWeight(.semibold)
                    .foregroundColor(isDirty ? .rpAccent : .gray)
                }
                .padding()
                
                Divider()
                
                // 텍스트 에디터
                TextEditor(text: $text)
                    .font(.body)
                    .foregroundColor(.rpTextPrimary)
                    .padding()
                    .focused($isFocused)
                    .onChange(of: text) { isDirty = true }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}
