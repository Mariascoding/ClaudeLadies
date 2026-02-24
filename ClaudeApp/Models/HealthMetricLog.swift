import Foundation
import SwiftData

@Model
final class HealthMetricLog {
    var date: Date
    var sleepDurationHours: Double?
    var deepSleepHours: Double?
    var remSleepHours: Double?
    var lightSleepHours: Double?
    var sleepQualityScore: Double?
    var hrvMs: Double?
    var restingHeartRateBpm: Double?
    var basalBodyTemperatureCelsius: Double?
    var steps: Int?

    init(date: Date) {
        self.date = date
    }
}
