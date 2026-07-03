import Foundation

struct GridCoord: Codable, Equatable {
    let col: Int
    let row: Int
    let elevation: Int

    var cell: MovementSystem.Cell {
        MovementSystem.Cell(col: col, row: row, elevation: elevation)
    }
}

struct SecretWarpDef: Codable, Equatable {
    let col: Int
    let row: Int
    let elevation: Int
    let skipAhead: Int
    let name: String

    var cell: MovementSystem.Cell {
        MovementSystem.Cell(col: col, row: row, elevation: elevation)
    }
}

struct LevelDefinition: Codable {
    let id: Int
    let name: String
    let theme: String
    let width: Int
    let height: Int
    let tiles: [TileDefinition]
    let spawnCol: Int
    let spawnRow: Int
    let spawnElevation: Int
    let helm: GridCoord?
    let chalice: GridCoord?
    let secretWarp: SecretWarpDef?

    var spawn: GridCoord {
        GridCoord(col: spawnCol, row: spawnRow, elevation: spawnElevation)
    }
}

enum TileKind: String, Codable {
    case floor
    case wall
    case rampNorth
    case rampSouth
    case rampEast
    case rampWest
    case stairs
    case pit
}

struct TileDefinition: Codable {
    let col: Int
    let row: Int
    let elevation: Int
    let kind: TileKind
}
