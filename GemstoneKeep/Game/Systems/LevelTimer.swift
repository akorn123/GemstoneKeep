import Foundation

/// Tracks level elapsed time for time bonus on clear.
final class LevelTimer {
    private var startTime: TimeInterval?
    private(set) var elapsed: TimeInterval = 0

    func start(at time: TimeInterval) {
        startTime = time
        elapsed = 0
    }

    func update(currentTime: TimeInterval) {
        guard let startTime else { return }
        elapsed = currentTime - startTime
    }

    func formattedElapsed() -> String {
        let total = Int(elapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
