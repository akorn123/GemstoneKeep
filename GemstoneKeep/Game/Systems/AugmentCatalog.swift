import Foundation

/// Run augments purchasable at the between-floor shop.
enum AugmentID: String, CaseIterable {
    case swiftPaws
    case ironHelm
    case gloomWard
    case gemMagnet
    case guardianHeart
    case richVein

    var definition: AugmentDef { AugmentCatalog.runAugments[id: self]! }
}

struct AugmentDef: Equatable {
    let id: AugmentID
    let name: String
    let detail: String
    let cost: Int
    let maxStacks: Int
}

enum AugmentCatalog {
    static let runAugments: [AugmentID: AugmentDef] = [
        .swiftPaws: AugmentDef(
            id: .swiftPaws, name: "Swift Paws",
            detail: "+12% movement speed", cost: 18, maxStacks: 3
        ),
        .ironHelm: AugmentDef(
            id: .ironHelm, name: "Iron Helm",
            detail: "Helm lasts +2 seconds", cost: 22, maxStacks: 2
        ),
        .gloomWard: AugmentDef(
            id: .gloomWard, name: "Gloom Ward",
            detail: "Enemies move 10% slower", cost: 20, maxStacks: 2
        ),
        .gemMagnet: AugmentDef(
            id: .gemMagnet, name: "Gem Magnet",
            detail: "Collect adjacent gems", cost: 28, maxStacks: 1
        ),
        .guardianHeart: AugmentDef(
            id: .guardianHeart, name: "Guardian Heart",
            detail: "Revive once this run", cost: 35, maxStacks: 1
        ),
        .richVein: AugmentDef(
            id: .richVein, name: "Rich Vein",
            detail: "+10 wallet gems now", cost: 12, maxStacks: 99
        ),
    ]

    static func randomShopOffers(
        stacks: [AugmentID: Int],
        wallet: Int,
        count: Int,
        discount: CGFloat
    ) -> [AugmentDef] {
        let affordable = AugmentID.allCases.compactMap { id -> AugmentDef? in
            let def = id.definition
            let current = stacks[id] ?? 0
            guard current < def.maxStacks else { return nil }
            let price = discountedCost(def.cost, discount: discount)
            guard wallet >= price || wallet >= price / 2 else { return nil }
            return def
        }
        var pool = affordable
        var offers: [AugmentDef] = []
        while offers.count < count, !pool.isEmpty {
            let index = Int.random(in: 0..<pool.count)
            offers.append(pool.remove(at: index))
        }
        if offers.isEmpty {
            return Array(AugmentID.allCases.prefix(count)).map(\.definition)
        }
        return offers
    }

    static func discountedCost(_ base: Int, discount: CGFloat) -> Int {
        max(1, Int((CGFloat(base) * (1 - discount)).rounded()))
    }
}

/// Permanent meta upgrades purchased with soul gems after a run ends.
enum MetaUpgradeID: String, CaseIterable {
    case heartyStart
    case thickFur
    case shrineDiscount
    case soulKeeper
    case keenEye

    var definition: MetaUpgradeDef { MetaCatalog.upgrades[id: self]! }
}

struct MetaUpgradeDef: Equatable {
    let id: MetaUpgradeID
    let name: String
    let detail: String
    let cost: Int
    let maxLevel: Int
}

enum MetaCatalog {
    static let upgrades: [MetaUpgradeID: MetaUpgradeDef] = [
        .heartyStart: MetaUpgradeDef(
            id: .heartyStart, name: "Hearty Start",
            detail: "+3 wallet gems each run", cost: 8, maxLevel: 5
        ),
        .thickFur: MetaUpgradeDef(
            id: .thickFur, name: "Thick Fur",
            detail: "+3% move speed (meta)", cost: 10, maxLevel: 4
        ),
        .shrineDiscount: MetaUpgradeDef(
            id: .shrineDiscount, name: "Shrine Favor",
            detail: "Shop prices −5%", cost: 12, maxLevel: 3
        ),
        .soulKeeper: MetaUpgradeDef(
            id: .soulKeeper, name: "Soul Keeper",
            detail: "+10% soul gems banked", cost: 15, maxLevel: 3
        ),
        .keenEye: MetaUpgradeDef(
            id: .keenEye, name: "Keen Eye",
            detail: "+1 wallet per gem pickup", cost: 20, maxLevel: 2
        ),
    ]

    static func randomCampOffers(levels: [MetaUpgradeID: Int], souls: Int, count: Int) -> [MetaUpgradeDef] {
        let pool = MetaUpgradeID.allCases.compactMap { id -> MetaUpgradeDef? in
            let def = id.definition
            guard (levels[id] ?? 0) < def.maxLevel, souls >= def.cost else { return nil }
            return def
        }
        var remaining = pool.shuffled()
        var result: [MetaUpgradeDef] = []
        while result.count < count, !remaining.isEmpty {
            result.append(remaining.removeFirst())
        }
        return result
    }
}
