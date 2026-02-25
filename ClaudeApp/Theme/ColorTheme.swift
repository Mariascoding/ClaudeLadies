import SwiftUI

enum ColorTheme: String, CaseIterable, Identifiable {
    case classic, winter, spring, summer, autumn

    var id: String { rawValue }

    static var current: ColorTheme {
        let raw = UserDefaults.standard.string(forKey: "appColorTheme") ?? "classic"
        if raw == "auto" {
            let resolved = UserDefaults.standard.string(forKey: "appResolvedTheme") ?? "classic"
            return ColorTheme(rawValue: resolved) ?? .classic
        }
        return ColorTheme(rawValue: raw) ?? .classic
    }

    static func forPhase(_ phase: CyclePhase) -> ColorTheme {
        switch phase {
        case .menstrual: .winter
        case .follicular: .spring
        case .ovulation: .summer
        case .luteal: .autumn
        }
    }

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .winter: "Winter"
        case .spring: "Spring"
        case .summer: "Summer"
        case .autumn: "Autumn"
        }
    }

    var previewColor: Color {
        lightCream
    }

    // MARK: - Light Cream

    var lightCream: Color {
        switch self {
        case .classic:
            Color(red: 253/255, green: 246/255, blue: 236/255)
        case .winter:
            Color(red: 245/255, green: 228/255, blue: 232/255)
        case .spring:
            Color(red: 237/255, green: 224/255, blue: 237/255)
        case .summer:
            Color(red: 253/255, green: 244/255, blue: 220/255)
        case .autumn:
            Color(red: 224/255, green: 232/255, blue: 240/255)
        }
    }

    // MARK: - Dark Cream

    var darkCream: Color {
        switch self {
        case .classic:
            Color(red: 28/255, green: 25/255, blue: 23/255)
        case .winter:
            Color(red: 30/255, green: 18/255, blue: 20/255)
        case .spring:
            Color(red: 28/255, green: 22/255, blue: 28/255)
        case .summer:
            Color(red: 30/255, green: 26/255, blue: 16/255)
        case .autumn:
            Color(red: 20/255, green: 24/255, blue: 32/255)
        }
    }

    // MARK: - Light WarmWhite

    var lightWarmWhite: Color {
        switch self {
        case .classic:
            Color(red: 255/255, green: 253/255, blue: 249/255)
        case .winter:
            Color(red: 252/255, green: 240/255, blue: 243/255)
        case .spring:
            Color(red: 250/255, green: 240/255, blue: 248/255)
        case .summer:
            Color(red: 255/255, green: 251/255, blue: 235/255)
        case .autumn:
            Color(red: 238/255, green: 244/255, blue: 250/255)
        }
    }

    // MARK: - Dark WarmWhite

    var darkWarmWhite: Color {
        switch self {
        case .classic:
            Color(red: 41/255, green: 37/255, blue: 36/255)
        case .winter:
            Color(red: 42/255, green: 28/255, blue: 31/255)
        case .spring:
            Color(red: 39/255, green: 30/255, blue: 39/255)
        case .summer:
            Color(red: 42/255, green: 37/255, blue: 24/255)
        case .autumn:
            Color(red: 30/255, green: 36/255, blue: 48/255)
        }
    }

    // MARK: - Light SoftBrown

    var lightSoftBrown: Color {
        switch self {
        case .classic:
            Color(red: 107/255, green: 91/255, blue: 78/255)
        case .winter:
            Color(red: 102/255, green: 48/255, blue: 58/255)
        case .spring:
            Color(red: 128/255, green: 90/255, blue: 118/255)
        case .summer:
            Color(red: 140/255, green: 100/255, blue: 50/255)
        case .autumn:
            Color(red: 75/255, green: 95/255, blue: 115/255)
        }
    }

    // MARK: - Dark SoftBrown

    var darkSoftBrown: Color {
        switch self {
        case .classic:
            Color(red: 212/255, green: 196/255, blue: 176/255)
        case .winter:
            Color(red: 224/255, green: 184/255, blue: 192/255)
        case .spring:
            Color(red: 216/255, green: 184/255, blue: 208/255)
        case .summer:
            Color(red: 224/255, green: 200/255, blue: 144/255)
        case .autumn:
            Color(red: 184/255, green: 200/255, blue: 216/255)
        }
    }

    // MARK: - Rose

    var rose: Color {
        switch self {
        case .classic:
            Color(red: 212/255, green: 131/255, blue: 143/255)
        case .winter:
            Color(red: 178/255, green: 100/255, blue: 120/255)
        case .spring:
            Color(red: 210/255, green: 140/255, blue: 168/255)
        case .summer:
            Color(red: 218/255, green: 125/255, blue: 110/255)
        case .autumn:
            Color(red: 175/255, green: 130/255, blue: 150/255)
        }
    }

    // MARK: - Sage

    var sage: Color {
        switch self {
        case .classic:
            Color(red: 163/255, green: 177/255, blue: 138/255)
        case .winter:
            Color(red: 120/255, green: 158/255, blue: 150/255)
        case .spring:
            Color(red: 140/255, green: 180/255, blue: 130/255)
        case .summer:
            Color(red: 170/255, green: 168/255, blue: 115/255)
        case .autumn:
            Color(red: 128/255, green: 152/255, blue: 158/255)
        }
    }

    // MARK: - Terracotta

    var terracotta: Color {
        switch self {
        case .classic:
            Color(red: 201/255, green: 123/255, blue: 99/255)
        case .winter:
            Color(red: 165/255, green: 108/255, blue: 130/255)
        case .spring:
            Color(red: 205/255, green: 140/255, blue: 118/255)
        case .summer:
            Color(red: 208/255, green: 135/255, blue: 68/255)
        case .autumn:
            Color(red: 158/255, green: 122/255, blue: 128/255)
        }
    }

    // MARK: - Adaptive Colors

    var cream: Color {
        let light = UIColor(lightCream)
        let dark = UIColor(darkCream)
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    var warmWhite: Color {
        let light = UIColor(lightWarmWhite)
        let dark = UIColor(darkWarmWhite)
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    var softBrown: Color {
        let light = UIColor(lightSoftBrown)
        let dark = UIColor(darkSoftBrown)
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
