import SwiftUI

struct DoNothingWellBanner: View {
    let phase: CyclePhase

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(Color.appSage)

            VStack(alignment: .leading, spacing: 4) {
                Text("Do Nothing Well")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appSoftBrown)

                Text("Today is for rest, not results. Give yourself permission to simply be.")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.appSage.opacity(0.12))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))
    }
}
