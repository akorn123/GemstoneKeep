import SpriteKit

/// Rook — badger knight with continuous grid movement and jump.
final class Rook: SKSpriteNode {
    private(set) var cell = MovementSystem.Cell(col: 0, row: 0, elevation: 0)
    private(set) var targetCell = MovementSystem.Cell(col: 0, row: 0, elevation: 0)

    var moveDirection: InputController.IsoDirection?
    var facingDirection: CGPoint = CGPoint(x: 1, y: 0)

    private(set) var isMovingBetweenTiles = false
    private(set) var isJumping = false
    private(set) var isDead = false

    var moveProgress: CGFloat = 0
    var tilesPerSecond: CGFloat = 4.5
    let jumpDuration: TimeInterval = 0.38
    let jumpHeight: CGFloat = 22

    private var jumpElapsed: TimeInterval = 0
    private var baseY: CGFloat = 0

    init(col: Int, row: Int, elevation: Int) {
        cell = MovementSystem.Cell(col: col, row: row, elevation: elevation)
        targetCell = cell
        super.init(texture: GameArt.rookTexture(), color: .clear, size: CGSize(width: 28, height: 36))
        anchorPoint = CGPoint(x: 0.5, y: 0.2)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

  /// Advances movement along the grid. Returns true if a tile boundary was crossed.
    @discardableResult
    func updateMovement(
        dt: TimeInterval,
        movement: MovementSystem,
        desiredDirection: InputController.IsoDirection?
    ) -> Bool {
        var crossed = false

        if isDead { return false }

        if isJumping {
            jumpElapsed += dt
            if jumpElapsed >= jumpDuration {
                isJumping = false
                jumpElapsed = 0
            }
        }

        guard let direction = desiredDirection else {
            isMovingBetweenTiles = false
            moveProgress = 0
            return false
        }

        if !isMovingBetweenTiles {
            if let next = movement.destination(from: cell, direction: direction) {
                targetCell = next
                isMovingBetweenTiles = true
                moveProgress = 0
                facingDirection = direction.screenVector
            } else {
                return false
            }
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
                facingDirection = direction.screenVector
            }
        }

        return crossed
    }

    func beginJump() -> Bool {
        guard !isJumping, !isDead else { return false }
        isJumping = true
        jumpElapsed = 0
        return true
    }

    func playDeath() {
        isDead = true
        isMovingBetweenTiles = false
        moveProgress = 0
        removeAllActions()
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.55)
        let fade = SKAction.fadeOut(withDuration: 0.55)
        run(.group([spin, fade]))
    }

    func respawn(col: Int, row: Int, elevation: Int, map: IsoMap) {
        isDead = false
        alpha = 1
        zRotation = 0
        isJumping = false
        jumpElapsed = 0
        isMovingBetweenTiles = false
        moveProgress = 0
        cell = MovementSystem.Cell(col: col, row: row, elevation: elevation)
        targetCell = cell
        setHelmPowered(false)
        applyScreenPosition(from: map)
    }

    func setHelmPowered(_ active: Bool) {
        texture = active ? GameArt.rookHelmPoweredTexture() : GameArt.rookTexture()
    }

    func applyScreenPosition(from map: IsoMap) {
        guard !isDead else { return }
        let from = map.screenPosition(col: cell.col, row: cell.row, elevation: cell.elevation)
        let sortCol: CGFloat
        let sortRow: CGFloat
        let sortElev: Int

        if isMovingBetweenTiles {
            let to = map.screenPosition(col: targetCell.col, row: targetCell.row, elevation: targetCell.elevation)
            let t = min(1, moveProgress)
            position = CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            sortCol = CGFloat(cell.col) + (CGFloat(targetCell.col - cell.col)) * t
            sortRow = CGFloat(cell.row) + (CGFloat(targetCell.row - cell.row)) * t
            sortElev = cell.elevation == targetCell.elevation
                ? cell.elevation
                : (t < 0.5 ? cell.elevation : targetCell.elevation)
        } else {
            position = from
            sortCol = CGFloat(cell.col)
            sortRow = CGFloat(cell.row)
            sortElev = cell.elevation
        }

        baseY = position.y
        if isJumping {
            let t = min(1, jumpElapsed / jumpDuration)
            position.y = baseY + sin(t * .pi) * jumpHeight
        }

        zPosition = IsoMath.entityZPosition(col: sortCol, row: sortRow, elevation: sortElev)
    }
}
