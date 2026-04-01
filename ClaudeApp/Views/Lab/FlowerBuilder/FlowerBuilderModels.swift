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
    case umber
    case sunYellow

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
        case .umber: "Umber"
        case .sunYellow: "Sun Yellow"
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
        case .umber: Color(red: 0.35, green: 0.22, blue: 0.12)
        case .sunYellow: Color(red: 1.0, green: 0.78, blue: 0.10)
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

    var shortName: String {
        switch self {
        case .outerPetals: "Outer"
        case .innerPetals: "Inner"
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

// MARK: - Flower Geometry

struct FlowerGeometry: Equatable {
    var outerCount: Int
    var backCount: Int
    var innerCount: Int
    var petalWidth: CGFloat     // outer petal width-to-height ratio
    var innerWidth: CGFloat     // inner petal width-to-height ratio
    var centerScale: CGFloat    // center radius as fraction of total size
    var stamenScale: CGFloat    // stamen radius as fraction of total size

    static let `default` = FlowerGeometry(
        outerCount: 8, backCount: 8, innerCount: 6,
        petalWidth: 0.6, innerWidth: 0.5,
        centerScale: 0.14, stamenScale: 0.22
    )
}

// MARK: - Flower Preset

enum FlowerPreset: String, CaseIterable, Identifiable {
    case rose, lotus, dahlia, lily, cosmos, forgetMeNot, peony, sunflower

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rose: "Rose"
        case .lotus: "Lotus"
        case .dahlia: "Dahlia"
        case .lily: "Lily"
        case .cosmos: "Cosmos"
        case .forgetMeNot: "Forget-Me-Not"
        case .peony: "Peony"
        case .sunflower: "Sunflower"
        }
    }

    var icon: String {
        switch self {
        case .rose: "camera.macro"
        case .lotus: "drop.fill"
        case .dahlia: "sun.max.fill"
        case .lily: "leaf.fill"
        case .cosmos: "sparkles"
        case .forgetMeNot: "star.fill"
        case .peony: "cloud.fill"
        case .sunflower: "sun.min.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .rose: FlowerColor.rose.color
        case .lotus: FlowerColor.blush.color
        case .dahlia: FlowerColor.coral.color
        case .lily: Color(red: 0.62, green: 0.55, blue: 0.42)
        case .cosmos: FlowerColor.lavender.color
        case .forgetMeNot: FlowerColor.midnight.color
        case .peony: FlowerColor.rose.color
        case .sunflower: FlowerColor.golden.color
        }
    }

    var outerDesign: OuterPetalDesign {
        switch self {
        case .rose: .classic
        case .lotus: .round       // smooth elliptical petals
        case .dahlia: .dahlia
        case .lily: .peony        // wide tepals with ruffled wavy edges
        case .cosmos: .cosmos
        case .forgetMeNot: .round // perfectly round petals
        case .peony: .peony
        case .sunflower: .dahlia  // narrow tapered tube = ray petals
        }
    }

    var innerDesign: InnerPetalDesign {
        switch self {
        case .rose: .tulip
        case .lotus: .lotus
        case .dahlia: .star
        case .lily: .bell         // trumpet-shaped inner tepals
        case .cosmos: .star
        case .forgetMeNot: .tulip
        case .peony: .lotus
        case .sunflower: .feather
        }
    }

    var stamen: StamenDesign {
        switch self {
        case .rose: .pollenCloud    // roses hide their stamens
        case .lotus: .pollenCloud
        case .dahlia: .pollenCloud  // dense petals hide stamens
        case .lily: .tendrils
        case .cosmos: .pollenCloud
        case .forgetMeNot: .corona      // white star corona
        case .peony: .pollenCloud   // hidden stamens
        case .sunflower: .pollenCloud
        }
    }

    var center: CenterDesign {
        switch self {
        case .rose: .swirl
        case .lotus: .rings        // tubular receptacle
        case .dahlia: .rings
        case .lily: .smooth
        case .cosmos: .seedSpiral
        case .forgetMeNot: .smooth // simple center
        case .peony: .swirl
        case .sunflower: .seedSpiral
        }
    }

    var outerColor: FlowerColor {
        switch self {
        case .rose: .rose
        case .lotus: .blush
        case .dahlia: .coral
        case .lily: .ivory
        case .cosmos: .lavender
        case .forgetMeNot: .lavender // brighter blue
        case .peony: .rose
        case .sunflower: .sunYellow
        }
    }

    var innerColor: FlowerColor {
        switch self {
        case .rose: .blush
        case .lotus: .ivory
        case .dahlia: .terracotta
        case .lily: .blush
        case .cosmos: .plum
        case .forgetMeNot: .lavender
        case .peony: .blush
        case .sunflower: .terracotta
        }
    }

    var stamenColor: FlowerColor {
        switch self {
        case .rose, .lotus, .lily, .cosmos, .peony: .golden
        case .dahlia: .golden
        case .forgetMeNot: .ivory   // white eye ring
        case .sunflower: .terracotta
        }
    }

    var centerColor: FlowerColor {
        switch self {
        case .rose: .sage
        case .lotus: .golden       // yellow center
        case .dahlia: .terracotta
        case .lily: .sage
        case .cosmos: .golden      // yellow disc center
        case .forgetMeNot: .golden // yellow center
        case .peony: .golden       // golden if visible
        case .sunflower: .umber    // dark brown seed disc
        }
    }

    var geometry: FlowerGeometry {
        switch self {
        case .rose:
            // Dense layered petals, tiny hidden center
            FlowerGeometry(outerCount: 16, backCount: 14, innerCount: 12,
                           petalWidth: 0.50, innerWidth: 0.48,
                           centerScale: 0.06, stamenScale: 0.10)
        case .lotus:
            // Broad smooth petals, visible golden center
            FlowerGeometry(outerCount: 12, backCount: 10, innerCount: 6,
                           petalWidth: 0.65, innerWidth: 0.55,
                           centerScale: 0.14, stamenScale: 0.18)
        case .dahlia:
            // Very dense quilled petals, thicker layering, hidden center
            FlowerGeometry(outerCount: 26, backCount: 24, innerCount: 18,
                           petalWidth: 0.32, innerWidth: 0.28,
                           centerScale: 0.05, stamenScale: 0.10)
        case .lily:
            // 3 outer + 3 inner alternating, wide tepals, huge prominent stamens
            FlowerGeometry(outerCount: 3, backCount: 3, innerCount: 3,
                           petalWidth: 0.70, innerWidth: 0.60,
                           centerScale: 0.08, stamenScale: 0.30)
        case .cosmos:
            // 8 flat ray petals, single open layer, visible center
            FlowerGeometry(outerCount: 8, backCount: 8, innerCount: 0,
                           petalWidth: 0.45, innerWidth: 0.40,
                           centerScale: 0.16, stamenScale: 0.18)
        case .forgetMeNot:
            // 5 broad round petals overlapping closely, corona eye ring
            FlowerGeometry(outerCount: 5, backCount: 0, innerCount: 0,
                           petalWidth: 0.98, innerWidth: 0.60,
                           centerScale: 0.12, stamenScale: 0.18)
        case .peony:
            // Dense ruffled layers, hidden center
            FlowerGeometry(outerCount: 18, backCount: 16, innerCount: 14,
                           petalWidth: 0.58, innerWidth: 0.52,
                           centerScale: 0.06, stamenScale: 0.12)
        case .sunflower:
            // Multi-layered ray petals around a massive dark seed disc
            FlowerGeometry(outerCount: 28, backCount: 24, innerCount: 16,
                           petalWidth: 0.45, innerWidth: 0.35,
                           centerScale: 0.32, stamenScale: 0.18)
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
    case round

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .dahlia: "Dahlia"
        case .peony: "Peony"
        case .heartleaf: "Heartleaf"
        case .cosmos: "Cosmos"
        case .round: "Round"
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
    case corona

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dewdrops: "Dewdrops"
        case .sunburst: "Sunburst"
        case .tendrils: "Tendrils"
        case .pollenCloud: "Pollen Cloud"
        case .crown: "Crown"
        case .corona: "Corona"
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
