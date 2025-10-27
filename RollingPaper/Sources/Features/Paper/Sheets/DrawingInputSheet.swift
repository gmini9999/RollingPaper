import SwiftUI
import PencilKit

struct DrawingInputSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var drawing = PKDrawing()
    @State private var selectedColor: UIColor = .black
    @State private var lineWidth: CGFloat = 4
    var onComplete: (PaperStickerKind) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                PKCanvasViewRepresentable(
                    drawing: $drawing,
                    strokeColor: selectedColor,
                    lineWidth: lineWidth
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack(spacing: 16) {
                        ForEach([UIColor.black, UIColor.red, UIColor.blue, UIColor.green], id: \.self) { color in
                            Circle()
                                .fill(Color(uiColor: color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    selectedColor == color ?
                                        Circle().stroke(Color.white, lineWidth: 3) : nil
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Slider(value: $lineWidth, in: 1...20)
                                .frame(width: 80)
                                .accentColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            drawing = PKDrawing()
                        }) {
                            Image(systemName: "eraser.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            let doodleContent = PaperStickerDoodleContent(
                                drawingData: drawing.dataRepresentation(),
                                opacity: 1.0
                            )
                            onComplete(.doodle(doodleContent))
                        }) {
                            Text("완료")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemBackground))
                            .opacity(0.95)
                    )
                    .padding(16)
                }
            }
        }
    }
}
