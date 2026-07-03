import Foundation

/// Persistent soul-gem meta upgrades between runs.
final class MetaProgression {
    static let shared = MetaProgression()

    private let defaults = UserDefaults.standard
    private enum Key {
        static let soulGems = "gk.meta.soulGems"
        static let levels = "gk.meta.levels"
    }

    private(set) var soulGems: Int
    private var levels: [String: Int]

    private init() {
        soulGems = defaults.integer(forKey: Key.soulGems)
        if let dict = defaults.dictionary(forKey: Key.levels) as? [String: Int] {
            levels = dict
        } else {
            levels = [:]
        }
    }

    func level(of id: MetaUpgradeID) -> Int {
        levels[id.rawValue] ?? 0
    }

    func startingWalletBonus() -> Int {
        level(of: .heartyStart) * 3
    }

    func soulBankMultiplier() -> CGFloat {
        1 + CGFloat(level(of: .soulKeeper)) * 0.10
    }

    @discardableResult
    func bankSouls(fromRunWallet wallet: Int, floorsCleared: Int) -> Int {
        let base = wallet / 10 + floorsCleared * 3
        let earned = Int((CGFloat(base) * soulBankMultiplier()).rounded())
        guard earned > 0 else { return 0 }
        soulGems += earned
        defaults.set(soulGems, forKey: Key.soulGems)
        return earned
    }

    @discardableResult
    func purchase(_ def: MetaUpgradeDef) -> Bool {
        guard level(of: def.id) < def.maxLevel, soulGems >= def.cost else { return false }
        soulGems -= def.cost
        levels[def.id.rawValue, default: 0] += 1
        defaults.set(soulGems, forKey: Key.soulGems)
        defaults.set(levels, forKey: Key.levels)
        return true
    }

    func allLevels() -> [MetaUpgradeID: Int] {
        MetaUpgradeID.allCases.reduce(into: [:]) { $0[$1] = level(of: $1) }
    }
}
