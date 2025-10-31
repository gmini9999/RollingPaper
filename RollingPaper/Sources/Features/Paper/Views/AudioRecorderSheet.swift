import SwiftUI

struct AudioRecorderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let model: PaperEditorViewModel
    @State private var viewModel = AudioRecordingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .rpSpaceXXXL) {
                Spacer(minLength: .rpSpaceM)
                waveformView
                durationView
                recordingControls
                Spacer(minLength: .rpSpaceM)
            }
            .padding(.horizontal, .rpSpaceXXL)
            .padding(.vertical, .rpSpaceXL)
            .navigationTitle("음성 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        viewModel.resetRecording()
                        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
                        addVoiceObject()
                    }
                    .disabled(!viewModel.hasRecording)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var waveformView: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(height: 140)
            .overlay {
                Image(systemName: "waveform")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)
            }
            .cornerRadius(.rpCornerXL + 8)
            .shadow(color: ShadowTokens.medium.color, radius: ShadowTokens.medium.radius * 1.25, y: ShadowTokens.medium.y * 1.5)
    }
    
    private var durationView: some View {
        Text(formatTime(viewModel.recordingDuration))
            .font(.system(size: 48, weight: .light, design: .monospaced))
            .foregroundStyle(.primary)
    }
    
    private var recordingControls: some View {
        HStack(spacing: .rpSpaceXXXL) {
            if viewModel.hasRecording {
                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.resetRecording()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
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

        model.addVoiceObject(audioURL: audioURL, duration: viewModel.recordingDuration)
        dismiss()
    }
}

