import GameController
import SpriteKit
import UIKit

/// Swipe-to-move with junction buffering, right-half jump tap, and game-controller support.
final class InputController {
    enum IsoDirection: CaseIterable {
        case northEast
        case southEast
        case southWest
        case northWest

        var gridDelta: (col: Int, row: Int) {
            switch self {
            case .northEast: return (1, -1)
            case .southEast: return (1, 1)
            case .southWest: return (-1, 1)
            case .northWest: return (-1, -1)
            }
        }

        var screenVector: CGPoint {
            switch self {
            case .northEast: return CGPoint(x: 1, y: 0.5)
            case .southEast: return CGPoint(x: 1, y: -0.5)
            case .southWest: return CGPoint(x: -1, y: -0.5)
            case .northWest: return CGPoint(x: -1, y: 0.5)
            }
        }

        var opposite: IsoDirection {
            switch self {
            case .northEast: return .southWest
            case .southEast: return .northWest
            case .southWest: return .northEast
            case .northWest: return .southEast
            }
        }
    }

    private var swipeStart: CGPoint?
    private var swipeStartIsLeftHalf = true
    private let swipeThreshold: CGFloat = 22

    /// Active run direction — Rook keeps moving until blocked.
    private(set) var runDirection: IsoDirection?

    /// Buffered turn applied at the next junction.
    private(set) var bufferedDirection: IsoDirection?

    private(set) var jumpPressed = false

    var useVirtualJoystick = false

    // MARK: - Touch

    func touchesBegan(at viewPoint: CGPoint, viewWidth: CGFloat) {
        swipeStart = viewPoint
        swipeStartIsLeftHalf = viewPoint.x < viewWidth * 0.5
    }

    func touchesEnded(at viewPoint: CGPoint, viewWidth: CGFloat) {
        defer { swipeStart = nil }
        guard let start = swipeStart else { return }

        let dx = viewPoint.x - start.x
        let dy = viewPoint.y - start.y
        let distance = hypot(dx, dy)

        if distance < swipeThreshold {
            if !swipeStartIsLeftHalf {
                jumpPressed = true
            }
            return
        }

        guard swipeStartIsLeftHalf else { return }
        setRunDirection(classifySwipe(dx: dx, dy: dy))
    }

    func consumeJump() -> Bool {
        let pressed = jumpPressed
        jumpPressed = false
        return pressed
    }

    func activeDirection() -> IsoDirection? {
        runDirection
    }

    func clearMovement() {
        runDirection = nil
        bufferedDirection = nil
    }

    func setRunDirection(_ direction: IsoDirection) {
        bufferedDirection = direction
        if runDirection == nil {
            runDirection = direction
        }
    }

    /// Apply a buffered swipe immediately when Rook is centered on a tile.
    func tryImmediateTurn(movement: MovementSystem, at cell: MovementSystem.Cell, atJunction: Bool) {
        guard atJunction, let buffered = bufferedDirection else { return }
        if movement.canMove(from: cell, direction: buffered) {
            runDirection = buffered
            bufferedDirection = nil
        }
    }

    /// Apply buffered turn at a tile boundary. Returns true if direction changed.
    @discardableResult
    func applyBufferedTurn(movement: MovementSystem, at cell: MovementSystem.Cell) -> Bool {
        guard let buffered = bufferedDirection else { return false }
        if movement.canMove(from: cell, direction: buffered) {
            let changed = runDirection != buffered
            runDirection = buffered
            bufferedDirection = nil
            return changed
        }
        bufferedDirection = nil
        return false
    }

    // MARK: - Game controller

    func pollControllers(movement: MovementSystem, at cell: MovementSystem.Cell) {
        guard let controller = GCController.controllers().first,
              let pad = controller.extendedGamepad ?? controller.microGamepad else { return }

        let lx = pad.leftThumbstick.xAxis.value
        let ly = pad.leftThumbstick.yAxis.value
        if let dir = directionFromStick(dx: CGFloat(lx), dy: CGFloat(ly)) {
            setRunDirection(dir)
        }

        if pad.buttonA.isPressed || pad.buttonX.isPressed {
            jumpPressed = true
        }
    }

    private func directionFromStick(dx: CGFloat, dy: CGFloat) -> IsoDirection? {
        guard hypot(dx, dy) > 0.35 else { return nil }
        return classifySwipe(dx: dx, dy: -dy)
    }

    private func classifySwipe(dx: CGFloat, dy: CGFloat) -> IsoDirection {
        let angle = atan2(dy, dx)
        let quadrant = (angle + .pi) / (.pi / 2)
        switch Int(round(quadrant)) % 4 {
        case 0: return .southWest
        case 1: return .northWest
        case 2: return .northEast
        default: return .southEast
        }
    }
}
