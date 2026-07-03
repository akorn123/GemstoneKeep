import Foundation

/// Picks the exit portal cell — farthest walkable tile from spawn.
enum ExitResolver {
    static func exitCell(
        map: IsoMap,
        spawn: MovementSystem.Cell
    ) -> MovementSystem.Cell {
        let walkable = map.walkableTiles.values
        guard !walkable.isEmpty else { return spawn }

        let best = walkable.max { lhs, rhs in
            manhattan(lhs, spawn) < manhattan(rhs, spawn)
        }
        return MovementSystem.Cell(
            col: best?.col ?? spawn.col,
            row: best?.row ?? spawn.row,
            elevation: best?.elevation ?? spawn.elevation
        )
    }

    private static func manhattan(_ tile: IsoMap.WalkableTile, _ spawn: MovementSystem.Cell) -> Int {
        abs(tile.col - spawn.col) + abs(tile.row - spawn.row) + abs(tile.elevation - spawn.elevation) * 2
    }
}
