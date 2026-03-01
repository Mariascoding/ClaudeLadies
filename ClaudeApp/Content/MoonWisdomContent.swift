import Foundation

// MARK: - Lunar Phase

enum LunarPhase: String, CaseIterable, Identifiable {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newMoon: "New Moon"
        case .waxingCrescent: "Waxing Crescent"
        case .firstQuarter: "First Quarter"
        case .waxingGibbous: "Waxing Gibbous"
        case .fullMoon: "Full Moon"
        case .waningGibbous: "Waning Gibbous"
        case .lastQuarter: "Last Quarter"
        case .waningCrescent: "Waning Crescent"
        }
    }

    var icon: String {
        switch self {
        case .newMoon: "moonphase.new.moon"
        case .waxingCrescent: "moonphase.waxing.crescent"
        case .firstQuarter: "moonphase.first.quarter"
        case .waxingGibbous: "moonphase.waxing.gibbous"
        case .fullMoon: "moonphase.full.moon"
        case .waningGibbous: "moonphase.waning.gibbous"
        case .lastQuarter: "moonphase.last.quarter"
        case .waningCrescent: "moonphase.waning.crescent"
        }
    }

    var startPhase: Double {
        switch self {
        case .newMoon: 0.0
        case .waxingCrescent: 0.0625
        case .firstQuarter: 0.1875
        case .waxingGibbous: 0.3125
        case .fullMoon: 0.4375
        case .waningGibbous: 0.5625
        case .lastQuarter: 0.6875
        case .waningCrescent: 0.8125
        }
    }

    var endPhase: Double {
        switch self {
        case .newMoon: 0.0625
        case .waxingCrescent: 0.1875
        case .firstQuarter: 0.3125
        case .waxingGibbous: 0.4375
        case .fullMoon: 0.5625
        case .waningGibbous: 0.6875
        case .lastQuarter: 0.8125
        case .waningCrescent: 0.9375
        }
    }

    static func from(moonPhase: Double) -> LunarPhase {
        let normalized = moonPhase.truncatingRemainder(dividingBy: 1.0)
        let phase = normalized < 0 ? normalized + 1.0 : normalized

        // Handle wrap-around for waning crescent → new moon
        if phase >= 0.9375 || phase < 0.0625 { return .newMoon }

        for lunarPhase in LunarPhase.allCases where lunarPhase != .newMoon {
            if phase >= lunarPhase.startPhase && phase < lunarPhase.endPhase {
                return lunarPhase
            }
        }
        return .newMoon
    }
}

// MARK: - Wisdom Data Types

struct MoonWisdomActivity {
    let description: String
    let tradition: String
}

struct MoonPhaseWisdom {
    let lunarPhase: LunarPhase
    let energyKeyword: String
    let advised: [MoonWisdomActivity]
    let avoid: [MoonWisdomActivity]
    let quote: String
    let quoteAttribution: String
}

// MARK: - Moon Wisdom Content

enum MoonWisdomContent {
    static func wisdom(for moonPhase: Double) -> MoonPhaseWisdom {
        let phase = LunarPhase.from(moonPhase: moonPhase)
        switch phase {
        case .newMoon: return newMoonWisdom
        case .waxingCrescent: return waxingCrescentWisdom
        case .firstQuarter: return firstQuarterWisdom
        case .waxingGibbous: return waxingGibbousWisdom
        case .fullMoon: return fullMoonWisdom
        case .waningGibbous: return waningGibbousWisdom
        case .lastQuarter: return lastQuarterWisdom
        case .waningCrescent: return waningCrescentWisdom
        }
    }

    // MARK: - Phase Wisdom Data

    static let newMoonWisdom = MoonPhaseWisdom(
        lunarPhase: .newMoon,
        energyKeyword: "Stillness",
        advised: [
            MoonWisdomActivity(description: "Set intentions for the cycle ahead", tradition: "Vedic"),
            MoonWisdomActivity(description: "Fast lightly or eat simply", tradition: "Ayurveda / TCM"),
            MoonWisdomActivity(description: "Begin a meditation practice", tradition: "Buddhist")
        ],
        avoid: [
            MoonWisdomActivity(description: "Launching new ventures", tradition: "Babylonian"),
            MoonWisdomActivity(description: "Cutting hair for growth", tradition: "Farmer's Almanac")
        ],
        quote: "In the dark of the moon, the seed knows which way to grow.",
        quoteAttribution: "Celtic"
    )

    static let waxingCrescentWisdom = MoonPhaseWisdom(
        lunarPhase: .waxingCrescent,
        energyKeyword: "Rising",
        advised: [
            MoonWisdomActivity(description: "Cut hair for growth", tradition: "Farmer's Almanac"),
            MoonWisdomActivity(description: "Begin projects and plant seeds", tradition: "Steiner / Celtic"),
            MoonWisdomActivity(description: "Gentle nourishment and warm foods", tradition: "TCM")
        ],
        avoid: [
            MoonWisdomActivity(description: "Signing major contracts", tradition: "Roman"),
            MoonWisdomActivity(description: "Overexertion or pushing limits", tradition: "Miranda Gray")
        ],
        quote: "The crescent moon is a bow from which the archer of intention shoots.",
        quoteAttribution: "Rumi"
    )

