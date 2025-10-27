import Foundation
import Combine
import AVFoundation

@MainActor
class AudioRecordingViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioTitle: String = ""
    @Published var recordedAudioURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("오디오 세션 설정 오류: \(error)")
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "recording_\(Date().timeIntervalSince1970).m4a"
        let fileURL = tempDir.appendingPathComponent(filename)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            recordedAudioURL = fileURL
            startDisplayLink()
        } catch {
            print("녹음 시작 오류: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopDisplayLink()
    }
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateDuration)
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateDuration() {
        if isRecording {
            recordingDuration += (displayLink?.duration ?? 0.016)
        }
    }
}
