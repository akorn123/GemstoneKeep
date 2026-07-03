import SpriteKit

/// Glowing exit portal — reach it to descend to the next floor.
final class ExitPortal: SKNode {
    let cell: MovementSystem.Cell

    init(cell: MovementSystem.Cell, map: IsoMap) {
        self.cell = cell
        super.init()
        name = "exitPortal"
        buildVisuals(map: map)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    private func buildVisuals(map: IsoMap) {
        let glow = SKShapeNode(circleOfRadius: 14)
        glow.fillColor = UIColor(red: 0.45, green: 0.85, blue: 0.95, alpha: 0.35)
        glow.strokeColor = UIColor(red: 0.55, green: 0.95, blue: 1.0, alpha: 0.85)
        glow.lineWidth = 2
        glow.zPosition = -0.02
        addChild(glow)

        let core = SKShapeNode(circleOfRadius: 6)
        core.fillColor = UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 0.95)
        core.strokeColor = .clear
        core.zPosition = 0.01
        addChild(core)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "EXIT"
        label.fontSize = 8
        label.fontColor = UIColor(white: 1, alpha: 0.9)
        label.position = CGPoint(x: 0, y: 16)
        label.zPosition = 0.02
        addChild(label)

        var pos = map.screenPosition(col: cell.col, row: cell.row, elevation: cell.elevation)
        pos.y += 8
        position = pos
        zPosition = IsoMath.zPosition(
            col: cell.col,
            row: cell.row,
            elevation: cell.elevation,
            layerOffset: IsoMath.zEntityOffset - 0.06
        )

        let pulse = SKAction.sequence([
            .scale(to: 1.08, duration: 0.7),
            .scale(to: 0.94, duration: 0.7),
        ])
        run(.repeatForever(pulse))
    }
}
