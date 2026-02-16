import SwiftUI
import SwiftData

extension Notification.Name {
    static let cycleDataDidChange = Notification.Name("cycleDataDidChange")
}

@Observable
final class InsightsViewModel {
    var currentPhase: CyclePhase = .menstrual
    var dayInCycle: Int = 1
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var phaseDescription: PhaseDescription?
    var phaseBoundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)] = []
    var symptomFrequencies: [(symptom: Symptom, count: Int)] = []
    var patternAnalysis: PatternAnalysis?
    var cycleLogs: [CycleLog] = []
    var expectedNextPeriodStart: Date? = nil
    var delayDays: Int = 0
    var lastPeriodStartDate: Date? = nil
    var manualOvulationDates: Set<Date> = []

    private var modelContext: ModelContext?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        guard let profile = fetchProfile() else { return }

        cycleLength = profile.cycleLength
        periodLength = profile.periodLength

        if let lastPeriodStart = profile.lastPeriodStartDate {
            let position = CycleCalculator.currentPosition(
                lastPeriodStart: lastPeriodStart,
                cycleLength: profile.cycleLength,
                periodLength: profile.periodLength
            )
            currentPhase = position.phase
            dayInCycle = position.dayInCycle
        }

        lastPeriodStartDate = profile.lastPeriodStartDate

        phaseDescription = PhaseDescriptions.description(for: currentPhase)
        phaseBoundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )
        loadCycleLogs()
        calculateExpectedNextPeriod()
        loadSymptomPatterns()
        loadPatternAnalysis()
    }

    private func loadSymptomPatterns() {
        guard let modelContext else { return }

        // Look back 90 days for symptom patterns
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        let descriptor = FetchDescriptor<SymptomEntry>(
            predicate: #Predicate { $0.date >= cutoff }
        )

        guard let entries = try? modelContext.fetch(descriptor) else { return }

        var counts: [Symptom: Int] = [:]
        for entry in entries {
            for symptom in entry.symptoms {
                counts[symptom, default: 0] += 1
            }
        }

        symptomFrequencies = counts
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { (symptom: $0.key, count: $0.value) }
    }

    private func loadPatternAnalysis() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<SymptomEntry>()
        guard let allEntries = try? modelContext.fetch(descriptor) else { return }

        let entries = allEntries.filter { !$0.symptomsRaw.isEmpty }
        guard !entries.isEmpty else {
            patternAnalysis = nil
            return
        }

        guard let profile = fetchProfile(),
              let lastPeriodStart = profile.lastPeriodStartDate else {
            patternAnalysis = nil
            return
        }

        patternAnalysis = PatternAnalysisEngine.analyze(
            entries: entries,
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength,
            lastPeriodStartDate: lastPeriodStart
        )
    }

    func addPeriod(on date: Date) {
        guard let modelContext else { return }
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: periodLength - 1, to: startDate)!

        let log = CycleLog(startDate: startDate, endDate: endDate)
        modelContext.insert(log)

        // Update profile if this is the most recent period
        if let profile = fetchProfile() {
            if let existing = profile.lastPeriodStartDate {
                if startDate > existing {
                    profile.lastPeriodStartDate = startDate
                }
            } else {
                profile.lastPeriodStartDate = startDate
            }
        }

        try? modelContext.save()
        refresh()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    /// Extends the nearest period whose end is within 7 days before the given date
    func extendPeriod(to date: Date) {
        guard let modelContext else { return }
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)

        guard let log = nearestExtendableLog(for: targetDay) else { return }
        log.endDate = targetDay

        try? modelContext.save()
        refresh()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    /// Finds a CycleLog whose endDate is within 7 days before the given date
    func nearestExtendableLog(for date: Date) -> CycleLog? {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        return cycleLogs.first { log in
            guard let endDate = log.endDate else { return false }
            let logEnd = calendar.startOfDay(for: endDate)
            // The tapped day must be after the period end and within 7 days
            let daysDiff = calendar.dateComponents([.day], from: logEnd, to: day).day ?? 0
            return daysDiff >= 1 && daysDiff <= 7
        }
    }

    /// Removes the CycleLog that contains the given date
    func removePeriod(containing date: Date) {
        guard let modelContext else { return }
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        guard let log = logContaining(date: day) else { return }
        modelContext.delete(log)

        // If this was the lastPeriodStartDate, revert to the previous one
        if let profile = fetchProfile() {
            let logStart = calendar.startOfDay(for: log.startDate)
            if let profileStart = profile.lastPeriodStartDate,
               calendar.startOfDay(for: profileStart) == logStart {
                // Find the most recent remaining log
                let remaining = cycleLogs.filter { $0 !== log }
                profile.lastPeriodStartDate = remaining.last.map { calendar.startOfDay(for: $0.startDate) }
            }
        }

        try? modelContext.save()
        refresh()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    /// Finds the CycleLog that contains the given date
    func logContaining(date: Date) -> CycleLog? {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        return cycleLogs.first { log in
            let logStart = calendar.startOfDay(for: log.startDate)
            if let endDate = log.endDate {
                let logEnd = calendar.startOfDay(for: endDate)
                return day >= logStart && day <= logEnd
            } else {
                let today = calendar.startOfDay(for: Date())
                return day >= logStart && day <= today
            }
        }
    }

    func addOvulation(on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        manualOvulationDates.insert(day)
    }

    func removeOvulation(on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        manualOvulationDates.remove(day)
    }

    func isManualOvulation(_ date: Date) -> Bool {
        manualOvulationDates.contains(Calendar.current.startOfDay(for: date))
    }

    private func loadCycleLogs() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CycleLog>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        cycleLogs = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func calculateExpectedNextPeriod() {
        let calendar = Calendar.current
        guard let lastStart = lastPeriodStartDate else {
            expectedNextPeriodStart = nil
            delayDays = 0
            return
        }

        let expected = calendar.date(byAdding: .day, value: cycleLength, to: calendar.startOfDay(for: lastStart))!
        expectedNextPeriodStart = expected

        // If there's an active period (endDate == nil), no delay
        if cycleLogs.contains(where: { $0.isActive }) {
            delayDays = 0
            return
        }

        // If a CycleLog starts on or after the expected date, no delay
        let expectedDay = calendar.startOfDay(for: expected)
        if cycleLogs.contains(where: { calendar.startOfDay(for: $0.startDate) >= expectedDay }) {
            delayDays = 0
            return
        }

        // If today is past expected and no next period logged, compute delay
        let today = calendar.startOfDay(for: Date())
        if today > expectedDay {
            delayDays = calendar.dateComponents([.day], from: expectedDay, to: today).day ?? 0
        } else {
            delayDays = 0
        }
    }

    private func fetchProfile() -> UserProfile? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }
}
