import SpriteKit

/// Builds and owns the isometric tile map with correct depth sorting.
final class IsoMap {
    let level: LevelDefinition
    let worldNode: SKNode

    private(set) var walkableTiles: [GridKey: WalkableTile] = [:]

    struct GridKey: Hashable {
        let col: Int
        let row: Int
        let elevation: Int
    }

    struct WalkableTile {
        let col: Int
        let row: Int
        let elevation: Int
        let kind: TileKind
    }

    init(level: LevelDefinition) {
        self.level = level
        worldNode = SKNode()
        worldNode.name = "world"
        build()
    }

    /// Centers the map so spawn sits near origin before entity placement.
    var mapOffset: CGPoint {
        let centerCol = level.width / 2
        let centerRow = level.height / 2
        return IsoMath.gridToScreen(col: centerCol, row: centerRow, elevation: 0)
    }

    func screenPosition(col: Int, row: Int, elevation: Int) -> CGPoint {
        let raw = IsoMath.gridToScreen(col: col, row: row, elevation: elevation)
        return CGPoint(x: raw.x - mapOffset.x, y: raw.y - mapOffset.y)
    }

    func tile(col: Int, row: Int, elevation: Int) -> WalkableTile? {
        walkableTiles[GridKey(col: col, row: row, elevation: elevation)]
    }

    func isWalkable(col: Int, row: Int, elevation: Int) -> Bool {
        tile(col: col, row: row, elevation: elevation) != nil
    }

    func isRamp(_ kind: TileKind) -> Bool {
        switch kind {
        case .rampNorth, .rampSouth, .rampEast, .rampWest:
            return true
        default:
            return false
        }
    }

    /// Movement direction that ascends when leaving this ramp tile.
    func rampAscendDirection(_ kind: TileKind) -> InputController.IsoDirection {
        switch kind {
        case .rampNorth: return .southEast
        case .rampSouth: return .northEast
        case .rampEast: return .southWest
        case .rampWest: return .northEast
        default: return .southEast
        }
    }

    // MARK: - Build

    private func build() {
        let sortedTiles = level.tiles.sorted { lhs, rhs in
            let zL = IsoMath.zPosition(col: lhs.col, row: lhs.row, elevation: lhs.elevation, layerOffset: 0)
            let zR = IsoMath.zPosition(col: rhs.col, row: rhs.row, elevation: rhs.elevation, layerOffset: 0)
            return zL < zR
        }

        for tile in sortedTiles {
            let node = makeTileNode(tile)
            worldNode.addChild(node)

            if isWalkable(tile.kind) {
                let key = GridKey(col: tile.col, row: tile.row, elevation: tile.elevation)
                walkableTiles[key] = WalkableTile(
                    col: tile.col,
                    row: tile.row,
                    elevation: tile.elevation,
                    kind: tile.kind
                )
            }
        }
    }

    private func makeTileNode(_ tile: TileDefinition) -> SKSpriteNode {
        let texture: SKTexture
        let layerOffset: CGFloat
        let anchorY: CGFloat

        switch tile.kind {
        case .floor:
            texture = GameArt.floorTexture(theme: level.theme, elevation: tile.elevation)
            layerOffset = IsoMath.zFloorOffset
            anchorY = 0.35
        case .wall:
            texture = GameArt.wallTexture(theme: level.theme)
            layerOffset = IsoMath.zWallOffset
            anchorY = 0.28
        case .rampNorth, .rampSouth, .rampEast, .rampWest:
            texture = GameArt.rampTexture(theme: level.theme, direction: tile.kind)
            layerOffset = IsoMath.zFloorOffset
            anchorY = 0.35
        case .stairs:
            texture = GameArt.stairsTexture(theme: level.theme)
            layerOffset = IsoMath.zFloorOffset
            anchorY = 0.32
        case .pit:
            texture = GameArt.floorTexture(theme: level.theme, elevation: tile.elevation)
            layerOffset = IsoMath.zFloorOffset
            anchorY = 0.35
        }

        let sprite = SKSpriteNode(texture: texture)
        sprite.anchorPoint = CGPoint(x: 0.5, y: anchorY)
        sprite.position = screenPosition(col: tile.col, row: tile.row, elevation: tile.elevation)
        sprite.zPosition = IsoMath.zPosition(
            col: tile.col,
            row: tile.row,
            elevation: tile.elevation,
            layerOffset: layerOffset
        )
        sprite.name = "tile_\(tile.col)_\(tile.row)_\(tile.elevation)"
        return sprite
    }

    /// Rendering hints for static tile geometry.
    func finalizeForRendering() {
        worldNode.enumerateChildNodes(withName: "tile_*") { node, _ in
            guard let sprite = node as? SKSpriteNode else { return }
            sprite.texture?.filteringMode = .nearest
        }
    }

    private func isWalkable(_ kind: TileKind) -> Bool {
        switch kind {
        case .floor, .rampNorth, .rampSouth, .rampEast, .rampWest, .stairs:
            return true
        case .wall, .pit:
            return false
        }
    }
}
