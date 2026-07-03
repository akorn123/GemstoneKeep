import AVFoundation
import Foundation

/// Lo-fi procedural background music — bundle `music_title` / `music_game` override when present.
final class MusicManager {
    static let shared = MusicManager()

    enum Track {
        case title
        case gameplay
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

    private var currentTrack: Track?
    private var isPrepared = false
    private var loopTimer: Timer?

    private init() {}

    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.35
        try? engine.start()
    }

    func play(_ track: Track) {
        guard GameSettings.musicEnabled else {
            stop()
            return
        }
        guard currentTrack != track else { return }
        stop()
        currentTrack = track

        let bundleName = track == .title ? "music_title" : "music_game"
        if playBundleLoop(bundleName) { return }

        prepare()
        scheduleProceduralLoop(track: track)
    }

    func stop() {
        loopTimer?.invalidate()
        loopTimer = nil
        player.stop()
        currentTrack = nil
    }

    func refresh() {
        if let track = currentTrack {
            let was = track
            currentTrack = nil
            play(was)
        } else if GameSettings.musicEnabled == false {
            stop()
        }
    }

    private func playBundleLoop(_ name: String) -> Bool {
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf")
            ?? Bundle.main.url(forResource: name, withExtension: "m4a") else {
            return false
        }
        guard let file = try? AVAudioFile(forReading: url) else { return false }
        prepare()
        player.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async { self?.playBundleLoop(name) }
        }
        if !player.isPlaying { player.play() }
        return true
    }

    private func scheduleProceduralLoop(track: Track) {
        let buffer = track == .title ? renderTitleLoop() : renderGameplayLoop()
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        if !player.isPlaying { player.play() }
    }

    private func renderTitleLoop() -> AVAudioPCMBuffer {
        // Am C F G arpeggio — calm castle theme
        let pattern: [Float] = [220, 262, 330, 392, 330, 262]
        return renderPattern(pattern, bpm: 72, noteLength: 0.22, volume: 0.12, wave: .triangle)
    }

    private func renderGameplayLoop() -> AVAudioPCMBuffer {
        // Faster minor pulse for tension
        let pattern: [Float] = [196, 233, 294, 233, 262, 196]
        return renderPattern(pattern, bpm: 108, noteLength: 0.14, volume: 0.1, wave: .square)
    }

    private func renderPattern(
        _ notes: [Float],
        bpm: Float,
        noteLength: Float,
        volume: Float,
        wave: SynthWave
    ) -> AVAudioPCMBuffer {
        let beat = 60 / bpm
        let step = beat * noteLength * 4
        let loopFrames = AVAudioFrameCount(Double(step * Float(notes.count)) * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: loopFrames)!
        buffer.frameLength = loopFrames
        guard let samples = buffer.floatChannelData?[0] else { return buffer }

        for i in 0..<Int(loopFrames) { samples[i] = 0 }

        let stepFrames = Int(step * Float(sampleRate))
        for (index, freq) in notes.enumerated() {
            let noteFrames = Int(step * 0.85 * Float(sampleRate))
            let offset = index * stepFrames
            let omega = 2 * Float.pi * freq / Float(sampleRate)
            for i in 0..<noteFrames where offset + i < Int(loopFrames) {
                let t = Float(i)
                let env = pow(0.92, t / Float(noteFrames))
                let phase = omega * t
                let sample: Float
                switch wave {
                case .triangle:
                    sample = 2 * abs(2 * (phase / (2 * .pi) - floor(phase / (2 * .pi) + 0.5))) - 1
                case .square:
                    sample = sin(phase) >= 0 ? 1 : -1
                }
                samples[offset + i] += sample * volume * env
            }
        }
        return buffer
    }

    private enum SynthWave { case triangle, square }
}
