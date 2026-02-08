import SwiftUI

extension Color {
    static let appRose = Color(red: 212/255, green: 131/255, blue: 143/255)
    static let appSage = Color(red: 163/255, green: 177/255, blue: 138/255)
    static let appCream = Color(red: 253/255, green: 246/255, blue: 236/255)
    static let appTerracotta = Color(red: 201/255, green: 123/255, blue: 99/255)
    static let appWarmWhite = Color(red: 255/255, green: 253/255, blue: 249/255)
    static let appSoftBrown = Color(red: 107/255, green: 91/255, blue: 78/255)

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
