import SwiftUI
import UIKit

// MARK: - Moon Archetype

enum MoonWomanArchetype: String, CaseIterable, Identifiable {
    case white   // New Moon
    case pink    // Waxing
    case red     // Full Moon
    case purple  // Waning

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .white: "\u{1F311}"   // 🌑
        case .pink:  "\u{1F313}"   // 🌓
        case .red:   "\u{1F315}"   // 🌕
        case .purple: "\u{1F317}"  // 🌗
        }
    }

    var title: String {
        switch self {
        case .white: "White Moon Woman"
        case .pink:  "Pink Moon Woman"
        case .red:   "Red Moon Woman"
        case .purple: "Purple Moon Woman"
        }
    }

    var subtitle: String {
        switch self {
        case .white: "Mystic \u{00B7} Priestess \u{00B7} Healer"
        case .pink:  "Maiden \u{00B7} Dreamer \u{00B7} Bloom"
        case .red:   "Wild \u{00B7} Visionary \u{00B7} Catalyst"
        case .purple: "Alchemist \u{00B7} Shadow Worker \u{00B7} Sage"
        }
    }

    var description: String {
        switch self {
        case .white:
            "Born under the new moon's hush, she bleeds in stillness and dreams in starlight. Her medicine is silence, intuition, and the quiet wisdom of the seer."
        case .pink:
            "Born under the waxing crescent, she rises with the moon's becoming. Her medicine is tender beginnings, sweetness, and the courage to bloom in plain view."
        case .red:
            "Born under the full moon's fire, she bleeds in her power. Her medicine is creation, passion, and the wild knowing of the woman who refuses to dim."
        case .purple:
            "Born under the waning moon, she walks between the worlds. Her medicine is release, transformation, and the deep magic of letting things end so something truer can begin."
        }
    }

    /// Short, color-matched narrations spoken one at a time while the
    /// flower blooms. Each line is paired with the layer it describes.
    struct StoryParts {
        let opening: String
        let centerLine: String
        let stamenLine: String
        let innerLine: String
        let outerLine: String
    }

    var storyParts: StoryParts {
        switch self {
        case .white:
            StoryParts(
                opening: "Drawn from new-moon stillness",
                centerLine: "A center of obsidian \u{2014} your quiet seeing",
                stamenLine: "Stamens of moonlight \u{2014} your soft spark",
                innerLine: "Inner petals of silver mist \u{2014} your knowing",
                outerLine: "Outer petals of midnight \u{2014} your shelter"
            )
        case .pink:
            StoryParts(
                opening: "Rising from waxing-moon tenderness",
                centerLine: "A center of cream \u{2014} your innocence",
                stamenLine: "Stamens of soft gold \u{2014} your spark",
                innerLine: "Inner petals of new mint \u{2014} your becoming",
                outerLine: "Outer petals of soft rose \u{2014} your sweetness"
            )
        case .red:
            StoryParts(
                opening: "Forming from full-moon fire",
                centerLine: "A center of bright white \u{2014} your truth",
                stamenLine: "Stamens of warm amber \u{2014} your spark",
                innerLine: "Inner petals of molten gold \u{2014} your power",
                outerLine: "Outer petals of blood red \u{2014} your fire"
            )
        case .purple:
            StoryParts(
                opening: "Conjured from waning-moon alchemy",
                centerLine: "A center of deep teal \u{2014} your depth",
                stamenLine: "Stamens of smoky grey \u{2014} your spark",
                innerLine: "Inner petals of dark plum \u{2014} your shadow",
                outerLine: "Outer petals of violet flame \u{2014} your magic"
            )
        }
    }
}

// MARK: - Auto Flower Config

struct AutoFlowerConfig {
    let outerDesign: OuterPetalDesign
    let innerDesign: InnerPetalDesign
    let stamenDesign: StamenDesign
    let centerDesign: CenterDesign
    let outerColor: Color
    let innerColor: Color
    let stamenColor: Color
    let centerColor: Color
    let geometry: FlowerGeometry
}

// MARK: - Variation Tables

/// A four-color palette that lives within an archetype's tonal family.
struct ArchetypePalette {
    let outer: Color
    let inner: Color
    let stamen: Color
    let center: Color
}

/// A complete shape recipe (designs + petal counts) for an archetype.
struct ArchetypeDesignTemplate {
    let outer: OuterPetalDesign
    let inner: InnerPetalDesign
    let stamen: StamenDesign
    let center: CenterDesign
    let geometry: FlowerGeometry
}

