import Foundation

/// Tracks discovered secret warps (jump in hidden corners).
final class SecretWarpTracker {
    private var discovered: Set<Int> = []

    func reset() {
        discovered.removeAll()
    }

    func isDiscovered(levelId: Int) -> Bool {
        discovered.contains(levelId)
    }

    func markDiscovered(levelId: Int) {
        discovered.insert(levelId)
    }
}
