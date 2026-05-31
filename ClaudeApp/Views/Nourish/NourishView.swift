import SwiftUI
import SwiftData

struct NourishView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = NourishViewModel()
    @State private var showRitualSuggestion = false
    @State private var showHairHealthInfo = false
    @State private var showPersonalItems = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    if viewModel.wellnessGoal != .prenatal && viewModel.wellnessGoal != .menopause {
                        protocolSelector
                    }

                    if viewModel.wellnessGoal == .prenatal {
                        // Pregnancy mode — no protocols, no cycle
                        PregnancyNourishView(viewModel: viewModel)

                        // Symptom checker for pregnancy
                        symptomCheckinForGoal
                    } else if viewModel.wellnessGoal == .menopause {
                        // Menopause mode — phantom rhythm, hormone sustaining
                        MenopauseNourishView(viewModel: viewModel)

                        // Symptom checker for menopause
                        symptomCheckinForGoal
                    } else {
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

                            // Symptom checker for cycle-based protocols
                            if let phase = viewModel.cyclePosition?.phase {
                                symptomCheckinCard(phase: phase)

                                ForEach(viewModel.symptomWisdomCards) { card in
                                    symptomWisdomCard(card, phase: phase)
                                }
                            }
                        }
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
                viewModel.refreshIfNewDay()
                Task { await viewModel.notificationManager.checkPermissionStatus() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            viewModel.refreshIfNewDay()
        }
        .sheet(isPresented: $showHairHealthInfo) {
            HairHealthInfoSheet()
        }
        .sheet(isPresented: $showPersonalItems) {
            PersonalItemsView()
                .onDisappear { viewModel.refresh() }
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
            Text("Protocol")
                .sectionLabel()

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

            HStack {
                if let goal = viewModel.wellnessGoal {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: goal.icon)
                            .font(.caption)
                            .foregroundStyle(goal.color)
                        Text("\(goalLabel(goal: goal))")
                            .captionStyle()
                    }
                }

                Spacer()

                Button {
                    showPersonalItems = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "person.crop.circle")
                            .font(.caption)
                        Text("My Items")
                            .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    }
                    .foregroundStyle(Color.appSage)
                }
            }

            // Restore dismissed items
            if !viewModel.dismissedItemIDs.isEmpty {
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        viewModel.restoreDismissedItems()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .font(.caption2)
                        Text("Restore hidden suggestions")
                            .font(.system(.caption2, design: AppTheme.fontFamily))
                    }
                    .foregroundStyle(Color.appSoftBrown.opacity(0.4))
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

    // MARK: - Goal Label

    private func goalLabel(goal: WellnessGoal) -> String {
        guard goal == .healthyCycle else { return goal.displayName }
        switch viewModel.selectedProtocol {
        case .hairHealth: return "Healthy Cycle & Strong Hair Retention"
        case .seedCycling: return "Healthy Cycle & Hormone Balance"
        case .cellDetox: return "Healthy Cycle & Cleanse"
        case .gutHeal: return "Healthy Cycle & Gut Healing"
        case .daoSt, .none: return goal.displayName
        }
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

            // Goal-specific wisdom (TTC, prenatal, postnatal)
            ForEach(viewModel.goalWisdomCards) { card in
                goalWisdomCardView(card, phase: position.phase)
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
            Text("How Do You Feel Today?")
                .sectionLabel(color: phase.accentColor)

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

    // MARK: - Symptom Check-in (Goal-based, for pregnancy/menopause)

    @ViewBuilder
    private var symptomCheckinForGoal: some View {
        if let goal = viewModel.wellnessGoal {
            let accentColor: Color = goal == .prenatal ? .appRose : .appTerracotta
            let symptoms = PeriodSymptomWisdom.symptoms(for: goal)
            let fallbackPhase: CyclePhase = goal == .prenatal ? .menstrual : .luteal

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("How Do You Feel Today?")
                    .sectionLabel(color: accentColor)

                Text("Tap any symptom for wisdom on what it means and what might help.")
                    .captionStyle()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: AppTheme.Spacing.sm) {
                    ForEach(symptoms) { symptom in
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
                            .background(isSelected ? accentColor : accentColor.opacity(0.08))
                            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
                        }
                    }
                }
            }
            .warmCard()
            .padding(.horizontal, AppTheme.Spacing.md)

            ForEach(viewModel.symptomWisdomCards) { card in
                symptomWisdomCard(card, phase: fallbackPhase)
            }
        }
    }

    // MARK: - Symptom Wisdom Card

    private func symptomWisdomCard(_ wisdom: SymptomWisdom, phase: CyclePhase) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(wisdom.symptom.emoji)
                    .font(.title3)
                Text(wisdom.symptom.displayName)
                    .font(.system(.headline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
                Spacer()
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("What It Means")
                    .sectionLabel(color: phase.accentColor)
                Text(wisdom.whatItMeans)
                    .serifBody()
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Why It Matters")
                    .sectionLabel(color: phase.accentColor)
                Text(wisdom.whyItMatters)
                    .serifBody()
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("What Might Help")
                    .sectionLabel(color: phase.accentColor)

                ForEach(wisdom.whatHelps, id: \.self) { tip in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        Circle()
                            .fill(phase.accentColor.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .padding(.top, 7)
                        Text(tip)
                            .serifBody()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Warm remedy
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "cup.and.heat.waves.fill")
                    .foregroundStyle(phase.accentColor.opacity(0.7))
                    .font(.caption)
                Text(wisdom.warmRemedy)
                    .serifCaption()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.sm)
            .background(phase.accentColor.opacity(0.04))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Goal Wisdom Card

    private func goalWisdomCardView(_ card: GoalWisdomCard, phase: CyclePhase) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(card.title)
                .font(.system(.headline, design: .serif, weight: .medium))
                .foregroundStyle(Color.appSoftBrown)

            Text(card.body)
                .serifBody()
                .fixedSize(horizontal: false, vertical: true)

            ForEach(card.tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Circle()
                        .fill(phase.accentColor.opacity(0.4))
                        .frame(width: 4, height: 4)
                        .padding(.top, 7)
                    Text(tip)
                        .serifBody()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
