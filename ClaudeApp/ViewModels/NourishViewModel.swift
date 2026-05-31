import SwiftUI
import SwiftData

@Observable
final class NourishViewModel {
    var dailyPlan: DailyNutritionPlan?
    var cyclePlan: DailyNutritionPlan?
    var selectedProtocol: NutritionProtocol?
    var wellnessGoal: WellnessGoal?
    var cyclePosition: CycleCalculator.CyclePosition?
    var nutritionLog: NutritionLog?
    var selectedSymptoms: [Symptom] = []
    var symptomWisdomCards: [SymptomWisdom] = []
    var goalWisdomCards: [GoalWisdomCard] = []
    var personalItems: [PersonalItem] = []
    var dismissedItemIDs: Set<String> = []
    var dietaryPreference: DietaryPreference = .omnivore
    var delayDays: Int = 0

    let notificationManager = NourishNotificationManager()

    private var modelContext: ModelContext?
    private var lastLoadedDate: Date?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext

        notificationManager.onPreferenceChanged = { [weak self] in
            self?.rescheduleNotificationsIfNeeded()
        }

        Task { await notificationManager.checkPermissionStatus() }

        refresh()
    }

    /// Call from the view to check if a new day started (e.g. midnight rollover)
    func refreshIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if lastLoadedDate != today {
            refresh()
        }
    }

    func refresh() {
        lastLoadedDate = Calendar.current.startOfDay(for: Date())
        guard let profile = fetchProfile() else { return }
        guard let lastPeriodStart = profile.lastPeriodStartDate else { return }

        wellnessGoal = profile.wellnessGoal
        selectedProtocol = profile.nutritionProtocol ?? .daoSt
        dietaryPreference = profile.dietaryPreference

        let position = CycleCalculator.currentPosition(
            lastPeriodStart: lastPeriodStart,
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength
        )
        self.cyclePosition = position
        calculateDelayDays(lastPeriodStart: lastPeriodStart, cycleLength: profile.cycleLength)

        loadPersonalItems()
        loadDismissedItems()
        loadTodaySymptomsFromLog()
        generatePlan(position: position)
        generateCyclePlan(position: position)
        generateGoalWisdom(position: position)
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
        let wasCompleted = nutritionLog.hasCompleted(item.id)
        nutritionLog.toggleItem(item.id)
        try? modelContext?.save()
        rescheduleNotificationsIfNeeded()
        // Each fresh check-off awards a drop of shinedust toward the
        // flower's growth. Un-checking does not remove prior drops.
        if !wasCompleted, let ctx = modelContext {
            Shinedust.award(.nutritionItem, in: ctx)
        }
    }

    func isItemCompleted(_ item: NutritionItem) -> Bool {
        nutritionLog?.hasCompleted(item.id) ?? false
    }

    func completedCount(for timeBlock: TimeBlock) -> Int {
        guard let nutritionLog else { return 0 }
        return timeBlock.allItems.filter { nutritionLog.hasCompleted($0.id) }.count
    }

    var activePlan: DailyNutritionPlan? {
        dailyPlan ?? cyclePlan
    }

    var totalCompletedCount: Int {
        guard let plan = activePlan, let nutritionLog else { return 0 }
        let merged = mergedPlan(plan)
        return merged.timeBlocks
            .flatMap(\.allItems)
            .filter { nutritionLog.hasCompleted($0.id) }
            .count
    }

    // MARK: - Notifications

    private func rescheduleNotificationsIfNeeded() {
        guard let plan = activePlan else { return }
        let completedIDs = Set(nutritionLog?.completedItemsRaw ?? [])
        notificationManager.rescheduleNotifications(plan: plan, completedItemIDs: completedIDs)
    }

    // MARK: - Symptom Wisdom & Daily Log

    func toggleSymptom(_ symptom: Symptom) {
        if let index = selectedSymptoms.firstIndex(of: symptom) {
            selectedSymptoms.remove(at: index)
            // If we un-toggled the last tapped, clear the wisdom card
            if lastTappedSymptom == symptom {
                lastTappedSymptom = nil
            }
        } else {
            selectedSymptoms.append(symptom)
            lastTappedSymptom = symptom
        }
        saveSymptomsToLog()
        updateWisdomCards()
    }

    func isSymptomSelected(_ symptom: Symptom) -> Bool {
        selectedSymptoms.contains(symptom)
    }

    private var lastTappedSymptom: Symptom?

    private func updateWisdomCards() {
        guard let tapped = lastTappedSymptom else {
            symptomWisdomCards = []
            return
        }
        let phase = cyclePosition?.phase ?? .follicular
        symptomWisdomCards = [PeriodSymptomWisdom.wisdom(for: tapped, phase: phase)]
    }

    private func saveSymptomsToLog() {
        guard let modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<SymptomEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )

        let entry: SymptomEntry
        if let existing = try? modelContext.fetch(descriptor).first {
            entry = existing
        } else {
            entry = SymptomEntry(date: Date())
            modelContext.insert(entry)
        }
        entry.symptoms = selectedSymptoms
        try? modelContext.save()
        NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
    }

    private func loadTodaySymptomsFromLog() {
        guard let modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<SymptomEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        if let entry = try? modelContext.fetch(descriptor).first {
            selectedSymptoms = entry.symptoms
        }
    }

    // MARK: - Private

    // MARK: - Personal Items & Dismissed Protocol Items

    private func loadPersonalItems() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<PersonalItem>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.name)]
        )
        personalItems = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadDismissedItems() {
        guard let modelContext else { return }
        let currentProtoRaw = selectedProtocol?.rawValue
        let descriptor = FetchDescriptor<DismissedProtocolItem>(
            predicate: #Predicate { $0.protocolRaw == currentProtoRaw || $0.protocolRaw == nil }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        dismissedItemIDs = Set(items.map(\.itemID))
    }

    func dismissProtocolItem(_ item: NutritionItem) {
        guard let modelContext else { return }
        let dismissed = DismissedProtocolItem(itemID: item.id, nutritionProtocol: selectedProtocol)
        modelContext.insert(dismissed)
        try? modelContext.save()
        dismissedItemIDs.insert(item.id)
    }

    func restoreDismissedItems() {
        guard let modelContext else { return }
        let currentProtoRaw = selectedProtocol?.rawValue
        let descriptor = FetchDescriptor<DismissedProtocolItem>(
            predicate: #Predicate { $0.protocolRaw == currentProtoRaw || $0.protocolRaw == nil }
        )
        if let items = try? modelContext.fetch(descriptor) {
            for item in items { modelContext.delete(item) }
            try? modelContext.save()
        }
        dismissedItemIDs.removeAll()
    }

    func isItemDismissed(_ item: NutritionItem) -> Bool {
        dismissedItemIDs.contains(item.id)
    }

    /// Merges personal items into a protocol plan, deduplicates, and removes dismissed items
    func mergedPlan(_ plan: DailyNutritionPlan) -> DailyNutritionPlan {
        let filtered = DietaryFilter.apply(plan, preference: dietaryPreference)
        return DailyNutritionPlan(
            todayFocus: filtered.todayFocus,
            morning: mergedTimeBlock(filtered.morning, time: .morning),
            afternoon: mergedTimeBlock(filtered.afternoon, time: .afternoon),
            evening: mergedTimeBlock(filtered.evening, time: .evening),
            avoid: filtered.avoid,
            rationale: filtered.rationale
        )
    }

    private func mergedTimeBlock(_ block: TimeBlock, time: TimeOfDay) -> TimeBlock {
        let myItems = personalItems
            .filter { $0.timeOfDay == time }
            .map { item in
                NutritionItem(name: item.name, category: item.category, timeBlock: time, origin: .personal)
            }

        let personalNames = Set(myItems.map { $0.name.lowercased() })

        func filtered(_ items: [NutritionItem], category: NutritionItemCategory) -> [NutritionItem] {
            let personal = myItems.filter { $0.category == category }
            let protocol_ = items.filter { item in
                !dismissedItemIDs.contains(item.id) &&
                !personalNames.contains(item.name.lowercased())
            }
            return personal + protocol_
        }

        return TimeBlock(
            timeOfDay: time,
            foods: filtered(block.foods, category: .food),
            supplements: filtered(block.supplements, category: .supplement),
            rituals: filtered(block.rituals, category: .ritual)
        )
    }

    private func generateGoalWisdom(position: CycleCalculator.CyclePosition) {
        let goal = wellnessGoal ?? .healthyCycle
        goalWisdomCards = GoalWisdomContent.cards(
            for: goal,
            phase: position.phase,
            dayInPhase: position.dayInPhase
        )
    }

    private func calculateDelayDays(lastPeriodStart: Date, cycleLength: Int) {
        let calendar = Calendar.current
        let expected = calendar.date(byAdding: .day, value: cycleLength, to: calendar.startOfDay(for: lastPeriodStart))!
        let today = calendar.startOfDay(for: Date())

        if let modelContext {
            // Check for active period
            let activeDescriptor = FetchDescriptor<CycleLog>(
                predicate: #Predicate<CycleLog> { $0.endDate == nil },
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            if (try? modelContext.fetch(activeDescriptor).first) != nil {
                delayDays = 0
                return
            }

            // Check if a new cycle started on/after expected date
            let allDescriptor = FetchDescriptor<CycleLog>(
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            if let logs = try? modelContext.fetch(allDescriptor) {
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

    /// Late period guidance appended to today's focus when period is overdue
    var latePeriodFocusNote: String? {
        guard delayDays > 0 else { return nil }

        let daysText = "Your period is \(delayDays) day\(delayDays == 1 ? "" : "s") late."

        if delayDays <= 3 {
            return "\(daysText) A day or two of variation is normal — your cycle responds to sleep, stress, and seasonal shifts. Continue warming foods and gentle movement."
        } else if delayDays <= 7 {
            return "\(daysText) Your body likely delayed ovulation this cycle, which pushes the period back. Focus on warmth, rest, and eating enough. Reduce intense exercise and caffeine — both raise cortisol which delays the bleed. A warm compress on your lower belly and raspberry leaf tea can help invite flow."
        } else {
            return "\(daysText) When ovulation is delayed or skipped, the period follows later. Common causes: undereating, stress, intense exercise, travel, or illness. Your body is protecting itself. To support the return of your bleed: eat warm nourishing meals regularly, prioritise sleep, reduce caffeine, take warm baths, and try raspberry leaf tea. If pregnancy is possible, consider testing."
        }
    }

    private func generateCyclePlan(position: CycleCalculator.CyclePosition) {
        let goal = wellnessGoal ?? .healthyCycle
        cyclePlan = CycleNourishContent.dailyPlan(
            phase: position.phase,
            dayInPhase: position.dayInPhase,
            goal: goal
        )
    }

    private func generatePlan(position: CycleCalculator.CyclePosition) {
        guard let selectedProtocol,
              selectedProtocol != .daoSt,
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
