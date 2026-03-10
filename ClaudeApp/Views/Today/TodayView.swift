import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthDataManager.self) private var healthManager
    @State private var viewModel = TodayViewModel()
    @StateObject private var moonState = MoonState()
    @State private var scrollOffset: CGFloat = 0
    @State private var rawScrollOffset: CGFloat = 0
    @State private var initialScrollY: CGFloat = 0
    @State private var showingMoonWisdom = false

    // Moon drifts down when scrolling up only
    private var moonDriftOffset: CGFloat {
        guard rawScrollOffset > 0 else { return 0 }
        return rawScrollOffset * 0.12
    }

    // Moon scales: 1.1 when pulling down, 1.0 at rest, 0.9 when scrolled up
    private var moonScale: CGFloat {
        let pullRange: CGFloat = 150  // full pull-down range for max scale
        let scrollRange: CGFloat = 400 // scroll range for min scale
        if rawScrollOffset < 0 {
            let progress = min(1, -rawScrollOffset / pullRange)
            return 1.0 + 0.1 * progress
        } else {
            let progress = min(1, rawScrollOffset / scrollRange)
            return 1.0 - 0.1 * progress
        }
    }

    private var moonOpacity: Double {
        let fadeStart: CGFloat = 50
        let fadeEnd: CGFloat = 400
        let clamped = min(max(scrollOffset, fadeStart), fadeEnd)
        return Double(1.0 - (clamped - fadeStart) / (fadeEnd - fadeStart))
    }

    private var headerOpacity: Double {
        let fadeStart: CGFloat = 30
        let fadeEnd: CGFloat = 250
        let clamped = min(max(scrollOffset, fadeStart), fadeEnd)
        return Double(1.0 - (clamped - fadeStart) / (fadeEnd - fadeStart))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Fixed: header + moon
            if let guidance = viewModel.guidance {
                VStack(spacing: AppTheme.Spacing.md) {
                    if viewModel.delayDays > 0 {
                        periodLateBanner
                    }

                    PhaseHeaderView(
                        greeting: guidance.greeting,
                        phase: guidance.phase,
                        dayInCycle: guidance.dayInCycle,
                        cycleLength: viewModel.cycleLength
                    )
                    .opacity(headerOpacity)

                    Group {
                        if moonState.isLoaded, let position = viewModel.cyclePosition {
                            LunarMirrorCard(
                                moonState: moonState,
                                dayInCycle: position.dayInCycle,
                                cycleLength: viewModel.cycleLength,
                                periodLength: viewModel.periodLength,
                                scrollOffset: scrollOffset,
                                showingWisdom: $showingMoonWisdom
                            )
                        } else {
                            MoonView(moonState: moonState)
                                .frame(height: 220)
                        }
                    }
                    .scaleEffect(moonScale)
                    .opacity(moonOpacity)
                    .offset(y: moonDriftOffset)
                }
            }

            // Scrollable content
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    if let guidance = viewModel.guidance {
                        // Scroll anchor — tracks Y position
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, newY in
                                    let raw = -newY + initialScrollY
                                    rawScrollOffset = raw
                                    scrollOffset = max(0, raw)
                                }
                                .onAppear {
                                    initialScrollY = geo.frame(in: .global).minY
                                }
                        }
                        .frame(height: 0)

                        Color.clear
                            .frame(height: 480)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showingMoonWisdom.toggle()
                                }
                            }

                        // Affirmation
                        Text("\"\(guidance.affirmation)\"")
                            .affirmationStyle()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)

                        // Health metrics
                        if let summary = healthManager.todaySummary {
                            HealthMetricsSummaryCard(
                                summary: summary,
                                phase: guidance.phase
                            )
                            .padding(.horizontal, AppTheme.Spacing.md)
                        }

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

                        // Nervous system guidance
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
        }
        .background(SkyBackgroundView())
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .cycleDataDidChange)) { _ in
            viewModel.refresh()
        }
        .task {
            await moonState.load()
            if healthManager.hasAnyConnectedSource {
                await healthManager.fetchTodayData()
            }
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
}
