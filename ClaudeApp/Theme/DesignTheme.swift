import SwiftUI

struct DesignTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String

    // MARK: - Spacing

    let spaceXXS: CGFloat
    let spaceXS: CGFloat
    let spaceSM: CGFloat
    let spaceMD: CGFloat
    let spaceLG: CGFloat
    let spaceXL: CGFloat
    let spaceXXL: CGFloat

    // MARK: - Colors (non-adaptive)

    let primary: Color
    let secondary: Color
    let tertiary: Color

    // MARK: - Colors (adaptive: separate light/dark)

    let textLight: Color
    let textDark: Color
    let backgroundLight: Color
    let backgroundDark: Color
    let surfaceLight: Color
    let surfaceDark: Color

    // MARK: - Typography

    let fontFamily: Font.Design
    let fontFamilyDisplay: Font.Design
    let typeSize: DynamicTypeSize
    let lineSpacing: CGFloat

    // MARK: - Radius

    let radiusSM: CGFloat
    let radiusMD: CGFloat
    let radiusLG: CGFloat
    let radiusXL: CGFloat
    let radiusPill: CGFloat

    // MARK: - Shadow

    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    // MARK: - Adaptive Color Accessors

    var text: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(textDark) : UIColor(textLight)
        })
    }

    var background: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(backgroundDark) : UIColor(backgroundLight)
        })
    }

    var surface: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(surfaceDark) : UIColor(surfaceLight)
        })
    }

    // MARK: - Presets

    static let serene = DesignTheme(
        id: "serene", name: "Serene", icon: "leaf.fill",
        spaceXXS: 2, spaceXS: 4, spaceSM: 8, spaceMD: 16, spaceLG: 24, spaceXL: 32, spaceXXL: 48,
        primary: Color(red: 212/255, green: 131/255, blue: 143/255),
        secondary: Color(red: 163/255, green: 177/255, blue: 138/255),
        tertiary: Color(red: 201/255, green: 123/255, blue: 99/255),
        textLight: Color(red: 107/255, green: 91/255, blue: 78/255),
        textDark: Color(red: 212/255, green: 196/255, blue: 176/255),
        backgroundLight: Color(red: 253/255, green: 246/255, blue: 236/255),
        backgroundDark: Color(red: 28/255, green: 25/255, blue: 23/255),
        surfaceLight: Color(red: 255/255, green: 253/255, blue: 249/255),
        surfaceDark: Color(red: 41/255, green: 37/255, blue: 36/255),
        fontFamily: .rounded, fontFamilyDisplay: .serif,
        typeSize: .medium, lineSpacing: 0,
        radiusSM: 8, radiusMD: 12, radiusLG: 20, radiusXL: 28, radiusPill: 100,
        shadowOpacity: 0.06, shadowRadius: 8, shadowY: 2
    )

    static let stark = DesignTheme(
        id: "stark", name: "Stark", icon: "bolt.fill",
        spaceXXS: 2, spaceXS: 3, spaceSM: 6, spaceMD: 12, spaceLG: 18, spaceXL: 24, spaceXXL: 36,
        primary: Color(red: 200/255, green: 50/255, blue: 50/255),
        secondary: Color(red: 46/255, green: 139/255, blue: 87/255),
        tertiary: Color(red: 220/255, green: 140/255, blue: 40/255),
        textLight: Color(red: 30/255, green: 30/255, blue: 30/255),
        textDark: Color(red: 225/255, green: 225/255, blue: 225/255),
        backgroundLight: Color(red: 240/255, green: 240/255, blue: 242/255),
        backgroundDark: Color(red: 18/255, green: 18/255, blue: 20/255),
        surfaceLight: Color(red: 255/255, green: 255/255, blue: 255/255),
        surfaceDark: Color(red: 32/255, green: 32/255, blue: 34/255),
        fontFamily: .default, fontFamilyDisplay: .default,
        typeSize: .small, lineSpacing: 0,
        radiusSM: 4, radiusMD: 6, radiusLG: 10, radiusXL: 14, radiusPill: 100,
        shadowOpacity: 0.12, shadowRadius: 10, shadowY: 4
    )

    static let airy = DesignTheme(
        id: "airy", name: "Airy", icon: "wind",
        spaceXXS: 2, spaceXS: 4, spaceSM: 8, spaceMD: 14, spaceLG: 20, spaceXL: 28, spaceXXL: 40,
        primary: Color(red: 140/255, green: 165/255, blue: 195/255),
        secondary: Color(red: 150/255, green: 185/255, blue: 160/255),
        tertiary: Color(red: 195/255, green: 175/255, blue: 145/255),
        textLight: Color(red: 85/255, green: 95/255, blue: 105/255),
        textDark: Color(red: 195/255, green: 200/255, blue: 210/255),
        backgroundLight: Color(red: 248/255, green: 248/255, blue: 250/255),
        backgroundDark: Color(red: 22/255, green: 22/255, blue: 26/255),
        surfaceLight: Color(red: 255/255, green: 255/255, blue: 255/255),
        surfaceDark: Color(red: 34/255, green: 34/255, blue: 38/255),
        fontFamily: .default, fontFamilyDisplay: .serif,
        typeSize: .medium, lineSpacing: 2,
        radiusSM: 4, radiusMD: 8, radiusLG: 12, radiusXL: 16, radiusPill: 100,
        shadowOpacity: 0.03, shadowRadius: 4, shadowY: 1
    )

    static let lush = DesignTheme(
        id: "lush", name: "Lush", icon: "sparkles",
        spaceXXS: 3, spaceXS: 6, spaceSM: 10, spaceMD: 20, spaceLG: 30, spaceXL: 40, spaceXXL: 60,
        primary: Color(red: 215/255, green: 150/255, blue: 165/255),
        secondary: Color(red: 140/255, green: 195/255, blue: 185/255),
        tertiary: Color(red: 225/255, green: 185/255, blue: 140/255),
        textLight: Color(red: 120/255, green: 100/255, blue: 95/255),
        textDark: Color(red: 215/255, green: 200/255, blue: 195/255),
        backgroundLight: Color(red: 255/255, green: 245/255, blue: 238/255),
        backgroundDark: Color(red: 28/255, green: 24/255, blue: 22/255),
        surfaceLight: Color(red: 250/255, green: 240/255, blue: 230/255),
        surfaceDark: Color(red: 40/255, green: 35/255, blue: 32/255),
        fontFamily: .rounded, fontFamilyDisplay: .rounded,
        typeSize: .large, lineSpacing: 2,
        radiusSM: 12, radiusMD: 16, radiusLG: 24, radiusXL: 32, radiusPill: 100,
        shadowOpacity: 0.05, shadowRadius: 12, shadowY: 3
    )

    static let ink = DesignTheme(
        id: "ink", name: "Ink", icon: "text.book.closed.fill",
        spaceXXS: 2, spaceXS: 4, spaceSM: 10, spaceMD: 18, spaceLG: 28, spaceXL: 36, spaceXXL: 52,
        primary: Color(red: 180/255, green: 155/255, blue: 90/255),
        secondary: Color(red: 130/255, green: 140/255, blue: 100/255),
        tertiary: Color(red: 195/255, green: 155/255, blue: 75/255),
        textLight: Color(red: 55/255, green: 40/255, blue: 30/255),
        textDark: Color(red: 210/255, green: 200/255, blue: 180/255),
        backgroundLight: Color(red: 245/255, green: 238/255, blue: 225/255),
        backgroundDark: Color(red: 24/255, green: 20/255, blue: 16/255),
        surfaceLight: Color(red: 255/255, green: 252/255, blue: 245/255),
        surfaceDark: Color(red: 36/255, green: 32/255, blue: 26/255),
        fontFamily: .serif, fontFamilyDisplay: .serif,
        typeSize: .medium, lineSpacing: 3,
        radiusSM: 6, radiusMD: 10, radiusLG: 16, radiusXL: 22, radiusPill: 100,
        shadowOpacity: 0.08, shadowRadius: 6, shadowY: 2
    )

    static let all: [DesignTheme] = [.serene, .stark, .airy, .lush, .ink]
}
