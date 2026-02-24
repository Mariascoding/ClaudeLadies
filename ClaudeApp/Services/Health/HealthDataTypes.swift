import Foundation

// MARK: - Data Source

enum HealthDataSourceType: String, CaseIterable, Identifiable, Codable {
    case appleHealth
    case ouraRing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleHealth: "Apple Health"
        case .ouraRing: "Oura Ring"
        }
    }

    var icon: String {
        switch self {
        case .appleHealth: "heart.fill"
        case .ouraRing: "circle.circle.fill"
        }
    }
}

// MARK: - Metric Types

enum HealthMetricType: String, CaseIterable, Identifiable, Codable {
    case sleep
    case hrv
    case restingHeartRate
    case basalBodyTemperature
    case steps

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sleep: "Sleep"
        case .hrv: "HRV"
        case .restingHeartRate: "Resting HR"
        case .basalBodyTemperature: "Temperature"
        case .steps: "Steps"
        }
    }

    var icon: String {
        switch self {
        case .sleep: "moon.zzz.fill"
        case .hrv: "waveform.path.ecg"
        case .restingHeartRate: "heart.fill"
        case .basalBodyTemperature: "thermometer.medium"
        case .steps: "figure.walk"
        }
    }

    var unit: String {
        switch self {
        case .sleep: "hrs"
        case .hrv: "ms"
        case .restingHeartRate: "bpm"
        case .basalBodyTemperature: "\u{00B0}C"
        case .steps: ""
        }
    }
}

// MARK: - Connection State

enum HealthConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
}

// MARK: - Sleep Summary

struct DailySleepSummary: Sendable {
    var totalDurationHours: Double
    var deepSleepHours: Double?
    var remSleepHours: Double?
    var lightSleepHours: Double?
    var qualityScore: Int?  // 0–100
}

// MARK: - Daily Health Summary

struct DailyHealthSummary: Sendable {
    let date: Date
    let source: HealthDataSourceType
    var sleep: DailySleepSummary?
    var hrvMs: Double?
    var restingHeartRateBpm: Double?
    var basalBodyTemperatureCelsius: Double?
    var steps: Int?
}

// MARK: - Merged Summary (multi-source)

struct MergedDailyHealthSummary {
    let date: Date
    var sleep: DailySleepSummary?
    var hrvMs: Double?
    var restingHeartRateBpm: Double?
    var basalBodyTemperatureCelsius: Double?
    var steps: Int?

    static func merge(_ summaries: [DailyHealthSummary]) -> MergedDailyHealthSummary? {
        guard let first = summaries.first else { return nil }
        var merged = MergedDailyHealthSummary(date: first.date)
        // Priority: Oura > Apple Health (Oura tends to have richer sleep/HRV data)
        let sorted = summaries.sorted { priority(for: $0.source) > priority(for: $1.source) }
        for s in sorted {
            if merged.sleep == nil { merged.sleep = s.sleep }
            if merged.hrvMs == nil { merged.hrvMs = s.hrvMs }
            if merged.restingHeartRateBpm == nil { merged.restingHeartRateBpm = s.restingHeartRateBpm }
            if merged.basalBodyTemperatureCelsius == nil { merged.basalBodyTemperatureCelsius = s.basalBodyTemperatureCelsius }
            if merged.steps == nil { merged.steps = s.steps }
        }
        return merged
    }

    private static func priority(for source: HealthDataSourceType) -> Int {
        switch source {
        case .ouraRing: 2
        case .appleHealth: 1
        }
    }
}
