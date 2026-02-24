import Foundation
import SwiftData

@Observable
final class HealthDataManager: @unchecked Sendable {
    private(set) var providers: [HealthDataSourceType: any HealthDataProvider] = [:]
    private(set) var todaySummary: MergedDailyHealthSummary?
    private(set) var isLoading = false

    var enabledSources: Set<HealthDataSourceType> {
        get {
            let raw = UserDefaults.standard.stringArray(forKey: "health_enabled_sources") ?? []
            return Set(raw.compactMap { HealthDataSourceType(rawValue: $0) })
        }
        set {
            UserDefaults.standard.set(newValue.map(\.rawValue), forKey: "health_enabled_sources")
        }
    }

    init() {
        // Register all available providers
        providers[.appleHealth] = AppleHealthProvider()
        providers[.ouraRing] = OuraProvider()
    }

    // MARK: - Connection Management

    func connectionState(for source: HealthDataSourceType) -> HealthConnectionState {
        providers[source]?.connectionState ?? .disconnected
    }

    func connect(source: HealthDataSourceType) async throws {
        guard let provider = providers[source] else { return }
        try await provider.connect()
        enabledSources.insert(source)
    }

    func disconnect(source: HealthDataSourceType) {
        providers[source]?.disconnect()
        enabledSources.remove(source)
    }

    // MARK: - Fetch Today

    func fetchTodayData() async {
        isLoading = true
        defer { isLoading = false }

        let today = Calendar.current.startOfDay(for: Date())
        var daySummaries: [DailyHealthSummary] = []

        for source in enabledSources {
            guard let provider = providers[source], provider.isAuthorized else { continue }
            do {
                if let summary = try await provider.fetchDailySummary(for: today) {
                    daySummaries.append(summary)
                }
            } catch {
                // Silently skip failed providers for today's data
            }
        }

        todaySummary = MergedDailyHealthSummary.merge(daySummaries)
    }

    // MARK: - Fetch Historical

    func fetchHistoricalData(days: Int) async -> [MergedDailyHealthSummary] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: today) else { return [] }

        // Collect all summaries from all enabled providers
        var allSummaries: [Date: [DailyHealthSummary]] = [:]

        for source in enabledSources {
            guard let provider = providers[source], provider.isAuthorized else { continue }
            do {
                let summaries = try await provider.fetchDailySummaries(from: startDate, to: today)
                for summary in summaries {
                    let day = calendar.startOfDay(for: summary.date)
                    allSummaries[day, default: []].append(summary)
                }
            } catch {
                // Skip failed providers
            }
        }

        // Merge per-day
        return allSummaries
            .sorted { $0.key < $1.key }
            .compactMap { MergedDailyHealthSummary.merge($0.value) }
    }

    // MARK: - Sync & Persist

    func syncAndPersist(modelContext: ModelContext) async {
        let historicalData = await fetchHistoricalData(days: 90)
        let calendar = Calendar.current

        for summary in historicalData {
            let day = calendar.startOfDay(for: summary.date)

            // Check if we already have a log for this day
            let descriptor = FetchDescriptor<HealthMetricLog>(
                predicate: #Predicate { $0.date == day }
            )
            let existing = (try? modelContext.fetch(descriptor))?.first

            if let log = existing {
                // Update existing
                updateLog(log, from: summary)
            } else {
                // Create new
                let log = HealthMetricLog(date: day)
                updateLog(log, from: summary)
                modelContext.insert(log)
            }
        }

        try? modelContext.save()
    }

    private func updateLog(_ log: HealthMetricLog, from summary: MergedDailyHealthSummary) {
        if let sleep = summary.sleep {
            log.sleepDurationHours = sleep.totalDurationHours
            log.deepSleepHours = sleep.deepSleepHours
            log.remSleepHours = sleep.remSleepHours
            log.lightSleepHours = sleep.lightSleepHours
            log.sleepQualityScore = sleep.qualityScore.map { Double($0) }
        }
        if let hrv = summary.hrvMs { log.hrvMs = hrv }
        if let rhr = summary.restingHeartRateBpm { log.restingHeartRateBpm = rhr }
        if let temp = summary.basalBodyTemperatureCelsius { log.basalBodyTemperatureCelsius = temp }
        if let steps = summary.steps { log.steps = steps }
    }

    // MARK: - Convenience

    var hasAnyConnectedSource: Bool {
        enabledSources.contains { providers[$0]?.isAuthorized == true }
    }

    var hasData: Bool {
        todaySummary != nil
    }
}
