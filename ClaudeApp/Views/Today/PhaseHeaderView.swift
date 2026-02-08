import SwiftUI

struct PhaseHeaderView: View {
    let greeting: String
    let phase: CyclePhase
    let dayInCycle: Int

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(greeting)
                .font(.system(.title3, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))

            HStack(spacing: AppTheme.Spacing.sm) {
                PhaseIcon(phase: phase, size: 32)
                Text(phase.innerSeason)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.appSoftBrown)
            }

            Text("Day \(dayInCycle) of your cycle")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
        }
        .padding(.top, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.md)
    }
}
