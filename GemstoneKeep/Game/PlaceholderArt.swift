import SpriteKit
import UIKit

/// Procedural placeholder textures — swap for sprite sheets later without touching game logic.
enum PlaceholderArt {
    private static var cache: [String: SKTexture] = [:]

    static func texture(named key: String, size: CGSize, draw: (CGContext, CGSize) -> Void) -> SKTexture {
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            draw(context.cgContext, size)
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        cache[key] = texture
        return texture
    }

    static func floorTexture(theme: String, elevation: Int) -> SKTexture {
        let colors = themeColors(theme)
        let base = colors.floor
        let highlight = colors.highlight
        let key = "floor_\(theme)_\(elevation)"
        return texture(named: key, size: CGSize(width: 64, height: 48)) { ctx, size in
            drawDiamond(ctx: ctx, size: size, fill: base, highlight: highlight, elevation: elevation)
        }
    }

    static func wallTexture(theme: String) -> SKTexture {
        let colors = themeColors(theme)
        let key = "wall_\(theme)"
        return texture(named: key, size: CGSize(width: 64, height: 56)) { ctx, size in
            drawWallBlock(ctx: ctx, size: size, fill: colors.wall, edge: colors.highlight)
        }
    }

    static func rampTexture(theme: String, direction: TileKind) -> SKTexture {
        let colors = themeColors(theme)
        let key = "ramp_\(theme)_\(direction.rawValue)"
        return texture(named: key, size: CGSize(width: 64, height: 52)) { ctx, size in
            drawRamp(ctx: ctx, size: size, fill: colors.ramp, edge: colors.highlight, direction: direction)
        }
    }

    static func stairsTexture(theme: String) -> SKTexture {
        let colors = themeColors(theme)
        let key = "stairs_\(theme)"
        return texture(named: key, size: CGSize(width: 64, height: 56)) { ctx, size in
            drawStairs(ctx: ctx, size: size, fill: colors.ramp, edge: colors.highlight)
        }
    }

    static func rookTexture() -> SKTexture {
        texture(named: "rook_v2", size: CGSize(width: 32, height: 40)) { ctx, size in
            let fur = UIColor(red: 0.52, green: 0.38, blue: 0.28, alpha: 1)
            let snout = UIColor(red: 0.68, green: 0.52, blue: 0.4, alpha: 1)
            let helm = UIColor(red: 0.78, green: 0.8, blue: 0.88, alpha: 1)
            let shadow = fur.darker().darker()

            ctx.setFillColor(shadow.cgColor)
            ctx.fillEllipse(in: CGRect(x: 5, y: 6, width: size.width - 6, height: size.height - 10))
            ctx.setFillColor(fur.cgColor)
            ctx.fillEllipse(in: CGRect(x: 4, y: 8, width: size.width - 8, height: size.height - 12))
            ctx.setFillColor(snout.cgColor)
            ctx.fillEllipse(in: CGRect(x: 10, y: 10, width: 12, height: 10))
            ctx.setFillColor(helm.cgColor)
            ctx.fill(CGRect(x: 7, y: 20, width: 18, height: 12))
            ctx.fill(CGRect(x: 9, y: 17, width: 14, height: 5))
            ctx.setFillColor(UIColor(red: 0.2, green: 0.22, blue: 0.3, alpha: 1).cgColor)
            ctx.fillEllipse(in: CGRect(x: 11, y: 23, width: 4, height: 4))
            ctx.fillEllipse(in: CGRect(x: 17, y: 23, width: 4, height: 4))
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.fillEllipse(in: CGRect(x: 12, y: 12, width: 3, height: 3))
            ctx.fillEllipse(in: CGRect(x: 17, y: 12, width: 3, height: 3))
            ctx.setFillColor(UIColor(white: 0.15, alpha: 1).cgColor)
            ctx.fill(CGRect(x: 13, y: 14, width: 6, height: 2))
        }
    }

