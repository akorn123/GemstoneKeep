import CoreGraphics
import SpriteKit

/// Shared isometric math for Gemstone Keep (2:1 diamond tiles).
enum IsoMath {
    static let tileWidth: CGFloat = 64
    static let tileHeight: CGFloat = 32
    static let elevationStep: CGFloat = 24

    /// Draw-order scale per diagonal step on the tile graph.
    static let zTileStep: CGFloat = 1.0

    /// Ensures an entire elevation layer sorts above the layer below at overlaps.
    static let zElevationStep: CGFloat = 100.0

    /// Floor tiles sit at the base of their cell.
    static let zFloorOffset: CGFloat = 0.0

    /// Vertical faces (walls, ramp sides) draw above the floor diamond they share.
    static let zWallOffset: CGFloat = 0.35

    /// Walkable entities draw above floor tiles at the same grid cell.
    static let zEntityOffset: CGFloat = 0.5

    /// Converts grid coordinates to scene-space position (origin at map center).
    static func gridToScreen(col: Int, row: Int, elevation: Int = 0) -> CGPoint {
        let halfW = tileWidth * 0.5
        let halfH = tileHeight * 0.5
        let x = CGFloat(col - row) * halfW
        let y = CGFloat(col + row) * halfH + CGFloat(elevation) * elevationStep
        return CGPoint(x: x, y: -y)
    }

    /// Depth key for painter's-algorithm ordering in SpriteKit.
    ///
    /// Sorting rule: larger `row + col` draws in front (farther south on screen).
    /// Higher elevation draws in front of lower tiles that overlap in screen space.
    /// Layer offsets break ties within the same cell.
    static func zPosition(col: Int, row: Int, elevation: Int, layerOffset: CGFloat) -> CGFloat {
        CGFloat(row + col) * zTileStep + CGFloat(elevation) * zElevationStep + layerOffset
    }

    /// Entity z-order while moving between cells (fractional grid position).
    static func entityZPosition(col: CGFloat, row: CGFloat, elevation: Int) -> CGFloat {
        CGFloat(row + col) * zTileStep + CGFloat(elevation) * zElevationStep + zEntityOffset
    }

    /// Visible tile span for camera zoom (~7×7 area in portrait).
    static func cameraScale(for viewSize: CGSize, visibleTiles: CGFloat = 7) -> CGFloat {
        let targetWidth = visibleTiles * tileWidth
        let targetHeight = visibleTiles * tileHeight * 1.4
        let scaleX = viewSize.width / targetWidth
        let scaleY = viewSize.height / targetHeight
        return min(scaleX, scaleY) * 1.15
    }
}
