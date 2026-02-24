import SwiftUI
import SwiftData

@main
struct ClaudeAppApp: App {
    @State private var authService = AuthenticationService()
    @State private var healthManager = HealthDataManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .environment(healthManager)
                .task { await authService.initialize() }
        }
        .modelContainer(for: [CycleLog.self, SymptomEntry.self, UserProfile.self, NutritionLog.self, HealthMetricLog.self])
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @AppStorage("appColorTheme") private var theme = "classic"
    @AppStorage("appResolvedTheme") private var resolvedTheme = "classic"
    @State private var showOnboarding: Bool?

    private var needsOnboarding: Bool {
        guard let profile = profiles.first else { return true }
        return !profile.hasCompletedOnboarding
    }

    private func updateAutoTheme() {
        guard theme == "auto",
              let profile = profiles.first,
              let lastPeriodStart = profile.lastPeriodStartDate else { return }
        let phase = CycleCalculator.currentPosition(
            lastPeriodStart: lastPeriodStart,
            cycleLength: profile.cycleLength,
            periodLength: profile.periodLength
        ).phase
        resolvedTheme = ColorTheme.forPhase(phase).rawValue
    }

    var body: some View {
        Group {
            if let showOnboarding {
                if showOnboarding {
                    OnboardingView {
                        withAnimation(AppTheme.gentleAnimation) {
                            self.showOnboarding = false
                        }
                    }
                } else {
                    ContentView()
                }
            } else {
                Color.appCream.ignoresSafeArea()
            }
        }
        .id(theme == "auto" ? "auto-\(resolvedTheme)" : theme)
        .onAppear {
            showOnboarding = needsOnboarding
            updateAutoTheme()
        }
        .onChange(of: theme) { _, _ in updateAutoTheme() }
    }
}
