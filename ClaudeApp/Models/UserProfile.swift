import Foundation
import SwiftData

@Model
final class UserProfile {
    var cycleLength: Int
    var periodLength: Int
    var lastPeriodStartDate: Date?
    var hasCompletedOnboarding: Bool

    init(
        cycleLength: Int = 28,
        periodLength: Int = 5,
        lastPeriodStartDate: Date? = nil,
        hasCompletedOnboarding: Bool = false
    ) {
        self.cycleLength = cycleLength
        self.periodLength = periodLength
        self.lastPeriodStartDate = lastPeriodStartDate
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
