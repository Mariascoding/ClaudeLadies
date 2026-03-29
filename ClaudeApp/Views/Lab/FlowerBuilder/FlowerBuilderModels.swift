import SwiftUI

// MARK: - Flower Color

enum FlowerColor: String, CaseIterable, Identifiable {
    case rose
    case sage
    case terracotta
    case golden
    case lavender
    case coral
    case midnight
    case blush
    case ivory
    case plum

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rose: "Rose"
        case .sage: "Sage"
        case .terracotta: "Terracotta"
        case .golden: "Golden"
        case .lavender: "Lavender"
        case .coral: "Coral"
        case .midnight: "Midnight"
        case .blush: "Blush"
        case .ivory: "Ivory"
        case .plum: "Plum"
        }
    }

    var color: Color {
        switch self {
        case .rose: .appRose
        case .sage: .appSage
        case .terracotta: .appTerracotta
        case .golden: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .lavender: Color(red: 0.69, green: 0.61, blue: 0.82)
        case .coral: Color(red: 0.93, green: 0.55, blue: 0.48)
        case .midnight: Color(red: 0.28, green: 0.35, blue: 0.55)
        case .blush: Color(red: 0.95, green: 0.80, blue: 0.78)
        case .ivory: Color(red: 0.96, green: 0.93, blue: 0.85)
        case .plum: Color(red: 0.60, green: 0.38, blue: 0.50)
        }
    }
}

// MARK: - Flower Part

enum FlowerPart: String, CaseIterable, Identifiable {
    case outerPetals
    case innerPetals
    case stamen
    case center

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .outerPetals: "Outer Petals"
        case .innerPetals: "Inner Petals"
        case .stamen: "Stamen"
        case .center: "Center"
        }
    }

    var icon: String {
        switch self {
        case .outerPetals: "sun.max"
        case .innerPetals: "leaf"
        case .stamen: "sparkles"
        case .center: "circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .outerPetals: .appRose
        case .innerPetals: .appTerracotta
        case .stamen: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .center: .appSage
        }
    }
}

// MARK: - Outer Petal Design

enum OuterPetalDesign: String, CaseIterable, Identifiable {
    case classic
    case dahlia
    case peony
    case heartleaf
    case cosmos

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .dahlia: "Dahlia"
        case .peony: "Peony"
        case .heartleaf: "Heartleaf"
        case .cosmos: "Cosmos"
        }
    }
}

// MARK: - Inner Petal Design

enum InnerPetalDesign: String, CaseIterable, Identifiable {
    case tulip
    case star
    case bell
    case feather
    case lotus

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tulip: "Tulip"
        case .star: "Star"
        case .bell: "Bell"
        case .feather: "Feather"
        case .lotus: "Lotus"
        }
    }
}

// MARK: - Stamen Design

enum StamenDesign: String, CaseIterable, Identifiable {
    case dewdrops
    case sunburst
    case tendrils
    case pollenCloud
    case crown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dewdrops: "Dewdrops"
        case .sunburst: "Sunburst"
        case .tendrils: "Tendrils"
        case .pollenCloud: "Pollen Cloud"
        case .crown: "Crown"
        }
    }
}

// MARK: - Center Design

enum CenterDesign: String, CaseIterable, Identifiable {
    case smooth
    case rings
    case seedSpiral
    case gem
    case swirl

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .smooth: "Smooth"
        case .rings: "Rings"
        case .seedSpiral: "Seed Spiral"
        case .gem: "Gem"
        case .swirl: "Swirl"
        }
    }
}
