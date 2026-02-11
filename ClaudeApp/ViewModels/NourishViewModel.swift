import SwiftUI
import SwiftData

@Observable
final class NourishViewModel {
    var dailyPlan: DailyNutritionPlan?
    var selectedProtocol: NutritionProtocol?
    var wellnessGoal: WellnessGoal?
    var cyclePosition: CycleCalculator.CyclePosition?
    var nutritionLog: NutritionLog?

    let notificationManager = NourishNotificationManager()

    private var modelContext: ModelContext?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext

        notificationManager.onPreferenceChanged = { [weak self] in
            self?.rescheduleNotificationsIfNeeded()
        }

        Task { await notificationManager.checkPermissionStatus() }

        refresh()
    }

    func refresh() {
        guard let profile = fetchProfile() else { return }
        guard let lastPeriodStart = profile.lastPeriodStartDate else { return }

        wellnessGoal = profile.wellnessGoal
        selectedProtocol = profile.nutritionProtocol

        let position = CycleCalculator.currentPosition(
            lastPeriodStart: lastPeriodStart,
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength
        )
        self.cyclePosition = position

        generatePlan(position: position)
        loadOrCreateTodayLog()
        rescheduleNotificationsIfNeeded()
    }

    func selectProtocol(_ nutritionProtocol: NutritionProtocol?) {
        selectedProtocol = nutritionProtocol
        saveProtocol(nutritionProtocol)

        if let position = cyclePosition {
            generatePlan(position: position)
        }
    }

    // MARK: - Check-off Tracking

    func toggleItem(_ item: NutritionItem) {
        guard let nutritionLog else { return }
        nutritionLog.toggleItem(item.id)
        try? modelContext?.save()
        rescheduleNotificationsIfNeeded()
    }

    func isItemCompleted(_ item: NutritionItem) -> Bool {
        nutritionLog?.hasCompleted(item.id) ?? false
    }

    func completedCount(for timeBlock: TimeBlock) -> Int {
        guard let nutritionLog else { return 0 }
        return timeBlock.allItems.filter { nutritionLog.hasCompleted($0.id) }.count
    }

    var totalCompletedCount: Int {
        guard let dailyPlan, let nutritionLog else { return 0 }
        return dailyPlan.timeBlocks
            .flatMap(\.allItems)
            .filter { nutritionLog.hasCompleted($0.id) }
            .count
    }

    // MARK: - Notifications

    private func rescheduleNotificationsIfNeeded() {
        guard let dailyPlan else { return }
        let completedIDs = Set(nutritionLog?.completedItemsRaw ?? [])
        notificationManager.rescheduleNotifications(plan: dailyPlan, completedItemIDs: completedIDs)
    }

    // MARK: - Private

    private func generatePlan(position: CycleCalculator.CyclePosition) {
        guard let selectedProtocol,
              let goal = wellnessGoal else {
            dailyPlan = nil
            return
        }

        dailyPlan = NutritionContent.dailyPlan(
            for: selectedProtocol,
            phase: position.phase,
            goal: goal
        )
    }

    private func loadOrCreateTodayLog() {
        guard let modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<NutritionLog>(
            predicate: #Predicate { $0.date == today }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            nutritionLog = existing
        } else {
            let newLog = NutritionLog(date: today)
            modelContext.insert(newLog)
            try? modelContext.save()
            nutritionLog = newLog
        }
    }

    private func fetchProfile() -> UserProfile? {
        guard let modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return try? modelContext.fetch(descriptor).first
    }

    private func saveProtocol(_ nutritionProtocol: NutritionProtocol?) {
        guard let modelContext,
              let profile = fetchProfile() else { return }
        profile.nutritionProtocol = nutritionProtocol
        try? modelContext.save()
    }
}
