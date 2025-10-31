import SwiftUI

struct AudioRecorderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var store: PaperCanvasStore
    @StateObject private var viewModel = AudioRecordingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer(minLength: 12)
                waveformView
                durationView
                recordingControls
                Spacer(minLength: 12)
            }
            .padding(.horizontal, SheetStyleGuide.Layout.horizontalPadding)
            .padding(.vertical, .rpSpaceXL)
            .navigationTitle("음성 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        viewModel.resetRecording()
                        SheetStyleGuide.Haptics.trigger(.cancel, reduceMotion: reduceMotion, feedbackCenter: feedbackCenter)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        SheetStyleGuide.Haptics.trigger(.confirm, reduceMotion: reduceMotion, feedbackCenter: feedbackCenter)
                        addVoiceObject()
                    }
                    .disabled(!viewModel.hasRecording)
                }
            }
        }
        .rpNavigationChrome()
        .rpBackground()
        .sheetChrome()
    }
    
    private var waveformView: some View {
        WaveformView(samples: viewModel.levelSamples, color: .accentColor)
            .frame(height: 140)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 6)
            )
    }
    
    private var durationView: some View {
        Text(formatTime(viewModel.recordingDuration))
            .font(.system(size: 48, weight: .light, design: .monospaced))
            .foregroundStyle(.primary)
    }
    
    private var recordingControls: some View {
        HStack(spacing: 32) {
            if viewModel.hasRecording {
                // Play/Pause button
                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                // Delete button
                Button {
                    viewModel.resetRecording()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
                // Record button
                Button {
                    viewModel.toggleRecording()
                } label: {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red : Color.accentColor)
                            .frame(width: 80, height: 80)
                        
                        if viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.isRecording)
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private func addVoiceObject() {
        guard let audioURL = viewModel.recordedAudioURL else { return }
        
        let defaultSize = CGSize(width: 100, height: 100)
        let transform = ObjectTransform(
            position: .zero,
            scale: 1.0,
            rotation: .zero,
            size: defaultSize
        )
        
        let voiceObject = VoiceObject(
            transform: transform,
            zIndex: Double(store.objects.count),
            audioURL: audioURL,
            duration: viewModel.recordingDuration
        )
        
        store.addObject(voiceObject)
        dismiss()
    }
}

