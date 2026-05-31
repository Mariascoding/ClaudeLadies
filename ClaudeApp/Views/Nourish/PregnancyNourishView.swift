import SwiftUI
import SwiftData

struct PregnancyNourishView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    let viewModel: NourishViewModel

    private var profile: UserProfile? { profiles.first }

    private var position: PregnancyCalculator.PregnancyPosition? {
        guard let start = profile?.pregnancyStartDate else { return nil }
        return PregnancyCalculator.currentPosition(pregnancyStart: start)
    }

    var body: some View {
        if let position {
            VStack(spacing: AppTheme.Spacing.md) {
                pregnancyHeaderCard(position)
                babyDevelopmentCard(position)

                let plan = PregnancyNutritionContent.dailyPlan(
                    trimester: position.trimester,
                    week: position.week
                )
                DailyTimelineView(
                    plan: plan,
                    phase: trimesterPhase(position.trimester),
                    viewModel: viewModel
                )
            }
        } else {
            noDatePrompt
        }
    }

    // MARK: - Pregnancy Header

    private func pregnancyHeaderCard(_ pos: PregnancyCalculator.PregnancyPosition) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Week and trimester
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(trimesterColor(pos.trimester))
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Week \(pos.week), Day \(pos.day)")
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .foregroundStyle(Color.appSoftBrown)
                    Text(pos.trimester.displayName)
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(trimesterColor(pos.trimester))
                }
                Spacer()
            }

            // Due date
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                Text("Due date: \(pos.dueDate, format: .dateTime.day().month(.wide).year())")
                    .captionStyle()
                Spacer()
                Text("\(pos.daysUntilDue) days to go")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(trimesterColor(pos.trimester))
            }

            // Progress bar
            let progress = min(1.0, Double(pos.totalDays) / 280.0)
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(trimesterColor(pos.trimester).opacity(0.15))
                            .frame(height: 6)
                        Capsule()
                            .fill(trimesterColor(pos.trimester))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("Week 1")
                    Spacer()
                    Text("Week 40")
                }
                .font(.system(.caption2, design: AppTheme.fontFamily))
                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Baby Development

    private func babyDevelopmentCard(_ pos: PregnancyCalculator.PregnancyPosition) -> some View {
        let size = PregnancyCalculator.babySize(week: pos.week)
        let milestone = PregnancyCalculator.developmentMilestone(week: pos.week)

        return VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Your Baby This Week")
                .sectionLabel(color: trimesterColor(pos.trimester))

            // Size comparison
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Baby is about the size of \(size.size)")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)

                HStack(spacing: AppTheme.Spacing.lg) {
                    Label(size.length, systemImage: "ruler")
                    Label(size.weight, systemImage: "scalemass")
                }
                .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(trimesterColor(pos.trimester))
            }

            // Development milestone
            Text(milestone)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - No Date

    private var noDatePrompt: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appRose.opacity(0.5))

            Text("When Did Your Pregnancy Begin?")
                .warmTitle()
                .multilineTextAlignment(.center)

            Text("Set your pregnancy start date in Settings to receive week-by-week nutrition guidance, baby development updates, and safe supplement recommendations.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.xxl)
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Helpers

    private func trimesterColor(_ trimester: PregnancyTrimester) -> Color {
        switch trimester {
        case .first: .appRose
        case .second: .appTerracotta
        case .third: .appSage
        }
    }

    /// Maps trimester to a CyclePhase for accent colors in DailyTimelineView
    private func trimesterPhase(_ trimester: PregnancyTrimester) -> CyclePhase {
        switch trimester {
        case .first: .menstrual
        case .second: .ovulation
        case .third: .follicular
        }
    }
}
