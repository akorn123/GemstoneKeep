import Foundation

/// Player preferences persisted locally.
enum GameSettings {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let haptics = "gk.settings.haptics"
        static let sound = "gk.settings.sound"
        static let music = "gk.settings.music"
        static let miniMap = "gk.settings.minimap"
        static let debugFPS = "gk.settings.debugFPS"
        static let crt = "gk.settings.crt"
    }

    static var hapticsEnabled: Bool {
        get { defaults.object(forKey: Key.haptics) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.haptics) }
    }

    static var soundEnabled: Bool {
        get { defaults.object(forKey: Key.sound) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.sound) }
    }

    static var musicEnabled: Bool {
        get { defaults.object(forKey: Key.music) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.music) }
    }

    static var showMiniMap: Bool {
        get { defaults.object(forKey: Key.miniMap) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.miniMap) }
    }

    static var showDebugFPS: Bool {
        get { defaults.object(forKey: Key.debugFPS) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Key.debugFPS) }
    }

    static var crtEnabled: Bool {
        get { defaults.object(forKey: Key.crt) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.crt) }
    }
}
