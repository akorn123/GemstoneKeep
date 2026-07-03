import SpriteKit

/// Post-run camp — bank soul gems and buy meta upgrades.
final class CampOverlay: SKNode {
    var onRetry: (() -> Void)?

    private let dim = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.86), size: .zero)
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let summaryLabel = SKLabelNode(fontNamed: "Menlo")
    private let soulsLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let retryLabel = SKLabelNode(fontNamed: "Menlo")
    private var offerNodes: [CampOfferNode] = []
    private var offers: [MetaUpgradeDef] = []

    override init() {
        super.init()
        name = "campOverlay"
        isHidden = true
        zPosition = 23_000

        dim.zPosition = 0
        addChild(dim)

        panel.fillColor = UIColor(red: 0.1, green: 0.08, blue: 0.14, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.75, green: 0.55, blue: 0.95, alpha: 0.85)
        panel.lineWidth = 2
        panel.zPosition = 1
        addChild(panel)

        titleLabel.text = "CAMP — RUN ENDED"
        titleLabel.fontSize = 17
        titleLabel.fontColor = UIColor(red: 0.85, green: 0.7, blue: 0.98, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 2
        addChild(titleLabel)

        summaryLabel.fontSize = 11
        summaryLabel.fontColor = UIColor(white: 0.8, alpha: 1)
        summaryLabel.numberOfLines = 0
        summaryLabel.horizontalAlignmentMode = .center
        summaryLabel.preferredMaxLayoutWidth = 280
        summaryLabel.zPosition = 2
        addChild(summaryLabel)

        soulsLabel.fontSize = 13
        soulsLabel.fontColor = UIColor(red: 0.75, green: 0.55, blue: 0.98, alpha: 1)
        soulsLabel.horizontalAlignmentMode = .center
        soulsLabel.zPosition = 2
        addChild(soulsLabel)

        retryLabel.text = "Tap to descend again"
        retryLabel.fontSize = 11
        retryLabel.fontColor = UIColor(white: 0.6, alpha: 0.9)
        retryLabel.horizontalAlignmentMode = .center
        retryLabel.zPosition = 2
        addChild(retryLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    func layout(for viewSize: CGSize, cameraScale: CGFloat) {
        let w = viewSize.width / cameraScale
        let h = viewSize.height / cameraScale
        dim.size = CGSize(width: w * 1.4, height: h * 1.4)

        let panelW = min(320, w * 0.9)
        let panelH: CGFloat = 310
        panel.path = CGPath(
            roundedRect: CGRect(x: -panelW * 0.5, y: -panelH * 0.5, width: panelW, height: panelH),
            cornerWidth: 10, cornerHeight: 10, transform: nil
        )

        titleLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 34)
        summaryLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 72)
        soulsLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 108)
        var y: CGFloat = 20
        for node in offerNodes {
            node.layout(width: panelW - 32)
            node.position = CGPoint(x: 0, y: y)
            y -= 52
        }
        retryLabel.position = CGPoint(x: 0, y: -panelH * 0.5 + 22)
    }

    func present(
        floorsCleared: Int,
        walletRemaining: Int,
        soulsBanked: Int,
        offers: [MetaUpgradeDef]
    ) {
        self.offers = offers
        offerNodes.forEach { $0.removeFromParent() }
        offerNodes.removeAll()

        for def in offers {
            let node = CampOfferNode(
                def: def,
                canAfford: MetaProgression.shared.soulGems >= def.cost
            )
            node.zPosition = 2
            addChild(node)
            offerNodes.append(node)
        }

        summaryLabel.text = "Floors cleared: \(floorsCleared)\nWallet lost: \(walletRemaining) gems"
        soulsLabel.text = "Soul gems: \(MetaProgression.shared.soulGems) (+\(soulsBanked) this run)"
        isHidden = false
        alpha = 0
        run(.fadeIn(withDuration: 0.25))
    }

    func refreshSouls() {
        soulsLabel.text = "Soul gems: \(MetaProgression.shared.soulGems)"
        for (node, def) in zip(offerNodes, offers) {
            node.update(canAfford: MetaProgression.shared.soulGems >= def.cost)
        }
    }

    func dismiss() {
        run(.sequence([
            .fadeOut(withDuration: 0.2),
            .run { [weak self] in self?.isHidden = true },
        ]))
    }

    func handleTap(at location: CGPoint) -> Bool {
        guard !isHidden else { return false }
        if let path = panel.path, !path.boundingBox.contains(location) {
            finish()
            return true
        }
        if location.y < retryLabel.position.y + 24 {
            finish()
            return true
        }
        return true
    }

    func offerIndex(at location: CGPoint) -> Int? {
        for (index, node) in offerNodes.enumerated() where node.hitRect.contains(location) {
            return index
        }
        return nil
    }

    private func finish() {
        dismiss()
        onRetry?()
    }
}

private final class CampOfferNode: SKNode {
    let hitRect: CGRect
    private let bg = SKShapeNode()
    private let nameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let detailLabel = SKLabelNode(fontNamed: "Menlo")
    private let priceLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    init(def: MetaUpgradeDef, canAfford: Bool) {
        hitRect = CGRect(x: -150, y: -20, width: 300, height: 40)
        super.init()
        name = def.id.rawValue

        bg.fillColor = UIColor(white: 0.1, alpha: 0.95)
        bg.strokeColor = canAfford
            ? UIColor(red: 0.7, green: 0.5, blue: 0.95, alpha: 0.85)
            : UIColor(white: 0.35, alpha: 0.5)
        bg.lineWidth = 1.5
        addChild(bg)

        nameLabel.text = def.name
        nameLabel.fontSize = 12
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.fontColor = .white
        addChild(nameLabel)

        detailLabel.text = def.detail
        detailLabel.fontSize = 9
        detailLabel.horizontalAlignmentMode = .left
        detailLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        addChild(detailLabel)

        priceLabel.text = "\(def.cost) souls"
        priceLabel.fontSize = 11
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.fontColor = canAfford
            ? UIColor(red: 0.8, green: 0.65, blue: 1, alpha: 1)
            : UIColor(red: 0.9, green: 0.4, blue: 0.4, alpha: 1)
        addChild(priceLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    func layout(width: CGFloat) {
        bg.path = CGPath(
            roundedRect: CGRect(x: -width * 0.5, y: -20, width: width, height: 40),
            cornerWidth: 6, cornerHeight: 6, transform: nil
        )
        nameLabel.position = CGPoint(x: -width * 0.5 + 10, y: 4)
        detailLabel.position = CGPoint(x: -width * 0.5 + 10, y: -12)
        priceLabel.position = CGPoint(x: width * 0.5 - 10, y: -4)
    }

    func update(canAfford: Bool) {
        bg.strokeColor = canAfford
            ? UIColor(red: 0.7, green: 0.5, blue: 0.95, alpha: 0.85)
            : UIColor(white: 0.35, alpha: 0.5)
        priceLabel.fontColor = canAfford
            ? UIColor(red: 0.8, green: 0.65, blue: 1, alpha: 1)
            : UIColor(red: 0.9, green: 0.4, blue: 0.4, alpha: 1)
    }
}
