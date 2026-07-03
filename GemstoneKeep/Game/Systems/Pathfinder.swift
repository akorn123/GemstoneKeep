import GameplayKit
import SpriteKit

/// A* pathfinding on the isometric walk graph (ramps, stairs, elevation).
final class Pathfinder {
    private let movement: MovementSystem

    init(movement: MovementSystem) {
        self.movement = movement
    }

    func direction(from start: MovementSystem.Cell, to goal: MovementSystem.Cell) -> InputController.IsoDirection? {
        guard start != goal else { return nil }
        guard let path = findPath(from: start, to: goal), path.count >= 2 else {
            return greedyDirection(from: start, toward: goal)
        }
        return linkDirection(from: path[0], to: path[1])
    }

    func findPath(from start: MovementSystem.Cell, to goal: MovementSystem.Cell) -> [MovementSystem.Cell]? {
        guard start != goal else { return [start] }

        struct Node {
            let cell: MovementSystem.Cell
            let g: Int
            let f: Int
        }

        var open: [Node] = [Node(cell: start, g: 0, f: heuristic(start, goal))]
        var cameFrom: [MovementSystem.Cell: MovementSystem.Cell] = [:]
        var gScore: [MovementSystem.Cell: Int] = [start: 0]
        var closed: Set<MovementSystem.Cell> = []

        while !open.isEmpty {
            open.sort { $0.f < $1.f }
            let current = open.removeFirst()
            if closed.contains(current.cell) { continue }
            closed.insert(current.cell)

            if current.cell == goal {
                var path = [goal]
                var cursor = goal
                while let prev = cameFrom[cursor] {
                    path.insert(prev, at: 0)
                    cursor = prev
                }
                return path
            }

            for dir in InputController.IsoDirection.allCases {
                guard let next = movement.destination(from: current.cell, direction: dir) else { continue }
                if closed.contains(next) { continue }
                let g = current.g + 1
                if let known = gScore[next], known <= g { continue }
                cameFrom[next] = current.cell
                gScore[next] = g
                open.append(Node(cell: next, g: g, f: g + heuristic(next, goal)))
            }
        }

        return nil
    }

    private func greedyDirection(
        from start: MovementSystem.Cell,
        toward goal: MovementSystem.Cell
    ) -> InputController.IsoDirection? {
        var best: InputController.IsoDirection?
        var bestScore = Int.max
        for dir in InputController.IsoDirection.allCases {
            guard let next = movement.destination(from: start, direction: dir) else { continue }
            let score = heuristic(next, goal)
            if score < bestScore {
                bestScore = score
                best = dir
            }
        }
        return best
    }

    private func linkDirection(
        from start: MovementSystem.Cell,
        to next: MovementSystem.Cell
    ) -> InputController.IsoDirection? {
        for dir in InputController.IsoDirection.allCases {
            if movement.destination(from: start, direction: dir) == next {
                return dir
            }
        }
        return nil
    }

    private func heuristic(_ a: MovementSystem.Cell, _ b: MovementSystem.Cell) -> Int {
        abs(a.col - b.col) + abs(a.row - b.row) + abs(a.elevation - b.elevation) * 3
    }
}
