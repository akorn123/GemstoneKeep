import AVFoundation
import Foundation

/// Game audio — procedural synth with optional bundled .caf / .m4a overrides.
enum AudioManager {
    static func prepare() {
        SynthAudioEngine.shared.prepare()
        MusicManager.shared.prepare()
    }

    static func playGemPickup(chain: Int) {
        SynthAudioEngine.shared.play(.gemPickup(chain: chain))
    }

    static func playLevelClear() {
        SynthAudioEngine.shared.play(.levelClear)
    }

    static func playJump() {
        SynthAudioEngine.shared.play(.jump)
    }

    static func playDeath() {
        SynthAudioEngine.shared.play(.death)
    }

    static func playGameOver() {
        SynthAudioEngine.shared.play(.gameOver)
    }

    static func playHelmGrab() {
        SynthAudioEngine.shared.play(.helmGrab)
    }

    static func playEnemyDestroy() {
        SynthAudioEngine.shared.play(.enemyDestroy)
    }

    static func playMenuTap() {
        SynthAudioEngine.shared.play(.menuTap)
    }

    static func playWarp() {
        SynthAudioEngine.shared.play(.warp)
    }
}
