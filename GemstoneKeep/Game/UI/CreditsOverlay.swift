import SpriteKit

/// Credits and legal info for the title screen.
final class CreditsOverlay: SKNode {
    var onClose: (() -> Void)?

    private let dim = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.85), size: .zero)
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let bodyLabel = SKLabelNode(fontNamed: "Menlo")
    private let closeLabel = SKLabelNode(fontNamed: "Menlo")

    override init() {
        super.init()
        name = "creditsOverlay"
        isHidden = true
        zPosition = 31_000

        dim.zPosition = 0
        addChild(dim)

        panel.fillColor = UIColor(red: 0.1, green: 0.09, blue: 0.15, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.75, green: 0.65, blue: 0.35, alpha: 0.85)
        panel.lineWidth = 2
        panel.zPosition = 1
        addChild(panel)

        titleLabel.text = "CREDITS"
        titleLabel.fontSize = 18
        titleLabel.fontColor = UIColor(red: 0.95, green: 0.88, blue: 0.45, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 2
        addChild(titleLabel)

        bodyLabel.fontSize = 11
        bodyLabel.fontColor = UIColor(white: 0.82, alpha: 1)
        bodyLabel.numberOfLines = 0
        bodyLabel.horizontalAlignmentMode = .center
        bodyLabel.preferredMaxLayoutWidth = 270
        bodyLabel.zPosition = 2
        bodyLabel.text = """
        Gemstone Keep v1.0

        Design & Code
        Staple Games

        A tribute to classic isometric
        arcade castles — built with
        Swift & SpriteKit.

        No data collected. No ads.
        Game Center optional.

        © 2026 Staple Games
        """
        addChild(bodyLabel)

        closeLabel.text = "Tap outside to close"
        closeLabel.fontSize = 11
        closeLabel.fontColor = UIColor(white: 0.6, alpha: 0.9)
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.zPosition = 2
        addChild(closeLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func layout(for viewSize: CGSize, cameraScale: CGFloat = 1) {
        let w = viewSize.width / cameraScale
        let h = viewSize.height / cameraScale
        dim.size = CGSize(width: w * 1.4, height: h * 1.4)

        let panelW = min(320, w * 0.88)
        let panelH: CGFloat = 300
        panel.path = CGPath(
            roundedRect: CGRect(x: -panelW * 0.5, y: -panelH * 0.5, width: panelW, height: panelH),
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )

        titleLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 40)
        bodyLabel.position = CGPoint(x: 0, y: 10)
        closeLabel.position = CGPoint(x: 0, y: -panelH * 0.5 + 24)
    }

    func present() {
        isHidden = false
        alpha = 0
        run(.fadeIn(withDuration: 0.2))
    }

    func dismiss() {
        run(.sequence([
            .fadeOut(withDuration: 0.18),
            .run { [weak self] in self?.isHidden = true },
        ]))
    }

    func handleTap(at location: CGPoint) -> Bool {
        guard !isHidden else { return false }
        if let path = panel.path, !path.boundingBox.contains(location) {
            dismiss()
            onClose?()
        }
        return true
    }
}
