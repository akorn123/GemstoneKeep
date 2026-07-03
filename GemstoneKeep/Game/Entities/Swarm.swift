import SpriteKit

/// Bee-like cloud that sweeps the map on a fixed patrol route.
final class Swarm: SKNode {
    private var grid = GridMover()
    private let patrol: [MovementSystem.Cell]
    private var legIndex = 1
    private var phase: Phase = .waiting
    private var phaseTimer: TimeInterval = 0

    private let waitDuration: TimeInterval = 2.5
    private var sweepSpeed: CGFloat = 7.0

    var cell: MovementSystem.Cell { grid.cell }

    private enum Phase {
        case waiting
        case sweeping
    }

    init(patrol: [MovementSystem.Cell]) {
        self.patrol = patrol
        super.init()
        name = "swarm"
        if let first = patrol.first {
            grid.setPosition(col: first.col, row: first.row, elevation: first.elevation)
        }
        buildVisuals()
    }

    func applySpeedMultiplier(_ multiplier: CGFloat) {
        sweepSpeed = 7.0 * multiplier
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    private func buildVisuals() {
        for i in 0..<4 {
            let bee = SKSpriteNode(texture: GameArt.swarmBeeTexture())
            bee.position = CGPoint(x: CGFloat(i % 2) * 10 - 5, y: CGFloat(i / 2) * 8 - 4)
            bee.zPosition = CGFloat(i) * 0.01
            addChild(bee)
            let buzz = SKAction.sequence([
                .moveBy(x: 2, y: -1, duration: 0.12 + Double(i) * 0.02),
                .moveBy(x: -2, y: 1, duration: 0.12 + Double(i) * 0.02),
            ])
            bee.run(.repeatForever(buzz))
        }
    }

    func update(dt: TimeInterval, movement: MovementSystem, map: IsoMap) {
        guard patrol.count >= 2 else { return }

        switch phase {
        case .waiting:
            phaseTimer += dt
            if phaseTimer >= waitDuration {
                phaseTimer = 0
                phase = .sweeping
                legIndex = 1
                aimToward(movement: movement, target: patrol[legIndex])
            }
        case .sweeping:
            grid.tilesPerSecond = sweepSpeed
            let crossed = grid.update(dt: dt, movement: movement) { [weak self] in
                guard let self else { return }
                self.aimToward(movement: movement, target: self.patrol[self.legIndex])
            }
            if crossed, grid.cell == patrol[legIndex], !grid.isMovingBetweenTiles {
                legIndex += 1
                if legIndex >= patrol.count {
                    phase = .waiting
                    legIndex = 1
                    grid.direction = nil
                    grid.isMovingBetweenTiles = false
                    grid.moveProgress = 0
                    if let first = patrol.first {
                        grid.setPosition(col: first.col, row: first.row, elevation: first.elevation)
                    }
                } else {
                    aimToward(movement: movement, target: patrol[legIndex])
                }
            }
        }

        grid.apply(to: self, map: map, zBias: 0.03)
    }

    private func aimToward(movement: MovementSystem, target: MovementSystem.Cell) {
        for dir in InputController.IsoDirection.allCases {
            if movement.destination(from: grid.cell, direction: dir) == target {
                grid.direction = dir
                return
            }
        }
        grid.direction = nil
    }
}
