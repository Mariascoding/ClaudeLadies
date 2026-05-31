import Foundation
import SwiftData

/// A supplement, food, or ritual the user currently takes or does — their personal baseline.
@Model
final class PersonalItem {
    var name: String
    var categoryRaw: String
    var timeOfDayRaw: String
    var isActive: Bool

    var category: NutritionItemCategory {
        get { NutritionItemCategory(rawValue: categoryRaw) ?? .supplement }
        set { categoryRaw = newValue.rawValue }
    }

    var timeOfDay: TimeOfDay {
        get { TimeOfDay(rawValue: timeOfDayRaw) ?? .morning }
        set { timeOfDayRaw = newValue.rawValue }
    }

    init(
        name: String,
        category: NutritionItemCategory,
        timeOfDay: TimeOfDay,
        isActive: Bool = true
    ) {
        self.name = name
        self.categoryRaw = category.rawValue
        self.timeOfDayRaw = timeOfDay.rawValue
        self.isActive = isActive
    }

    /// Convert to a NutritionItem for display in time blocks
    var asNutritionItem: NutritionItem {
        NutritionItem(name: name, category: category, timeBlock: timeOfDay)
    }
}

/// Tracks protocol-suggested items the user has opted out of.
@Model
final class DismissedProtocolItem {
    var itemID: String
    var protocolRaw: String?

    var nutritionProtocol: NutritionProtocol? {
        get { protocolRaw.flatMap { NutritionProtocol(rawValue: $0) } }
        set { protocolRaw = newValue?.rawValue }
    }

    init(itemID: String, nutritionProtocol: NutritionProtocol?) {
        self.itemID = itemID
        self.protocolRaw = nutritionProtocol?.rawValue
    }
}
