import CoreGraphics
import SpriteKit

/// Resolves grid movement including ramps, stairs, and elevation changes.
final class MovementSystem {
    struct Cell: Hashable, Equatable {
        var col: Int
        var row: Int
        var elevation: Int
    }

    struct StairLink: Equatable {
        let from: Cell
        let direction: InputController.IsoDirection
        let to: Cell
    }

    private let map: IsoMap
    private let stairLinks: [StairLink]

    init(map: IsoMap, level: LevelDefinition) {
        self.map = map
        self.stairLinks = Self.stairLinks(from: level)
    }

    static func stairLinks(from level: LevelDefinition) -> [StairLink] {
        var links: [StairLink] = []
        let stairs = level.tiles.filter { $0.kind == .stairs }
        for tile in stairs {
            let from = Cell(col: tile.col, row: tile.row, elevation: tile.elevation)
            for dir in InputController.IsoDirection.allCases {
                let d = dir.gridDelta
                let nc = tile.col + d.col
                let nr = tile.row + d.row
                guard let partner = stairs.first(where: {
                    $0.col == nc && $0.row == nr && $0.elevation != tile.elevation
                }) else { continue }
                let to = Cell(col: partner.col, row: partner.row, elevation: partner.elevation)
                let link = StairLink(from: from, direction: dir, to: to)
                if !links.contains(where: { $0.from == link.from && $0.direction == link.direction }) {
                    links.append(link)
                }
            }
        }
        return links
    }

    func destination(from cell: Cell, direction: InputController.IsoDirection) -> Cell? {
        let delta = direction.gridDelta

        if let stair = stairLinks.first(where: {
            $0.from == cell && $0.direction == direction
        }) {
            return stair.to
        }

        let nc = cell.col + delta.col
        let nr = cell.row + delta.row

        if map.isWalkable(col: nc, row: nr, elevation: cell.elevation) {
            return Cell(col: nc, row: nr, elevation: cell.elevation)
        }

        if let current = map.tile(col: cell.col, row: cell.row, elevation: cell.elevation),
           map.isRamp(current.kind),
           map.rampAscendDirection(current.kind) == direction,
           map.isWalkable(col: nc, row: nr, elevation: cell.elevation + 1) {
            return Cell(col: nc, row: nr, elevation: cell.elevation + 1)
        }

        if map.isWalkable(col: nc, row: nr, elevation: cell.elevation - 1) {
            if let dest = map.tile(col: nc, row: nr, elevation: cell.elevation - 1) {
                if map.isRamp(dest.kind) {
                    if map.rampAscendDirection(dest.kind) == direction.opposite {
                        return Cell(col: nc, row: nr, elevation: cell.elevation - 1)
                    }
                } else if dest.kind == .floor || dest.kind == .stairs {
                    return Cell(col: nc, row: nr, elevation: cell.elevation - 1)
                }
            }
        }

        if map.isWalkable(col: nc, row: nr, elevation: cell.elevation + 1),
           let current = map.tile(col: cell.col, row: cell.row, elevation: cell.elevation),
           map.isRamp(current.kind),
           map.rampAscendDirection(current.kind) == direction {
            return Cell(col: nc, row: nr, elevation: cell.elevation + 1)
        }

        return nil
    }

    func canMove(from cell: Cell, direction: InputController.IsoDirection) -> Bool {
        destination(from: cell, direction: direction) != nil
    }
}
