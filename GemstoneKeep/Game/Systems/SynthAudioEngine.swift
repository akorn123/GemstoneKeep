import AVFoundation
import Foundation

/// Retro arcade SFX via procedural synthesis — bundle .caf files used when present.
final class SynthAudioEngine {
    static let shared = SynthAudioEngine()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    private var isPrepared = false

    private init() {}

    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()
    }

    func playBundle(_ name: String) -> Bool {
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf")
            ?? Bundle.main.url(forResource: name, withExtension: "wav") else {
            return false
        }
        guard let file = try? AVAudioFile(forReading: url) else { return false }
        prepare()
        player.scheduleFile(file, at: nil, completionHandler: nil)
        if !player.isPlaying { player.play() }
        return true
    }

    func play(_ preset: SFXPreset) {
        guard GameSettings.soundEnabled else { return }
        if playBundle(preset.bundleName) { return }
        prepare()
        let buffer = render(preset)
        player.scheduleBuffer(buffer, completionHandler: nil)
        if !player.isPlaying { player.play() }
    }

    enum SFXPreset {
        case gemPickup(chain: Int)
        case jump
        case death
        case levelClear
        case gameOver
        case helmGrab
        case enemyDestroy
        case menuTap
        case warp

        var bundleName: String {
            switch self {
            case .gemPickup: return "sfx_gem"
            case .jump: return "sfx_jump"
            case .death: return "sfx_death"
            case .levelClear: return "sfx_clear"
            case .gameOver: return "sfx_gameover"
            case .helmGrab: return "sfx_helm"
            case .enemyDestroy: return "sfx_zap"
            case .menuTap: return "sfx_menu"
            case .warp: return "sfx_warp"
            }
        }
    }

    private func render(_ preset: SFXPreset) -> AVAudioPCMBuffer {
        switch preset {
        case .gemPickup(let chain):
            let pitch = 880 + Float(min(chain, 6)) * 55
            return tone(frequency: pitch, duration: 0.07, volume: 0.22, wave: .square, decay: 0.92)
        case .jump:
            return sweep(start: 280, end: 620, duration: 0.1, volume: 0.18)
        case .death:
            return noiseBurst(duration: 0.28, volume: 0.2)
                .mixed(with: sweep(start: 420, end: 80, duration: 0.35, volume: 0.24))
        case .levelClear:
            return arpeggio(notes: [523, 659, 784, 1047], step: 0.09, volume: 0.16)
        case .gameOver:
            return arpeggio(notes: [392, 330, 262], step: 0.14, volume: 0.18)
        case .helmGrab:
            return arpeggio(notes: [440, 554, 659, 880], step: 0.07, volume: 0.2)
        case .enemyDestroy:
            return tone(frequency: 220, duration: 0.05, volume: 0.2, wave: .square, decay: 0.85)
                .mixed(with: tone(frequency: 110, duration: 0.08, volume: 0.15, wave: .triangle, decay: 0.9))
        case .menuTap:
            return tone(frequency: 520, duration: 0.04, volume: 0.12, wave: .triangle, decay: 0.8)
        case .warp:
            return sweep(start: 200, end: 1200, duration: 0.35, volume: 0.2)
        }
    }

    private enum Waveform { case sine, square, triangle, noise }

    private func tone(
        frequency: Float,
        duration: Float,
        volume: Float,
        wave: Waveform,
        decay: Float
    ) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(Double(duration) * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return buffer }

        let omega = 2 * Float.pi * frequency / Float(sampleRate)
        for i in 0..<Int(frameCount) {
            let t = Float(i)
            let env = pow(decay, t / Float(frameCount))
            let phase = omega * t
            let sample: Float
            switch wave {
            case .sine: sample = sin(phase)
            case .square: sample = sin(phase) >= 0 ? 1 : -1
            case .triangle: sample = 2 * abs(2 * (phase / (2 * .pi) - floor(phase / (2 * .pi) + 0.5))) - 1
            case .noise: sample = Float.random(in: -1...1)
            }
            samples[i] = sample * volume * env
        }
        return buffer
    }

    private func sweep(start: Float, end: Float, duration: Float, volume: Float) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(Double(duration) * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return buffer }

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(frameCount)
            let freq = start + (end - start) * t
            let omega = 2 * Float.pi * freq / Float(sampleRate)
            let env = 1 - t * 0.35
            samples[i] = sin(omega * Float(i)) * volume * env
        }
        return buffer
    }

    private func arpeggio(notes: [Float], step: Float, volume: Float) -> AVAudioPCMBuffer {
        let total = step * Float(notes.count)
        let frameCount = AVAudioFrameCount(Double(total) * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return buffer }

        for i in 0..<Int(frameCount) {
            samples[i] = 0
        }

        let stepFrames = Int(step * Float(sampleRate))
        for (index, note) in notes.enumerated() {
            let partial = tone(frequency: note, duration: step * 0.95, volume: volume, wave: .square, decay: 0.88)
            guard let partialSamples = partial.floatChannelData?[0] else { continue }
            let offset = index * stepFrames
            for i in 0..<min(stepFrames, Int(partial.frameLength)) where offset + i < Int(frameCount) {
                samples[offset + i] += partialSamples[i]
            }
        }
        return buffer
    }

    private func noiseBurst(duration: Float, volume: Float) -> AVAudioPCMBuffer {
        tone(frequency: 0, duration: duration, volume: volume, wave: .noise, decay: 0.95)
    }
}

private extension AVAudioPCMBuffer {
    func mixed(with other: AVAudioPCMBuffer) -> AVAudioPCMBuffer {
        let count = max(frameLength, other.frameLength)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buffer.frameLength = count
        guard let a = floatChannelData?[0], let b = other.floatChannelData?[0], let out = buffer.floatChannelData?[0] else {
            return self
        }
        for i in 0..<Int(count) {
            let av = i < Int(frameLength) ? a[i] : 0
            let bv = i < Int(other.frameLength) ? b[i] : 0
            out[i] = max(-1, min(1, av + bv))
        }
        return buffer
    }
}
