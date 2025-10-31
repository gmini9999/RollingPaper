import SwiftUI

struct StickyNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    var store: PaperCanvasStore
    
    @State private var noteText: String = ""
    @State private var noteColor: Color = .yellow
    @FocusState private var isTextFieldFocused: Bool
    
    private let availableColors: [Color] = [
        .yellow,
        Color(red: 1.0, green: 0.9, blue: 0.7),
        Color(red: 0.7, green: 1.0, blue: 0.9),
        Color(red: 1.0, green: 0.8, blue: 0.9),
        Color(red: 0.9, green: 0.9, blue: 1.0),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .rpSpaceXXXL - 4) {
                    previewSection
                    textEditorSection
                    colorPickerSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, .rpSpaceXL)
                .padding(.horizontal, .rpSpaceXXL)
            }
            .navigationTitle("스티커 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addStickyNote()
                    }
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            Text("미리보기")
                .font(Typography.caption)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                noteColor
                    .clipShape(RoundedRectangle(cornerRadius: .rpCornerL, style: .continuous))
                    .shadow(color: ShadowTokens.medium.color, radius: ShadowTokens.medium.radius, y: ShadowTokens.medium.y)
                
                Text(noteText.isEmpty ? "메모를 입력하세요" : noteText)
                    .font(.system(size: 16))
                    .foregroundColor(noteText.isEmpty ? .gray : .black)
                    .padding(.rpSpaceL)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: 140)
        }
    }
    
    private var textEditorSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            Text("메모 내용")
                .font(Typography.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $noteText)
                .frame(height: 160)
                .padding(.rpSpaceM)
                .background(
                    RoundedRectangle(cornerRadius: .rpCornerXL + 2, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: ShadowTokens.small.color, radius: ShadowTokens.small.radius, y: ShadowTokens.small.y)
                )
                .focused($isTextFieldFocused)
        }
    }
    
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            Text("색상")
                .font(Typography.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: .rpSpaceM) {
                ForEach(availableColors, id: \.self) { color in
                    colorSwatch(color: color)
                }
            }
        }
    }
    
    private func colorSwatch(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 48, height: 48)
            .shadow(color: ShadowTokens.small.color, radius: ShadowTokens.small.radius, y: ShadowTokens.small.y)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: color == noteColor ? 3 : 1)
            )
            .overlay(
                Group {
                    if color == noteColor {
                        Image(systemName: "checkmark")
                            .foregroundColor(.primary)
                            .font(Typography.body.weight(.semibold))
                    }
                }
            )
            .onTapGesture {
                noteColor = color
            }
    }
    
    private func addStickyNote() {
        let defaultSize = CGSize(width: 200, height: 150)
        let transform = ObjectTransform(
            position: .zero,
            scale: 1.0,
            rotation: .zero,
            size: defaultSize
        )
        
        let stickyNote = StickyNoteObject(
            transform: transform,
            zIndex: Double(store.objects.count),
            text: noteText,
            noteColor: noteColor,
            fontName: "SF Pro",
            fontSize: 16
        )
        
        store.addObject(stickyNote)
        dismiss()
    }
}

