import SwiftUI

extension Color {
    static var appRose: Color { ColorTheme.current.rose }
    static var appSage: Color { ColorTheme.current.sage }
    static var appCream: Color { ColorTheme.current.cream }
    static var appTerracotta: Color { ColorTheme.current.terracotta }
    static var appWarmWhite: Color { ColorTheme.current.warmWhite }
    static var appSoftBrown: Color { ColorTheme.current.softBrown }

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