// MARK: - Engine

enum MoonWomanArchetypeEngine {

    /// Returns the moon phase as a value in [0, 1) using a deterministic
    /// synodic-month calculation. Accurate to within ~6 hours, fully offline.
    /// 0.0 = new moon, 0.5 = full moon, 1.0 wraps to new moon.
    static func moonPhase(on date: Date) -> Double {
        // Reference new moon: 2000-01-06 18:14 UTC
        let referenceNewMoon = Date(timeIntervalSince1970: 947182440)
        let synodic = 29.530588853
        let days = date.timeIntervalSince(referenceNewMoon) / 86_400.0
        var phase = (days / synodic).truncatingRemainder(dividingBy: 1.0)
        if phase < 0 { phase += 1 }
        return phase
    }

    /// Maps a normalized moon phase [0, 1) to one of four archetypes.
    static func archetype(for phase: Double) -> MoonWomanArchetype {
        switch phase {
        case ..<0.125, 0.875...:
            return .white   // New
        case 0.125..<0.375:
            return .pink    // Waxing
        case 0.375..<0.625:
            return .red     // Full
        case 0.625..<0.875:
            return .purple  // Waning
        default:
            return .white
        }
    }

    static func archetype(for date: Date) -> MoonWomanArchetype {
        archetype(for: moonPhase(on: date))
    }

    // MARK: - Seeded Flower Config

    /// Builds a unique flower for the given archetype using the seed string
    /// to deterministically pick a palette, design template, and hue shift.
    /// With 6 palettes × 3 designs × 21 hue shifts per archetype, this yields
    /// hundreds of distinct flowers within each moon family — so two purple
    /// women never get the same purple.
    static func flowerConfig(
        for archetype: MoonWomanArchetype,
        seed: String
    ) -> AutoFlowerConfig {
        let pals = palettes(for: archetype)
        let dgs = designs(for: archetype)

        let h1 = stableHash(seed + "|palette")
        let h2 = stableHash(seed + "|design")
        let h3 = stableHash(seed + "|hue")

        let palette = pals[h1 % pals.count]
        let design = dgs[h2 % dgs.count]
        let hueShift = (Double(h3 % 21) - 10) * 1.4  // ~ -14° to +14°

        return AutoFlowerConfig(
            outerDesign: design.outer,
            innerDesign: design.inner,
            stamenDesign: design.stamen,
            centerDesign: design.center,
            outerColor:  shiftHue(palette.outer,  by: hueShift),
            innerColor:  shiftHue(palette.inner,  by: hueShift * 0.6),
            stamenColor: shiftHue(palette.stamen, by: hueShift * 0.4),
            centerColor: shiftHue(palette.center, by: hueShift * 0.3),
            geometry: design.geometry
        )
    }

    // MARK: - Lookup

    static func palettes(for archetype: MoonWomanArchetype) -> [ArchetypePalette] {
        switch archetype {
        case .white:  return whitePalettes
        case .pink:   return pinkPalettes
        case .red:    return redPalettes
        case .purple: return purplePalettes
        }
    }

    static func designs(for archetype: MoonWomanArchetype) -> [ArchetypeDesignTemplate] {
        switch archetype {
        case .white:  return whiteDesigns
        case .pink:   return pinkDesigns
        case .red:    return redDesigns
        case .purple: return purpleDesigns
        }
    }

    // MARK: - Hash & Hue Helpers

