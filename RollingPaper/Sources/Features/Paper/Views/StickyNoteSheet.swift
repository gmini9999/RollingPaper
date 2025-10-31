import SwiftUI

struct StickyNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PaperCanvasStore
    
    @State private var noteText: String = ""
    @State private var noteColor: Color = .yellow
    @FocusState private var isTextFieldFocused: Bool
    
    private let availableColors: [Color] = [
        .yellow,
        Color(red: 1.0, green: 0.9, blue: 0.7), // Peach
        Color(red: 0.7, green: 1.0, blue: 0.9), // Mint
        Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
        Color(red: 0.9, green: 0.9, blue: 1.0), // Lavender
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SheetStyleGuide.Layout.sectionSpacing) {
                    previewSection
                    textEditorSection
                    colorPickerSection
                }
                .frame(maxWidth: SheetStyleGuide.Layout.maxContentWidth, alignment: .leading)
                .padding(.vertical, .rpSpaceXL)
                .padding(.horizontal, SheetStyleGuide.Layout.horizontalPadding)
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
        .rpNavigationChrome()
        .rpBackground()
        .sheetChrome()
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("미리보기")
                .font(.rpCaption)
                .foregroundColor(Color.rpTextSecondary)
            
            ZStack(alignment: .topLeading) {
                noteColor
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                
                Text(noteText.isEmpty ? "메모를 입력하세요" : noteText)
                    .font(.system(size: 16))
                    .foregroundColor(noteText.isEmpty ? .gray : .black)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: 140)
        }
    }
    
    private var textEditorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메모 내용")
                .font(.rpCaption)
                .foregroundColor(Color.rpTextSecondary)
            
            TextEditor(text: $noteText)
                .frame(height: 160)
                .padding(.rpSpaceM)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                )
                .focused($isTextFieldFocused)
        }
    }
    
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("색상")
                .font(.rpCaption)
                .foregroundColor(Color.rpTextSecondary)
            
            HStack(spacing: 12) {
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
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: color == noteColor ? 3 : 1)
            )
            .overlay(
                Group {
                    if color == noteColor {
                        Image(systemName: "checkmark")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
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

