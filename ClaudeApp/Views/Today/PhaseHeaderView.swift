import SwiftUI

struct PhaseHeaderView: View {
    let greeting: String
    let phase: CyclePhase
    let dayInCycle: Int
    var cycleLength: Int = 28

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(greeting)
                .font(.system(.title3, design: AppTheme.fontFamily))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))

            HStack(spacing: AppTheme.Spacing.sm) {
                PhaseIcon(phase: phase, size: 32)
                Text(phase.innerSeason)
                    .font(.system(.largeTitle, design: AppTheme.fontFamily, weight: .bold))
                    .foregroundStyle(Color.appSoftBrown)
            }

            // Date
            VStack(spacing: 2) {
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(.subheadline, design: AppTheme.fontFamily))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
            }

            // Phase and cycle day
            Text("\(phase.displayName) Phase · Day \(dayInCycle)\(dayInCycle <= cycleLength ? " of \(cycleLength)" : "")")
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(phase.accentColor)
        }
        .padding(.top, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.md)
    }
}
