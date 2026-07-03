import SpriteKit

/// Short particle burst when a gem is collected.
enum GemSparkleBurst {
    static func emit(
        at position: CGPoint,
        in parent: SKNode,
        hueIndex: Int,
        zPosition: CGFloat
    ) {
        let color = GameArt.gemUIColor(hueIndex: hueIndex)
        let count = 8
        for i in 0..<count {
            let spark = SKSpriteNode(texture: GameArt.gemSparkleTexture())
            spark.color = color
            spark.colorBlendFactor = 0.65
            spark.setScale(CGFloat.random(in: 0.35...0.7))
            spark.position = position
            spark.zPosition = zPosition + 0.05
            spark.alpha = 0.95
            parent.addChild(spark)

            let angle = (CGFloat(i) / CGFloat(count)) * (.pi * 2) + CGFloat.random(in: -0.2...0.2)
            let distance = CGFloat.random(in: 18...36)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance + 8
            let duration = TimeInterval.random(in: 0.22...0.38)

            spark.run(.sequence([
                .group([
                    .moveBy(x: dx, y: dy, duration: duration),
                    .scale(to: 0.05, duration: duration),
                    .fadeOut(withDuration: duration),
                    .rotate(byAngle: CGFloat.random(in: -1.5...1.5), duration: duration),
                ]),
                .removeFromParent(),
            ]))
        }

        let flash = SKShapeNode(circleOfRadius: 6)
        flash.fillColor = color.withAlphaComponent(0.55)
        flash.strokeColor = .clear
        flash.position = position
        flash.zPosition = zPosition + 0.04
        parent.addChild(flash)
        flash.run(.sequence([
            .group([
                .scale(to: 2.8, duration: 0.18),
                .fadeOut(withDuration: 0.18),
            ]),
            .removeFromParent(),
        ]))
    }
}
