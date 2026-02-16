import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @StateObject private var moonState = MoonState()

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                if let guidance = viewModel.guidance {
                    // Period late banner
                    if viewModel.delayDays > 0 {
                        periodLateBanner
                    }

                    PhaseHeaderView(
                        greeting: guidance.greeting,
                        phase: guidance.phase,
                        dayInCycle: guidance.dayInCycle,
                        cycleLength: viewModel.cycleLength
                    )

                    // Moon phase
                    MoonView(moonState: moonState)
                        .frame(height: 220)

                    // Cycle–Moon alignment
                    if moonState.isLoaded, let position = viewModel.cyclePosition {
                        CycleMoonAlignmentView(
                            moonPhase: moonState.moonPhase,
                            dayInCycle: position.dayInCycle,
                            cycleLength: viewModel.cycleLength,
                            phase: position.phase
                        )
                    }

                    // Affirmation
                    Text("\"\(guidance.affirmation)\"")
                        .affirmationStyle()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    // Do Nothing Well banner
                    if guidance.doNothingWellDay {
                        DoNothingWellBanner(phase: guidance.phase)
                            .padding(.horizontal, AppTheme.Spacing.md)
                    }

                    // Daily guidance card
                    DailyGuidanceCard(
                        protectMessage: guidance.protectMessage,
                        decisionTiming: guidance.decisionTiming,
                        phase: guidance.phase
                    )
                    .padding(.horizontal, AppTheme.Spacing.md)

                    // Nervous system selector
                    NervousSystemSelector(
                        selectedState: viewModel.selectedNervousSystemState
                    ) { state in
                        viewModel.selectNervousSystemState(state)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)

                    // Nervous system guidance (when a state is selected)
                    if let nsGuidance = guidance.nervousSystemGuidance {
                        NervousSystemGuidanceView(guidance: nsGuidance)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                } else {
                    noDataView
                }

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
        }
        .background(backgroundGradient)
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .cycleDataDidChange)) { _ in
            viewModel.refresh()
        }
        .task {
            await moonState.load()
        }
    }

    private var periodLateBanner: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
            Text("Period is \(viewModel.delayDays) day\(viewModel.delayDays == 1 ? "" : "s") late")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
        }
        .foregroundStyle(Color.appRose)
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(Color.appRose.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var noDataView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer(minLength: 100)

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appRose)

            Text("Welcome")
                .warmTitle()

            Text("Complete your setup in Settings to receive your daily guidance.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    private var backgroundGradient: some View {
        Group {
            if let phase = viewModel.guidance?.phase {
                LinearGradient(
                    colors: phase.gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                Color.appCream.ignoresSafeArea()
            }
        }
    }
}
