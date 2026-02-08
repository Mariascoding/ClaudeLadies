import SwiftUI

struct DailyGuidanceCard: View {
    let protectMessage: String
    let decisionTiming: String
    let phase: CyclePhase

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundStyle(phase.accentColor)
                Text("Today's Guidance")
                    .warmHeadline()
            }

            Text(protectMessage)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(phase.accentColor.opacity(0.2))

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "clock")
                    .foregroundStyle(phase.accentColor.opacity(0.7))
                    .font(.caption)
                Text(decisionTiming)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
            }
        }
        .warmCard()
    }
}
