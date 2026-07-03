import SpriteKit

/// Shown when the player reaches the floor exit portal.
final class LevelClearOverlay: SKNode {
    var onContinue: (() -> Void)?

    private let dim = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.72), size: .zero)
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let detailLabel = SKLabelNode(fontNamed: "Menlo")
    private let continueLabel = SKLabelNode(fontNamed: "Menlo")

    override init() {
        super.init()
        name = "levelClearOverlay"
        isHidden = true
        zPosition = 20_000

        dim.zPosition = 0
        addChild(dim)

        panel.fillColor = UIColor(red: 0.1, green: 0.09, blue: 0.16, alpha: 0.95)
        panel.strokeColor = UIColor(red: 0.55, green: 0.78, blue: 0.95, alpha: 0.9)
        panel.lineWidth = 2
        panel.zPosition = 1
        addChild(panel)

        titleLabel.fontSize = 20
        titleLabel.fontColor = UIColor(red: 0.95, green: 0.88, blue: 0.45, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 2
        addChild(titleLabel)

        scoreLabel.fontSize = 26
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 2
        addChild(scoreLabel)

        detailLabel.fontSize = 12
        detailLabel.fontColor = UIColor(white: 0.78, alpha: 1)
        detailLabel.numberOfLines = 0
        detailLabel.horizontalAlignmentMode = .center
        detailLabel.preferredMaxLayoutWidth = 260
        detailLabel.zPosition = 2
        addChild(detailLabel)

        continueLabel.fontSize = 11
        continueLabel.fontColor = UIColor(white: 0.65, alpha: 0.9)
        continueLabel.horizontalAlignmentMode = .center
        continueLabel.zPosition = 2
        addChild(continueLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func layout(for viewSize: CGSize, cameraScale: CGFloat) {
        let w = viewSize.width / cameraScale
        let h = viewSize.height / cameraScale
        dim.size = CGSize(width: w * 1.4, height: h * 1.4)

        let panelW: CGFloat = min(300, w * 0.82)
        let panelH: CGFloat = 200
        panel.path = CGPath(
            roundedRect: CGRect(x: -panelW * 0.5, y: -panelH * 0.5, width: panelW, height: panelH),
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )

        titleLabel.position = CGPoint(x: 0, y: 52)
        scoreLabel.position = CGPoint(x: 0, y: 10)
        detailLabel.position = CGPoint(x: 0, y: -30)
        continueLabel.position = CGPoint(x: 0, y: -72)
    }

    func present(summary: LevelClearSummary, nextLevelName: String?, floorNumber: Int) {
        isHidden = false
        alpha = 0
        titleLabel.text = "FLOOR \(floorNumber) CLEARED"
        scoreLabel.text = "\(summary.walletGems) gems"

        var lines: [String] = [
            "Wallet: \(summary.walletGems) spendable gems",
            "Gems this floor: \(summary.gemsCollected)",
            "Score: \(summary.totalScore)",
        ]
        if summary.timeBonus > 0 {
            let secs = Int(summary.elapsedTime)
            lines.append("Time \(secs / 60):\(String(format: "%02d", secs % 60)) — +\(summary.timeBonus) score")
        }
        detailLabel.text = lines.joined(separator: "\n")

        if let next = nextLevelName {
            continueLabel.text = "Tap to descend to \(next)"
        } else {
            continueLabel.text = "Tap to descend deeper"
        }

        run(.fadeIn(withDuration: 0.25))
        HapticsManager.levelClear()
    }

    func dismiss() {
        run(.sequence([
            .fadeOut(withDuration: 0.2),
            .run { [weak self] in self?.isHidden = true },
        ]))
    }

    func handleTap() {
        dismiss()
        onContinue?()
    }
}
