import SpriteKit

/// Collectible gem with sparkle and glow placeholder visuals.
final class Gem: SKNode {
    let cell: MovementSystem.Cell
    let hueIndex: Int

    init(cell: MovementSystem.Cell, hueIndex: Int) {
        self.cell = cell
        self.hueIndex = hueIndex
        super.init()
        name = "gem"
        buildVisuals()
        startAnimations()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    private func buildVisuals() {
        let glow = SKSpriteNode(texture: GameArt.gemGlowTexture(hueIndex: hueIndex))
        glow.name = "glow"
        glow.alpha = 0.45
        glow.setScale(1.35)
        glow.zPosition = -0.02
        addChild(glow)

        let sprite = SKSpriteNode(texture: GameArt.gemTexture(hueIndex: hueIndex))
        sprite.name = "sprite"
        sprite.zPosition = 0
        addChild(sprite)

        let sparkle = SKSpriteNode(texture: GameArt.gemSparkleTexture())
        sparkle.name = "sparkle"
        sparkle.alpha = 0.85
        sparkle.setScale(0.55)
        sparkle.zPosition = 0.02
        addChild(sparkle)
    }

    private func startAnimations() {
        let pulseUp = SKAction.scale(to: 1.12, duration: 0.55)
        let pulseDown = SKAction.scale(to: 0.92, duration: 0.55)
        pulseUp.timingMode = .easeInEaseOut
        pulseDown.timingMode = .easeInEaseOut
        childNode(withName: "sprite")?.run(.repeatForever(.sequence([pulseUp, pulseDown])))

        if let glow = childNode(withName: "glow") {
            let fadeIn = SKAction.fadeAlpha(to: 0.65, duration: 0.7)
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.7)
            glow.run(.repeatForever(.sequence([fadeIn, fadeOut])))
        }

        if let sparkle = childNode(withName: "sparkle") {
            let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            let twinkle = SKAction.sequence([
                .group([
                    .fadeAlpha(to: 1.0, duration: 0.25),
                    .scale(to: 0.75, duration: 0.25),
                ]),
                .group([
                    .fadeAlpha(to: 0.25, duration: 0.35),
                    .scale(to: 0.45, duration: 0.35),
                ]),
            ])
            sparkle.run(.repeatForever(spin))
            sparkle.run(.repeatForever(twinkle))

            let orbit = SKAction.sequence([
                .moveBy(x: 4, y: 2, duration: 0.6),
                .moveBy(x: -4, y: -2, duration: 0.6),
            ])
            sparkle.run(.repeatForever(orbit))
        }

        children.compactMap { $0 as? SKSpriteNode }.forEach { sprite in
            sprite.texture?.filteringMode = .nearest
        }
    }

    func playCollectAnimation(completion: @escaping () -> Void) {
        removeAllActions()
        children.forEach { $0.removeAllActions() }
        let pop = SKAction.group([
            .scale(to: 1.5, duration: 0.12),
            .fadeOut(withDuration: 0.14),
        ])
        run(.sequence([pop, .removeFromParent()]), completion: completion)
    }

    func playEatenAnimation() {
        removeAllActions()
        children.forEach { $0.removeAllActions() }
        let sink = SKAction.group([
            .scale(to: 0.2, duration: 0.22),
            .fadeOut(withDuration: 0.22),
            .moveBy(x: 0, y: -8, duration: 0.22),
        ])
        run(.sequence([sink, .removeFromParent()]))
    }
}
