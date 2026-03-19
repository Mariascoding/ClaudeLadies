import SwiftUI
import SwiftData

struct PieChartLabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @State private var displayedCycleDay: Int = 1

    private var cycleLength: Int {
        viewModel.cycleLength
    }

    private var currentCycleDay: Int {
        viewModel.cyclePosition?.dayInCycle ?? 1
    }

    private var phaseForDay: CyclePhase {
        phaseFromDay(displayedCycleDay, cycleLength: cycleLength)
    }

    private var phaseDesc: PhaseDescription {
        PhaseDescriptions.description(for: phaseForDay)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Pie chart dial
                pieChartDial
                    .padding(.top, AppTheme.Spacing.md)

                // Day indicator
                dayIndicator

                // Phase info card
                phaseInfoCard
                    .padding(.horizontal, AppTheme.Spacing.md)

                // Back to today button
                if displayedCycleDay != currentCycleDay {
                    backToTodayButton
                }

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
        }
        .background(SkyBackgroundView())
        .navigationTitle("Cycle Dial")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.load(modelContext: modelContext)
            displayedCycleDay = currentCycleDay
        }
    }

    // MARK: - Pie Chart Dial

    private var pieChartDial: some View {
        let radius: CGFloat = 150
        let segments = getPieSegments(for: cycleLength)
        let overlay = getPieOverlay(for: cycleLength)
        let todayHighlight = getTodayOverlay(
            for: cycleLength,
            todayUnit: displayedCycleDay - 1,
            highlightColor: .white
        )

        return ZStack {
            // Base colored pie
            FadedPieChartView(
                segments: segments,
                radius: radius,
                focusUnit: Double(displayedCycleDay)
            )

            // Subtle grayscale depth overlay
            RotatedPieChartView(
                segments: overlay,
                radius: radius,
                focusUnit: Double(displayedCycleDay)
            )
            .opacity(0.08)
            .blendMode(.multiply)

            // Day tick marks
            DayTicksView(cycleLength: cycleLength, radius: radius)
                .rotationEffect(.degrees(-(Double(displayedCycleDay - 1) / Double(cycleLength) * 360) + (180.0 / Double(cycleLength))))

            // Today marker
            RotatedPieChartView(
                segments: todayHighlight,
                radius: radius,
                focusUnit: Double(displayedCycleDay)
            )
            .opacity(0.6)

            // Center cutout with day number
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: radius * 0.7, height: radius * 0.7)

            VStack(spacing: 2) {
                Text("Day")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                Text("\(displayedCycleDay)")
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundStyle(phaseForDay.accentColor)
            }

            // Drag interaction layer
            PieChartDragInteractionLayer(
                displayedCycleDay: $displayedCycleDay,
                cycleLength: cycleLength
            )
            .frame(width: radius * 2, height: radius * 2)
        }
        .frame(width: radius * 2, height: radius * 2)
        .clipShape(Circle())
        .frame(maxWidth: .infinity)
    }

    // MARK: - Day Indicator

    private var dayIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(phaseForDay.accentColor.opacity(0.3))
                .frame(width: 8, height: 8)

            Text(phaseDesc.title)
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.8))

            Text(phaseDesc.innerSeason)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(phaseForDay.accentColor.opacity(0.8))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .background(phaseForDay.accentColor.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    // MARK: - Phase Info Card

    private var phaseInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("Hormones", systemImage: "waveform.path")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(phaseForDay.accentColor)

            Text(phaseDesc.hormoneHighlight)
                .guidanceText()

            Divider()
                .background(Color.appSoftBrown.opacity(0.15))

            Label("Superpower", systemImage: "sparkles")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(phaseForDay.accentColor.opacity(0.8))

            Text(phaseDesc.superpower)
                .guidanceText()

            Divider()
                .background(Color.appSoftBrown.opacity(0.15))

            Label("Nourishment", systemImage: "leaf.fill")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(phaseForDay.accentColor.opacity(0.8))

            Text(phaseDesc.nourishment)
                .guidanceText()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .animation(.easeInOut(duration: 0.3), value: displayedCycleDay)
    }

    // MARK: - Back to Today

    private var backToTodayButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                displayedCycleDay = currentCycleDay
            }
        } label: {
            Label("Back to Today", systemImage: "arrow.uturn.backward")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.appRose)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(Color.appRose.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    // MARK: - Helpers

    private func phaseFromDay(_ day: Int, cycleLength: Int) -> CyclePhase {
        switch day {
        case 1...5: return .menstrual
        case 6...13: return .follicular
        case 14...16: return .ovulation
        default: return .luteal
        }
    }
}
