import SwiftUI
import PhotosUI

struct MediaPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPHPicker = false
    @State private var selectedImage: UIImage?
    @State private var mediaTitle: String = ""
    var onComplete: (PaperStickerKind) -> Void
    
    var body: some View {
        ZStack {
            Color.rpSurface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button("취소") { dismiss() }
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("미디어 추가")
                        .font(.headline)
                        .foregroundColor(.rpTextPrimary)
                    
                    Spacer()
                    
                    Button("완료") {
                        if selectedImage != nil {
                            let photoContent = PaperStickerImageContent(
                                source: .asset(name: "temp")
                            )
                            onComplete(.photo(photoContent))
                        }
                    }
                    .foregroundColor(.rpAccent)
                    .fontWeight(.semibold)
                    .disabled(selectedImage == nil)
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(12)
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Button("선택") {
                                    showPHPicker = true
                                }
                                .foregroundColor(.rpAccent)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            .padding()
                        }
                        
                        VStack(spacing: 4) {
                            Text("제목 (선택사항)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("", text: $mediaTitle)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showPHPicker) {
            PHPickerViewControllerWrapper(selectedImage: $selectedImage)
        }
    }
}
