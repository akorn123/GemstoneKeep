import SpriteKit

/// Places gems on walkable tiles and handles collection.
final class GemField {
    typealias GridKey = IsoMap.GridKey

    let container = SKNode()

    private var gems: [GridKey: Gem] = [:]

    var remainingCount: Int { gems.count }

    var activeGemCells: [MovementSystem.Cell] {
        gems.keys.map { MovementSystem.Cell(col: $0.col, row: $0.row, elevation: $0.elevation) }
    }

    func populate(map: IsoMap, excludingSpawn spawn: MovementSystem.Cell, excluding exit: MovementSystem.Cell) {
        container.removeAllChildren()
        gems.removeAll()

        var hue = 0
        for tile in map.walkableTiles.values {
            let cell = MovementSystem.Cell(col: tile.col, row: tile.row, elevation: tile.elevation)
            if cell == spawn || cell == exit { continue }

            let key = GridKey(col: tile.col, row: tile.row, elevation: tile.elevation)
            let gem = Gem(cell: cell, hueIndex: hue % 6)
            hue += 1

            var pos = map.screenPosition(col: cell.col, row: cell.row, elevation: cell.elevation)
            pos.y += 10
            gem.position = pos
            gem.zPosition = IsoMath.zPosition(
                col: cell.col,
                row: cell.row,
                elevation: cell.elevation,
                layerOffset: IsoMath.zEntityOffset - 0.08
            )

            gems[key] = gem
            container.addChild(gem)
        }
    }

    @discardableResult
    func tryCollect(at cell: MovementSystem.Cell) -> Bool {
        let key = GridKey(col: cell.col, row: cell.row, elevation: cell.elevation)
        guard let gem = gems.removeValue(forKey: key) else { return false }
        GemSparkleBurst.emit(
            at: gem.position,
            in: container,
            hueIndex: gem.hueIndex,
            zPosition: gem.zPosition
        )
        gem.playCollectAnimation {}
        return true
    }

    /// Gloomer eats a gem — gem vanishes; wallet penalty handled by GameScene.
    @discardableResult
    func consumeByEnemy(at cell: MovementSystem.Cell) -> Bool {
        let key = GridKey(col: cell.col, row: cell.row, elevation: cell.elevation)
        guard gems[key] != nil else { return false }
        guard let gem = gems.removeValue(forKey: key) else { return false }
        gem.playEatenAnimation()
        return true
    }
}
