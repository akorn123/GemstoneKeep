import Foundation

/// Procedural helpers for handcrafted castle layouts.
enum LevelBuilder {
    static func hollowRect(width: Int, height: Int) -> [TileDefinition] {
        var tiles: [TileDefinition] = []
        for row in 0..<height {
            for col in 0..<width {
                let border = row == 0 || col == 0 || row == height - 1 || col == width - 1
                tiles.append(TileDefinition(
                    col: col,
                    row: row,
                    elevation: 0,
                    kind: border ? .wall : .floor
                ))
            }
        }
        return tiles
    }

    @discardableResult
    static func setFloor(
        _ tiles: inout [TileDefinition],
        col: Int,
        row: Int,
        elevation: Int = 0,
        kind: TileKind = .floor
    ) {
        tiles.removeAll { $0.col == col && $0.row == row }
        tiles.append(TileDefinition(col: col, row: row, elevation: elevation, kind: kind))
    }

    @discardableResult
    static func fillRect(
        _ tiles: inout [TileDefinition],
        colRange: ClosedRange<Int>,
        rowRange: ClosedRange<Int>,
        elevation: Int,
        kind: TileKind = .floor
    ) {
        for row in rowRange {
            for col in colRange {
                setFloor(&tiles, col: col, row: row, elevation: elevation, kind: kind)
            }
        }
    }

    static func addRamp(
        _ tiles: inout [TileDefinition],
        col: Int,
        row: Int,
        direction: TileKind,
        elevation: Int = 0
    ) {
        setFloor(&tiles, col: col, row: row, elevation: elevation, kind: direction)
    }

    static func make(
        id: Int,
        name: String,
        theme: String,
        width: Int,
        height: Int,
        tiles: [TileDefinition],
        spawn: GridCoord,
        helm: GridCoord? = nil,
        chalice: GridCoord? = nil,
        secretWarp: SecretWarpDef? = nil
    ) -> LevelDefinition {
        LevelDefinition(
            id: id,
            name: name,
            theme: theme,
            width: width,
            height: height,
            tiles: tiles,
            spawnCol: spawn.col,
            spawnRow: spawn.row,
            spawnElevation: spawn.elevation,
            helm: helm,
            chalice: chalice,
            secretWarp: secretWarp
        )
    }
}
