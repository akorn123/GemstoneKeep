import Foundation

/// Roguelite — one life per run; Guardian Heart grants a revive.
final class LivesManager {
    static let startingLives = 1

    private(set) var lives = startingLives

    func reset() {
        lives = Self.startingLives
    }

    /// Returns true when the run is over (no lives left).
    @discardableResult
    func loseLife() -> Bool {
        lives = max(0, lives - 1)
        return lives <= 0
    }
}
