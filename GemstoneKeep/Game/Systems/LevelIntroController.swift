import CoreGraphics
import SpriteKit

/// Cinematic flyover before gameplay — pans across scenic map waypoints.
final class LevelIntroController {
    private(set) var isActive = false

    private var waypoints: [CGPoint] = []
    private var segmentDuration: TimeInterval = 0.85
    private var elapsed: TimeInterval = 0
    private var currentSegment = 0

    var onComplete: (() -> Void)?

    func configure(map: IsoMap, level: LevelDefinition, spawn: MovementSystem.Cell) {
        waypoints = Self.buildWaypoints(map: map, level: level, spawn: spawn)
        currentSegment = 0
        elapsed = 0
    }

    func begin() {
        isActive = waypoints.count >= 2
        elapsed = 0
        currentSegment = 0
        if !isActive {
            onComplete?()
        }
    }

    func currentFocus() -> CGPoint {
        guard let first = waypoints.first else { return .zero }
        return first
    }

    /// Returns the camera focus for this frame. Call each update while active.
    @discardableResult
    func update(dt: TimeInterval) -> CGPoint? {
        guard isActive, waypoints.count >= 2 else { return nil }

        elapsed += dt
        let duration = segmentDuration
        let totalSegments = waypoints.count - 1

        while elapsed >= duration, currentSegment < totalSegments {
            elapsed -= duration
            currentSegment += 1
        }

        if currentSegment >= totalSegments {
            isActive = false
            onComplete?()
            return waypoints.last
        }

        let from = waypoints[currentSegment]
        let to = waypoints[currentSegment + 1]
        let t = easeInOut(min(1, elapsed / duration))
        return CGPoint(
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t
        )
    }

    private func easeInOut(_ t: CGFloat) -> CGFloat {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    private static func buildWaypoints(
        map: IsoMap,
        level: LevelDefinition,
        spawn: MovementSystem.Cell
    ) -> [CGPoint] {
        let walkable = Array(map.walkableTiles.values)
        guard !walkable.isEmpty else {
            return [map.screenPosition(col: spawn.col, row: spawn.row, elevation: spawn.elevation)]
        }

        var points: [CGPoint] = []
        let spawnPos = map.screenPosition(col: spawn.col, row: spawn.row, elevation: spawn.elevation)
        points.append(spawnPos)

        let cols = walkable.map(\.col)
        let rows = walkable.map(\.row)
        let minC = cols.min() ?? 0
        let maxC = cols.max() ?? level.width - 1
        let minR = rows.min() ?? 0
        let maxR = rows.max() ?? level.height - 1

        let corners = [
            (minC, minR),
            (maxC, minR),
            (maxC, maxR),
            (minC, maxR),
        ]

        for (col, row) in corners {
            if let tile = nearestWalkable(col: col, row: row, in: walkable) {
                let pos = map.screenPosition(col: tile.col, row: tile.row, elevation: tile.elevation)
                if !points.contains(where: { $0.distance(to: pos) < 24 }) {
                    points.append(pos)
                }
            }
        }

        if let peak = walkable.max(by: { $0.elevation < $1.elevation }), peak.elevation > 0 {
            let pos = map.screenPosition(col: peak.col, row: peak.row, elevation: peak.elevation)
            if !points.contains(where: { $0.distance(to: pos) < 20 }) {
                points.append(pos)
            }
        }

        points.append(spawnPos)
        return points
    }

    private static func nearestWalkable(
        col: Int,
        row: Int,
        in tiles: [IsoMap.WalkableTile]
    ) -> IsoMap.WalkableTile? {
        tiles.min { lhs, rhs in
            let dl = abs(lhs.col - col) + abs(lhs.row - row)
            let dr = abs(rhs.col - col) + abs(rhs.row - row)
            return dl < dr
        }
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
