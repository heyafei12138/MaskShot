import Foundation

final class SettingsStore {
    static let shared = SettingsStore()

    private enum Key {
        static let defaultRedactionStyle = "defaultRedactionStyle"
        static let autoLoadLatestScreenshot = "autoLoadLatestScreenshot"
        static let removeMetadataOnExport = "removeMetadataOnExport"
        static let appearance = "appearance"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.defaultRedactionStyle: RedactionStyle.blackout.rawValue,
            Key.autoLoadLatestScreenshot: false,
            Key.removeMetadataOnExport: true,
            Key.appearance: "Obsidian Dark"
        ])
    }

    var defaultRedactionStyle: RedactionStyle {
        get {
            RedactionStyle(rawValue: defaults.string(forKey: Key.defaultRedactionStyle) ?? "") ?? .blackout
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.defaultRedactionStyle)
        }
    }

    var autoLoadLatestScreenshot: Bool {
        get { defaults.bool(forKey: Key.autoLoadLatestScreenshot) }
        set { defaults.set(newValue, forKey: Key.autoLoadLatestScreenshot) }
    }

    var removeMetadataOnExport: Bool {
        get { defaults.bool(forKey: Key.removeMetadataOnExport) }
        set { defaults.set(newValue, forKey: Key.removeMetadataOnExport) }
    }

    var appearance: String {
        get { defaults.string(forKey: Key.appearance) ?? "Obsidian Dark" }
        set { defaults.set(newValue, forKey: Key.appearance) }
    }
}
