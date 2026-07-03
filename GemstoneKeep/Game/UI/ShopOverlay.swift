import SpriteKit

/// Between-floor shop — pick one of three augments.
final class ShopOverlay: SKNode {
    var onFinished: (() -> Void)?

    private let dim = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.84), size: .zero)
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let walletLabel = SKLabelNode(fontNamed: "Menlo")
    private let skipLabel = SKLabelNode(fontNamed: "Menlo")
    private var offerNodes: [ShopOfferNode] = []
    private var offers: [AugmentDef] = []

    override init() {
        super.init()
        name = "shopOverlay"
        isHidden = true
        zPosition = 22_000

        dim.zPosition = 0
        addChild(dim)

        panel.fillColor = UIColor(red: 0.08, green: 0.12, blue: 0.14, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.45, green: 0.88, blue: 0.72, alpha: 0.9)
        panel.lineWidth = 2
        panel.zPosition = 1
        addChild(panel)

        titleLabel.text = "SHRINE — SPEND GEMS"
        titleLabel.fontSize = 16
        titleLabel.fontColor = UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 2
        addChild(titleLabel)

        walletLabel.fontSize = 12
        walletLabel.fontColor = UIColor(white: 0.85, alpha: 1)
        walletLabel.horizontalAlignmentMode = .center
        walletLabel.zPosition = 2
        addChild(walletLabel)

        skipLabel.text = "Tap below to skip"
        skipLabel.fontSize = 11
        skipLabel.fontColor = UIColor(white: 0.55, alpha: 0.9)
        skipLabel.horizontalAlignmentMode = .center
        skipLabel.zPosition = 2
        addChild(skipLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func layout(for viewSize: CGSize, cameraScale: CGFloat) {
        let w = viewSize.width / cameraScale
        let h = viewSize.height / cameraScale
        dim.size = CGSize(width: w * 1.4, height: h * 1.4)

        let panelW = min(320, w * 0.9)
        let panelH: CGFloat = 280
        panel.path = CGPath(
            roundedRect: CGRect(x: -panelW * 0.5, y: -panelH * 0.5, width: panelW, height: panelH),
            cornerWidth: 10, cornerHeight: 10, transform: nil
        )

        titleLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 36)
        walletLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 58)
        var y: CGFloat = 40
        for node in offerNodes {
            node.layout(width: panelW - 32)
            node.position = CGPoint(x: 0, y: y)
            y -= 58
        }
        skipLabel.position = CGPoint(x: 0, y: -panelH * 0.5 + 22)
    }

    func present(
        offers: [AugmentDef],
        wallet: Int,
        discount: CGFloat,
        run: RunState
    ) {
        self.offers = offers
        offerNodes.forEach { $0.removeFromParent() }
        offerNodes.removeAll()

        for def in offers {
            let node = ShopOfferNode(def: def, discount: discount, canAfford: run.canBuy(def, discount: discount))
            node.zPosition = 2
            addChild(node)
            offerNodes.append(node)
        }

        walletLabel.text = "Wallet: \(wallet) gems"
        isHidden = false
        alpha = 0
        run(.fadeIn(withDuration: 0.22))
    }

    func refreshWallet(_ wallet: Int, discount: CGFloat, run: RunState) {
        walletLabel.text = "Wallet: \(wallet) gems"
        for (node, def) in zip(offerNodes, offers) {
            node.update(canAfford: run.canBuy(def, discount: discount))
        }
    }

    func dismiss() {
        run(.sequence([
            .fadeOut(withDuration: 0.18),
            .run { [weak self] in self?.isHidden = true },
        ]))
    }

    func handleTap(at location: CGPoint) -> Bool {
        guard !isHidden else { return false }

        for node in offerNodes where node.hitRect.contains(location) {
            return node.name != nil
        }

        if let path = panel.path, !path.boundingBox.contains(location) {
            finish()
        } else if location.y < skipLabel.position.y + 20 {
            finish()
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
        onFinished?()
    }
}

private final class ShopOfferNode: SKNode {
    let hitRect: CGRect
    private let priceLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let nameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let detailLabel = SKLabelNode(fontNamed: "Menlo")
    private let bg = SKShapeNode()

    init(def: AugmentDef, discount: CGFloat, canAfford: Bool) {
        nameLabel.text = def.name
        detailLabel.text = def.detail
        let price = AugmentCatalog.discountedCost(def.cost, discount: discount)
        priceLabel.text = "\(price)g"
        hitRect = CGRect(x: -150, y: -22, width: 300, height: 44)
        super.init()
        name = def.id.rawValue

        bg.fillColor = UIColor(white: 0.12, alpha: 0.95)
        bg.strokeColor = canAfford
            ? UIColor(red: 0.45, green: 0.85, blue: 0.65, alpha: 0.8)
            : UIColor(white: 0.35, alpha: 0.6)
        bg.lineWidth = 1.5
        bg.zPosition = 0
        addChild(bg)

        nameLabel.fontSize = 13
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.zPosition = 1
        addChild(nameLabel)

        detailLabel.fontSize = 10
        detailLabel.fontColor = UIColor(white: 0.72, alpha: 1)
        detailLabel.horizontalAlignmentMode = .left
        detailLabel.zPosition = 1
        addChild(detailLabel)

        priceLabel.fontSize = 13
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.fontColor = canAfford
            ? UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1)
            : UIColor(red: 0.9, green: 0.45, blue: 0.45, alpha: 1)
        priceLabel.zPosition = 1
        addChild(priceLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    func layout(width: CGFloat) {
        bg.path = CGPath(
            roundedRect: CGRect(x: -width * 0.5, y: -22, width: width, height: 44),
            cornerWidth: 6, cornerHeight: 6, transform: nil
        )
        nameLabel.position = CGPoint(x: -width * 0.5 + 10, y: 2)
        detailLabel.position = CGPoint(x: -width * 0.5 + 10, y: -14)
        priceLabel.position = CGPoint(x: width * 0.5 - 10, y: -6)
    }

    func update(canAfford: Bool) {
        bg.strokeColor = canAfford
            ? UIColor(red: 0.45, green: 0.85, blue: 0.65, alpha: 0.8)
            : UIColor(white: 0.35, alpha: 0.6)
        priceLabel.fontColor = canAfford
            ? UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1)
            : UIColor(red: 0.9, green: 0.45, blue: 0.45, alpha: 1)
    }
}
