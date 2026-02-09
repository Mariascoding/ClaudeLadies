import SwiftUI
import SwiftData

@Observable
final class NourishViewModel {
    var nutritionGuidance: NutritionGuidance?
    var selectedProtocol: NutritionProtocol?
    var wellnessGoal: WellnessGoal?
    var cyclePosition: CycleCalculator.CyclePosition?

    private var modelContext: ModelContext?

    func load(modelContext: ModelContext) {
        self.modelContext = modelContext
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

        generateGuidance(position: position)
    }

    func selectProtocol(_ nutritionProtocol: NutritionProtocol?) {
        selectedProtocol = nutritionProtocol
        saveProtocol(nutritionProtocol)

        if let position = cyclePosition {
            generateGuidance(position: position)
        }
    }

    private func generateGuidance(position: CycleCalculator.CyclePosition) {
        guard let selectedProtocol,
              let goal = wellnessGoal else {
            nutritionGuidance = nil
            return
        }

        nutritionGuidance = NutritionContent.guidance(
            for: selectedProtocol,
            phase: position.phase,
            goal: goal
        )
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
