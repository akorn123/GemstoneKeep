import SpriteKit

/// Level pickups — magic helm and golden chalice.
final class PickupField {
    let container = SKNode()

    private var helmCell: MovementSystem.Cell?
    private var chaliceCell: MovementSystem.Cell?
    private(set) var helmAvailable = false
    private(set) var chaliceAvailable = false

    func populate(level: LevelDefinition, map: IsoMap) {
        container.removeAllChildren()
        helmAvailable = false
        chaliceAvailable = false
        helmCell = nil
        chaliceCell = nil

        if let coord = level.helm, map.isWalkable(col: coord.col, row: coord.row, elevation: coord.elevation) {
            let cell = coord.cell
            helmCell = cell
            helmAvailable = true
            addPickup(texture: GameArt.helmPickupTexture(), cell: cell, map: map, name: "helm")
        }

        if let coord = level.chalice, map.isWalkable(col: coord.col, row: coord.row, elevation: coord.elevation) {
            let cell = coord.cell
            chaliceCell = cell
            chaliceAvailable = true
            addPickup(texture: GameArt.chaliceTexture(), cell: cell, map: map, name: "chalice")
        }
    }

    func tryCollectHelm(at cell: MovementSystem.Cell) -> Bool {
        guard helmAvailable, cell == helmCell else { return false }
        helmAvailable = false
        container.childNode(withName: "helm")?.run(.sequence([
            .group([.scale(to: 1.4, duration: 0.12), .fadeOut(withDuration: 0.15)]),
            .removeFromParent(),
        ]))
        return true
    }

    func tryCollectChalice(at cell: MovementSystem.Cell) -> Bool {
        guard chaliceAvailable, cell == chaliceCell else { return false }
        chaliceAvailable = false
        container.childNode(withName: "chalice")?.run(.sequence([
            .group([.scale(to: 1.3, duration: 0.15), .fadeOut(withDuration: 0.18)]),
            .removeFromParent(),
        ]))
        return true
    }

    private func addPickup(texture: SKTexture, cell: MovementSystem.Cell, map: IsoMap, name: String) {
        let sprite = SKSpriteNode(texture: texture)
        sprite.name = name
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        var pos = map.screenPosition(col: cell.col, row: cell.row, elevation: cell.elevation)
        pos.y += 14
        sprite.position = pos
        sprite.zPosition = IsoMath.zPosition(
            col: cell.col,
            row: cell.row,
            elevation: cell.elevation,
            layerOffset: IsoMath.zEntityOffset - 0.05
        )
        let pulse = SKAction.sequence([
            .scale(to: 1.08, duration: 0.5),
            .scale(to: 0.94, duration: 0.5),
        ])
        sprite.run(.repeatForever(pulse))
        container.addChild(sprite)
    }
}
