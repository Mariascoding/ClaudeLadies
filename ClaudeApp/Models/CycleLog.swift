import Foundation
import SwiftData

@Model
final class CycleLog {
    var startDate: Date
    var endDate: Date?
    var cycleLength: Int?

    @Relationship(deleteRule: .cascade, inverse: \SymptomEntry.cycleLog)
    var symptomEntries: [SymptomEntry] = []

    init(startDate: Date, endDate: Date? = nil, cycleLength: Int? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.cycleLength = cycleLength
    }

    var periodLength: Int? {
        guard let endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day.map { $0 + 1 }
    }

    var isActive: Bool {
        endDate == nil
    }
}
