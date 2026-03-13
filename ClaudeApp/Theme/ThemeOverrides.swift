import SwiftUI

@Observable
class ThemeOverrides {
    static let shared = ThemeOverrides()

    var activeTheme: DesignTheme? {
        didSet {
            if let theme = activeTheme {
                UserDefaults.standard.set(theme.id, forKey: "activeDesignTheme")
            } else {
                UserDefaults.standard.removeObject(forKey: "activeDesignTheme")
            }
        }
    }

    private init() {
        if let savedId = UserDefaults.standard.string(forKey: "activeDesignTheme"),
           UserDefaults.standard.bool(forKey: "devConsoleEnabled") {
            activeTheme = DesignTheme.all.first { $0.id == savedId }
        }
    }
}
