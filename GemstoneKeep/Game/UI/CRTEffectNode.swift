import SpriteKit
import UIKit

/// Retro CRT overlay — scanlines, vignette, and subtle phosphor flicker.
final class CRTEffectNode: SKNode {
    private let scanlines = SKSpriteNode()
    private let vignette = SKSpriteNode()
    private var flickerPhase: TimeInterval = 0

    override init() {
        super.init()
        name = "crtEffect"
        isUserInteractionEnabled = false
        zPosition = 99_000

        scanlines.texture = Self.scanlineTexture()
        scanlines.blendMode = .alpha
        scanlines.alpha = 0.55
        scanlines.zPosition = 1
        addChild(scanlines)

        vignette.texture = Self.vignetteTexture()
        vignette.blendMode = .multiply
        vignette.alpha = 0.72
        vignette.zPosition = 2
        addChild(vignette)

        applySettings()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func applySettings() {
        isHidden = !GameSettings.crtEnabled
    }

    func layout(for viewSize: CGSize, cameraScale: CGFloat = 1) {
        let w = viewSize.width / cameraScale
        let h = viewSize.height / cameraScale
        let size = CGSize(width: w * 1.15, height: h * 1.15)
        scanlines.size = size
        vignette.size = size
    }

    func update(dt: TimeInterval) {
        guard !isHidden else { return }
        flickerPhase += dt
        let flicker = 0.96 + 0.04 * sin(flickerPhase * 9.5)
        scanlines.alpha = CGFloat(flicker) * 0.55
    }

    private static func scanlineTexture() -> SKTexture {
        GameArt.texture(named: "crt_scanlines", size: CGSize(width: 8, height: 128)) { ctx, size in
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
            ctx.setFillColor(UIColor(white: 0, alpha: 0.22).cgColor)
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(CGRect(x: 0, y: y, width: size.width, height: 1))
                y += 3
            }
        }
    }

    private static func vignetteTexture() -> SKTexture {
        GameArt.texture(named: "crt_vignette", size: CGSize(width: 128, height: 128)) { ctx, size in
            let colors = [
                UIColor.white.cgColor,
                UIColor(white: 0.55, alpha: 1).cgColor,
                UIColor(white: 0.15, alpha: 1).cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.35, 0.72, 1.0]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) else { return }
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let radius = size.width * 0.72
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: .drawsAfterEndLocation
            )
        }
    }
}
