import SwiftUI
import SwiftData

@main
struct ClaudeAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [CycleLog.self, SymptomEntry.self, UserProfile.self])
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding: Bool?

    private var needsOnboarding: Bool {
        guard let profile = profiles.first else { return true }
        return !profile.hasCompletedOnboarding
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
        .onAppear {
            showOnboarding = needsOnboarding
        }
    }
}