    static let firstQuarterWisdom = MoonPhaseWisdom(
        lunarPhase: .firstQuarter,
        energyKeyword: "Action",
        advised: [
            MoonWisdomActivity(description: "Make decisions and take action", tradition: "Babylonian / Roman"),
            MoonWisdomActivity(description: "Creative problem-solving", tradition: "Celtic"),
            MoonWisdomActivity(description: "Cut hair for strength", tradition: "Farmer's Almanac")
        ],
        avoid: [
            MoonWisdomActivity(description: "Quitting projects midway", tradition: "Steiner"),
            MoonWisdomActivity(description: "Excessive rest or withdrawal", tradition: "TCM")
        ],
        quote: "At the half-moon, the warrior and the sage are one.",
        quoteAttribution: "Mahabharata"
    )

    static let waxingGibbousWisdom = MoonPhaseWisdom(
        lunarPhase: .waxingGibbous,
        energyKeyword: "Refining",
        advised: [
            MoonWisdomActivity(description: "Refine and polish ongoing work", tradition: "Farmer's Almanac"),
            MoonWisdomActivity(description: "Socialize and network", tradition: "Roman / Torah"),
            MoonWisdomActivity(description: "Rich nourishment and building foods", tradition: "Ayurveda")
        ],
        avoid: [
            MoonWisdomActivity(description: "Starting entirely new ventures", tradition: "Steiner"),
            MoonWisdomActivity(description: "Extended isolation", tradition: "Miranda Gray")
        ],
        quote: "What the farmer tends in the swelling moon, the harvest remembers.",
        quoteAttribution: "Farmer's Almanac"
    )

    static let fullMoonWisdom = MoonPhaseWisdom(
        lunarPhase: .fullMoon,
        energyKeyword: "Culmination",
        advised: [
            MoonWisdomActivity(description: "Harvest and celebrate achievements", tradition: "Celtic / Torah"),
            MoonWisdomActivity(description: "Finalize negotiations and deals", tradition: "Babylonian"),
            MoonWisdomActivity(description: "Deep meditation and ritual", tradition: "Buddhist / Vedic")
        ],
        avoid: [
            MoonWisdomActivity(description: "Impulsive decisions", tradition: "Ayurveda"),
            MoonWisdomActivity(description: "Fasting or restricting food", tradition: "Ayurveda / TCM")
        ],
        quote: "The full moon does not argue with the darkness \u{2014} it simply shines.",
        quoteAttribution: "Buddhist"
    )

    static let waningGibbousWisdom = MoonPhaseWisdom(
        lunarPhase: .waningGibbous,
        energyKeyword: "Sharing",
        advised: [
            MoonWisdomActivity(description: "Share knowledge and teach others", tradition: "Celtic"),
            MoonWisdomActivity(description: "Begin detox or cleansing protocols", tradition: "TCM / Ayurveda"),
            MoonWisdomActivity(description: "Practice gratitude rituals", tradition: "Wiccan / Vedic")
        ],
        avoid: [
            MoonWisdomActivity(description: "Starting new projects", tradition: "Steiner"),
            MoonWisdomActivity(description: "Cutting hair for growth", tradition: "Farmer's Almanac")
        ],
        quote: "The wise gardener prunes in the waning light.",
        quoteAttribution: "Biodynamic"
    )

    static let lastQuarterWisdom = MoonPhaseWisdom(
        lunarPhase: .lastQuarter,
        energyKeyword: "Releasing",
        advised: [
            MoonWisdomActivity(description: "Release what no longer serves you", tradition: "Wiccan / Vedic"),
            MoonWisdomActivity(description: "Deep inner work and journaling", tradition: "Buddhist"),
            MoonWisdomActivity(description: "Lighter eating and simplicity", tradition: "TCM")
        ],
        avoid: [
            MoonWisdomActivity(description: "Signing new contracts", tradition: "Roman / Babylonian"),
            MoonWisdomActivity(description: "Overextending socially", tradition: "Celtic")
        ],
        quote: "To know what to release is greater wisdom than to know what to grasp.",
        quoteAttribution: "Lao Tzu"
    )

    static let waningCrescentWisdom = MoonPhaseWisdom(
        lunarPhase: .waningCrescent,
        energyKeyword: "Surrender",
        advised: [
            MoonWisdomActivity(description: "Rest deeply and restore energy", tradition: "Ayurveda / TCM"),
            MoonWisdomActivity(description: "Dreamwork and contemplation", tradition: "Wiccan / Vedic"),
            MoonWisdomActivity(description: "Clear space and prepare for renewal", tradition: "Farmer's Almanac")
        ],
        avoid: [
            MoonWisdomActivity(description: "Beginning anything new", tradition: "Universal"),
            MoonWisdomActivity(description: "Demanding social obligations", tradition: "TCM")
        ],
        quote: "Rest is not the absence of action \u{2014} it is the deepest action of all.",
        quoteAttribution: "Vedic"
    )
}
