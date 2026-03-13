import SwiftUI

extension Color {
    static var appRose: Color {
        ThemeOverrides.shared.activeTheme?.primary ?? ColorTheme.current.rose
    }
    static var appSage: Color {
        ThemeOverrides.shared.activeTheme?.secondary ?? ColorTheme.current.sage
    }
    static var appCream: Color {
        ThemeOverrides.shared.activeTheme?.background ?? ColorTheme.current.cream
    }
    static var appTerracotta: Color {
        ThemeOverrides.shared.activeTheme?.tertiary ?? ColorTheme.current.terracotta
    }
    static var appWarmWhite: Color {
        ThemeOverrides.shared.activeTheme?.surface ?? ColorTheme.current.warmWhite
    }
    static var appSoftBrown: Color {
        ThemeOverrides.shared.activeTheme?.text ?? ColorTheme.current.softBrown
    }

    static func phaseGradient(for phase: CyclePhase) -> LinearGradient {
        LinearGradient(
            colors: phase.gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension ShapeStyle where Self == Color {
    static var warmBackground: Color { .appCream }
    static var cardBackground: Color { .appWarmWhite }
}
