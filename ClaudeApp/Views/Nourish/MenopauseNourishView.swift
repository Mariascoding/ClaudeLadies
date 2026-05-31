import SwiftUI
import SwiftData

struct MenopauseNourishView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    let viewModel: NourishViewModel

    private var profile: UserProfile? { profiles.first }

    private var position: MenopauseCalculator.MenopausePosition? {
        guard let lastBleed = profile?.menopauseLastBleedDate else { return nil }
        return MenopauseCalculator.currentPosition(lastBleedDate: lastBleed)
    }

    var body: some View {
        if let position {
            VStack(spacing: AppTheme.Spacing.md) {
                menopauseHeaderCard(position)

                let plan = MenopauseNutritionContent.dailyPlan(
                    phase: position.phase,
                    dayInPhase: position.dayInPhase
                )
                DailyTimelineView(
                    plan: plan,
                    phase: phaseMapping(position.phase),
                    viewModel: viewModel
                )
            }
        } else {
            noDatePrompt
        }
    }

    // MARK: - Header

    private func menopauseHeaderCard(_ pos: MenopauseCalculator.MenopausePosition) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Phase name and icon
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: pos.phase.icon)
                    .foregroundStyle(phaseColor(pos.phase))
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(pos.phase.displayName)
                        .font(.system(.title2, design: AppTheme.fontFamily, weight: .bold))
                        .foregroundStyle(Color.appSoftBrown)
                    Text("Day \(pos.dayInPhase) · Rhythm Day \(pos.dayInCycle)")
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(phaseColor(pos.phase))
                }
                Spacer()
            }

            Text(pos.phase.description)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            // Rhythm visualisation
            HStack(spacing: 2) {
                ForEach(MenopausePhase.allCases, id: \.rawValue) { phase in
                    let isActive = phase == pos.phase
                    RoundedRectangle(cornerRadius: 4)
                        .fill(phaseColor(phase).opacity(isActive ? 0.6 : 0.15))
                        .frame(height: 6)
                }
            }

            HStack {
                Text("\(pos.daysSinceLastBleed) days since last bleed")
                    .captionStyle()
                Spacer()
                Text("Your body's hormone rhythm continues")
                    .font(.system(.caption2, design: AppTheme.fontFamilySerif))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - No Date

    private var noDatePrompt: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "sun.and.horizon.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appTerracotta.opacity(0.5))

            Text("When Was Your Last Bleed?")
                .warmTitle()
                .multilineTextAlignment(.center)

            Text("Set the date of your last menstrual bleed in Settings. Your body still cycles hormonally — we'll use this date to align your nutrition rhythm and help sustain your hormone levels naturally.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.xxl)
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Helpers

    private func phaseColor(_ phase: MenopausePhase) -> Color {
        switch phase {
        case .restore: .appRose
        case .build: .appSage
        case .sustain: .appTerracotta
        case .ground: .appSoftBrown
        }
    }

    private func phaseMapping(_ phase: MenopausePhase) -> CyclePhase {
        switch phase {
        case .restore: .menstrual
        case .build: .follicular
        case .sustain: .ovulation
        case .ground: .luteal
        }
    }
}
