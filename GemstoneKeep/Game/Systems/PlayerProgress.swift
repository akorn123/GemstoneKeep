import Foundation

/// Local persistence for high scores and run stats.
final class PlayerProgress {
    static let shared = PlayerProgress()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let highScore = "gk.progress.highScore"
        static let deepestLevelIndex = "gk.progress.deepestLevel"
        static let warpsFound = "gk.progress.warpsFound"
        static let totalGems = "gk.progress.totalGems"
        static let runsPlayed = "gk.progress.runsPlayed"
    }

    private(set) var highScore: Int
    private(set) var deepestLevelIndex: Int
    private(set) var discoveredWarpLevelIds: Set<Int>
    private(set) var totalGemsCollected: Int
    private(set) var runsPlayed: Int

    private init() {
        highScore = defaults.integer(forKey: Key.highScore)
        deepestLevelIndex = defaults.integer(forKey: Key.deepestLevelIndex)
        let warpList = defaults.array(forKey: Key.warpsFound) as? [Int] ?? []
        discoveredWarpLevelIds = Set(warpList)
        totalGemsCollected = defaults.integer(forKey: Key.totalGems)
        runsPlayed = defaults.integer(forKey: Key.runsPlayed)
    }

    func recordRunEnd(score: Int, levelIndex: Int) {
        runsPlayed += 1
        defaults.set(runsPlayed, forKey: Key.runsPlayed)
        if score > highScore {
            highScore = score
            defaults.set(highScore, forKey: Key.highScore)
        }
        updateDeepestLevel(levelIndex)
    }

    func updateDeepestLevel(_ index: Int) {
        guard index > deepestLevelIndex else { return }
        deepestLevelIndex = index
        defaults.set(deepestLevelIndex, forKey: Key.deepestLevelIndex)
    }

    func recordWarp(levelId: Int) {
        guard discoveredWarpLevelIds.insert(levelId).inserted else { return }
        defaults.set(Array(discoveredWarpLevelIds).sorted(), forKey: Key.warpsFound)
    }

    func recordGemsCollected(_ count: Int) {
        guard count > 0 else { return }
        totalGemsCollected += count
        defaults.set(totalGemsCollected, forKey: Key.totalGems)
    }
}
