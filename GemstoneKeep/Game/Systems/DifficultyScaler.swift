import CoreGraphics
import Foundation

/// Escalating enemy counts and speed per level + loop (post-12 replay).
struct DifficultyScaler {
    struct Tier {
        let gloomerCount: Int
        let stalkerCount: Int
        let wardenCount: Int
        let hasSwarm: Bool
        let speedMultiplier: CGFloat
    }

    static let levelsPerLoop = 12

    static func tier(levelId: Int, loop: Int) -> Tier {
        let t = baseTier(levelId: levelId)
        let loopBoost = CGFloat(loop) * 0.12
        return Tier(
            gloomerCount: t.gloomerCount + loop,
            stalkerCount: t.stalkerCount + loop / 2,
            wardenCount: t.wardenCount + loop / 3,
            hasSwarm: t.hasSwarm || loop > 0,
            speedMultiplier: min(2.0, t.speedMultiplier + loopBoost)
        )
    }

    private static func baseTier(levelId: Int) -> Tier {
        switch levelId {
        case 1: return Tier(gloomerCount: 2, stalkerCount: 0, wardenCount: 0, hasSwarm: false, speedMultiplier: 1.0)
        case 2: return Tier(gloomerCount: 2, stalkerCount: 1, wardenCount: 0, hasSwarm: false, speedMultiplier: 1.02)
        case 3: return Tier(gloomerCount: 3, stalkerCount: 1, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.05)
        case 4: return Tier(gloomerCount: 2, stalkerCount: 1, wardenCount: 0, hasSwarm: false, speedMultiplier: 1.06)
        case 5: return Tier(gloomerCount: 3, stalkerCount: 1, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.08)
        case 6: return Tier(gloomerCount: 3, stalkerCount: 2, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.1)
        case 7: return Tier(gloomerCount: 3, stalkerCount: 1, wardenCount: 1, hasSwarm: false, speedMultiplier: 1.1)
        case 8: return Tier(gloomerCount: 3, stalkerCount: 2, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.12)
        case 9: return Tier(gloomerCount: 4, stalkerCount: 2, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.14)
        case 10: return Tier(gloomerCount: 3, stalkerCount: 2, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.15)
        case 11: return Tier(gloomerCount: 4, stalkerCount: 2, wardenCount: 2, hasSwarm: true, speedMultiplier: 1.18)
        case 12: return Tier(gloomerCount: 4, stalkerCount: 3, wardenCount: 2, hasSwarm: true, speedMultiplier: 1.2)
        default: return Tier(gloomerCount: 3, stalkerCount: 2, wardenCount: 1, hasSwarm: true, speedMultiplier: 1.1)
        }
    }

    static func loopCount(forLevelIndex index: Int) -> Int {
        max(0, index / levelsPerLoop)
    }

    static func levelId(forLevelIndex index: Int) -> Int {
        (index % levelsPerLoop) + 1
    }
}
