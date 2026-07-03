import GameplayKit
import SpriteKit

/// Slow blob enemy that wanders the grid and eats gems.
final class Gloomer: SKSpriteNode {
    weak var movement: MovementSystem?

    private var grid = GridMover()

    private(set) lazy var stateMachine: GKStateMachine = {
        GKStateMachine(states: [
            GloomerMoveState(gloomer: self),
            GloomerChooseDirectionState(gloomer: self),
        ])
    }()

    var cell: MovementSystem.Cell { grid.cell }
    var wanderDirection: InputController.IsoDirection? {
        get { grid.direction }
        set { grid.direction = newValue }
    }
    var isMovingBetweenTiles: Bool { grid.isMovingBetweenTiles }

    init(col: Int, row: Int, elevation: Int) {
        super.init(texture: GameArt.gloomerTexture(), color: .clear, size: CGSize(width: 30, height: 26))
        anchorPoint = CGPoint(x: 0.5, y: 0.25)
        name = "gloomer"
        grid.setPosition(col: col, row: row, elevation: elevation)
        grid.tilesPerSecond = 2.1
        let wobble = SKAction.sequence([
            SKAction.scaleX(to: 1.08, duration: 0.45),
            SKAction.scaleX(to: 0.94, duration: 0.45),
        ])
        run(.repeatForever(wobble))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func startWandering() {
        pickRandomDirection()
        stateMachine.enter(GloomerMoveState.self)
    }

    func pickRandomDirection() {
        guard let movement else { return }
        let options = InputController.IsoDirection.allCases.filter {
            movement.canMove(from: grid.cell, direction: $0)
        }
        grid.direction = options.randomElement()
    }

    func applySpeedMultiplier(_ multiplier: CGFloat) {
        grid.tilesPerSecond = 2.1 * multiplier
    }

    @discardableResult
    func updateMovement(dt: TimeInterval) -> Bool {
        guard let movement else { return false }
        return grid.update(dt: dt, movement: movement) { [weak self] in
            self?.stateMachine.enter(GloomerChooseDirectionState.self)
        }
    }

    func applyScreenPosition(from map: IsoMap) {
        grid.apply(to: self, map: map, zBias: -0.02)
    }
}

// MARK: - GK states

final class GloomerMoveState: GKState {
    private weak var gloomer: Gloomer?

    init(gloomer: Gloomer) {
        self.gloomer = gloomer
        super.init()
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let gloomer, let dir = gloomer.wanderDirection else {
            stateMachine?.enter(GloomerChooseDirectionState.self)
            return
        }
        if gloomer.movement?.canMove(from: gloomer.cell, direction: dir) == false {
            stateMachine?.enter(GloomerChooseDirectionState.self)
        }
    }
}

final class GloomerChooseDirectionState: GKState {
    private weak var gloomer: Gloomer?

    init(gloomer: Gloomer) {
        self.gloomer = gloomer
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        gloomer?.pickRandomDirection()
        stateMachine?.enter(GloomerMoveState.self)
    }
}
