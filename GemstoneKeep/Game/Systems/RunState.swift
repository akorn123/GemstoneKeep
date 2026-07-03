import CoreGraphics
import Foundation

/// Wallet, augments, and per-run state for roguelite mode.
final class RunState {
    private(set) var walletGems = 0
    private(set) var augmentStacks: [AugmentID: Int] = [:]
    private(set) var floorsCleared = 0
    private(set) var gemsCollectedThisRun = 0
    private(set) var usedRevive = false

    func reset(metaStartingWallet: Int) {
        walletGems = metaStartingWallet
        augmentStacks = [:]
        floorsCleared = 0
        gemsCollectedThisRun = 0
        usedRevive = false
    }

    func addWallet(_ amount: Int) {
        guard amount > 0 else { return }
        walletGems += amount
    }

    @discardableResult
    func spendWallet(_ amount: Int) -> Bool {
        guard amount > 0, walletGems >= amount else { return false }
        walletGems -= amount
        return true
    }

    func recordFloorCleared() {
        floorsCleared += 1
    }

    func recordGemCollected() {
        gemsCollectedThisRun += 1
    }

    func stacks(of id: AugmentID) -> Int {
        augmentStacks[id] ?? 0
    }

    func canBuy(_ def: AugmentDef, discount: CGFloat) -> Bool {
        let price = AugmentCatalog.discountedCost(def.cost, discount: discount)
        return walletGems >= price && stacks(of: def.id) < def.maxStacks
    }

    @discardableResult
    func purchase(_ def: AugmentDef, discount: CGFloat) -> Bool {
        guard stacks(of: def.id) < def.maxStacks else { return false }
        let price = AugmentCatalog.discountedCost(def.cost, discount: discount)
        guard spendWallet(price) else { return false }
        augmentStacks[def.id, default: 0] += 1
        if def.id == .richVein {
            addWallet(10)
        }
        return true
    }

    var hasGuardianHeart: Bool {
        stacks(of: .guardianHeart) > 0
    }

    func consumeRevive() {
        usedRevive = true
    }

    func shouldOfferShop(afterClearingFloor floor: Int) -> Bool {
        floor > 0 && floor % 2 == 0
    }
}

struct RunModifiers {
    let moveSpeedMultiplier: CGFloat
    let helmDurationBonus: TimeInterval
    let enemySpeedMultiplier: CGFloat
    let gemMagnetEnabled: Bool
    let walletPerGem: Int
    let shopDiscount: CGFloat

    static func compute(run: RunState, meta: MetaProgression) -> RunModifiers {
        let swift = CGFloat(run.stacks(of: .swiftPaws)) * 0.12
        let gloom = CGFloat(run.stacks(of: .gloomWard)) * 0.10
        let metaSpeed = CGFloat(meta.level(of: .thickFur)) * 0.03
        let metaDiscount = CGFloat(meta.level(of: .shrineDiscount)) * 0.05

        return RunModifiers(
            moveSpeedMultiplier: 1 + swift + metaSpeed,
            helmDurationBonus: TimeInterval(run.stacks(of: .ironHelm)) * 2,
            enemySpeedMultiplier: max(0.55, 1 - gloom),
            gemMagnetEnabled: run.stacks(of: .gemMagnet) > 0,
            walletPerGem: 1 + meta.level(of: .keenEye),
            shopDiscount: metaDiscount
        )
    }
}
