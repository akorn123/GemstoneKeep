import CoreGraphics
import SpriteKit

/// Shared tile-to-tile movement for grid enemies.
struct GridMover {
    var cell = MovementSystem.Cell(col: 0, row: 0, elevation: 0)
    var targetCell = MovementSystem.Cell(col: 0, row: 0, elevation: 0)
    var direction: InputController.IsoDirection?
    var isMovingBetweenTiles = false
    var moveProgress: CGFloat = 0
    var tilesPerSecond: CGFloat = 2.0

    mutating func setPosition(col: Int, row: Int, elevation: Int) {
        cell = MovementSystem.Cell(col: col, row: row, elevation: elevation)
        targetCell = cell
        isMovingBetweenTiles = false
        moveProgress = 0
    }

    @discardableResult
    mutating func update(
        dt: TimeInterval,
        movement: MovementSystem,
        onBlocked: (() -> Void)? = nil
    ) -> Bool {
        guard let direction else { return false }
        var crossed = false

        if !isMovingBetweenTiles {
            guard let next = movement.destination(from: cell, direction: direction) else {
                onBlocked?()
                return false
            }
            targetCell = next
            isMovingBetweenTiles = true
            moveProgress = 0
        }

        moveProgress += tilesPerSecond * CGFloat(dt)

        if moveProgress >= 1 {
            crossed = true
            cell = targetCell
            moveProgress -= 1
            isMovingBetweenTiles = false

            if let next = movement.destination(from: cell, direction: direction) {
                targetCell = next
                isMovingBetweenTiles = true
            } else {
                onBlocked?()
            }
        }

        return crossed
    }

    func apply(to node: SKNode, map: IsoMap, zBias: CGFloat = -0.02) {
        let from = map.screenPosition(col: cell.col, row: cell.row, elevation: cell.elevation)
        let sortCol: CGFloat
        let sortRow: CGFloat
        let sortElev: Int

        if isMovingBetweenTiles {
            let to = map.screenPosition(col: targetCell.col, row: targetCell.row, elevation: targetCell.elevation)
            let t = min(1, moveProgress)
            node.position = CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            sortCol = CGFloat(cell.col) + CGFloat(targetCell.col - cell.col) * t
            sortRow = CGFloat(cell.row) + CGFloat(targetCell.row - cell.row) * t
            sortElev = cell.elevation == targetCell.elevation
                ? cell.elevation
                : (t < 0.5 ? cell.elevation : targetCell.elevation)
        } else {
            node.position = from
            sortCol = CGFloat(cell.col)
            sortRow = CGFloat(cell.row)
            sortElev = cell.elevation
        }

        node.zPosition = IsoMath.entityZPosition(col: sortCol, row: sortRow, elevation: sortElev) + zBias
    }
}
