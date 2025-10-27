import SwiftUI
import PencilKit

struct PKCanvasViewRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var strokeColor: UIColor = .black
    var lineWidth: CGFloat = 4
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        
        canvas.tool = PKInkingTool(.pen, color: strokeColor, width: lineWidth)
        canvas.backgroundColor = .black
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        uiView.tool = PKInkingTool(.pen, color: strokeColor, width: lineWidth)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        
        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            _drawing.wrappedValue = canvasView.drawing
        }
    }
}
