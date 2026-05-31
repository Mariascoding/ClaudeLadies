import Foundation
import SwiftData
import SwiftUI

enum ShinedustSource: String, CaseIterable, Codable, Identifiable {
    case nutritionItem
    case breathingExercise
    case dayLog
    case somaticExercise
    case grounding

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .nutritionItem:     "Nourishment noted"
        case .breathingExercise: "Breath practice"
        case .dayLog:            "Day tended"
        case .somaticExercise:   "Somatic practice"
        case .grounding:         "Grounded"
        }
    }

    var iconName: String {
        switch self {
        case .nutritionItem:     "leaf.fill"
        case .breathingExercise: "wind"
        case .dayLog:            "book.closed.fill"
        case .somaticExercise:   "figure.mind.and.body"
        case .grounding:         "mountain.2.fill"
        }
    }

    /// Default drop amount awarded by this source.
    var defaultAmount: Int {
        switch self {
        case .nutritionItem:     1
        case .breathingExercise: 3
        case .dayLog:            2
        case .somaticExercise:   2
        case .grounding:         1
        }
    }

    var accentColor: Color {
        switch self {
        case .nutritionItem:     .appSage
        case .breathingExercise: .appRose
        case .dayLog:            .appTerracotta
        case .somaticExercise:   Color(red: 0.72, green: 0.58, blue: 0.82)
        case .grounding:         .appSoftBrown
        }
    }
}

@Model
final class ShinedustEvent {
    var timestamp: Date
    var sourceRaw: String
    var amount: Int

    init(timestamp: Date = .now, source: ShinedustSource, amount: Int? = nil) {
        self.timestamp = timestamp
        self.sourceRaw = source.rawValue
        self.amount = amount ?? source.defaultAmount
    }

    var source: ShinedustSource {
        ShinedustSource(rawValue: sourceRaw) ?? .nutritionItem
    }
}

// MARK: - Award Helper
//
// Shared entry point for any completion event across the app. Inserts a
// ShinedustEvent into the given context and saves. Callers decide the
// source — the amount defaults to the source's standard drop count but
// can be overridden for special rewards.

enum Shinedust {
    static func award(
        _ source: ShinedustSource,
        amount: Int? = nil,
        in modelContext: ModelContext
    ) {
        let event = ShinedustEvent(source: source, amount: amount)
        modelContext.insert(event)
        try? modelContext.save()
    }

    /// Awards a drop only if the same source has not already produced a
    /// drop today. Prevents spammy rewards for actions the user might
    /// trigger many times per day (e.g. toggling symptoms).
    static func awardOncePerDay(
        _ source: ShinedustSource,
        amount: Int? = nil,
        in modelContext: ModelContext
    ) {
        let today = Calendar.current.startOfDay(for: .now)
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
        let raw = source.rawValue
        let descriptor = FetchDescriptor<ShinedustEvent>(
            predicate: #Predicate { $0.timestamp >= today && $0.timestamp < tomorrow && $0.sourceRaw == raw }
        )
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }
        award(source, amount: amount, in: modelContext)
    }
}

// MARK: - Growth Level
//
// Converts total accumulated drops into a 0…1 growth level with a soft
// saturating curve so early drops feel rewarding and the flower keeps
// growing (slower) forever. Milestones unlock visual tiers on top of
// the base bloom rendering.

enum GrowthLevel {
    /// Normalized 0…1 growth — approaches 1 as total → ∞.
    static func level(for totalDrops: Int) -> CGFloat {
        guard totalDrops > 0 else { return 0 }
        // Half-growth at 40 drops, ~0.8 at 160 drops, asymptote at 1.
        let k: CGFloat = 40
        let t = CGFloat(totalDrops)
        return t / (t + k)
    }

    /// Visual tiers keyed off total drops — matches what the GrowthOverlay
    /// layers in on the flower.
    enum Tier: Int, CaseIterable, Comparable {
        case seed = 0       // 0–9 drops
        case sprouting = 1  // 10–24 drops
        case budding = 2    // 25–49 drops
        case radiant = 3    // 50–99 drops
        case magical = 4    // 100+ drops

        static func < (lhs: Tier, rhs: Tier) -> Bool { lhs.rawValue < rhs.rawValue }

        static func tier(for totalDrops: Int) -> Tier {
            switch totalDrops {
            case ..<10:    .seed
            case 10..<25:  .sprouting
            case 25..<50:  .budding
            case 50..<100: .radiant
            default:       .magical
            }
        }

        var displayName: String {
            switch self {
            case .seed:      "Seedling"
            case .sprouting: "Sprouting"
            case .budding:   "Budding"
            case .radiant:   "Radiant"
            case .magical:   "Magical"
            }
        }

        /// Drop count that marks the start of the NEXT tier, or nil if at top.
        var nextThreshold: Int? {
            switch self {
            case .seed:      10
            case .sprouting: 25
            case .budding:   50
            case .radiant:   100
            case .magical:   nil
            }
        }

        /// Drop count at which this tier begins.
        var floor: Int {
            switch self {
            case .seed:      0
            case .sprouting: 10
            case .budding:   25
            case .radiant:   50
            case .magical:   100
            }
        }
    }
}
