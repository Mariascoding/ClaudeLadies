import SwiftUI

struct DailyGuidanceCard: View {
    let protectMessage: String
    let decisionTiming: String
    let phase: CyclePhase

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Subtle phase accent line at top
            Capsule()
                .fill(phase.accentColor.opacity(0.4))
                .frame(width: 40, height: 3)
                .padding(.bottom, AppTheme.Spacing.xs)

            Text("Today's Guidance")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(phase.accentColor)
                .textCase(.uppercase)
                .kerning(1.2)

            Text(protectMessage)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(phase.accentColor.opacity(0.5))
                Text(decisionTiming)
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            }
        }
        .warmCard()
    }
}
