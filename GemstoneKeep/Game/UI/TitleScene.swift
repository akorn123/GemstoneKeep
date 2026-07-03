import SpriteKit
import UIKit

/// Main menu — play, settings, Game Center boards.
final class TitleScene: SKScene {
    private let settingsOverlay = SettingsOverlay()
    private let creditsOverlay = CreditsOverlay()
    private let crtEffect = CRTEffectNode()
    private var playButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private var settingsButton = SKLabelNode(fontNamed: "Menlo")
    private var boardsButton = SKLabelNode(fontNamed: "Menlo")
    private var achievementsButton = SKLabelNode(fontNamed: "Menlo")
    private var creditsButton = SKLabelNode(fontNamed: "Menlo")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo")
    private var subtitleLabel = SKLabelNode(fontNamed: "Menlo")
    private var versionLabel = SKLabelNode(fontNamed: "Menlo")

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.08, green: 0.07, blue: 0.12, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        HapticsManager.prepare()
        AudioManager.prepare()
        PerformanceTuner.applySceneDefaults(self)
        GameCenterManager.shared.authenticate()
        MusicManager.shared.play(.title)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "GEMSTONE KEEP"
        title.fontSize = 26
        title.fontColor = UIColor(red: 0.95, green: 0.88, blue: 0.45, alpha: 1)
        title.name = "title"
        addChild(title)

        subtitleLabel.text = "Roguelite descent — gather gems, reach the exit."
        subtitleLabel.fontSize = 12
        subtitleLabel.fontColor = UIColor(white: 0.72, alpha: 0.85)
        subtitleLabel.name = "subtitle"
        addChild(subtitleLabel)

        playButton.text = "▶  PLAY"
        playButton.fontSize = 22
        playButton.fontColor = UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1)
        playButton.name = "play"
        addChild(playButton)

        settingsButton.text = "Settings"
        settingsButton.fontSize = 14
        settingsButton.fontColor = UIColor(white: 0.8, alpha: 0.9)
        settingsButton.name = "settings"
        addChild(settingsButton)

        boardsButton.text = "Leaderboards"
        boardsButton.fontSize = 14
        boardsButton.fontColor = UIColor(white: 0.8, alpha: 0.9)
        boardsButton.name = "boards"
        addChild(boardsButton)

        achievementsButton.text = "Achievements"
        achievementsButton.fontSize = 13
        achievementsButton.fontColor = UIColor(white: 0.75, alpha: 0.88)
        achievementsButton.name = "achievements"
        addChild(achievementsButton)

        creditsButton.text = "Credits"
        creditsButton.fontSize = 13
        creditsButton.fontColor = UIColor(white: 0.75, alpha: 0.88)
        creditsButton.name = "credits"
        addChild(creditsButton)

        highScoreLabel.fontSize = 12
        highScoreLabel.fontColor = UIColor(white: 0.65, alpha: 0.85)
        highScoreLabel.name = "highScore"
        addChild(highScoreLabel)

        versionLabel.fontSize = 10
        versionLabel.fontColor = UIColor(white: 0.45, alpha: 0.8)
        versionLabel.name = "version"
        versionLabel.text = "v\(Bundle.main.appVersion)"
        addChild(versionLabel)

        settingsOverlay.onClose = { [weak self] in
            self?.applyDebugHUD()
            self?.crtEffect.applySettings()
            MusicManager.shared.refresh()
        }
        addChild(settingsOverlay)
        addChild(creditsOverlay)
        addChild(crtEffect)

        layoutMenu()
        refreshHighScore()
        applyDebugHUD()

        let pulse = SKAction.sequence([
            .scale(to: 1.04, duration: 0.9),
            .scale(to: 1.0, duration: 0.9),
        ])
        playButton.run(.repeatForever(pulse))
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutMenu()
        settingsOverlay.layout(for: size)
        creditsOverlay.layout(for: size)
        crtEffect.layout(for: size)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        crtEffect.update(dt: dt)
    }

    private var lastUpdateTime: TimeInterval = 0

    private func layoutMenu() {
        let h = size.height
        childNode(withName: "title")?.position = CGPoint(x: 0, y: h * 0.22)
        subtitleLabel.position = CGPoint(x: 0, y: h * 0.22 - 34)
        playButton.position = CGPoint(x: 0, y: -h * 0.02)
        settingsButton.position = CGPoint(x: -88, y: -h * 0.15)
        boardsButton.position = CGPoint(x: 88, y: -h * 0.15)
        achievementsButton.position = CGPoint(x: -72, y: -h * 0.22)
        creditsButton.position = CGPoint(x: 72, y: -h * 0.22)
        highScoreLabel.position = CGPoint(x: 0, y: -h * 0.30)
        versionLabel.position = CGPoint(x: 0, y: -h * 0.36)
        settingsOverlay.layout(for: size)
        creditsOverlay.layout(for: size)
        crtEffect.layout(for: size)
        crtEffect.applySettings()
    }

    private func refreshHighScore() {
        let best = PlayerProgress.shared.highScore
        highScoreLabel.text = best > 0 ? "Best: \(best) · Souls: \(MetaProgression.shared.soulGems)" : "Souls: \(MetaProgression.shared.soulGems)"
    }

    private func applyDebugHUD() {
        view?.showsFPS = GameSettings.showDebugFPS
        view?.showsNodeCount = GameSettings.showDebugFPS
    }

    private func startGame() {
        guard let view else { return }
        AudioManager.playMenuTap()
        HapticsManager.menuTap()
        MusicManager.shared.play(.gameplay)
        let game = GameScene(size: size)
        game.scaleMode = .resizeFill
        view.presentScene(game, transition: .fade(withDuration: 0.45))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if settingsOverlay.handleTap(at: location) {
            if settingsOverlay.isHidden {
                applyDebugHUD()
                MusicManager.shared.refresh()
            }
            return
        }

        if creditsOverlay.handleTap(at: location) {
            return
        }

        let nodes = nodes(at: location)
        if nodes.contains(where: { $0.name == "play" }) {
            startGame()
            return
        }
        if nodes.contains(where: { $0.name == "settings" }) {
            AudioManager.playMenuTap()
            HapticsManager.menuTap()
            settingsOverlay.present()
            return
        }
        if nodes.contains(where: { $0.name == "boards" }) {
            AudioManager.playMenuTap()
            HapticsManager.menuTap()
            guard let root = view?.window?.rootViewController else { return }
            if GameCenterManager.shared.isAuthenticated {
                GameCenterManager.shared.showLeaderboards(from: root)
            }
            return
        }
        if nodes.contains(where: { $0.name == "achievements" }) {
            AudioManager.playMenuTap()
            HapticsManager.menuTap()
            guard let root = view?.window?.rootViewController else { return }
            if GameCenterManager.shared.isAuthenticated {
                GameCenterManager.shared.showAchievements(from: root)
            }
            return
        }
        if nodes.contains(where: { $0.name == "credits" }) {
            AudioManager.playMenuTap()
            HapticsManager.menuTap()
            creditsOverlay.present()
            return
        }
    }
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}
