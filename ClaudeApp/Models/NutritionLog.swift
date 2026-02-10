import Foundation
import SwiftData

@Model
final class NutritionLog {
    var date: Date
    var completedItemsRaw: [String]

    init(date: Date, completedItems: [String] = []) {
        self.date = Calendar.current.startOfDay(for: date)
        self.completedItemsRaw = completedItems
    }

    func hasCompleted(_ itemID: String) -> Bool {
        completedItemsRaw.contains(itemID)
    }

    func toggleItem(_ itemID: String) {
        if hasCompleted(itemID) {
            completedItemsRaw.removeAll { $0 == itemID }
        } else {
            completedItemsRaw.append(itemID)
        }
    }

    var completedCount: Int {
        completedItemsRaw.count
    }
}
