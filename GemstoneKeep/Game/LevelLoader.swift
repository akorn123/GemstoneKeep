import Foundation

enum LevelLoader {
    static var levelCount: Int { LevelCatalog.all.count }

    static func load(id: Int) -> LevelDefinition? {
        LevelCatalog.all.first { $0.id == id }
    }

    /// Absolute run index — wraps every 12 levels for endless loop with scaling difficulty.
    static func level(at index: Int) -> LevelDefinition? {
        guard index >= 0, !LevelCatalog.all.isEmpty else { return nil }
        return LevelCatalog.all[index % LevelCatalog.all.count]
    }

    static func loadFromBundle(named filename: String) -> LevelDefinition? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(LevelDefinition.self, from: data)
    }

    static func defaultLevel() -> LevelDefinition {
        LevelCatalog.all[0]
    }

    static func nextLevelName(after index: Int) -> String? {
        level(at: index + 1)?.name
    }
}
