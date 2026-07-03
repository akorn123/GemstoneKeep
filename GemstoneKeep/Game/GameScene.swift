import GameController
import SpriteKit

final class GameScene: SKScene {
    private enum GamePhase {
        case intro
        case playing
        case dying
        case levelClear
        case shop
        case camp
    }

    private var isoMap: IsoMap!
    private var rook: Rook!
    private var movement: MovementSystem!
    private var gemField = GemField()
    private var pickupField = PickupField()
    private var enemySystem = EnemySystem()
    private var scoreManager = ScoreManager()
    private var livesManager = LivesManager()
    private var powerUpManager = PowerUpManager()
    private var levelTimer = LevelTimer()
    private var secretWarpTracker = SecretWarpTracker()
    private let runState = RunState()
    private var runModifiers = RunModifiers.compute(run: RunState(), meta: MetaProgression.shared)
    private var cameraController: CameraController!
    private let levelIntroController = LevelIntroController()
    private let crtEffect = CRTEffectNode()
    private let inputController = InputController()
    private let levelClearOverlay = LevelClearOverlay()
    private let shopOverlay = ShopOverlay()
    private let campOverlay = CampOverlay()
    private let miniMap = MiniMapNode()

    private let worldLayer = SKNode()
    private let gemLayer = SKNode()
    private let entityLayer = SKNode()
    private let hudLayer = SKNode()

    private var scoreLabel: SKLabelNode!
    private var gemsLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var helmBar: SKShapeNode!

    private var currentLevel: LevelDefinition!
    private var currentLevelIndex = 0
    private var levelSpawn = MovementSystem.Cell(col: 0, row: 0, elevation: 0)
    private var exitCell = MovementSystem.Cell(col: 0, row: 0, elevation: 0)
    private var exitPortal: ExitPortal?
    private var shopOffers: [AugmentDef] = []
    private var campOffers: [MetaUpgradeDef] = []
    private var soulsBankedThisRun = 0

    private var gamePhase: GamePhase = .playing
    private var lastUpdateTime: TimeInterval = 0
    private var deathTimer: TimeInterval = 0
    private let deathDelay: TimeInterval = 1.15
    private var miniMapTimer: TimeInterval = 0
    private let miniMapInterval: TimeInterval = 0.1
    private var isPortrait: Bool { size.height >= size.width }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.08, green: 0.07, blue: 0.12, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        HapticsManager.prepare()
        PerformanceTuner.applySceneDefaults(self)
        AudioManager.prepare()
        MusicManager.shared.play(.gameplay)
        GCController.startWirelessControllerDiscovery(completionHandler: nil)

        worldLayer.addChild(gemLayer)
        addChild(worldLayer)

        entityLayer.name = "entities"
        worldLayer.addChild(entityLayer)
        entityLayer.addChild(enemySystem.container)

        setupCamera()
        setupHUD()
        hudLayer.addChild(levelClearOverlay)
        hudLayer.addChild(shopOverlay)
        hudLayer.addChild(campOverlay)
        hudLayer.addChild(miniMap)

        levelClearOverlay.onContinue = { [weak self] in
            self?.continueAfterFloorClear()
        }
        shopOverlay.onFinished = { [weak self] in
            self?.advanceToNextLevel()
        }
        campOverlay.onRetry = { [weak self] in
            self?.startNewRun()
        }

