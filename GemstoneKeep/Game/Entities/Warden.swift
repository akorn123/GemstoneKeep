import GameplayKit
import SpriteKit

/// Witch-like specter — faster than Rook on flat ground, slow on stairs.
final class Warden: SKSpriteNode {
    weak var movement: MovementSystem?
    weak var pathfinder: Pathfinder?
    weak var map: IsoMap?

    private var grid = GridMover()
    private var repathTimer: TimeInterval = 0
    private let repathInterval: TimeInterval = 0.4
    private var flatSpeed: CGFloat = 5.6
    private var stairSpeed: CGFloat = 2.0

    private(set) lazy var stateMachine: GKStateMachine = {
        GKStateMachine(states: [WardenHuntState(warden: self)])
    }()

    var cell: MovementSystem.Cell { grid.cell }

    init(col: Int, row: Int, elevation: Int) {
        super.init(texture: GameArt.wardenTexture(), color: .clear, size: CGSize(width: 34, height: 38))
        anchorPoint = CGPoint(x: 0.5, y: 0.2)
        name = "warden"
        grid.setPosition(col: col, row: row, elevation: elevation)
        grid.tilesPerSecond = 5.6
        let hover = SKAction.sequence([
            .moveBy(x: 0, y: 3, duration: 0.55),
            .moveBy(x: 0, y: -3, duration: 0.55),
        ])
        run(.repeatForever(hover))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func startHunting() {
        stateMachine.enter(WardenHuntState.self)
    }

    func applySpeedMultiplier(_ multiplier: CGFloat) {
        flatSpeed = 5.6 * multiplier
        stairSpeed = 2.0 * multiplier
    }

    func update(dt: TimeInterval, target: MovementSystem.Cell) {
        guard let map, let movement else { return }
        stateMachine.update(deltaTime: dt)

        grid.tilesPerSecond = currentSpeed()

        repathTimer += dt
        if repathTimer >= repathInterval || grid.direction == nil {
            repathTimer = 0
            grid.direction = pathfinder?.direction(from: grid.cell, to: target)
        }

        _ = grid.update(dt: dt, movement: movement) { [weak self] in
            guard let self else { return }
            self.grid.direction = self.pathfinder?.direction(from: self.grid.cell, to: target)
        }
        grid.apply(to: self, map: map, zBias: -0.01)
    }

    private func currentSpeed() -> CGFloat {
        guard let map, let tile = map.tile(col: grid.cell.col, row: grid.cell.row, elevation: grid.cell.elevation) else {
            return flatSpeed
        }
        if tile.kind == .stairs { return stairSpeed }
        return flatSpeed
    }
}

final class WardenHuntState: GKState {
    private weak var warden: Warden?

    init(warden: Warden) {
        self.warden = warden
        super.init()
    }
}