    static func gemTexture(hueIndex: Int) -> SKTexture {
        let color = gemColor(hueIndex: hueIndex)
        let key = "gem_v2_\(hueIndex)"
        return texture(named: key, size: CGSize(width: 20, height: 24)) { ctx, size in
            let cx = size.width * 0.5
            let facets: [CGPoint] = [
                CGPoint(x: cx, y: size.height - 2),
                CGPoint(x: size.width - 2, y: size.height * 0.58),
                CGPoint(x: size.width - 3, y: size.height * 0.32),
                CGPoint(x: cx, y: 2),
                CGPoint(x: 3, y: size.height * 0.32),
                CGPoint(x: 2, y: size.height * 0.58),
            ]
            ctx.setFillColor(color.darker().cgColor)
            ctx.move(to: facets[0])
            facets.dropFirst().forEach { ctx.addLine(to: $0) }
            ctx.closePath()
            ctx.fillPath()

            ctx.setFillColor(color.cgColor)
            ctx.move(to: facets[0])
            ctx.addLine(to: facets[1])
            ctx.addLine(to: facets[3])
            ctx.addLine(to: facets[5])
            ctx.closePath()
            ctx.fillPath()

            ctx.setFillColor(color.brighter().cgColor)
            ctx.move(to: facets[0])
            ctx.addLine(to: facets[1])
            ctx.addLine(to: facets[2])
            ctx.addLine(to: facets[3])
            ctx.closePath()
            ctx.fillPath()

            ctx.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
            ctx.fill(CGRect(x: cx - 1.5, y: size.height * 0.55, width: 3, height: 5))
        }
    }

    static func gemGlowTexture(hueIndex: Int) -> SKTexture {
        let color = gemColor(hueIndex: hueIndex)
        let key = "gem_glow_\(hueIndex)"
        return texture(named: key, size: CGSize(width: 24, height: 24)) { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            ctx.setFillColor(color.withAlphaComponent(0.55).cgColor)
            ctx.fillEllipse(in: rect.insetBy(dx: 2, dy: 2))
        }
    }

    static func gemSparkleTexture() -> SKTexture {
        texture(named: "gem_sparkle", size: CGSize(width: 12, height: 12)) { ctx, size in
            ctx.setFillColor(UIColor.white.cgColor)
            let cx = size.width * 0.5
            let cy = size.height * 0.5
            ctx.fill(CGRect(x: cx - 1, y: 1, width: 2, height: size.height - 2))
            ctx.fill(CGRect(x: 1, y: cy - 1, width: size.width - 2, height: 2))
        }
    }

    static func gloomerTexture() -> SKTexture {
        texture(named: "gloomer", size: CGSize(width: 30, height: 24)) { ctx, size in
            let body = UIColor(red: 0.38, green: 0.18, blue: 0.48, alpha: 1)
            let eye = UIColor(red: 0.95, green: 0.82, blue: 0.22, alpha: 1)
            let rect = CGRect(origin: .zero, size: size)
            ctx.setFillColor(body.cgColor)
            ctx.fillEllipse(in: rect.insetBy(dx: 2, dy: 4))
            ctx.setFillColor(body.darker().cgColor)
            ctx.fillEllipse(in: CGRect(x: 4, y: 4, width: size.width - 8, height: size.height * 0.45))
            ctx.setFillColor(eye.cgColor)
            ctx.fillEllipse(in: CGRect(x: 7, y: 9, width: 5, height: 6))
            ctx.fillEllipse(in: CGRect(x: 18, y: 9, width: 5, height: 6))
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.fillEllipse(in: CGRect(x: 9, y: 11, width: 2, height: 2))
            ctx.fillEllipse(in: CGRect(x: 20, y: 11, width: 2, height: 2))
        }
    }