        startNewRun()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        cameraController?.configure(for: size, portrait: isPortrait)
        layoutHUD()
        let scale = camera?.xScale ?? 1
        levelClearOverlay.layout(for: size, cameraScale: scale)
        shopOverlay.layout(for: size, cameraScale: scale)
        campOverlay.layout(for: size, cameraScale: scale)
        miniMap.layout(in: size, cameraScale: scale)
        crtEffect.layout(for: size, cameraScale: scale)
    }

    // MARK: - Run / level flow

    private func startNewRun() {
        levelClearOverlay.isHidden = true
        shopOverlay.isHidden = true
        campOverlay.isHidden = true
        scoreManager.resetRun()
        livesManager.reset()
        secretWarpTracker.reset()
        AchievementTracker.shared.beginRun()
        runState.reset(metaStartingWallet: MetaProgression.shared.startingWalletBonus())
        refreshRunModifiers()
        loadLevel(at: 0)
    }

    private func refreshRunModifiers() {
        runModifiers = RunModifiers.compute(run: runState, meta: MetaProgression.shared)
        rook?.tilesPerSecond = 4.5 * runModifiers.moveSpeedMultiplier
        enemySystem.setPlayerEnemySpeedMultiplier(runModifiers.enemySpeedMultiplier)
    }

    private func loadLevel(at index: Int) {
        guard let level = LevelLoader.level(at: index) else {
            loadLevel(at: 0)
            return
        }

        currentLevel = level
        currentLevelIndex = index
        deathTimer = 0
        miniMapTimer = 0
        scoreManager.beginLevel()
        AchievementTracker.shared.beginLevel()
        powerUpManager.deactivateHelm()
        lastUpdateTime = 0
        exitPortal = nil

        worldLayer.childNode(withName: "world")?.removeFromParent()
        rook?.removeFromParent()
        gemLayer.removeAllChildren()
        pickupField.container.removeFromParent()
        enemySystem.container.removeAllChildren()

        isoMap = IsoMap(level: level)
        isoMap.worldNode.name = "world"
        worldLayer.insertChild(isoMap.worldNode, at: 0)
        isoMap.finalizeForRendering()

        movement = MovementSystem(map: isoMap, level: level)

        levelSpawn = MovementSystem.Cell(
            col: level.spawnCol,
            row: level.spawnRow,
            elevation: level.spawnElevation
        )
        exitCell = ExitResolver.exitCell(map: isoMap, spawn: levelSpawn)

        gemField.populate(map: isoMap, excludingSpawn: levelSpawn, excluding: exitCell)
        gemLayer.addChild(gemField.container)

        let portal = ExitPortal(cell: exitCell, map: isoMap)
        exitPortal = portal
        gemLayer.addChild(portal)

        pickupField.populate(level: level, map: isoMap)
        gemLayer.addChild(pickupField.container)

        let loop = DifficultyScaler.loopCount(forLevelIndex: index)
        let tier = DifficultyScaler.tier(levelId: level.id, loop: loop)
        refreshRunModifiers()
        enemySystem.reset(
            level: level,
            map: isoMap,
            movement: movement,
            spawn: levelSpawn,
            tier: tier,
            playerEnemySpeedMultiplier: runModifiers.enemySpeedMultiplier
        )

        miniMap.configure(level: level, map: isoMap, exitCell: exitCell)
        miniMap.isHidden = !GameSettings.showMiniMap

        rook = Rook(col: levelSpawn.col, row: levelSpawn.row, elevation: levelSpawn.elevation)
        rook.tilesPerSecond = 4.5 * runModifiers.moveSpeedMultiplier
        rook.applyScreenPosition(from: isoMap)
        entityLayer.addChild(rook)

        inputController.clearMovement()

        hudLayer.childNode(withName: "levelLabel")?.removeFromParent()
        let levelLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        levelLabel.name = "levelLabel"
        let floor = currentLevelIndex + 1
        let loopSuffix = loop > 0 ? " · Loop \(loop + 1)" : ""
        levelLabel.text = "FLOOR \(floor) — \(level.name)\(loopSuffix)"
        levelLabel.fontSize = 14
        levelLabel.fontColor = UIColor(white: 0.92, alpha: 0.85)
        levelLabel.horizontalAlignmentMode = .center
        hudLayer.addChild(levelLabel)

        updateScoreHUD()
        updateHelmBar()
        layoutHUD()
        miniMap.layout(in: size, cameraScale: camera?.xScale ?? 1)
        crtEffect.applySettings()
        crtEffect.layout(for: size, cameraScale: camera?.xScale ?? 1)
        beginLevelIntro()
    }

    private func beginLevelIntro() {
        gamePhase = .intro
        levelIntroController.configure(map: isoMap, level: currentLevel, spawn: levelSpawn)
        levelIntroController.onComplete = { [weak self] in
            guard let self else { return }
            self.gamePhase = .playing
            self.lastUpdateTime = 0
            self.cameraController.snap(to: self.rook.position)
        }
        levelIntroController.begin()
        cameraController.snap(to: levelIntroController.currentFocus())
    }

    private func continueAfterFloorClear() {
        runState.recordFloorCleared()
        if runState.shouldOfferShop(afterClearingFloor: runState.floorsCleared) {
            presentShop()
        } else {
            advanceToNextLevel()
        }
    }

    private func presentShop() {
        gamePhase = .shop
        shopOffers = AugmentCatalog.randomShopOffers(
            stacks: runState.augmentStacks,
            wallet: runState.walletGems,
            count: 3,
            discount: runModifiers.shopDiscount
        )
        shopOverlay.layout(for: size, cameraScale: camera?.xScale ?? 1)
        shopOverlay.present(
            offers: shopOffers,
            wallet: runState.walletGems,
            discount: runModifiers.shopDiscount,
            run: runState
        )
    }

    private func advanceToNextLevel() {
        loadLevel(at: currentLevelIndex + 1)
    }

    private func checkSecretWarp() {
        guard gamePhase == .playing,
              let warp = currentLevel.secretWarp,
              !secretWarpTracker.isDiscovered(levelId: currentLevel.id),
              rook.cell == warp.cell,
              rook.isJumping else { return }

        secretWarpTracker.markDiscovered(levelId: currentLevel.id)
        AchievementTracker.shared.recordWarp(levelId: currentLevel.id)
        inputController.clearMovement()
        showBanner("SECRET — \(warp.name)!", color: UIColor(red: 0.75, green: 0.55, blue: 0.98, alpha: 1))
        HapticsManager.warp()
        cameraController.addShake(intensity: 0.55)
        AudioManager.playWarp()
        loadLevel(at: currentLevelIndex + warp.skipAhead)
    }

    private func triggerLevelClear() {
        guard gamePhase == .playing else { return }
        gamePhase = .levelClear
        inputController.clearMovement()
        powerUpManager.deactivateHelm()
        rook.setHelmPowered(false)

        _ = scoreManager.finalizeFloorClear(elapsed: levelTimer.elapsed, walletGems: runState.walletGems)
        AchievementTracker.shared.recordLevelClear(
            levelId: currentLevel.id,
            levelIndex: currentLevelIndex
        )
        AchievementTracker.shared.checkScore(scoreManager.score)
        guard let summary = scoreManager.lastClearSummary else { return }
        let nextName = LevelLoader.level(at: currentLevelIndex + 1)?.name
        levelClearOverlay.layout(for: size, cameraScale: camera?.xScale ?? 1)
        levelClearOverlay.present(
            summary: summary,
            nextLevelName: nextName,
            floorNumber: currentLevelIndex + 1
        )
        cameraController.addShake(intensity: 0.35)
        AudioManager.playLevelClear()
    }

    private func triggerDeath() {
        guard gamePhase == .playing else { return }
        gamePhase = .dying
        deathTimer = 0
        inputController.clearMovement()
        powerUpManager.deactivateHelm()
        rook.setHelmPowered(false)
        rook.playDeath()
        cameraController.addShake(intensity: 0.75)
        HapticsManager.death()
        AudioManager.playDeath()
    }

    private func finishDeathSequence() {
        if runState.hasGuardianHeart && !runState.usedRevive {
            runState.consumeRevive()
            rook.respawn(col: levelSpawn.col, row: levelSpawn.row, elevation: levelSpawn.elevation, map: isoMap)
            inputController.clearMovement()
            gamePhase = .playing
            cameraController.snap(to: rook.position)
            showBanner("GUARDIAN HEART!", color: UIColor(red: 0.95, green: 0.55, blue: 0.75, alpha: 1))
            HapticsManager.extraLife()
            return
        }

        let isGameOver = livesManager.loseLife()
        updateLivesHUD()

        if isGameOver {
            PlayerProgress.shared.recordRunEnd(
                score: scoreManager.score,
                levelIndex: currentLevelIndex
            )
            PlayerProgress.shared.recordGemsCollected(runState.gemsCollectedThisRun)
            AchievementTracker.shared.checkScore(scoreManager.score)
            GameCenterManager.shared.submitScore(scoreManager.score)
            soulsBankedThisRun = MetaProgression.shared.bankSouls(
                fromRunWallet: runState.walletGems,
                floorsCleared: runState.floorsCleared
            )
            campOffers = MetaCatalog.randomCampOffers(
                levels: MetaProgression.shared.allLevels(),
                souls: MetaProgression.shared.soulGems,
                count: 3
            )
            gamePhase = .camp
            campOverlay.layout(for: size, cameraScale: camera?.xScale ?? 1)
            campOverlay.present(
                floorsCleared: runState.floorsCleared,
                walletRemaining: runState.walletGems,
                soulsBanked: soulsBankedThisRun,
                offers: campOffers
            )
            AudioManager.playGameOver()
        }
    }

    private func handleGemStolenByEnemy() {
        if runState.walletGems > 0 {
            _ = runState.spendWallet(1)
            showBanner("-1 gem stolen!", color: UIColor(red: 0.95, green: 0.45, blue: 0.45, alpha: 1), small: true)
            updateScoreHUD()
        }
    }

    // MARK: - Setup

    private func setupCamera() {
        let cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        cameraController = CameraController(cameraNode: cameraNode)
        cameraController.configure(for: size, portrait: isPortrait)
    }

    private func setupHUD() {
        hudLayer.name = "hud"
        hudLayer.zPosition = 10_000
        camera?.addChild(hudLayer)

        camera?.addChild(crtEffect)
        crtEffect.applySettings()
        crtEffect.layout(for: size, cameraScale: camera?.xScale ?? 1)

        scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontSize = 13
        scoreLabel.fontColor = UIColor(red: 0.95, green: 0.88, blue: 0.45, alpha: 1)
        scoreLabel.horizontalAlignmentMode = .left
        hudLayer.addChild(scoreLabel)

        livesLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        livesLabel.name = "livesLabel"
        livesLabel.fontSize = 12
        livesLabel.fontColor = UIColor(red: 0.95, green: 0.55, blue: 0.55, alpha: 1)
        livesLabel.horizontalAlignmentMode = .center
        hudLayer.addChild(livesLabel)

        gemsLabel = SKLabelNode(fontNamed: "Menlo")
        gemsLabel.name = "gemsLabel"
        gemsLabel.fontSize = 12
        gemsLabel.fontColor = UIColor(white: 0.82, alpha: 0.9)
        gemsLabel.horizontalAlignmentMode = .right
        hudLayer.addChild(gemsLabel)

        timerLabel = SKLabelNode(fontNamed: "Menlo")
        timerLabel.name = "timerLabel"
        timerLabel.fontSize = 11
        timerLabel.fontColor = UIColor(white: 0.75, alpha: 0.85)
        timerLabel.horizontalAlignmentMode = .right
        hudLayer.addChild(timerLabel)

        helmBar = SKShapeNode(rectOf: CGSize(width: 48, height: 4), cornerRadius: 2)
        helmBar.fillColor = UIColor(red: 0.4, green: 0.75, blue: 0.98, alpha: 0.9)
        helmBar.strokeColor = UIColor(white: 0.5, alpha: 0.5)
        helmBar.lineWidth = 0.5
        helmBar.isHidden = true
        helmBar.zPosition = 1
        hudLayer.addChild(helmBar)

        let hint = SKLabelNode(fontNamed: "Menlo")
        hint.name = "hintLabel"
        hint.text = "Reach EXIT · Spend gems at shrines"
        hint.fontSize = 11
        hint.fontColor = UIColor(white: 0.7, alpha: 0.7)
        hint.horizontalAlignmentMode = .center
        hudLayer.addChild(hint)

        layoutHUD()
    }

    private func layoutHUD() {
        guard let camera = camera else { return }
        let halfH = size.height * 0.5 / camera.xScale
        let halfW = size.width * 0.5 / camera.xScale
        let topInset: CGFloat = 36 / camera.xScale
        let sideInset: CGFloat = 14 / camera.xScale

        hudLayer.childNode(withName: "levelLabel")?.position = CGPoint(x: 0, y: halfH - topInset)
        scoreLabel.position = CGPoint(x: -halfW + sideInset, y: halfH - topInset)
        livesLabel.position = CGPoint(x: 0, y: halfH - topInset - 16 / camera.xScale)
        gemsLabel.position = CGPoint(x: halfW - sideInset, y: halfH - topInset)
        timerLabel.position = CGPoint(x: halfW - sideInset, y: halfH - topInset - 16 / camera.xScale)
        helmBar.position = CGPoint(x: 0, y: halfH - topInset - 30 / camera.xScale)
        hudLayer.childNode(withName: "hintLabel")?.position = CGPoint(x: 0, y: halfH - topInset - 44 / camera.xScale)
        miniMap.layout(in: size, cameraScale: camera.xScale)
    }

    private func updateHelmBar() {
        if powerUpManager.isHelmActive {
            helmBar.isHidden = false
            let w: CGFloat = 48 * powerUpManager.helmProgress
            helmBar.path = CGPath(roundedRect: CGRect(x: -24, y: -2, width: max(4, w), height: 4), cornerWidth: 2, cornerHeight: 2, transform: nil)
        } else {
            helmBar.isHidden = true
        }
    }

    private func updateScoreHUD() {
        scoreLabel.text = "SCORE \(scoreManager.score)"
        gemsLabel.text = "WALLET \(runState.walletGems)"
        timerLabel.text = levelTimer.formattedElapsed()
        updateLivesHUD()
    }

    private func updateLivesHUD() {
        let revive = runState.hasGuardianHeart && !runState.usedRevive ? " · REVIVE" : ""
        livesLabel.text = "PERMADEATH\(revive)"
    }

    // MARK: - Gems & combat

    private func checkGemCollection(at time: TimeInterval) {
        tryCollectAndAward(at: rook.cell, time: time)
        guard runModifiers.gemMagnetEnabled else { return }
        for dir in InputController.IsoDirection.allCases {
            let d = dir.gridDelta
            let neighbor = MovementSystem.Cell(
                col: rook.cell.col + d.col,
                row: rook.cell.row + d.row,
                elevation: rook.cell.elevation
            )
            tryCollectAndAward(at: neighbor, time: time)
        }
    }

    private func tryCollectAndAward(at cell: MovementSystem.Cell, time: TimeInterval) {
        guard gemField.tryCollect(at: cell) else { return }
        let walletGain = runModifiers.walletPerGem
        runState.addWallet(walletGain)
        runState.recordGemCollected()
        let result = scoreManager.registerGemPickup(at: time, isFinalGem: false)
        AchievementTracker.shared.recordGemCollected()
        cameraController.addShake(intensity: 0.07)
        HapticsManager.gemPickup()
        AudioManager.playGemPickup(chain: result.pickupChain)
        showPickupFloater(points: result.pointsEarned, wallet: walletGain)
        updateScoreHUD()
    }

    private func checkExitReached() {
        guard rook.cell == exitCell else { return }
        triggerLevelClear()
    }

    private func checkPickupCollection() {
        if pickupField.tryCollectHelm(at: rook.cell) {
            powerUpManager.activateHelm(durationBonus: runModifiers.helmDurationBonus)
            rook.setHelmPowered(true)
            HapticsManager.helmGrab()
            AudioManager.playHelmGrab()
            updateHelmBar()
        }

        if pickupField.tryCollectChalice(at: rook.cell) {
            let points = scoreManager.registerChalice()
            runState.addWallet(15)
            AchievementTracker.shared.recordChalice()
            HapticsManager.gemPickup()
            showPickupFloater(points: points, wallet: 15)
            updateScoreHUD()
            enemySystem.spawnEmergencyWarden(
                level: currentLevel,
                map: isoMap,
                movement: movement,
                near: rook.cell
            )
            showBanner("THE WARDEN STIRS!", color: UIColor(red: 0.95, green: 0.45, blue: 0.35, alpha: 1))
        }
    }

    private func checkEnemyCollision() {
        guard gamePhase == .playing, !rook.isDead else { return }

        if powerUpManager.isHelmActive {
            if enemySystem.containsEnemy(at: rook.cell) {
                let points = powerUpManager.registerHelmKill()
                scoreManager.registerHelmKill(points: points)
                AchievementTracker.shared.recordHelmKill()
                enemySystem.destroyEnemies(at: rook.cell)
                cameraController.addShake(intensity: 0.2)
                AudioManager.playEnemyDestroy()
                HapticsManager.gemPickup()
                showPickupFloater(points: points)
                updateScoreHUD()
            }
            return
        }

        guard !rook.isJumping else { return }
        if enemySystem.containsEnemy(at: rook.cell) {
            triggerDeath()
        }
    }

    private func showPickupFloater(points: Int, wallet: Int? = nil) {
        if let wallet {
            showBanner("+\(wallet)g · \(points)pts", color: UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1), small: true)
        } else {
            showBanner("+\(points)", color: UIColor(red: 0.55, green: 0.95, blue: 0.72, alpha: 1), small: true)
        }
    }

    private func showBanner(_ text: String, color: UIColor, small: Bool = false) {
        guard let camera else { return }
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = text
        label.fontSize = small ? 13 : 15
        label.fontColor = color
        label.position = CGPoint(
            x: rook.position.x,
            y: rook.position.y + (small ? 28 : 40)
        )
        label.zPosition = rook.zPosition + 1
        worldLayer.addChild(label)

        let rise = SKAction.moveBy(x: 0, y: 24 / camera.xScale, duration: 0.55)
        let fade = SKAction.fadeOut(withDuration: 0.55)
        label.run(.sequence([.group([rise, fade]), .removeFromParent()]))
    }

    // MARK: - Loop

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        switch gamePhase {
        case .intro:
            updateIntro(dt: dt)
        case .playing:
            updatePlaying(dt: dt, currentTime: currentTime)
        case .dying:
            crtEffect.update(dt: dt)
            cameraController.follow(worldPosition: rook.position, dt: dt)
            deathTimer += dt
            enemySystem.update(dt: dt, gemField: gemField, rookCell: rook.cell, onGemStolen: { [weak self] in
                self?.handleGemStolenByEnemy()
            })
            if deathTimer >= deathDelay {
                finishDeathSequence()
            }
        case .levelClear, .shop, .camp:
            break
        }
    }

    private func updateIntro(dt: TimeInterval) {
        crtEffect.update(dt: dt)
        if let focus = levelIntroController.update(dt: dt) {
            cameraController.pan(to: focus, dt: dt)
        }
    }

    private func updatePlaying(dt: TimeInterval, currentTime: TimeInterval) {
        crtEffect.update(dt: dt)
        if lastUpdateTime > 0 {
            levelTimer.update(currentTime: currentTime)
        } else {
            levelTimer.start(at: currentTime)
        }
        powerUpManager.update(dt: dt)
        if !powerUpManager.isHelmActive {
            rook.setHelmPowered(false)
        }
        updateHelmBar()

        inputController.pollControllers(movement: movement, at: rook.cell)

        if inputController.consumeJump(), rook.beginJump() {
            HapticsManager.jump()
            AudioManager.playJump()
            checkSecretWarp()
        }

        let direction = inputController.activeDirection()
        let crossed = rook.updateMovement(dt: dt, movement: movement, desiredDirection: direction)

        if crossed {
            if inputController.applyBufferedTurn(movement: movement, at: rook.cell) {
                HapticsManager.turn()
            }
            checkGemCollection(at: currentTime)
            checkPickupCollection()
            checkExitReached()
        }

        enemySystem.update(dt: dt, gemField: gemField, rookCell: rook.cell, onGemStolen: { [weak self] in
            self?.handleGemStolenByEnemy()
        })

        if gemsLabel.text != "WALLET \(runState.walletGems)" {
            gemsLabel.text = "WALLET \(runState.walletGems)"
        }
        timerLabel.text = levelTimer.formattedElapsed()

        miniMapTimer += dt
        miniMap.updateRookOnly(rook.cell)
        if miniMapTimer >= miniMapInterval {
            miniMapTimer = 0
            miniMap.update(
                rookCell: rook.cell,
                gemCells: gemField.activeGemCells,
                enemyCells: enemySystem.enemyCells()
            )
        }

        checkEnemyCollision()

        rook.applyScreenPosition(from: isoMap)
        cameraController.setLeadDirection(rook.facingDirection)
        cameraController.follow(worldPosition: rook.position, dt: dt)
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view else { return }
        let location = touch.location(in: self)

        switch gamePhase {
        case .levelClear:
            levelClearOverlay.handleTap()
        case .shop:
            handleShopTap(at: location)
        case .camp:
            handleCampTap(at: location)
        case .playing:
            inputController.touchesBegan(at: touch.location(in: view), viewWidth: view.bounds.width)
        case .intro, .dying:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view else { return }
        guard gamePhase == .playing else { return }

        inputController.touchesEnded(at: touch.location(in: view), viewWidth: view.bounds.width)
        inputController.tryImmediateTurn(
            movement: movement,
            at: rook.cell,
            atJunction: !rook.isMovingBetweenTiles
        )
    }

    private func handleShopTap(at location: CGPoint) {
        if let index = shopOverlay.offerIndex(at: location), index < shopOffers.count {
            let def = shopOffers[index]
            if runState.purchase(def, discount: runModifiers.shopDiscount) {
                refreshRunModifiers()
                rook.tilesPerSecond = 4.5 * runModifiers.moveSpeedMultiplier
                HapticsManager.gemPickup()
                AudioManager.playMenuTap()
                shopOverlay.refreshWallet(runState.walletGems, discount: runModifiers.shopDiscount, run: runState)
                updateScoreHUD()
                updateLivesHUD()
            }
            return
        }
        _ = shopOverlay.handleTap(at: location)
    }

    private func handleCampTap(at location: CGPoint) {
        if let index = campOverlay.offerIndex(at: location), index < campOffers.count {
            let def = campOffers[index]
            if MetaProgression.shared.purchase(def) {
                HapticsManager.levelClear()
                AudioManager.playMenuTap()
                campOverlay.refreshSouls()
            }
            return
        }
        _ = campOverlay.handleTap(at: location)
    }
}
