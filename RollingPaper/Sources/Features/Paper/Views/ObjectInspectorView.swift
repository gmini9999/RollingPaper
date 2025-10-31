import SwiftUI

struct ObjectInspectorView: View {
    @Environment(PaperCanvasStore.self) private var store
    let objectID: UUID
    
    @State private var textFontColor: Color = .primary
    @State private var textBackgroundColor: Color = Color(.systemBackground)
    @State private var textFontSize: CGFloat = 20
    @State private var shapeFillColor: Color = .blue
    @State private var shapeStrokeColor: Color = .blue
    @State private var shapeStrokeWidth: CGFloat = 2
    @State private var noteColor: Color = .yellow
    @State private var noteFontSize: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: .rpSpaceXXL) {
            if let object = store.objects.first(where: { $0.id == objectID }) {
                if let textObj = object as? TextObject {
                    textInspector(textObj)
                } else if let shapeObj = object as? ShapeObject {
                    shapeInspector(shapeObj)
                } else if let noteObj = object as? StickyNoteObject {
                    stickyNoteInspector(noteObj)
                } else {
                    Text("선택한 객체를 편집할 수 없습니다.")
                        .font(Typography.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.rpSpaceXXL)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerXL, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: ShadowTokens.large.color, radius: ShadowTokens.large.radius, y: ShadowTokens.large.y)
        .frame(minWidth: 260)
    }
    
    private func textInspector(_ object: TextObject) -> some View {
        VStack(alignment: .leading, spacing: .rpSpaceXL) {
            inspectorHeader(title: "텍스트 편집", systemImage: "text.alignleft")
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("글자 색상")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                ColorPicker("글자 색상", selection: $textFontColor)
                    .labelsHidden()
                    .onChange(of: textFontColor) { _, newColor in
                        updateTextObject(object, fontColor: newColor)
                    }
            }
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("배경 색상")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                ColorPicker("배경 색상", selection: $textBackgroundColor)
                    .labelsHidden()
                    .onChange(of: textBackgroundColor) { _, newColor in
                        updateTextObject(object, backgroundColor: newColor)
                    }
            }
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("글자 크기: \(Int(textFontSize))pt")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $textFontSize, in: 12...48, step: 1)
                    .onChange(of: textFontSize) { _, newSize in
                        updateTextObject(object, fontSize: newSize)
                    }
            }

            TextField("텍스트 내용", text: Binding(
                get: { object.text },
                set: { updateTextObject(object, text: $0) }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .onAppear {
            textFontColor = object.fontColor
            textBackgroundColor = object.backgroundColor
            textFontSize = object.fontSize
        }
    }
    
    private func shapeInspector(_ object: ShapeObject) -> some View {
        VStack(alignment: .leading, spacing: .rpSpaceXL) {
            inspectorHeader(title: "도형 편집", systemImage: "square.on.circle")
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("채우기 색상")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                ColorPicker("채우기 색상", selection: $shapeFillColor)
                    .labelsHidden()
                    .onChange(of: shapeFillColor) { _, newColor in
                        updateShapeObject(object, fillColor: newColor)
                    }
            }
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("선 색상")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                ColorPicker("선 색상", selection: $shapeStrokeColor)
                    .labelsHidden()
                    .onChange(of: shapeStrokeColor) { _, newColor in
                        updateShapeObject(object, strokeColor: newColor)
                    }
            }
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("선 두께: \(Int(shapeStrokeWidth))pt")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $shapeStrokeWidth, in: 1...12, step: 1)
                    .onChange(of: shapeStrokeWidth) { _, newWidth in
                        updateShapeObject(object, strokeWidth: newWidth)
                    }
            }
            
            TextField("도형 안의 텍스트", text: Binding(
                get: { object.text },
                set: { updateShapeObject(object, text: $0) }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .onAppear {
            shapeFillColor = object.fillColor
            shapeStrokeColor = object.strokeColor
            shapeStrokeWidth = object.strokeWidth
        }
    }
    
    private func stickyNoteInspector(_ object: StickyNoteObject) -> some View {
        VStack(alignment: .leading, spacing: .rpSpaceXL) {
            inspectorHeader(title: "스티커 메모 편집", systemImage: "note.text")
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("메모 색상")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                ColorPicker("메모 색상", selection: $noteColor)
                    .labelsHidden()
                    .onChange(of: noteColor) { _, newColor in
                        updateStickyNoteObject(object, noteColor: newColor)
                    }
            }
            
            VStack(alignment: .leading, spacing: .rpSpaceS) {
                Text("글자 크기: \(Int(noteFontSize))pt")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $noteFontSize, in: 12...32, step: 1)
                    .onChange(of: noteFontSize) { _, newSize in
                        updateStickyNoteObject(object, fontSize: newSize)
                    }
            }
        }
        .onAppear {
            noteColor = object.noteColor
            noteFontSize = object.fontSize
        }
    }
    
    private func inspectorHeader(title: LocalizedStringKey, systemImage: String) -> some View {
        HStack(spacing: .rpSpaceM) {
            Image(systemName: systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(Typography.body.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Text(title)
                .font(Typography.title3)
                .foregroundStyle(.primary)
        }
    }
    
    // MARK: - Update Helpers
    
    private func updateTextObject(_ object: TextObject,
                                  fontColor: Color? = nil,
                                  backgroundColor: Color? = nil,
                                  fontSize: CGFloat? = nil,
                                  text: String? = nil) {
        var textObj = object
        
        if let color = fontColor {
            textObj.fontColor = color
        }
        if let background = backgroundColor {
            textObj.backgroundColor = background
        }
        if let size = fontSize {
            textObj.fontSize = size
        }
        if let newText = text {
            textObj.text = newText
        }
        
        store.updateObject(object.id, with: textObj)
    }
    
    private func updateShapeObject(_ object: ShapeObject,
                                   fillColor: Color? = nil,
                                   strokeColor: Color? = nil,
                                   strokeWidth: CGFloat? = nil,
                                   text: String? = nil) {
        var shapeObj = object
        
        if let color = fillColor {
            shapeObj.fillColor = color
        }
        if let border = strokeColor {
            shapeObj.strokeColor = border
        }
        if let width = strokeWidth {
            shapeObj.strokeWidth = width
        }
        if let newText = text {
            shapeObj.text = newText
        }
        
        store.updateObject(object.id, with: shapeObj)
    }
    
    private func updateStickyNoteObject(_ object: StickyNoteObject, noteColor: Color? = nil, fontSize: CGFloat? = nil) {
        var noteObj = object
        
        if let color = noteColor {
            noteObj.noteColor = color
        }
        if let size = fontSize {
            noteObj.fontSize = size
        }
        
        store.updateObject(object.id, with: noteObj)
    }
}

