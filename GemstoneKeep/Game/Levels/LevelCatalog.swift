import Foundation

/// Twelve handcrafted castles — 3 per theme across stone, ice, garden, obsidian.
enum LevelCatalog {
    static let all: [LevelDefinition] = [
        stoneGate,
        innerWard,
        baronsBulwark,
        frostVestibule,
        glacierGallery,
        crystalCrown,
        ivyCourt,
        thornMaze,
        bloomSanctum,
        ashAtrium,
        voidRampart,
        eclipseSpire,
    ]

    // MARK: - Stone Keep (1–3)

    private static var stoneGate: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 4...7, rowRange: 4...7, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 4, row: 3, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 4, direction: .rampEast)
        LevelBuilder.addRamp(&tiles, col: 4, row: 8, direction: .rampSouth)
        LevelBuilder.setFloor(&tiles, col: 7, row: 8, elevation: 1, kind: .stairs)
        LevelBuilder.setFloor(&tiles, col: 8, row: 9, elevation: 0, kind: .stairs)
        return LevelBuilder.make(
            id: 1, name: "Stone Gate", theme: "stone_keep",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 2, row: 2, elevation: 0),
            helm: GridCoord(col: 6, row: 6, elevation: 1),
            chalice: GridCoord(col: 7, row: 8, elevation: 1)
        )
    }

    private static var innerWard: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 10, height: 10)
        LevelBuilder.fillRect(&tiles, colRange: 3...6, rowRange: 3...6, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 3, row: 2, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 6, row: 3, direction: .rampEast)
        return LevelBuilder.make(
            id: 2, name: "Inner Ward", theme: "stone_keep",
            width: 10, height: 10, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 1),
            chalice: GridCoord(col: 6, row: 6, elevation: 1),
            secretWarp: SecretWarpDef(col: 8, row: 1, elevation: 0, skipAhead: 3, name: "Moonlit Alcove")
        )
    }

    private static var baronsBulwark: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 2...5, rowRange: 5...8, elevation: 1)
        LevelBuilder.fillRect(&tiles, colRange: 6...9, rowRange: 2...5, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 2, row: 4, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 6, row: 6, direction: .rampSouth)
        LevelBuilder.addRamp(&tiles, col: 9, row: 2, direction: .rampEast)
        LevelBuilder.setFloor(&tiles, col: 5, row: 9, elevation: 0, kind: .pit)
        LevelBuilder.setFloor(&tiles, col: 6, row: 9, elevation: 0, kind: .pit)
        return LevelBuilder.make(
            id: 3, name: "Baron's Bulwark", theme: "stone_keep",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 8, row: 4, elevation: 1),
            chalice: GridCoord(col: 4, row: 7, elevation: 1)
        )
    }

    // MARK: - Ice Spire (4–6)

    private static var frostVestibule: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 11, height: 11)
        LevelBuilder.fillRect(&tiles, colRange: 4...7, rowRange: 3...7, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 4, row: 2, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 7, direction: .rampSouth)
        return LevelBuilder.make(
            id: 4, name: "Frost Vestibule", theme: "ice_spire",
            width: 11, height: 11, tiles: tiles,
            spawn: GridCoord(col: 1, row: 5, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 1),
            chalice: GridCoord(col: 7, row: 4, elevation: 1)
        )
    }

    private static var glacierGallery: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 10)
        LevelBuilder.fillRect(&tiles, colRange: 2...9, rowRange: 2...3, elevation: 1)
        LevelBuilder.fillRect(&tiles, colRange: 2...9, rowRange: 6...7, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 5, row: 4, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 5, row: 5, direction: .rampSouth)
        LevelBuilder.setFloor(&tiles, col: 1, row: 8, elevation: 0, kind: .stairs)
        LevelBuilder.setFloor(&tiles, col: 2, row: 9, elevation: 1, kind: .stairs)
        return LevelBuilder.make(
            id: 5, name: "Glacier Gallery", theme: "ice_spire",
            width: 12, height: 10, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 9, row: 2, elevation: 1),
            chalice: GridCoord(col: 2, row: 7, elevation: 1)
        )
    }

    private static var crystalCrown: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 5...6, rowRange: 5...6, elevation: 2)
        LevelBuilder.fillRect(&tiles, colRange: 4...7, rowRange: 4...7, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 4, row: 3, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 5, row: 4, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 5, direction: .rampEast)
        return LevelBuilder.make(
            id: 6, name: "Crystal Crown", theme: "ice_spire",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 2, row: 9, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 2),
            chalice: GridCoord(col: 6, row: 6, elevation: 2),
            secretWarp: SecretWarpDef(col: 1, row: 9, elevation: 0, skipAhead: 4, name: "Frost Rift")
        )
    }

    // MARK: - Garden Labyrinth (7–9)

    private static var ivyCourt: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 11, height: 11)
        LevelBuilder.fillRect(&tiles, colRange: 3...7, rowRange: 3...7, elevation: 0, kind: .floor)
        for col in stride(from: 3, through: 7, by: 2) {
            for row in stride(from: 3, through: 7, by: 2) {
                LevelBuilder.setFloor(&tiles, col: col, row: row, elevation: 1)
            }
        }
        LevelBuilder.addRamp(&tiles, col: 3, row: 2, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 3, direction: .rampEast)
        return LevelBuilder.make(
            id: 7, name: "Ivy Court", theme: "garden_labyrinth",
            width: 11, height: 11, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 1),
            chalice: GridCoord(col: 7, row: 7, elevation: 1)
        )
    }

    private static var thornMaze: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        for col in [4, 6, 8] {
            LevelBuilder.setFloor(&tiles, col: col, row: 5, elevation: 0, kind: .wall)
            LevelBuilder.setFloor(&tiles, col: col, row: 6, elevation: 0, kind: .wall)
        }
        LevelBuilder.fillRect(&tiles, colRange: 9...10, rowRange: 2...4, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 8, row: 3, direction: .rampEast)
        return LevelBuilder.make(
            id: 8, name: "Thorn Maze", theme: "garden_labyrinth",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 9, row: 3, elevation: 1),
            chalice: GridCoord(col: 10, row: 2, elevation: 1)
        )
    }

    private static var bloomSanctum: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 4...8, rowRange: 4...8, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 4, row: 3, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 8, row: 4, direction: .rampEast)
        LevelBuilder.addRamp(&tiles, col: 4, row: 8, direction: .rampSouth)
        LevelBuilder.addRamp(&tiles, col: 3, row: 4, direction: .rampWest)
        return LevelBuilder.make(
            id: 9, name: "Bloom Sanctum", theme: "garden_labyrinth",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 1, row: 10, elevation: 0),
            helm: GridCoord(col: 6, row: 6, elevation: 1),
            chalice: GridCoord(col: 8, row: 8, elevation: 1),
            secretWarp: SecretWarpDef(col: 9, row: 9, elevation: 0, skipAhead: 3, name: "Hedge Portal")
        )
    }

    // MARK: - Obsidian Tower (10–12)

    private static var ashAtrium: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 11, height: 11)
        LevelBuilder.fillRect(&tiles, colRange: 3...7, rowRange: 2...8, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 3, row: 1, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 8, direction: .rampSouth)
        return LevelBuilder.make(
            id: 10, name: "Ash Atrium", theme: "obsidian_tower",
            width: 11, height: 11, tiles: tiles,
            spawn: GridCoord(col: 1, row: 5, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 1),
            chalice: GridCoord(col: 7, row: 3, elevation: 1)
        )
    }

    private static var voidRampart: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 2...4, rowRange: 2...9, elevation: 1)
        LevelBuilder.fillRect(&tiles, colRange: 7...9, rowRange: 2...9, elevation: 1)
        LevelBuilder.addRamp(&tiles, col: 5, row: 5, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 6, row: 6, direction: .rampSouth)
        LevelBuilder.setFloor(&tiles, col: 5, row: 6, elevation: 0, kind: .pit)
        LevelBuilder.setFloor(&tiles, col: 6, row: 5, elevation: 0, kind: .pit)
        return LevelBuilder.make(
            id: 11, name: "Void Rampart", theme: "obsidian_tower",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 8, row: 8, elevation: 1),
            chalice: GridCoord(col: 3, row: 8, elevation: 1)
        )
    }

    private static var eclipseSpire: LevelDefinition {
        var tiles = LevelBuilder.hollowRect(width: 12, height: 12)
        LevelBuilder.fillRect(&tiles, colRange: 4...7, rowRange: 4...7, elevation: 1)
        LevelBuilder.fillRect(&tiles, colRange: 5...6, rowRange: 5...6, elevation: 2)
        LevelBuilder.addRamp(&tiles, col: 4, row: 3, direction: .rampNorth)
        LevelBuilder.addRamp(&tiles, col: 7, row: 4, direction: .rampEast)
        LevelBuilder.addRamp(&tiles, col: 4, row: 8, direction: .rampSouth)
        LevelBuilder.addRamp(&tiles, col: 3, row: 4, direction: .rampWest)
        LevelBuilder.setFloor(&tiles, col: 8, row: 8, elevation: 1, kind: .stairs)
        LevelBuilder.setFloor(&tiles, col: 9, row: 9, elevation: 0, kind: .stairs)
        return LevelBuilder.make(
            id: 12, name: "Eclipse Spire", theme: "obsidian_tower",
            width: 12, height: 12, tiles: tiles,
            spawn: GridCoord(col: 1, row: 1, elevation: 0),
            helm: GridCoord(col: 5, row: 5, elevation: 2),
            chalice: GridCoord(col: 6, row: 6, elevation: 2)
        )
    }
}
