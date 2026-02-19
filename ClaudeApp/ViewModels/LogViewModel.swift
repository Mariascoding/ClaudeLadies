import SwiftUI
import SwiftData

@Observable
final class LogViewModel {
    var todaySymptoms: Set<Symptom> = []
    var todayTags: [String] = []
    var allKnownTags: [String] = []
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
        loadAllKnownTags()
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
            todayTags = entry.customTags
        } else {
            todayEntry = nil
            todaySymptoms = []
            todayTags = []
        }
    }

    private func checkPeriodStatus() {
        isPeriodActive = fetchActiveCycleLog() != nil
    }

    func addTag(_ tag: String) {
        let normalized = tag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty, !todayTags.contains(normalized) else { return }
        todayTags.append(normalized)
        saveTodayTags()
        if !allKnownTags.contains(normalized) {
            allKnownTags.append(normalized)
            allKnownTags.sort()
        }
    }

    func removeTag(_ tag: String) {
        let normalized = tag.trimmingCharacters(in: .whitespaces).lowercased()
        todayTags.removeAll { $0 == normalized }
        saveTodayTags()
    }

    private func saveTodayTags() {
        guard let modelContext else { return }
        if let entry = todayEntry {
            entry.customTags = todayTags
        } else {
            let entry = SymptomEntry(date: Date())
            entry.customTags = todayTags
            modelContext.insert(entry)
            todayEntry = entry
        }
        try? modelContext.save()
    }

    private func loadAllKnownTags() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SymptomEntry>()
        guard let entries = try? modelContext.fetch(descriptor) else { return }
        var tagSet = Set<String>()
        for entry in entries {
            for tag in entry.customTags {
                tagSet.insert(tag)
            }
        }
        allKnownTags = tagSet.sorted()
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
