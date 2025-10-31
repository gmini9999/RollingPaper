import SwiftUI

struct CustomObjectsOverlay: View {
    let objects: [any CanvasObject]
    @Environment(PaperCanvasStore.self) private var store
    @Environment(GestureCoordinationManager.self) private var gestureManager
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ForEach(objects, id: \.id) { object in
                renderCustomObject(object, center: center)
            }
        }
    }
    
    @ViewBuilder
    private func renderCustomObject(_ object: any CanvasObject, center: CGPoint) -> some View {
        let isSelected = store.selectedObjectIDs.contains(object.id)
        
        Group {
            if let stickyNote = object as? StickyNoteObject {
                StickyNoteObjectView(object: stickyNote, isSelected: isSelected)
            } else if let sticker = object as? StickerObject {
                StickerObjectView(object: sticker, isSelected: isSelected)
            } else if let voice = object as? VoiceObject {
                VoiceObjectView(object: voice, isSelected: isSelected)
            } else if let image = object as? ImageObject {
                ImageObjectView(object: image, isSelected: isSelected)
            }
        }
        .frame(width: object.transform.size.width * object.transform.scale,
               height: object.transform.size.height * object.transform.scale)
        .rotationEffect(object.transform.rotation)
        .position(x: center.x + object.transform.position.x,
                 y: center.y + object.transform.position.y)
        .contentShape(Rectangle())
        .gesture(
            TapGesture()
                .onEnded { _ in
                    store.selectObject(object.id)
                    gestureManager.enterEditMode(for: object.id)
                }
        )
        .gesture(
            DragGesture()
                .onEnded { value in
                    guard gestureManager.canEditSticker(object.id) else { return }
                    var newTransform = object.transform
                    newTransform.position = CGPoint(
                        x: object.transform.position.x + value.translation.width,
                        y: object.transform.position.y + value.translation.height
                    )
                    store.updateTransform(for: object.id, newTransform)
                    gestureManager.exitEditMode()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onEnded { value in
                    guard gestureManager.canEditSticker(object.id) else { return }
                    var newTransform = object.transform
                    newTransform.scale = max(object.transform.scale * value, 0.1)
                    store.updateTransform(for: object.id, newTransform)
                }
        )
        .simultaneousGesture(
            RotationGesture()
                .onEnded { value in
                    guard gestureManager.canEditSticker(object.id) else { return }
                    var newTransform = object.transform
                    newTransform.rotation = object.transform.rotation + value
                    store.updateTransform(for: object.id, newTransform)
                }
        )
        .overlay(selectionOverlay(isSelected: isSelected))
    }

    @ViewBuilder
    private func selectionOverlay(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: .rpCornerXXL + 12, style: .continuous)
                .stroke(Color.accentColor, lineWidth: 2.5)
                .shadow(color: Color.accentColor.opacity(OpacityTokens.medium), radius: .rpSpaceM, y: 6)
                .padding(-10)
                .allowsHitTesting(false)
        }
    }
}

// Helper view for ImageObject
struct ImageObjectView: View {
    let object: ImageObject
    let isSelected: Bool
    
    var body: some View {
        Group {
            if let uiImage = UIImage(data: object.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
        .cornerRadius(object.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: object.cornerRadius)
                .stroke(Color.accentColor, lineWidth: isSelected ? 3 : 0)
        )
    }
}

