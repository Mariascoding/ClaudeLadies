import SwiftUI
import SwiftData

@Observable
final class TodayViewModel {
    var guidance: DailyGuidance?
    var selectedNervousSystemState: NervousSystemState?
    var cyclePosition: CycleCalculator.CyclePosition?
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var delayDays: Int = 0
    var isPeriodActive: Bool = false
    var phaseBoundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)] = []

    private var modelContext: ModelContext?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        guard let profile = fetchProfile() else { return }
        guard let lastPeriodStart = profile.lastPeriodStartDate else { return }

        let position = CycleCalculator.currentPosition(
            lastPeriodStart: lastPeriodStart,
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength
        )
        self.cyclePosition = position
        self.cycleLength = profile.cycleLength
        self.periodLength = profile.periodLength
        self.phaseBoundaries = CycleCalculator.phaseBoundaries(
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength
        )

        // Check period status and calculate delay
        isPeriodActive = fetchActiveCycleLog() != nil
        calculateDelayDays(lastPeriodStart: lastPeriodStart, cycleLength: profile.cycleLength)

        // Load today's nervous system state from symptom entry
        if let todayEntry = fetchTodayEntry() {
            selectedNervousSystemState = todayEntry.nervousSystemState
        }

        generateGuidance(position: position)
    }

    func selectNervousSystemState(_ state: NervousSystemState) {
        selectedNervousSystemState = state
        saveTodayNervousSystemState(state)

        if let position = cyclePosition {
            generateGuidance(position: position)
        }
    }

    private func generateGuidance(position: CycleCalculator.CyclePosition) {
        guidance = GuidanceEngine.guidance(
            phase: position.phase,
            dayInCycle: position.dayInCycle,
            dayInPhase: position.dayInPhase,
            nervousSystemState: selectedNervousSystemState
        )
    }

    private func calculateDelayDays(lastPeriodStart: Date, cycleLength: Int) {
        let calendar = Calendar.current
        let expected = calendar.date(byAdding: .day, value: cycleLength, to: calendar.startOfDay(for: lastPeriodStart))!
        let today = calendar.startOfDay(for: Date())

        if isPeriodActive {
            delayDays = 0
            return
        }

        // Check if a new cycle log exists on/after expected date
        if let modelContext {
            let descriptor = FetchDescriptor<CycleLog>(
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            if let logs = try? modelContext.fetch(descriptor) {
                let expectedDay = calendar.startOfDay(for: expected)
                if logs.contains(where: { calendar.startOfDay(for: $0.startDate) >= expectedDay }) {
                    delayDays = 0
                    return
                }
            }
        }

        if today > expected {
            delayDays = calendar.dateComponents([.day], from: expected, to: today).day ?? 0
        } else {
            delayDays = 0
        }
    }

    private func fetchActiveCycleLog() -> CycleLog? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<CycleLog>(
            predicate: #Predicate<CycleLog> { $0.endDate == nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchProfile() -> UserProfile? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchTodayEntry() -> SymptomEntry? {
        guard let modelContext else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<SymptomEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func saveTodayNervousSystemState(_ state: NervousSystemState) {
        guard let modelContext else { return }
        if let entry = fetchTodayEntry() {
            entry.nervousSystemState = state
        } else {
            let entry = SymptomEntry(date: Date(), nervousSystemState: state)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }
}
