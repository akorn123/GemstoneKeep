import SpriteKit

/// Toggle panel for sound, haptics, mini-map, and debug HUD.
final class SettingsOverlay: SKNode {
    var onClose: (() -> Void)?

    private let dim = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.82), size: .zero)
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var rows: [SettingsRow] = []
    private let closeLabel = SKLabelNode(fontNamed: "Menlo")

    override init() {
        super.init()
        name = "settingsOverlay"
        isHidden = true
        zPosition = 30_000

        dim.zPosition = 0
        addChild(dim)

        panel.fillColor = UIColor(red: 0.1, green: 0.1, blue: 0.16, alpha: 0.97)
        panel.strokeColor = UIColor(white: 0.55, alpha: 0.85)
        panel.lineWidth = 2
        panel.zPosition = 1
        addChild(panel)

        titleLabel.text = "SETTINGS"
        titleLabel.fontSize = 18
        titleLabel.fontColor = UIColor(red: 0.92, green: 0.86, blue: 0.55, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 2
        addChild(titleLabel)

        rows = [
            SettingsRow(label: "Haptics", getter: { GameSettings.hapticsEnabled }, setter: { GameSettings.hapticsEnabled = $0 }),
            SettingsRow(label: "Sound", getter: { GameSettings.soundEnabled }, setter: { GameSettings.soundEnabled = $0 }),
            SettingsRow(label: "Music", getter: { GameSettings.musicEnabled }, setter: {
                GameSettings.musicEnabled = $0
                MusicManager.shared.refresh()
            }),
            SettingsRow(label: "Mini-map", getter: { GameSettings.showMiniMap }, setter: { GameSettings.showMiniMap = $0 }),
            SettingsRow(label: "CRT filter", getter: { GameSettings.crtEnabled }, setter: { GameSettings.crtEnabled = $0 }),
            SettingsRow(label: "Debug FPS", getter: { GameSettings.showDebugFPS }, setter: { GameSettings.showDebugFPS = $0 }),
        ]
        for row in rows {
            row.node.zPosition = 2
            addChild(row.node)
        }

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

        let panelW = min(300, w * 0.84)
        let panelH: CGFloat = 328
        panel.path = CGPath(
            roundedRect: CGRect(x: -panelW * 0.5, y: -panelH * 0.5, width: panelW, height: panelH),
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )

        titleLabel.position = CGPoint(x: 0, y: panelH * 0.5 - 36)
        var y: CGFloat = 36
        for row in rows {
            row.layout(width: panelW - 40)
            row.node.position = CGPoint(x: 0, y: y)
            y -= 34
        }
        closeLabel.position = CGPoint(x: 0, y: -panelH * 0.5 + 24)
    }

    func present() {
        isHidden = false
        alpha = 0
        refresh()
        run(.fadeIn(withDuration: 0.2))
    }

    func dismiss() {
        run(.sequence([
            .fadeOut(withDuration: 0.18),
            .run { [weak self] in self?.isHidden = true },
        ]))
    }

    func refresh() {
        rows.forEach { $0.refresh() }
    }

    func handleTap(at location: CGPoint) -> Bool {
        guard !isHidden else { return false }

        for row in rows {
            let center = row.node.position
            let hit = CGRect(x: center.x - 130, y: center.y - 14, width: 260, height: 28)
            if hit.contains(location) {
                row.toggle()
                HapticsManager.menuTap()
                return true
            }
        }

        if let path = panel.path, !path.boundingBox.contains(location) {
            dismiss()
            onClose?()
        }
        return true
    }
}

private final class SettingsRow {
    let node = SKNode()
    private let label = SKLabelNode(fontNamed: "Menlo")
    private let valueLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let getter: () -> Bool
    private let setter: (Bool) -> Void

    init(label title: String, getter: @escaping () -> Bool, setter: @escaping (Bool) -> Void) {
        self.getter = getter
        self.setter = setter
        label.text = title
        label.fontSize = 14
        label.fontColor = UIColor(white: 0.88, alpha: 1)
        label.horizontalAlignmentMode = .left
        valueLabel.fontSize = 14
        valueLabel.horizontalAlignmentMode = .right
        node.addChild(label)
        node.addChild(valueLabel)
        refresh()
    }

    func layout(width: CGFloat) {
        label.position = CGPoint(x: -width * 0.5, y: -5)
        valueLabel.position = CGPoint(x: width * 0.5, y: -5)
    }

    func refresh() {
        let on = getter()
        valueLabel.text = on ? "ON" : "OFF"
        valueLabel.fontColor = on
            ? UIColor(red: 0.5, green: 0.92, blue: 0.65, alpha: 1)
            : UIColor(red: 0.9, green: 0.45, blue: 0.45, alpha: 1)
    }

    func toggle() {
        setter(!getter())
        refresh()
    }
}
