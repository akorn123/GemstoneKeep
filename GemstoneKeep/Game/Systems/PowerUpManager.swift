import Foundation

/// Magic helm — ~8s invincibility and enemy destruction with escalating points.
final class PowerUpManager {
    static let helmDuration: TimeInterval = 8
    static let helmKillBase = 500

    private(set) var isHelmActive = false
    private(set) var helmTimeRemaining: TimeInterval = 0
    private(set) var helmKillChain = 0
    private var helmTotalDuration: TimeInterval = 8

    func activateHelm(durationBonus: TimeInterval = 0) {
        isHelmActive = true
        helmTotalDuration = Self.helmDuration + durationBonus
        helmTimeRemaining = helmTotalDuration
        helmKillChain = 0
    }

    func update(dt: TimeInterval) {
        guard isHelmActive else { return }
        helmTimeRemaining -= dt
        if helmTimeRemaining <= 0 {
            deactivateHelm()
        }
    }

    func deactivateHelm() {
        isHelmActive = false
        helmTimeRemaining = 0
        helmKillChain = 0
    }

    /// Points for the next helm kill (doubles per kill during one helm).
    func registerHelmKill() -> Int {
        let points = Self.helmKillBase * (1 << helmKillChain)
        helmKillChain += 1
        return points
    }

    var helmProgress: CGFloat {
        guard isHelmActive, helmTotalDuration > 0 else { return 0 }
        return CGFloat(helmTimeRemaining / helmTotalDuration)
    }
}
