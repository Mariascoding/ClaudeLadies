import Foundation
import SwiftData

@Model
final class UserProfile {
    var cycleLength: Int
    var periodLength: Int
    var lastPeriodStartDate: Date?
    var hasCompletedOnboarding: Bool
    var wellnessGoalRaw: String?
    var nutritionProtocolRaw: String?
    var pregnancyStartDate: Date?
    var menopauseLastBleedDate: Date?
    var dietaryPreferenceRaw: String?

    var dietaryPreference: DietaryPreference {
        get { dietaryPreferenceRaw.flatMap { DietaryPreference(rawValue: $0) } ?? .omnivore }
        set { dietaryPreferenceRaw = newValue.rawValue }
    }

    var wellnessGoal: WellnessGoal? {
        get { wellnessGoalRaw.flatMap { WellnessGoal(rawValue: $0) } }
        set { wellnessGoalRaw = newValue?.rawValue }
    }

    var nutritionProtocol: NutritionProtocol? {
        get { nutritionProtocolRaw.flatMap { NutritionProtocol(rawValue: $0) } }
        set { nutritionProtocolRaw = newValue?.rawValue }
    }

    init(
        cycleLength: Int = 28,
        periodLength: Int = 5,
        lastPeriodStartDate: Date? = nil,
        hasCompletedOnboarding: Bool = false,
        wellnessGoal: WellnessGoal? = nil,
        nutritionProtocol: NutritionProtocol? = nil
    ) {
        self.cycleLength = cycleLength
        self.periodLength = periodLength
        self.lastPeriodStartDate = lastPeriodStartDate
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.wellnessGoalRaw = wellnessGoal?.rawValue
        self.nutritionProtocolRaw = nutritionProtocol?.rawValue
    }
}
