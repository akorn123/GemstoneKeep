import SpriteKit
import UIKit

/// Loads textures from Assets.xcassets when present, otherwise enhanced procedural art.
enum GameArt {
    private static var cache: [String: SKTexture] = [:]

    static func floorTexture(theme: String, elevation: Int) -> SKTexture {
        load("tile_floor_\(theme)_\(elevation)") {
            PlaceholderArt.floorTexture(theme: theme, elevation: elevation)
        }
    }

    static func wallTexture(theme: String) -> SKTexture {
        load("tile_wall_\(theme)") { PlaceholderArt.wallTexture(theme: theme) }
    }

    static func rampTexture(theme: String, direction: TileKind) -> SKTexture {
        load("tile_ramp_\(theme)_\(direction.rawValue)") {
            PlaceholderArt.rampTexture(theme: theme, direction: direction)
        }
    }

    static func stairsTexture(theme: String) -> SKTexture {
        load("tile_stairs_\(theme)") { PlaceholderArt.stairsTexture(theme: theme) }
    }

    static func rookTexture() -> SKTexture {
        load("rook") { PlaceholderArt.rookTexture() }
    }

    static func rookHelmPoweredTexture() -> SKTexture {
        load("rook_helm") { PlaceholderArt.rookHelmPoweredTexture() }
    }

    static func gemTexture(hueIndex: Int) -> SKTexture {
        load("gem_\(hueIndex % 6)") { PlaceholderArt.gemTexture(hueIndex: hueIndex) }
    }

    static func gemGlowTexture(hueIndex: Int) -> SKTexture {
        load("gem_glow_\(hueIndex % 6)") { PlaceholderArt.gemGlowTexture(hueIndex: hueIndex) }
    }

    static func gemSparkleTexture() -> SKTexture {
        load("gem_sparkle") { PlaceholderArt.gemSparkleTexture() }
    }

    static func gemUIColor(hueIndex: Int) -> UIColor {
        PlaceholderArt.gemUIColor(hueIndex: hueIndex)
    }

    static func gloomerTexture() -> SKTexture {
        load("gloomer") { PlaceholderArt.gloomerTexture() }
    }

    static func stalkerTexture() -> SKTexture {
        load("stalker") { PlaceholderArt.stalkerTexture() }
    }

    static func wardenTexture() -> SKTexture {
        load("warden") { PlaceholderArt.wardenTexture() }
    }

    static func swarmBeeTexture() -> SKTexture {
        load("swarm_bee") { PlaceholderArt.swarmBeeTexture() }
    }

    static func helmPickupTexture() -> SKTexture {
        load("pickup_helm") { PlaceholderArt.helmPickupTexture() }
    }

    static func chaliceTexture() -> SKTexture {
        load("pickup_chalice") { PlaceholderArt.chaliceTexture() }
    }

    /// Shared procedural texture helper (CRT overlays, etc.).
    static func texture(named key: String, size: CGSize, draw: (CGContext, CGSize) -> Void) -> SKTexture {
        PlaceholderArt.texture(named: key, size: size, draw: draw)
    }

    private static func load(_ name: String, fallback: () -> SKTexture) -> SKTexture {
        if let cached = cache[name] { return cached }
        if let image = UIImage(named: name), image.size.width > 2 {
            let texture = SKTexture(image: image)
            texture.filteringMode = .nearest
            cache[name] = texture
            return texture
        }
        let texture = fallback()
        cache[name] = texture
        return texture
    }
}
