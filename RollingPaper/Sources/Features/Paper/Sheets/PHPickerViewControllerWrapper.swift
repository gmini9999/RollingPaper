import SwiftUI
import PhotosUI

struct PHPickerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var selectedImage: UIImage?
        let dismiss: DismissAction
        
        init(selectedImage: Binding<UIImage?>, dismiss: DismissAction) {
            _selectedImage = selectedImage
            self.dismiss = dismiss
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                dismiss()
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.selectedImage = image
                        self.dismiss()
                    }
                }
            }
        }
    }
}
