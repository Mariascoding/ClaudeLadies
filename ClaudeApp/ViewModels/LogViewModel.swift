import SwiftUI
import SwiftData

@Observable
final class LogViewModel {
    var todaySymptoms: Set<Symptom> = []
    var isPeriodActive: Bool = false
    var todayEntry: SymptomEntry?

    private var modelContext: ModelContext?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        loadTodayEntry()
        checkPeriodStatus()
    }

    func toggleSymptom(_ symptom: Symptom) {
        if todaySymptoms.contains(symptom) {
            todaySymptoms.remove(symptom)
        } else {
            todaySymptoms.insert(symptom)
        }
        saveTodaySymptoms()
    }

    func startPeriod(on date: Date = Date()) {
        guard let modelContext else { return }
        let startDate = Calendar.current.startOfDay(for: date)
        let log = CycleLog(startDate: startDate)
        modelContext.insert(log)

        // Update user profile's last period start date
        if let profile = fetchProfile() {
            profile.lastPeriodStartDate = startDate
        }

        isPeriodActive = true
        try? modelContext.save()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    func endPeriod() {
        guard let modelContext else { return }
        if let activeLog = fetchActiveCycleLog() {
            activeLog.endDate = Date()
        }
        isPeriodActive = false
        try? modelContext.save()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    private func loadTodayEntry() {
        if let entry = fetchTodayEntry() {
            todayEntry = entry
            todaySymptoms = Set(entry.symptoms)
        } else {
            todayEntry = nil
            todaySymptoms = []
        }
    }

    private func checkPeriodStatus() {
        isPeriodActive = fetchActiveCycleLog() != nil
    }

    private func saveTodaySymptoms() {
        guard let modelContext else { return }
        if let entry = todayEntry {
            entry.symptoms = Array(todaySymptoms)
        } else {
            let entry = SymptomEntry(date: Date(), symptoms: Array(todaySymptoms))
            modelContext.insert(entry)
            todayEntry = entry
        }
        try? modelContext.save()
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
}
