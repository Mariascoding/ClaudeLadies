import SwiftUI
import SwiftData

struct NourishView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = NourishViewModel()
    @State private var showRitualSuggestion = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    protocolSelector

                    if let position = viewModel.cyclePosition,
                       viewModel.selectedProtocol != nil {
                        NourishNotificationCard(
                            notificationManager: viewModel.notificationManager,
                            accentColor: position.phase.accentColor
                        )
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }

                    if let plan = viewModel.dailyPlan,
                       let position = viewModel.cyclePosition {
                        DailyTimelineView(
                            plan: plan,
                            phase: position.phase,
                            viewModel: viewModel
                        )
                    } else if viewModel.selectedProtocol == nil {
                        noProtocolPrompt
                    }

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Nourish")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.load(modelContext: modelContext)
            suggestRitualsIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refresh()
                Task { await viewModel.notificationManager.checkPermissionStatus() }
            }
        }
        .alert("Enable ritual reminders?", isPresented: $showRitualSuggestion) {
            Button("Enable") {
                viewModel.notificationManager.ritualNotificationsEnabled = true
            }
            Button("Not now", role: .cancel) { }
        } message: {
            Text("Rituals like warm lemon water and evening journaling are easy to forget. A gentle nudge can help make them part of your rhythm.")
        }
    }

    // MARK: - Protocol Selector

    private var protocolSelector: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Nutrition Protocol")
                .warmHeadline()

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NutritionProtocol.allCases) { nutritionProtocol in
                    protocolButton(nutritionProtocol)
                }
            }

            if let goal = viewModel.wellnessGoal {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: goal.icon)
                        .font(.caption)
                        .foregroundStyle(goal.color)
                    Text("Goal: \(goal.displayName)")
                        .captionStyle()
                }
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func protocolButton(_ nutritionProtocol: NutritionProtocol) -> some View {
        let isSelected = viewModel.selectedProtocol == nutritionProtocol

        return Button {
            withAnimation(AppTheme.gentleAnimation) {
                if isSelected {
                    viewModel.selectProtocol(nil)
                } else {
                    viewModel.selectProtocol(nutritionProtocol)
                }
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: nutritionProtocol.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : nutritionProtocol.color)

                Text(nutritionProtocol.displayName)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? nutritionProtocol.color : nutritionProtocol.color.opacity(0.08))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
        }
    }

    // MARK: - Ritual Suggestion

    private func suggestRitualsIfNeeded() {
        let manager = viewModel.notificationManager
        guard viewModel.selectedProtocol != nil,
              manager.permissionStatus == .authorized,
              !manager.hasPromptedRituals,
              !manager.ritualNotificationsEnabled else { return }
        manager.hasPromptedRituals = true
        showRitualSuggestion = true
    }

    // MARK: - Empty State

    private var noProtocolPrompt: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appSage.opacity(0.5))

            Text("Choose a Protocol")
                .warmTitle()

            Text("Select a nutrition protocol above to receive daily food, supplement, and timing guidance tailored to your cycle phase.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)

            Text("Your body knows the way.\nLet food be your gentle guide.")
                .affirmationStyle()
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.xxl)
    }
}
