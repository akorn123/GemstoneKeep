import GameKit
import UIKit

/// Game Center authentication, leaderboards, and achievements.
final class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    enum LeaderboardID {
        static let highScore = "gemstonekeep.leaderboard.highscore"
        static let deepestLevel = "gemstonekeep.leaderboard.deepest_level"
    }

    private(set) var isAuthenticated = false

    private override init() {
        super.init()
    }

    func authenticate() {
        guard GKLocalPlayer.local.isAuthenticated == false else {
            isAuthenticated = true
            return
        }

        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController {
                self?.presentAuth(viewController)
                return
            }
            self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
            if error != nil {
                self?.isAuthenticated = false
            }
        }
    }

    func submitScore(_ score: Int) {
        guard isAuthenticated, score > 0 else { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [LeaderboardID.highScore]
        ) { _ in }
    }

    func submitDeepestLevel(_ levelIndex: Int) {
        guard isAuthenticated, levelIndex >= 0 else { return }
        GKLeaderboard.submitScore(
            levelIndex + 1,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [LeaderboardID.deepestLevel]
        ) { _ in }
    }

    func reportAchievement(_ id: String, percentComplete: Double = 100) {
        guard isAuthenticated else { return }
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { _ in }
    }

    func showLeaderboards(from viewController: UIViewController) {
        guard isAuthenticated else { return }
        let controller = GKGameCenterViewController(state: .leaderboards)
        controller.gameCenterDelegate = self
        viewController.present(controller, animated: true)
    }

    func showAchievements(from viewController: UIViewController) {
        guard isAuthenticated else { return }
        let controller = GKGameCenterViewController(state: .achievements)
        controller.gameCenterDelegate = self
        viewController.present(controller, animated: true)
    }

    private func presentAuth(_ controller: UIViewController) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController else { return }
        root.present(controller, animated: true)
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
