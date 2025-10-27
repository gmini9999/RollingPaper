import SwiftUI

struct AudioRecordingSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AudioRecordingViewModel()
    var onComplete: (PaperStickerKind) -> Void
    
    var timeString: String {
        let minutes = Int(viewModel.recordingDuration) / 60
        let seconds = Int(viewModel.recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.isRecording)
                
                Text(viewModel.isRecording ? "녹음 중..." : "준비 완료")
                    .font(.headline)
                    .foregroundColor(.rpTextPrimary)
                
                Text(timeString)
                    .font(.title2)
                    .monospacedDigit()
                    .foregroundColor(.rpTextSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 32) {
                Button(action: { viewModel.stopRecording() }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                Button(action: { viewModel.toggleRecording() }) {
                    Image(systemName: viewModel.isRecording ? "pause.circle.fill" : "record.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                }
            }
            
            Divider()
                .padding(.horizontal)
            
            TextField("제목 (선택사항)", text: $viewModel.audioTitle)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            if viewModel.recordedAudioURL != nil {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundColor(.rpAccent)
                    Text(timeString)
                    Button(action: { }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.rpAccent)
                    }
                    Spacer()
                    Button("재녹음") {
                        viewModel.recordingDuration = 0
                        viewModel.recordedAudioURL = nil
                        viewModel.isRecording = false
                    }
                    .foregroundColor(.rpAccent)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack {
                Button("취소") { dismiss() }
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("재녹음") {
                    viewModel.recordingDuration = 0
                    viewModel.recordedAudioURL = nil
                    viewModel.isRecording = false
                }
                .foregroundColor(.rpAccent)
                
                Button("완료") {
                    if let url = viewModel.recordedAudioURL {
                        let audioContent = PaperStickerVoiceContent(
                            audioURL: url,
                            duration: viewModel.recordingDuration,
                            title: viewModel.audioTitle.isEmpty ? nil : viewModel.audioTitle
                        )
                        onComplete(.voice(audioContent))
                    }
                }
                .foregroundColor(.rpAccent)
                .fontWeight(.semibold)
                .disabled(viewModel.recordedAudioURL == nil)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.rpSurface.ignoresSafeArea())
    }
}
