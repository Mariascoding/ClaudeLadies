import SwiftUI

extension Color {
    static let appRose = Color(red: 212/255, green: 131/255, blue: 143/255)
    static let appSage = Color(red: 163/255, green: 177/255, blue: 138/255)
    static var appCream: Color { ColorTheme.current.cream }
    static let appTerracotta = Color(red: 201/255, green: 123/255, blue: 99/255)
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
