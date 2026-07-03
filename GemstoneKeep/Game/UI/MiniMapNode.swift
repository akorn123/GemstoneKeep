import SpriteKit

/// Corner mini-map — maze outline, gems, enemies, and Rook.
final class MiniMapNode: SKNode {
    private let background = SKShapeNode()
    private let tilesNode = SKNode()
    private let dotsNode = SKNode()
    private let rookDot = SKShapeNode(circleOfRadius: 2.2)
    private let exitDot = SKShapeNode(circleOfRadius: 2.4)

    private var levelWidth = 1
    private var levelHeight = 1
    private let mapSize: CGFloat = 76
    private var gemDots: [SKShapeNode] = []
    private var enemyDots: [SKShapeNode] = []

    override init() {
        super.init()
        name = "miniMap"

        background.fillColor = UIColor(white: 0.04, alpha: 0.82)
        background.strokeColor = UIColor(white: 0.35, alpha: 0.7)
        background.lineWidth = 1
        background.zPosition = 0
        addChild(background)

        tilesNode.zPosition = 1
        addChild(tilesNode)

        dotsNode.zPosition = 2
        addChild(dotsNode)

        rookDot.fillColor = .white
        rookDot.strokeColor = .clear
        rookDot.zPosition = 3
        addChild(rookDot)

        exitDot.fillColor = UIColor(red: 0.45, green: 0.85, blue: 0.95, alpha: 0.95)
        exitDot.strokeColor = .clear
        exitDot.zPosition = 2.5
        exitDot.isHidden = true
        addChild(exitDot)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func configure(level: LevelDefinition, map: IsoMap, exitCell: MovementSystem.Cell? = nil) {
        levelWidth = level.width
        levelHeight = level.height
        tilesNode.removeAllChildren()
        gemDots.removeAll()
        enemyDots.removeAll()
        dotsNode.removeAllChildren()

        if let exitCell {
            exitDot.isHidden = false
            exitDot.position = mapPoint(col: exitCell.col, row: exitCell.row)
        } else {
            exitDot.isHidden = true
        }

        background.path = CGPath(
            roundedRect: CGRect(x: -mapSize * 0.5 - 4, y: -mapSize * 0.5 - 4, width: mapSize + 8, height: mapSize + 8),
            cornerWidth: 4,
            cornerHeight: 4,
            transform: nil
        )

        for tile in level.tiles {
            let isWalkable: Bool
            switch tile.kind {
            case .floor, .rampNorth, .rampSouth, .rampEast, .rampWest, .stairs:
                isWalkable = true
            case .wall, .pit:
                isWalkable = false
            }
            let dot = SKShapeNode(rectOf: CGSize(width: 2.2, height: 1.4))
            dot.fillColor = isWalkable
                ? UIColor(white: 0.28, alpha: 0.55)
                : UIColor(white: 0.12, alpha: 0.35)
            dot.strokeColor = .clear
            dot.position = mapPoint(col: tile.col, row: tile.row)
            tilesNode.addChild(dot)
        }
    }

    func update(
        rookCell: MovementSystem.Cell,
        gemCells: [MovementSystem.Cell],
        enemyCells: [MovementSystem.Cell]
    ) {
        syncDots(&gemDots, cells: gemCells, color: UIColor(red: 0.4, green: 0.9, blue: 0.55, alpha: 0.95), radius: 1.6)
        syncDots(&enemyDots, cells: enemyCells, color: UIColor(red: 0.95, green: 0.3, blue: 0.35, alpha: 0.95), radius: 1.8)
        rookDot.position = mapPoint(col: rookCell.col, row: rookCell.row)
    }

    func updateRookOnly(_ rookCell: MovementSystem.Cell) {
        rookDot.position = mapPoint(col: rookCell.col, row: rookCell.row)
    }

    private func syncDots(
        _ pool: inout [SKShapeNode],
        cells: [MovementSystem.Cell],
        color: UIColor,
        radius: CGFloat
    ) {
        while pool.count < cells.count {
            let dot = SKShapeNode(circleOfRadius: radius)
            dot.strokeColor = .clear
            dotsNode.addChild(dot)
            pool.append(dot)
        }
        while pool.count > cells.count {
            pool.removeLast().removeFromParent()
        }
        for (dot, cell) in zip(pool, cells) {
            dot.fillColor = color
            dot.position = mapPoint(col: cell.col, row: cell.row)
            dot.isHidden = false
        }
    }

    private func mapPoint(col: Int, row: Int) -> CGPoint {
        let nx = (CGFloat(col) + 0.5) / CGFloat(levelWidth)
        let ny = (CGFloat(row) + 0.5) / CGFloat(levelHeight)
        return CGPoint(
            x: (nx - 0.5) * mapSize,
            y: (ny - 0.5) * mapSize
        )
    }

    func layout(in viewSize: CGSize, cameraScale: CGFloat) {
        let halfW = viewSize.width * 0.5 / cameraScale
        let halfH = viewSize.height * 0.5 / cameraScale
        let inset: CGFloat = 18 / cameraScale
        position = CGPoint(x: -halfW + mapSize * 0.5 + inset, y: -halfH + mapSize * 0.5 + inset)
    }
}
