import SwiftUI

enum CyclePhase: String, CaseIterable, Codable {
    case menstrual
    case follicular
    case ovulation
    case luteal

    var displayName: String {
        switch self {
        case .menstrual: "Menstrual"
        case .follicular: "Follicular"
        case .ovulation: "Ovulation"
        case .luteal: "Luteal"
        }
    }

    var innerSeason: String {
        switch self {
        case .menstrual: "Inner Winter"
        case .follicular: "Inner Spring"
        case .ovulation: "Inner Summer"
        case .luteal: "Inner Autumn"
        }
    }

    var icon: String {
        switch self {
        case .menstrual: "moon.stars.fill"
        case .follicular: "leaf.fill"
        case .ovulation: "sun.max.fill"
        case .luteal: "cloud.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .menstrual: .appRose
        case .follicular: .appSage
        case .ovulation: .appTerracotta
        case .luteal: .appSoftBrown
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .menstrual: [.appRose.opacity(0.3), .appCream]
        case .follicular: [.appSage.opacity(0.3), .appCream]
        case .ovulation: [.appTerracotta.opacity(0.25), .appCream]
        case .luteal: [.appSoftBrown.opacity(0.2), .appCream]
        }
    }
}
