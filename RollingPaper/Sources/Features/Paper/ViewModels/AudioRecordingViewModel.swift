import Foundation
import Combine
import AVFoundation

@MainActor
class AudioRecordingViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioTitle: String = ""
    @Published var recordedAudioURL: URL?
    @Published var isPlaying = false
    @Published var levelSamples: [CGFloat] = Array(repeating: 0, count: 40)
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private let maxSamples = 40
    
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
            RPLogger.error(L10n.Error.Audio.sessionSetup(error.localizedDescription), error: error, category: .audio)
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
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            recordedAudioURL = fileURL
            levelSamples = Array(repeating: 0, count: maxSamples)
            startDisplayLink()
        } catch {
            RPLogger.error(L10n.Error.Audio.recordingStart(error.localizedDescription), error: error, category: .audio)
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopDisplayLink()
        refreshLevelSamples(decay: true)
    }

    func resetRecording() {
        if isRecording {
            stopRecording()
        }
        recordingDuration = 0
        recordedAudioURL = nil
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
        levelSamples = Array(repeating: 0, count: maxSamples)
    }

    var hasRecording: Bool {
        recordedAudioURL != nil
    }

    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
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
            audioRecorder?.updateMeters()
            let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
            let normalized = normalizedPowerLevel(power)
            appendSample(normalized)
        }
    }

    private func startPlayback() {
        guard let url = recordedAudioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            RPLogger.error(L10n.Error.Audio.playback(error.localizedDescription), error: error, category: .audio)
            isPlaying = false
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        audioPlayer = nil
    }

    private func appendSample(_ level: CGFloat) {
        levelSamples.append(level)
        if levelSamples.count > maxSamples {
            levelSamples.removeFirst(levelSamples.count - maxSamples)
        }
    }

    private func refreshLevelSamples(decay: Bool) {
        if decay {
            levelSamples = levelSamples.map { max($0 * 0.6, 0.02) }
        } else {
            levelSamples = Array(repeating: 0, count: maxSamples)
        }
    }

    private func normalizedPowerLevel(_ decibels: Float) -> CGFloat {
        if decibels.isInfinite || decibels.isNaN { return 0 }
        let minDb: Float = -80
        let clamped = max(decibels, minDb)
        return CGFloat((clamped - minDb) / -minDb)
    }
}
