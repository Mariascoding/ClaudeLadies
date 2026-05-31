import SwiftUI

struct PhaseHeaderView: View {
    let greeting: String
    let phase: CyclePhase
    let dayInCycle: Int
    var cycleLength: Int = 28

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            // Greeting — soft, small
            Text(greeting)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                .padding(.bottom, 2)

            // Inner Season — the hero statement
            Text(phase.innerSeason)
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundStyle(Color.appSoftBrown)
                .kerning(0.5)

            // Phase day — minimal, elegant
            Text("\(phase.displayName) · Day \(dayInCycle)\(dayInCycle <= cycleLength ? " of \(cycleLength)" : "")")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(phase.accentColor.opacity(0.8))
                .padding(.top, 2)

            // Date — understated
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
        }
        .padding(.top, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.sm)
    }
}
