import Foundation
import SwiftData

/// Persisted answers from the Auto Flower intake. Lets the user keep
/// their flower across launches: the same inputs deterministically
/// re-produce the same archetype + flower config, while cycle position
/// is recomputed fresh each session.
@Model
final class AutoFlowerProfile {
    var displayName: String
    var ageSelection: Int
    var hasPeriod: Bool
    var periodDate: Date
    var createdDate: Date

    init(
        displayName: String,
        ageSelection: Int,
        hasPeriod: Bool,
        periodDate: Date,
        createdDate: Date = .now
    ) {
        self.displayName = displayName
        self.ageSelection = ageSelection
        self.hasPeriod = hasPeriod
        self.periodDate = periodDate
        self.createdDate = createdDate
    }
}
