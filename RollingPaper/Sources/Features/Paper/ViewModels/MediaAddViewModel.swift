import SwiftUI
import Combine
import AVFoundation
import PencilKit

/// Media input completion handler that returns a PaperStickerKind
typealias MediaInputCompletion = (PaperStickerKind) -> Void

/// View model for managing media input sheets and state
@MainActor
class MediaAddViewModel: NSObject, ObservableObject {
    
    // MARK: - Published State
    
    @Published var isSheetPresented = false
    @Published var selectedMediaType: MediaType? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Media-specific state
    @Published var textInput: String = ""
    @Published var textStyle: PaperStickerTextContent.Style = .body
    @Published var textForegroundColor: Color = .rpTextPrimary
    @Published var textBackgroundColor: Color = .rpSurfaceAlt
    
    @Published var pkDrawing: PKDrawing = PKDrawing()
    @Published var drawingStrokeColor: Color = .rpAccent
    @Published var drawingLineWidth: CGFloat = 4
    
    @Published var selectedPhotoURL: URL? = nil
    @Published var photoFrameStyle: PhotoFrameStyle = .border
    
    @Published var recordingDuration: TimeInterval = 0
    @Published var isRecording = false
    @Published var recordedAudioURL: URL? = nil
    @Published var audioTitle: String = ""
    
    @Published var selectedVideoURL: URL? = nil
    @Published var videoDuration: TimeInterval = 0
    @Published var videoTitle: String = ""
    
    // MARK: - Nested Types
    
    enum MediaType: String, CaseIterable {
        case text = "Text"
        case drawing = "Drawing"
        case photo = "Photo"
        case audio = "Audio"
        case video = "Video"
        
        var systemImage: String {
            switch self {
            case .text:
                return "text.alignleft"
            case .drawing:
                return "pencil.circle"
            case .photo:
                return "photo"
            case .audio:
                return "waveform.circle"
            case .video:
                return "video"
            }
        }
    }
    
    enum PhotoFrameStyle: String, CaseIterable {
        case border = "Border"
        case shadow = "Shadow"
        case frame = "Frame"
        case polaroid = "Polaroid"
    }
    
    // MARK: - Properties
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var recordingStartTime: Date?
    
    var completion: MediaInputCompletion?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Sheet Management
    
    func showSheet() {
        isSheetPresented = true
    }
    
    func hideSheet() {
        isSheetPresented = false
        clearMediaState()
    }
    
    func selectMediaType(_ type: MediaType) {
        selectedMediaType = type
    }
    
    // MARK: - Text Input
    
    func resetTextInput() {
        textInput = ""
        textStyle = .body
        textForegroundColor = .rpTextPrimary
        textBackgroundColor = .rpSurfaceAlt
    }
    
    func confirmTextSticker() {
        guard !textInput.isEmpty else {
            errorMessage = "텍스트를 입력하세요."
            return
        }
        
        let content = PaperStickerTextContent(
            text: textInput,
            style: textStyle,
            foregroundColor: textForegroundColor,
            backgroundColor: textBackgroundColor
        )
        completion?(.text(content))
        hideSheet()
    }
    
    // MARK: - Drawing Input
    
    func resetDrawing() {
        pkDrawing = PKDrawing()
        drawingStrokeColor = .rpAccent
        drawingLineWidth = 4
    }
    
    func confirmDrawingSticker() {
        let content = PaperStickerDoodleContent.fromPencilKitDrawing(
            pkDrawing,
            strokeColor: drawingStrokeColor,
            lineWidth: drawingLineWidth
        )
        completion?(.doodle(content))
        hideSheet()
    }
    
    // MARK: - Audio Recording
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            errorMessage = "오디오 세션 설정 실패: \(error.localizedDescription)"
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = "recording_\(UUID().uuidString).m4a"
        let audioFileURL = documentsPath.appendingPathComponent(audioFileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingStartTime = Date()
            startRecordingTimer()
        } catch {
            errorMessage = "녹음 시작 실패: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        displayLink?.invalidate()
        displayLink = nil
        
        if let url = audioRecorder?.url {
            recordedAudioURL = url
        }
    }
    
    private func startRecordingTimer() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateRecordingDuration)
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateRecordingDuration() {
        if let startTime = recordingStartTime {
            recordingDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    func confirmAudioSticker() {
        guard let audioURL = recordedAudioURL else {
            errorMessage = "오디오 파일이 없습니다."
            return
        }
        
        let content = PaperStickerVoiceContent(
            audioURL: audioURL,
            duration: recordingDuration,
            title: audioTitle.isEmpty ? nil : audioTitle
        )
        completion?(.voice(content))
        hideSheet()
    }
    
    // MARK: - Helper Methods
    
    private func clearMediaState() {
        resetTextInput()
        resetDrawing()
        selectedPhotoURL = nil
        recordedAudioURL = nil
        selectedVideoURL = nil
        recordingDuration = 0
        isRecording = false
        errorMessage = nil
    }
}

// MARK: - AVAudioRecorderDelegate

extension MediaAddViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // The implementation will be called on MainActor through the wrapper
    }
}
