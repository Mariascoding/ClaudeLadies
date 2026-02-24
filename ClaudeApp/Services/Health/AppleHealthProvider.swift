import Foundation
import HealthKit

@Observable
final class AppleHealthProvider: @unchecked Sendable, HealthDataProvider {
    let sourceType: HealthDataSourceType = .appleHealth
    private(set) var connectionState: HealthConnectionState = .disconnected
    private(set) var isAuthorized = false

    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current

    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleep) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.insert(hrv) }
        if let rhr = HKObjectType.quantityType(forIdentifier: .restingHeartRate) { types.insert(rhr) }
        if let temp = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) { types.insert(temp) }
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        return types
    }

    // MARK: - Connection

    func connect() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            connectionState = .error("HealthKit not available on this device")
            return
        }

        connectionState = .connecting

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            connectionState = .connected
        } catch {
            connectionState = .error(error.localizedDescription)
            throw error
        }
    }

    func disconnect() {
        isAuthorized = false
        connectionState = .disconnected
    }

    // MARK: - Fetch

    func fetchDailySummary(for date: Date) async throws -> DailyHealthSummary? {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return nil }

        async let sleepResult = fetchSleep(from: dayStart, to: dayEnd)
        async let hrvResult = fetchStatistic(type: .heartRateVariabilitySDNN, unit: HKUnit.secondUnit(with: .milli), from: dayStart, to: dayEnd)
        async let rhrResult = fetchStatistic(type: .restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()), from: dayStart, to: dayEnd)
        async let tempResult = fetchStatistic(type: .basalBodyTemperature, unit: HKUnit.degreeCelsius(), from: dayStart, to: dayEnd)
        async let stepsResult = fetchCumulativeStatistic(type: .stepCount, unit: HKUnit.count(), from: dayStart, to: dayEnd)

        let sleep = try await sleepResult
        let hrv = try await hrvResult
        let rhr = try await rhrResult
        let temp = try await tempResult
        let steps = try await stepsResult

        // If nothing was returned, skip this day
        guard sleep != nil || hrv != nil || rhr != nil || temp != nil || steps != nil else {
            return nil
        }

        return DailyHealthSummary(
            date: dayStart,
            source: .appleHealth,
            sleep: sleep,
            hrvMs: hrv,
            restingHeartRateBpm: rhr,
            basalBodyTemperatureCelsius: temp,
            steps: steps.map { Int($0) }
        )
    }

    func fetchDailySummaries(from startDate: Date, to endDate: Date) async throws -> [DailyHealthSummary] {
        var summaries: [DailyHealthSummary] = []
        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while current <= end {
            if let summary = try await fetchDailySummary(for: current) {
                summaries.append(summary)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return summaries
    }

    // MARK: - Sleep

    private func fetchSleep(from start: Date, to end: Date) async throws -> DailySleepSummary? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )

        let samples = try await descriptor.result(for: healthStore)
        guard !samples.isEmpty else { return nil }

        var totalSeconds: TimeInterval = 0
        var deepSeconds: TimeInterval = 0
        var remSeconds: TimeInterval = 0
        var lightSeconds: TimeInterval = 0

        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)

            switch value {
            case .asleepDeep:
                deepSeconds += duration
                totalSeconds += duration
            case .asleepREM:
                remSeconds += duration
                totalSeconds += duration
            case .asleepCore:
                lightSeconds += duration
                totalSeconds += duration
            case .asleepUnspecified:
                totalSeconds += duration
            default:
                break // inBed, awake, etc.
            }
        }

        guard totalSeconds > 0 else { return nil }

        return DailySleepSummary(
            totalDurationHours: totalSeconds / 3600.0,
            deepSleepHours: deepSeconds > 0 ? deepSeconds / 3600.0 : nil,
            remSleepHours: remSeconds > 0 ? remSeconds / 3600.0 : nil,
            lightSleepHours: lightSeconds > 0 ? lightSeconds / 3600.0 : nil,
            qualityScore: nil
        )
    }

    // MARK: - Statistics (average)

    private func fetchStatistic(
        type identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from start: Date,
        to end: Date
    ) async throws -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = result?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Statistics (cumulative sum)

    private func fetchCumulativeStatistic(
        type identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from start: Date,
        to end: Date
    ) async throws -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = result?.sumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}