    static func stalkerTexture() -> SKTexture {
        texture(named: "stalker", size: CGSize(width: 32, height: 28)) { ctx, size in
            let bone = UIColor(red: 0.88, green: 0.86, blue: 0.82, alpha: 1)
            let eye = UIColor(red: 0.95, green: 0.22, blue: 0.18, alpha: 1)
            ctx.setFillColor(bone.cgColor)
            ctx.fillEllipse(in: CGRect(x: 4, y: 8, width: size.width - 8, height: size.height - 10))
            ctx.fillEllipse(in: CGRect(x: 10, y: 16, width: 12, height: 10))
            ctx.setFillColor(eye.cgColor)
            ctx.fillEllipse(in: CGRect(x: 10, y: 12, width: 5, height: 5))
            ctx.fillEllipse(in: CGRect(x: 18, y: 12, width: 5, height: 5))
            ctx.setStrokeColor(bone.darker().cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: 8, y: 20))
            ctx.addLine(to: CGPoint(x: 4, y: 6))
            ctx.move(to: CGPoint(x: 24, y: 20))
            ctx.addLine(to: CGPoint(x: 28, y: 6))
            ctx.strokePath()
        }
    }

    static func wardenTexture() -> SKTexture {
        texture(named: "warden", size: CGSize(width: 34, height: 38)) { ctx, size in
            let robe = UIColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 0.85)
            let face = UIColor(red: 0.75, green: 0.68, blue: 0.82, alpha: 1)
            let eye = UIColor(red: 0.45, green: 0.95, blue: 0.72, alpha: 1)
            ctx.setFillColor(robe.cgColor)
            ctx.fillEllipse(in: CGRect(x: 6, y: 4, width: size.width - 12, height: size.height - 8))
            ctx.setFillColor(face.cgColor)
            ctx.fillEllipse(in: CGRect(x: 11, y: 18, width: 12, height: 12))
            ctx.setFillColor(eye.cgColor)
            ctx.fillEllipse(in: CGRect(x: 13, y: 21, width: 3, height: 4))
            ctx.fillEllipse(in: CGRect(x: 18, y: 21, width: 3, height: 4))
        }
    }

    static func swarmBeeTexture() -> SKTexture {
        texture(named: "swarm_bee", size: CGSize(width: 10, height: 8)) { ctx, size in
            ctx.setFillColor(UIColor(red: 0.95, green: 0.78, blue: 0.15, alpha: 1).cgColor)
            ctx.fillEllipse(in: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))
            ctx.setFillColor(UIColor(white: 0.15, alpha: 0.7).cgColor)
            ctx.fill(CGRect(x: 2, y: 3, width: size.width - 4, height: 2))
        }
    }

    static func helmPickupTexture() -> SKTexture {
        texture(named: "helm_pickup", size: CGSize(width: 22, height: 20)) { ctx, size in
            ctx.setFillColor(UIColor(red: 0.78, green: 0.82, blue: 0.95, alpha: 1).cgColor)
            ctx.fill(CGRect(x: 4, y: 6, width: size.width - 8, height: size.height - 10))
            ctx.setFillColor(UIColor(red: 0.55, green: 0.6, blue: 0.75, alpha: 1).cgColor)
            ctx.fill(CGRect(x: 2, y: 10, width: size.width - 4, height: 6))
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)
            ctx.fill(CGRect(x: 8, y: 12, width: 6, height: 3))
        }
    }

    static func chaliceTexture() -> SKTexture {
        texture(named: "chalice", size: CGSize(width: 20, height: 24)) { ctx, size in
            let gold = UIColor(red: 0.95, green: 0.78, blue: 0.22, alpha: 1)
            ctx.setFillColor(gold.cgColor)
            ctx.fill(CGRect(x: 5, y: 10, width: 10, height: 10))
            ctx.fill(CGRect(x: 3, y: 4, width: 14, height: 8))
            ctx.setFillColor(gold.darker().cgColor)
            ctx.fill(CGRect(x: 8, y: 2, width: 4, height: 4))
            ctx.fill(CGRect(x: 7, y: 18, width: 6, height: 4))
        }
    }

    static func rookHelmPoweredTexture() -> SKTexture {
        texture(named: "rook_helm", size: CGSize(width: 32, height: 40)) { ctx, size in
            let body = UIColor(red: 0.45, green: 0.32, blue: 0.22, alpha: 1)
            let helm = UIColor(red: 0.92, green: 0.94, blue: 1.0, alpha: 1)
            let glow = UIColor(red: 0.45, green: 0.75, blue: 0.98, alpha: 0.5)
            ctx.setFillColor(glow.cgColor)
            ctx.fillEllipse(in: CGRect(x: 0, y: 4, width: size.width, height: size.height - 6))
            ctx.setFillColor(body.cgColor)
            ctx.fillEllipse(in: CGRect(x: 4, y: 8, width: size.width - 8, height: size.height - 12))
            ctx.setFillColor(helm.cgColor)
            ctx.fillEllipse(in: CGRect(x: 6, y: 18, width: 20, height: 16))
            ctx.setFillColor(UIColor(red: 0.35, green: 0.65, blue: 0.95, alpha: 1).cgColor)
            ctx.fillEllipse(in: CGRect(x: 10, y: 22, width: 5, height: 5))
            ctx.fillEllipse(in: CGRect(x: 17, y: 22, width: 5, height: 5))
        }
    }

    static func gemUIColor(hueIndex: Int) -> UIColor {
        gemColor(hueIndex: hueIndex)
    }

    private static func gemColor(hueIndex: Int) -> UIColor {
        switch hueIndex % 6 {
        case 0: return UIColor(red: 0.95, green: 0.28, blue: 0.38, alpha: 1)
        case 1: return UIColor(red: 0.35, green: 0.82, blue: 0.95, alpha: 1)
        case 2: return UIColor(red: 0.48, green: 0.92, blue: 0.42, alpha: 1)
        case 3: return UIColor(red: 0.95, green: 0.78, blue: 0.22, alpha: 1)
        case 4: return UIColor(red: 0.72, green: 0.42, blue: 0.95, alpha: 1)
        default: return UIColor(red: 0.95, green: 0.52, blue: 0.22, alpha: 1)
        }
    }

    // MARK: - Drawing primitives

    private struct ThemeColors {
        let floor: UIColor
        let wall: UIColor
        let ramp: UIColor
        let highlight: UIColor
    }

    private static func themeColors(_ theme: String) -> ThemeColors {
        switch theme {
        case "ice_spire":
            return ThemeColors(
                floor: UIColor(red: 0.72, green: 0.86, blue: 0.95, alpha: 1),
                wall: UIColor(red: 0.55, green: 0.72, blue: 0.88, alpha: 1),
                ramp: UIColor(red: 0.62, green: 0.78, blue: 0.92, alpha: 1),
                highlight: UIColor(red: 0.9, green: 0.96, blue: 1.0, alpha: 1)
            )
        case "garden_labyrinth":
            return ThemeColors(
                floor: UIColor(red: 0.42, green: 0.62, blue: 0.38, alpha: 1),
                wall: UIColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 1),
                ramp: UIColor(red: 0.48, green: 0.58, blue: 0.36, alpha: 1),
                highlight: UIColor(red: 0.72, green: 0.86, blue: 0.58, alpha: 1)
            )
        case "obsidian_tower":
            return ThemeColors(
                floor: UIColor(red: 0.28, green: 0.24, blue: 0.34, alpha: 1),
                wall: UIColor(red: 0.16, green: 0.12, blue: 0.22, alpha: 1),
                ramp: UIColor(red: 0.34, green: 0.28, blue: 0.42, alpha: 1),
                highlight: UIColor(red: 0.55, green: 0.42, blue: 0.72, alpha: 1)
            )
        default: // stone_keep
            return ThemeColors(
                floor: UIColor(red: 0.55, green: 0.52, blue: 0.48, alpha: 1),
                wall: UIColor(red: 0.38, green: 0.36, blue: 0.34, alpha: 1),
                ramp: UIColor(red: 0.48, green: 0.45, blue: 0.42, alpha: 1),
                highlight: UIColor(red: 0.72, green: 0.68, blue: 0.62, alpha: 1)
            )
        }
    }

    private static func drawDiamond(ctx: CGContext, size: CGSize, fill: UIColor, highlight: UIColor, elevation: Int) {
        let w = size.width
        let h = size.height * 0.55
        let top = CGPoint(x: w * 0.5, y: size.height - h * 0.5 - CGFloat(elevation) * 2)
        let right = CGPoint(x: w * 0.75, y: top.y - h * 0.5)
        let bottom = CGPoint(x: w * 0.5, y: right.y - h * 0.5)
        let left = CGPoint(x: w * 0.25, y: right.y)

        ctx.setFillColor(fill.darker().cgColor)
        ctx.move(to: left)
        ctx.addLine(to: bottom)
        ctx.addLine(to: right)
        ctx.closePath()
        ctx.fillPath()

        ctx.setFillColor(fill.cgColor)
        ctx.move(to: top)
        ctx.addLine(to: right)
        ctx.addLine(to: bottom)
        ctx.addLine(to: left)
        ctx.closePath()
        ctx.fillPath()

        ctx.setStrokeColor(highlight.withAlphaComponent(0.75).cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: top)
        ctx.addLine(to: right)
        ctx.strokePath()

        // Cobble cross-hatch
        ctx.setStrokeColor(fill.darker().darker().withAlphaComponent(0.25).cgColor)
        ctx.setLineWidth(0.5)
        let midX = (left.x + right.x) * 0.5
        let midY = (top.y + bottom.y) * 0.5
        ctx.move(to: CGPoint(x: midX - 6, y: midY))
        ctx.addLine(to: CGPoint(x: midX + 6, y: midY))
        ctx.move(to: CGPoint(x: midX, y: midY - 4))
        ctx.addLine(to: CGPoint(x: midX, y: midY + 4))
        ctx.strokePath()
    }

    private static func drawWallBlock(ctx: CGContext, size: CGSize, fill: UIColor, edge: UIColor) {
        drawDiamond(ctx: ctx, size: size, fill: fill, highlight: edge, elevation: 0)
        let blockHeight: CGFloat = 20
        let w = size.width
        let topY = size.height * 0.35
        ctx.setFillColor(fill.darker().cgColor)
        ctx.fill(CGRect(x: w * 0.25, y: topY - blockHeight, width: w * 0.5, height: blockHeight))
        ctx.setFillColor(edge.withAlphaComponent(0.45).cgColor)
        ctx.fill(CGRect(x: w * 0.72, y: topY - blockHeight, width: w * 0.06, height: blockHeight))

        // Brick courses
        ctx.setStrokeColor(fill.darker().darker().withAlphaComponent(0.35).cgColor)
        ctx.setLineWidth(0.6)
        for row in 0..<3 {
            let y = topY - blockHeight + CGFloat(row) * 6 + 4
            ctx.move(to: CGPoint(x: w * 0.27, y: y))
            ctx.addLine(to: CGPoint(x: w * 0.73, y: y))
            let offset: CGFloat = row % 2 == 0 ? 0 : 5
            ctx.move(to: CGPoint(x: w * 0.27 + offset, y: y - 6))
            ctx.addLine(to: CGPoint(x: w * 0.27 + offset, y: y))
        }
        ctx.strokePath()
    }

    private static func drawRamp(ctx: CGContext, size: CGSize, fill: UIColor, edge: UIColor, direction: TileKind) {
        drawDiamond(ctx: ctx, size: size, fill: fill, highlight: edge, elevation: 0)
        ctx.setFillColor(edge.withAlphaComponent(0.85).cgColor)
        let arrow: String
        switch direction {
        case .rampNorth: arrow = "▲"
        case .rampSouth: arrow = "▼"
        case .rampEast: arrow = "▶"
        case .rampWest: arrow = "◀"
        default: arrow = "↗"
        }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        let text = arrow as NSString
        let textSize = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: (size.width - textSize.width) * 0.5, y: size.height * 0.38), withAttributes: attrs)
    }

    private static func drawStairs(ctx: CGContext, size: CGSize, fill: UIColor, edge: UIColor) {
        drawDiamond(ctx: ctx, size: size, fill: fill, highlight: edge, elevation: 0)
        for i in 0..<3 {
            let y = size.height * 0.42 + CGFloat(i) * 5
            ctx.setFillColor(edge.withAlphaComponent(0.7).cgColor)
            ctx.fill(CGRect(x: size.width * 0.3, y: y, width: size.width * 0.4, height: 3))
        }
    }
}

private extension UIColor {
    func darker() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * 0.75, green: g * 0.75, blue: b * 0.75, alpha: a)
    }

    func brighter() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(1, r * 1.2 + 0.08), green: min(1, g * 1.2 + 0.08), blue: min(1, b * 1.2 + 0.08), alpha: a)
    }
}
