import Foundation

/// Ten local achievements mirrored to Game Center when available.
final class AchievementTracker {
    static let shared = AchievementTracker()

    enum ID: String, CaseIterable {
        case firstGem = "gemstonekeep.achievement.first_gem"
        case clearCastle = "gemstonekeep.achievement.clear_castle"
        case score25k = "gemstonekeep.achievement.score_25k"
        case score100k = "gemstonekeep.achievement.score_100k"
        case secretWarp = "gemstonekeep.achievement.secret_warp"
        case allWarps = "gemstonekeep.achievement.all_warps"
        case reachIce = "gemstonekeep.achievement.reach_ice"
        case reachEclipse = "gemstonekeep.achievement.reach_eclipse"
        case helmMaster = "gemstonekeep.achievement.helm_master"
        case chaliceHunter = "gemstonekeep.achievement.chalice_hunter"
    }

    private static let secretWarpLevelIds: Set<Int> = [2, 6, 9]

    private let defaults = UserDefaults.standard
    private let storageKey = "gk.achievements.unlocked"
    private var unlocked: Set<String>
    private var helmKillsThisLevel = 0
    private var gemsThisRun = 0

    private init() {
        let stored = defaults.array(forKey: storageKey) as? [String] ?? []
        unlocked = Set(stored)
    }

    func beginRun() {
        helmKillsThisLevel = 0
        gemsThisRun = 0
    }

    func beginLevel() {
        helmKillsThisLevel = 0
    }

    func recordGemCollected() {
        gemsThisRun += 1
        unlock(.firstGem)
    }

    var gemsCollectedThisRun: Int { gemsThisRun }

    func recordLevelClear(levelId: Int, levelIndex: Int) {
        if levelId == 1 { unlock(.clearCastle) }
        if levelId >= 4 { unlock(.reachIce) }
        if levelId >= 12 { unlock(.reachEclipse) }
        PlayerProgress.shared.updateDeepestLevel(levelIndex)
        GameCenterManager.shared.submitDeepestLevel(levelIndex)
    }

    func recordWarp(levelId: Int) {
        unlock(.secretWarp)
        PlayerProgress.shared.recordWarp(levelId: levelId)
        if PlayerProgress.shared.discoveredWarpLevelIds.isSuperset(of: Self.secretWarpLevelIds) {
            unlock(.allWarps)
        }
    }

    func recordHelmKill() {
        helmKillsThisLevel += 1
        if helmKillsThisLevel >= 5 {
            unlock(.helmMaster)
        }
    }

    func recordChalice() {
        unlock(.chaliceHunter)
    }

    func checkScore(_ score: Int) {
        if score >= 25_000 { unlock(.score25k) }
        if score >= 100_000 { unlock(.score100k) }
    }

    func isUnlocked(_ id: ID) -> Bool {
        unlocked.contains(id.rawValue)
    }

    private func unlock(_ id: ID) {
        guard unlocked.insert(id.rawValue).inserted else { return }
        defaults.set(Array(unlocked).sorted(), forKey: storageKey)
        GameCenterManager.shared.reportAchievement(id.rawValue)
    }
}
