import SwiftUI
import SwiftData

struct NourishView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = NourishViewModel()
    @State private var showRitualSuggestion = false
    @State private var showHairHealthInfo = false

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

                    if let position = viewModel.cyclePosition,
                       viewModel.selectedProtocol == .daoSt {
                        cycleNourishSection(position: position)
                    } else if let plan = viewModel.dailyPlan,
                              let position = viewModel.cyclePosition {
                        DailyTimelineView(
                            plan: plan,
                            phase: position.phase,
                            viewModel: viewModel
                        )
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
        .sheet(isPresented: $showHairHealthInfo) {
            HairHealthInfoSheet()
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

            if let selected = viewModel.selectedProtocol {
                Text(selected.focusDescription)
                    .font(.system(.caption, design: AppTheme.fontFamilySerif))
                    .foregroundStyle(selected.color.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                    viewModel.selectProtocol(.daoSt)
                } else {
                    viewModel.selectProtocol(nutritionProtocol)
                }
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: nutritionProtocol.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : nutritionProtocol.color)

                Text(nutritionProtocol.displayName)
                    .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? nutritionProtocol.color : nutritionProtocol.color.opacity(0.08))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
            .overlay(alignment: .topTrailing) {
                if nutritionProtocol == .hairHealth {
                    Button {
                        showHairHealthInfo = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(isSelected ? .white.opacity(0.8) : nutritionProtocol.color.opacity(0.6))
                    }
                    .padding(4)
                }
            }
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

    // MARK: - Cycle Nourish (No Protocol)

    private func cycleNourishSection(position: CycleCalculator.CyclePosition) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if let cyclePlan = viewModel.cyclePlan {
                DailyTimelineView(
                    plan: cyclePlan,
                    phase: position.phase,
                    viewModel: viewModel
                )
            }

            // Symptom check-in
            symptomCheckinCard(phase: position.phase)

            // Wisdom cards for selected symptoms
            ForEach(viewModel.symptomWisdomCards) { card in
                symptomWisdomCard(card, phase: position.phase)
            }
        }
    }

    // MARK: - Symptom Check-in

    private func symptomCheckinCard(phase: CyclePhase) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.text.clipboard")
                    .foregroundStyle(phase.accentColor)
                Text("How Do You Feel Today?")
                    .warmHeadline()
            }

            Text("Tap any symptom for ancient wisdom on what it means, why it matters, and what might help.")
                .captionStyle()

            let commonSymptoms = PeriodSymptomWisdom.commonSymptoms(for: phase)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: AppTheme.Spacing.sm) {
                ForEach(commonSymptoms) { symptom in
                    let isSelected = viewModel.isSymptomSelected(symptom)
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            viewModel.toggleSymptom(symptom)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(symptom.emoji)
                                .font(.title3)
                            Text(symptom.displayName)
                                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(isSelected ? phase.accentColor : phase.accentColor.opacity(0.08))
                        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
                    }
                }
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Symptom Wisdom Card

    private func symptomWisdomCard(_ wisdom: SymptomWisdom, phase: CyclePhase) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(wisdom.symptom.emoji)
                    .font(.title2)
                Text(wisdom.symptom.displayName)
                    .warmHeadline()
                Spacer()
            }

            // What it means
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("What It Means")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(phase.accentColor)
                Text(wisdom.whatItMeans)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Why it matters
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Why It Matters")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(phase.accentColor)
                Text(wisdom.whyItMatters)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)
            }

            // What helps
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("What Might Help")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(phase.accentColor)

                ForEach(wisdom.whatHelps, id: \.self) { tip in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                            .foregroundStyle(phase.accentColor.opacity(0.6))
                            .padding(.top, 3)
                        Text(tip)
                            .guidanceText()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Warm remedy highlight
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "cup.and.heat.waves.fill")
                    .foregroundStyle(phase.accentColor)
                    .font(.body)
                Text(wisdom.warmRemedy)
                    .font(.system(.caption, design: AppTheme.fontFamilySerif))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.sm)
            .background(phase.accentColor.opacity(0.06))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
