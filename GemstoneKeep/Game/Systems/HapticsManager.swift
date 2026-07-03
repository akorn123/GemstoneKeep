import UIKit

enum HapticsManager {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let selection = UISelectionFeedbackGenerator()

    static func prepare() {
        light.prepare()
        medium.prepare()
        heavy.prepare()
        selection.prepare()
    }

    static func jump() {
        guard GameSettings.hapticsEnabled else { return }
        light.impactOccurred()
    }

    static func turn() {
        guard GameSettings.hapticsEnabled else { return }
        light.impactOccurred(intensity: 0.45)
    }

    static func gemPickup() {
        guard GameSettings.hapticsEnabled else { return }
        light.impactOccurred(intensity: 0.7)
    }

    static func levelClear() {
        guard GameSettings.hapticsEnabled else { return }
        medium.impactOccurred()
    }

    static func death() {
        guard GameSettings.hapticsEnabled else { return }
        heavy.impactOccurred()
    }

    static func gameOver() {
        guard GameSettings.hapticsEnabled else { return }
        heavy.impactOccurred(intensity: 1.0)
    }

    static func extraLife() {
        guard GameSettings.hapticsEnabled else { return }
        medium.impactOccurred(intensity: 0.8)
    }

    static func helmGrab() {
        guard GameSettings.hapticsEnabled else { return }
        medium.impactOccurred(intensity: 0.9)
    }

    static func menuTap() {
        guard GameSettings.hapticsEnabled else { return }
        selection.selectionChanged()
    }

    static func warp() {
        guard GameSettings.hapticsEnabled else { return }
        medium.impactOccurred(intensity: 0.95)
    }
}
