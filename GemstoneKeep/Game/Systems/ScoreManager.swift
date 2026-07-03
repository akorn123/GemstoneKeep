import Foundation

struct GemPickupResult {
    let pointsEarned: Int
    let baseGemPoints: Int
    let finalGemBonus: Int
    let levelClearBonus: Int
    let isFinalGem: Bool
    let pickupChain: Int
}

struct LevelClearSummary {
    let totalScore: Int
    let gemsCollected: Int
    let lastPickup: GemPickupResult
    let timeBonus: Int
    let elapsedTime: TimeInterval
    let walletGems: Int
}

/// Tracks score, pickups, helm kills, and level-clear bonuses.
final class ScoreManager {
    static let gemValue = 10
    static let finalGemBonus = 500
    static let levelClearBonus = 1_000
    static let chaliceValue = 2_500
    static let chainWindow: TimeInterval = 0.65
    static let parTime: TimeInterval = 75

    private(set) var score = 0
    private(set) var gemsThisLevel = 0
    private(set) var pickupChain = 0
    private(set) var lastClearSummary: LevelClearSummary?

    private(set) var lastGemPickup: GemPickupResult?

    private var lastPickupTime: TimeInterval = -1

    func beginLevel() {
        gemsThisLevel = 0
        pickupChain = 0
        lastPickupTime = -1
        lastGemPickup = nil
    }

    func resetRun() {
        score = 0
        beginLevel()
        lastClearSummary = nil
    }

    @discardableResult
    func registerGemPickup(at time: TimeInterval, isFinalGem: Bool) -> GemPickupResult {
        if lastPickupTime < 0 || time - lastPickupTime > Self.chainWindow {
            pickupChain = 0
        } else {
            pickupChain += 1
        }
        lastPickupTime = time
        gemsThisLevel += 1

        var base = Self.gemValue
        var finalBonus = 0
        var clearBonus = 0
        if isFinalGem {
            finalBonus = Self.finalGemBonus
            clearBonus = Self.levelClearBonus
        }

        let earned = base + finalBonus + clearBonus
        score += earned

        let result = GemPickupResult(
            pointsEarned: earned,
            baseGemPoints: base,
            finalGemBonus: finalBonus,
            levelClearBonus: clearBonus,
            isFinalGem: isFinalGem,
            pickupChain: pickupChain
        )
        lastGemPickup = result
        return result
    }

    @discardableResult
    func registerChalice() -> Int {
        score += Self.chaliceValue
        return Self.chaliceValue
    }

    @discardableResult
    func registerHelmKill(points: Int) -> Int {
        score += points
        return points
    }

    func timeBonus(for elapsed: TimeInterval) -> Int {
        if elapsed <= Self.parTime {
            return Int(1_500 + (Self.parTime - elapsed) * 18)
        }
        return max(0, Int(600 - (elapsed - Self.parTime) * 8))
    }

    @discardableResult
    func finalizeFloorClear(elapsed: TimeInterval, walletGems: Int) -> LevelClearSummary? {
        let bonus = timeBonus(for: elapsed)
        score += bonus
        let summary = LevelClearSummary(
            totalScore: score,
            gemsCollected: gemsThisLevel,
            lastPickup: lastGemPickup ?? GemPickupResult(
                pointsEarned: 0, baseGemPoints: 0, finalGemBonus: 0,
                levelClearBonus: 0, isFinalGem: false, pickupChain: 0
            ),
            timeBonus: bonus,
            elapsedTime: elapsed,
            walletGems: walletGems
        )
        lastClearSummary = summary
        return summary
    }

    func pickupPitchOffset(for chain: Int) -> Float {
        min(0.35, Float(chain) * 0.06)
    }
}
