import SpriteKit

/// SKView and scene tuning for stable 60fps on device.
enum PerformanceTuner {
    static func configure(_ view: SKView) {
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.shouldCullNonVisibleNodes = true
        view.showsFPS = GameSettings.showDebugFPS
        view.showsNodeCount = GameSettings.showDebugFPS
    }

    static func applySceneDefaults(_ scene: SKScene) {
        scene.shouldEnableEffects = true
    }
}
