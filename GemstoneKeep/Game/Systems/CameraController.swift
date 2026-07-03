import SpriteKit

/// Smooth follow camera with directional lead, trauma-based screen shake.
final class CameraController {
    let cameraNode: SKCameraNode

    private var targetPosition: CGPoint = .zero
    private var leadDirection: CGPoint = .zero
    private let leadDistance: CGFloat = 48
    private let lerpFactor: CGFloat = 0.12

    private var shakeTrauma: CGFloat = 0
    private var shakeOffset: CGPoint = .zero
    private var shakeSeed: UInt64 = 0xC0FFEE

    init(cameraNode: SKCameraNode) {
        self.cameraNode = cameraNode
    }

    func configure(for viewSize: CGSize, portrait: Bool) {
        let visibleTiles: CGFloat = portrait ? 7 : 9
        let scale = IsoMath.cameraScale(for: viewSize, visibleTiles: visibleTiles)
        cameraNode.setScale(1.0 / scale)
    }

    func setLeadDirection(_ direction: CGPoint) {
        if direction != .zero {
            leadDirection = direction
        }
    }

    func snap(to worldPosition: CGPoint) {
        targetPosition = worldPosition
        applyPosition(around: worldPosition)
    }

    func follow(worldPosition: CGPoint, dt: TimeInterval) {
        targetPosition = worldPosition
        let desired = framedPosition(around: worldPosition)
        let t = min(1.0, lerpFactor + CGFloat(dt) * 2.0)
        let base = cameraNode.position.lerp(to: desired, t: t)
        updateShake(dt: dt)
        cameraNode.position = CGPoint(x: base.x + shakeOffset.x, y: base.y + shakeOffset.y)
    }

    /// Pan without follow lerp — used during level intro flyover.
    func pan(to worldPosition: CGPoint, dt: TimeInterval) {
        targetPosition = worldPosition
        let t = min(1.0, 0.18 + CGFloat(dt) * 3.0)
        let base = cameraNode.position.lerp(to: worldPosition, t: t)
        updateShake(dt: dt)
        cameraNode.position = CGPoint(x: base.x + shakeOffset.x, y: base.y + shakeOffset.y)
    }

    func addShake(intensity: CGFloat) {
        shakeTrauma = min(1.0, shakeTrauma + intensity)
    }

    private func applyPosition(around focus: CGPoint) {
        updateShake(dt: 0)
        let base = framedPosition(around: focus)
        cameraNode.position = CGPoint(x: base.x + shakeOffset.x, y: base.y + shakeOffset.y)
    }

    private func framedPosition(around focus: CGPoint) -> CGPoint {
        let lead = leadDirection.normalized() * leadDistance
        return CGPoint(x: focus.x + lead.x, y: focus.y + lead.y)
    }

    private func updateShake(dt: TimeInterval) {
        shakeTrauma = max(0, shakeTrauma - CGFloat(dt) * 2.8)
        guard shakeTrauma > 0.001 else {
            shakeOffset = .zero
            return
        }
        let magnitude = shakeTrauma * shakeTrauma * 14
        shakeSeed = shakeSeed &* 1_103_515_245 &+ 12_345
        let rx = pseudoRandom(shakeSeed) * 2 - 1
        shakeSeed = shakeSeed &* 1_103_515_245 &+ 54_321
        let ry = pseudoRandom(shakeSeed) * 2 - 1
        shakeOffset = CGPoint(x: rx * magnitude, y: ry * magnitude)
    }

    private func pseudoRandom(_ seed: UInt64) -> CGFloat {
        CGFloat((seed >> 16) & 0xFFFF) / CGFloat(0xFFFF)
    }
}

private extension CGPoint {
    func lerp(to other: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(x: x + (other.x - x) * t, y: y + (other.y - y) * t)
    }

    func normalized() -> CGPoint {
        let len = sqrt(x * x + y * y)
        guard len > 0.0001 else { return .zero }
        return CGPoint(x: x / len, y: y / len)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
