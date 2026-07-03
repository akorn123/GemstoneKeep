import GameplayKit
import SpriteKit

/// Skeletal hound that paths toward Rook using A*.
final class Stalker: SKSpriteNode {
    weak var movement: MovementSystem?
    weak var pathfinder: Pathfinder?

    private var grid = GridMover()
    private var repathTimer: TimeInterval = 0
    private let repathInterval: TimeInterval = 0.35

    private(set) lazy var stateMachine: GKStateMachine = {
        GKStateMachine(states: [StalkerChaseState(stalker: self)])
    }()

    var cell: MovementSystem.Cell { grid.cell }

    init(col: Int, row: Int, elevation: Int) {
        super.init(texture: GameArt.stalkerTexture(), color: .clear, size: CGSize(width: 32, height: 30))
        anchorPoint = CGPoint(x: 0.5, y: 0.22)
        name = "stalker"
        grid.setPosition(col: col, row: row, elevation: elevation)
        grid.tilesPerSecond = 3.6
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func startChasing() {
        stateMachine.enter(StalkerChaseState.self)
    }

    func applySpeedMultiplier(_ multiplier: CGFloat) {
        grid.tilesPerSecond = 3.6 * multiplier
    }

    func update(dt: TimeInterval, target: MovementSystem.Cell, map: IsoMap) {
        stateMachine.update(deltaTime: dt)
        repathTimer += dt
        if repathTimer >= repathInterval || grid.direction == nil {
            repathTimer = 0
            grid.direction = pathfinder?.direction(from: grid.cell, to: target)
        }

        guard let movement else { return }
        _ = grid.update(dt: dt, movement: movement) { [weak self] in
            self?.grid.direction = self?.pathfinder?.direction(from: self?.grid.cell ?? target, to: target)
        }
        grid.apply(to: self, map: map, zBias: -0.015)
    }
}

final class StalkerChaseState: GKState {
    private weak var stalker: Stalker?

    init(stalker: Stalker) {
        self.stalker = stalker
        super.init()
    }
}
