import SwiftUI
import SwiftData

@Observable
final class InsightsViewModel {
    var currentPhase: CyclePhase = .menstrual
    var dayInCycle: Int = 1
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var phaseDescription: PhaseDescription?
    var phaseBoundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)] = []
    var symptomFrequencies: [(symptom: Symptom, count: Int)] = []

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

        phaseDescription = PhaseDescriptions.description(for: currentPhase)
        phaseBoundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )
        loadSymptomPatterns()
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

    private func fetchProfile() -> UserProfile? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }
}