    /// Stable djb2 hash → bounded positive Int. Deterministic across runs.
    private static func stableHash(_ s: String) -> Int {
        var hash: UInt64 = 5381
        for byte in s.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
        }
        return Int(hash & 0x7FFFFFFFFFFFFFFF)
    }

    /// Rotates the hue of a SwiftUI Color by the given degrees, preserving
    /// saturation and brightness. Used to add subtle per-flower color drift.
    private static func shiftHue(_ color: Color, by degrees: Double) -> Color {
        let ui = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return color
        }
        var newH = h + CGFloat(degrees / 360.0)
        newH = newH.truncatingRemainder(dividingBy: 1.0)
        if newH < 0 { newH += 1 }
        return Color(hue: Double(newH), saturation: Double(s), brightness: Double(b))
    }

    // MARK: - White Palettes & Designs

    private static let whitePalettes: [ArchetypePalette] = [
        // Midnight lotus
        ArchetypePalette(
            outer:  Color(red: 0.18, green: 0.20, blue: 0.40),
            inner:  Color(red: 0.85, green: 0.87, blue: 0.92),
            stamen: Color(red: 0.96, green: 0.97, blue: 1.00),
            center: Color(red: 0.22, green: 0.22, blue: 0.28)
        ),
        // Pearl moonstone
        ArchetypePalette(
            outer:  Color(red: 0.78, green: 0.80, blue: 0.88),
            inner:  Color(red: 0.92, green: 0.92, blue: 0.96),
            stamen: Color(red: 0.55, green: 0.58, blue: 0.70),
            center: Color(red: 0.18, green: 0.18, blue: 0.28)
        ),
        // Starlight blue
        ArchetypePalette(
            outer:  Color(red: 0.32, green: 0.42, blue: 0.62),
            inner:  Color(red: 0.78, green: 0.85, blue: 0.95),
            stamen: Color(red: 0.92, green: 0.92, blue: 1.00),
            center: Color(red: 0.15, green: 0.20, blue: 0.35)
        ),
        // Frost quartz
        ArchetypePalette(
            outer:  Color(red: 0.92, green: 0.95, blue: 0.98),
            inner:  Color(red: 0.65, green: 0.70, blue: 0.85),
            stamen: Color(red: 0.85, green: 0.88, blue: 0.95),
            center: Color(red: 0.40, green: 0.45, blue: 0.55)
        ),
        // Black velvet
        ArchetypePalette(
            outer:  Color(red: 0.10, green: 0.08, blue: 0.18),
            inner:  Color(red: 0.55, green: 0.55, blue: 0.65),
            stamen: Color(red: 0.92, green: 0.90, blue: 0.85),
            center: Color(red: 0.15, green: 0.12, blue: 0.22)
        ),
        // Sapphire dusk
        ArchetypePalette(
            outer:  Color(red: 0.22, green: 0.30, blue: 0.55),
            inner:  Color(red: 0.45, green: 0.55, blue: 0.75),
            stamen: Color(red: 0.88, green: 0.92, blue: 0.98),
            center: Color(red: 0.10, green: 0.15, blue: 0.30)
        )
    ]

    private static let whiteDesigns: [ArchetypeDesignTemplate] = [
        ArchetypeDesignTemplate(
            outer: .round, inner: .lotus, stamen: .corona, center: .gem,
            geometry: FlowerGeometry(
                outerCount: 12, backCount: 10, innerCount: 6,
                petalWidth: 0.65, innerWidth: 0.55,
                centerScale: 0.14, stamenScale: 0.18,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .peony, inner: .lotus, stamen: .crown, center: .smooth,
            geometry: FlowerGeometry(
                outerCount: 14, backCount: 12, innerCount: 8,
                petalWidth: 0.60, innerWidth: 0.50,
                centerScale: 0.13, stamenScale: 0.16,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .heartleaf, inner: .star, stamen: .fairyDust, center: .swirl,
            geometry: FlowerGeometry(
                outerCount: 10, backCount: 8, innerCount: 5,
                petalWidth: 0.70, innerWidth: 0.55,
                centerScale: 0.15, stamenScale: 0.20,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        )
    ]

    // MARK: - Pink Palettes & Designs

    private static let pinkPalettes: [ArchetypePalette] = [
        // Soft rose
        ArchetypePalette(
            outer:  Color(red: 0.96, green: 0.78, blue: 0.82),
            inner:  Color(red: 0.78, green: 0.92, blue: 0.84),
            stamen: Color(red: 0.95, green: 0.85, blue: 0.55),
            center: Color(red: 0.96, green: 0.93, blue: 0.85)
        ),
        // Coral peach
        ArchetypePalette(
            outer:  Color(red: 0.97, green: 0.72, blue: 0.62),
            inner:  Color(red: 0.95, green: 0.88, blue: 0.78),
            stamen: Color(red: 0.92, green: 0.65, blue: 0.45),
            center: Color(red: 0.98, green: 0.92, blue: 0.85)
        ),
        // Bubblegum pink
        ArchetypePalette(
            outer:  Color(red: 0.98, green: 0.62, blue: 0.78),
            inner:  Color(red: 0.92, green: 0.85, blue: 0.92),
            stamen: Color(red: 0.98, green: 0.78, blue: 0.45),
            center: Color(red: 0.98, green: 0.95, blue: 0.92)
        ),
        // Strawberry blush
        ArchetypePalette(
            outer:  Color(red: 0.95, green: 0.55, blue: 0.62),
            inner:  Color(red: 0.78, green: 0.88, blue: 0.72),
            stamen: Color(red: 0.95, green: 0.78, blue: 0.42),
            center: Color(red: 0.96, green: 0.90, blue: 0.82)
        ),
        // Mauve fairy
        ArchetypePalette(
            outer:  Color(red: 0.88, green: 0.68, blue: 0.78),
            inner:  Color(red: 0.85, green: 0.78, blue: 0.85),
            stamen: Color(red: 0.92, green: 0.75, blue: 0.55),
            center: Color(red: 0.95, green: 0.88, blue: 0.82)
        ),
        // Apricot bloom
        ArchetypePalette(
            outer:  Color(red: 0.98, green: 0.78, blue: 0.62),
            inner:  Color(red: 0.85, green: 0.92, blue: 0.78),
            stamen: Color(red: 0.95, green: 0.85, blue: 0.42),
            center: Color(red: 0.98, green: 0.92, blue: 0.78)
        )
    ]

    private static let pinkDesigns: [ArchetypeDesignTemplate] = [
        ArchetypeDesignTemplate(
            outer: .cherryBlossom, inner: .tulip, stamen: .sunburst, center: .smooth,
            geometry: FlowerGeometry(
                outerCount: 5, backCount: 5, innerCount: 0,
                petalWidth: 0.85, innerWidth: 0.50,
                centerScale: 0.10, stamenScale: 0.22,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .round, inner: .tulip, stamen: .dewdrops, center: .rings,
            geometry: FlowerGeometry(
                outerCount: 8, backCount: 8, innerCount: 6,
                petalWidth: 0.75, innerWidth: 0.55,
                centerScale: 0.12, stamenScale: 0.18,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .cosmos, inner: .star, stamen: .sunburst, center: .seedSpiral,
            geometry: FlowerGeometry(
                outerCount: 8, backCount: 8, innerCount: 0,
                petalWidth: 0.45, innerWidth: 0.40,
                centerScale: 0.16, stamenScale: 0.18,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        )
    ]

    // MARK: - Red Palettes & Designs

    private static let redPalettes: [ArchetypePalette] = [
        // Blood crimson
        ArchetypePalette(
            outer:  Color(red: 0.72, green: 0.10, blue: 0.15),
            inner:  Color(red: 0.92, green: 0.72, blue: 0.15),
            stamen: Color(red: 0.95, green: 0.55, blue: 0.20),
            center: Color(red: 0.98, green: 0.95, blue: 0.88)
        ),
        // Sunset orange
        ArchetypePalette(
            outer:  Color(red: 0.95, green: 0.45, blue: 0.18),
            inner:  Color(red: 0.98, green: 0.78, blue: 0.32),
            stamen: Color(red: 0.92, green: 0.85, blue: 0.42),
            center: Color(red: 0.98, green: 0.92, blue: 0.85)
        ),
        // Burgundy wine
        ArchetypePalette(
            outer:  Color(red: 0.50, green: 0.10, blue: 0.18),
            inner:  Color(red: 0.85, green: 0.55, blue: 0.30),
            stamen: Color(red: 0.92, green: 0.65, blue: 0.42),
            center: Color(red: 0.98, green: 0.88, blue: 0.75)
        ),
        // Ruby fire
        ArchetypePalette(
            outer:  Color(red: 0.85, green: 0.18, blue: 0.22),
            inner:  Color(red: 0.98, green: 0.65, blue: 0.18),
            stamen: Color(red: 0.95, green: 0.78, blue: 0.32),
            center: Color(red: 0.98, green: 0.95, blue: 0.88)
        ),
        // Pomegranate
        ArchetypePalette(
            outer:  Color(red: 0.78, green: 0.22, blue: 0.30),
            inner:  Color(red: 0.92, green: 0.45, blue: 0.32),
            stamen: Color(red: 0.95, green: 0.72, blue: 0.32),
            center: Color(red: 0.98, green: 0.90, blue: 0.78)
        ),
        // Cinnabar amber
        ArchetypePalette(
            outer:  Color(red: 0.88, green: 0.32, blue: 0.18),
            inner:  Color(red: 0.98, green: 0.72, blue: 0.22),
            stamen: Color(red: 0.95, green: 0.85, blue: 0.45),
            center: Color(red: 0.98, green: 0.92, blue: 0.82)
        )
    ]

    private static let redDesigns: [ArchetypeDesignTemplate] = [
        ArchetypeDesignTemplate(
            outer: .dahlia, inner: .star, stamen: .pollenCloud, center: .rings,
            geometry: FlowerGeometry(
                outerCount: 26, backCount: 24, innerCount: 18,
                petalWidth: 0.32, innerWidth: 0.28,
                centerScale: 0.05, stamenScale: 0.10,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .peony, inner: .feather, stamen: .pollenCloud, center: .gem,
            geometry: FlowerGeometry(
                outerCount: 22, backCount: 20, innerCount: 14,
                petalWidth: 0.45, innerWidth: 0.38,
                centerScale: 0.07, stamenScale: 0.12,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .rose, inner: .lotus, stamen: .tendrils, center: .swirl,
            geometry: FlowerGeometry(
                outerCount: 18, backCount: 16, innerCount: 12,
                petalWidth: 0.55, innerWidth: 0.48,
                centerScale: 0.08, stamenScale: 0.14,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        )
    ]

    // MARK: - Purple Palettes & Designs

    private static let purplePalettes: [ArchetypePalette] = [
        // Deep amethyst
        ArchetypePalette(
            outer:  Color(red: 0.45, green: 0.28, blue: 0.62),
            inner:  Color(red: 0.32, green: 0.18, blue: 0.32),
            stamen: Color(red: 0.55, green: 0.50, blue: 0.58),
            center: Color(red: 0.12, green: 0.30, blue: 0.32)
        ),
        // Wisteria dream
        ArchetypePalette(
            outer:  Color(red: 0.62, green: 0.55, blue: 0.85),
            inner:  Color(red: 0.45, green: 0.38, blue: 0.65),
            stamen: Color(red: 0.85, green: 0.78, blue: 0.92),
            center: Color(red: 0.30, green: 0.22, blue: 0.42)
        ),
        // Royal indigo
        ArchetypePalette(
            outer:  Color(red: 0.30, green: 0.18, blue: 0.55),
            inner:  Color(red: 0.55, green: 0.40, blue: 0.78),
            stamen: Color(red: 0.92, green: 0.85, blue: 0.62),
            center: Color(red: 0.10, green: 0.05, blue: 0.22)
        ),
        // Smoky lilac
        ArchetypePalette(
            outer:  Color(red: 0.72, green: 0.62, blue: 0.78),
            inner:  Color(red: 0.50, green: 0.42, blue: 0.55),
            stamen: Color(red: 0.92, green: 0.85, blue: 0.88),
            center: Color(red: 0.35, green: 0.28, blue: 0.42)
        ),
        // Plum velvet
        ArchetypePalette(
            outer:  Color(red: 0.55, green: 0.20, blue: 0.45),
            inner:  Color(red: 0.78, green: 0.55, blue: 0.70),
            stamen: Color(red: 0.95, green: 0.78, blue: 0.85),
            center: Color(red: 0.20, green: 0.10, blue: 0.18)
        ),
        // Twilight orchid
        ArchetypePalette(
            outer:  Color(red: 0.62, green: 0.32, blue: 0.75),
            inner:  Color(red: 0.92, green: 0.78, blue: 0.92),
            stamen: Color(red: 0.78, green: 0.55, blue: 0.85),
            center: Color(red: 0.32, green: 0.18, blue: 0.42)
        )
    ]

    private static let purpleDesigns: [ArchetypeDesignTemplate] = [
        ArchetypeDesignTemplate(
            outer: .peony, inner: .lotus, stamen: .tendrils, center: .swirl,
            geometry: FlowerGeometry(
                outerCount: 18, backCount: 16, innerCount: 14,
                petalWidth: 0.58, innerWidth: 0.52,
                centerScale: 0.06, stamenScale: 0.12,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .rose, inner: .star, stamen: .corona, center: .gem,
            geometry: FlowerGeometry(
                outerCount: 16, backCount: 14, innerCount: 12,
                petalWidth: 0.55, innerWidth: 0.48,
                centerScale: 0.10, stamenScale: 0.14,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        ),
        ArchetypeDesignTemplate(
            outer: .heartleaf, inner: .bell, stamen: .tendrils, center: .seedSpiral,
            geometry: FlowerGeometry(
                outerCount: 12, backCount: 10, innerCount: 8,
                petalWidth: 0.62, innerWidth: 0.55,
                centerScale: 0.12, stamenScale: 0.18,
                outerGradientStrength: 0, innerGradientStrength: 0
            )
        )
    ]
}
