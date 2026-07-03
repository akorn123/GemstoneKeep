import SpriteKit

/// Spawns and updates all enemy types for the current level.
final class EnemySystem {
    let container = SKNode()

    private var gloomers: [Gloomer] = []
    private var stalkers: [Stalker] = []
    private var wardens: [Warden] = []
    private var swarms: [Swarm] = []

    private var pathfinder: Pathfinder?
    private var tierSpeedMultiplier: CGFloat = 1.0
    private var playerSpeedMultiplier: CGFloat = 1.0
    private var speedMultiplier: CGFloat = 1.0
    private weak var map: IsoMap?
    private weak var movement: MovementSystem?

    func reset(
        level: LevelDefinition,
        map: IsoMap,
        movement: MovementSystem,
        spawn: MovementSystem.Cell,
        tier: DifficultyScaler.Tier,
        playerEnemySpeedMultiplier: CGFloat = 1
    ) {
        container.removeAllChildren()
        gloomers.removeAll()
        stalkers.removeAll()
        wardens.removeAll()
        swarms.removeAll()

        self.map = map
        self.movement = movement
        tierSpeedMultiplier = tier.speedMultiplier
        playerSpeedMultiplier = playerEnemySpeedMultiplier
        applyCombinedSpeedMultiplier()
        pathfinder = Pathfinder(movement: movement)

        var usedCells: [MovementSystem.Cell] = [spawn]
        var rng = SeededRNG(seed: UInt64(level.id) &* 9_177)

        func takeSpawnCells(_ count: Int) -> [MovementSystem.Cell] {
            guard count > 0 else { return [] }
            var candidates = map.walkableTiles.values.map {
                MovementSystem.Cell(col: $0.col, row: $0.row, elevation: $0.elevation)
            }
            candidates.removeAll { usedCells.contains($0) }
            candidates.shuffle(using: &rng)
            let picked = Array(candidates.prefix(count))
            usedCells.append(contentsOf: picked)
            return picked
        }

        for cell in takeSpawnCells(tier.gloomerCount) {
            let gloomer = Gloomer(col: cell.col, row: cell.row, elevation: cell.elevation)
            gloomer.movement = movement
            gloomer.applySpeedMultiplier(speedMultiplier)
            gloomer.applyScreenPosition(from: map)
            gloomer.startWandering()
            gloomers.append(gloomer)
            container.addChild(gloomer)
        }

        for cell in takeSpawnCells(tier.stalkerCount) {
            let stalker = Stalker(col: cell.col, row: cell.row, elevation: cell.elevation)
            stalker.movement = movement
            stalker.pathfinder = pathfinder
            stalker.applySpeedMultiplier(speedMultiplier)
            stalker.startChasing()
            stalkers.append(stalker)
            container.addChild(stalker)
        }

        for cell in takeSpawnCells(tier.wardenCount) {
            let warden = Warden(col: cell.col, row: cell.row, elevation: cell.elevation)
            warden.movement = movement
            warden.pathfinder = pathfinder
            warden.map = map
            warden.applySpeedMultiplier(speedMultiplier)
            warden.startHunting()
            wardens.append(warden)
            container.addChild(warden)
        }

        if tier.hasSwarm {
            let patrol = Self.buildSwarmPatrol(level: level, map: map)
            if patrol.count >= 2 {
                let swarm = Swarm(patrol: patrol)
                swarm.applySpeedMultiplier(speedMultiplier)
                swarms.append(swarm)
                container.addChild(swarm)
            }
        }
    }

    func setPlayerEnemySpeedMultiplier(_ multiplier: CGFloat) {
        playerSpeedMultiplier = multiplier
        applyCombinedSpeedMultiplier()
    }

    private func applyCombinedSpeedMultiplier() {
        speedMultiplier = tierSpeedMultiplier * playerSpeedMultiplier
        for gloomer in gloomers { gloomer.applySpeedMultiplier(speedMultiplier) }
        for stalker in stalkers { stalker.applySpeedMultiplier(speedMultiplier) }
        for warden in wardens { warden.applySpeedMultiplier(speedMultiplier) }
        for swarm in swarms { swarm.applySpeedMultiplier(speedMultiplier) }
    }

    func update(
        dt: TimeInterval,
        gemField: GemField,
        rookCell: MovementSystem.Cell,
        onGemStolen: (() -> Void)? = nil
    ) {
        guard let map, let movement else { return }

        for gloomer in gloomers {
            gloomer.stateMachine.update(deltaTime: dt)
            if gloomer.updateMovement(dt: dt) {
                if gemField.consumeByEnemy(at: gloomer.cell) {
                    onGemStolen?()
                }
            }
            gloomer.applyScreenPosition(from: map)
        }

        for stalker in stalkers {
            stalker.update(dt: dt, target: rookCell, map: map)
        }

        for warden in wardens {
            warden.update(dt: dt, target: rookCell)
        }

        for swarm in swarms {
            swarm.update(dt: dt, movement: movement, map: map)
        }
    }

    func containsEnemy(at cell: MovementSystem.Cell) -> Bool {
        enemyCells().contains(cell)
    }

    func destroyEnemies(at cell: MovementSystem.Cell) {
        gloomers.removeAll { g in
            if g.cell == cell {
                g.run(.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()]))
                return true
            }
            return false
        }
        stalkers.removeAll { s in
            if s.cell == cell {
                s.run(.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()]))
                return true
            }
            return false
        }
        wardens.removeAll { w in
            if w.cell == cell {
                w.run(.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()]))
                return true
            }
            return false
        }
        swarms.removeAll { s in
            if s.cell == cell {
                s.run(.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()]))
                return true
            }
            return false
        }
    }

    func enemyCells() -> [MovementSystem.Cell] {
        var cells: [MovementSystem.Cell] = []
        cells.append(contentsOf: gloomers.map(\.cell))
        cells.append(contentsOf: stalkers.map(\.cell))
        cells.append(contentsOf: wardens.map(\.cell))
        cells.append(contentsOf: swarms.map(\.cell))
        return cells
    }

    func spawnEmergencyWarden(level: LevelDefinition, map: IsoMap, movement: MovementSystem, near cell: MovementSystem.Cell) {
        guard wardens.count < 2, let pathfinder else { return }
        let spawn = cell
        guard map.isWalkable(col: spawn.col, row: spawn.row, elevation: spawn.elevation) else { return }
        let warden = Warden(col: spawn.col, row: spawn.row, elevation: spawn.elevation)
        warden.movement = movement
        warden.pathfinder = pathfinder
        warden.map = map
        warden.applySpeedMultiplier(speedMultiplier)
        warden.startHunting()
        wardens.append(warden)
        container.addChild(warden)
    }

    /// Connected NE diagonal sweep along the ground floor.
    static func buildSwarmPatrol(level: LevelDefinition, map: IsoMap) -> [MovementSystem.Cell] {
        var path: [MovementSystem.Cell] = []
        var col = 1
        var row = level.height - 2

        while col < level.width - 1 && row >= 1 {
            let cell = MovementSystem.Cell(col: col, row: row, elevation: 0)
            if map.isWalkable(col: col, row: row, elevation: 0) {
                path.append(cell)
            }
            col += 1
            row -= 1
        }
        return path
    }
}

/// Deterministic shuffle for reproducible enemy placement per level.
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
