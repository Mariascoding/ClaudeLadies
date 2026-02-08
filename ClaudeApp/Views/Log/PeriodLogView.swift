import SwiftUI

struct PeriodLogView: View {
    let isPeriodActive: Bool
    let onStart: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: isPeriodActive ? "drop.fill" : "drop")
                    .foregroundStyle(Color.appRose)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isPeriodActive ? "Period Active" : "Period")
                        .warmHeadline()

                    Text(isPeriodActive ? "Tap to mark the end of your period" : "Tap to mark the start of your period")
                        .captionStyle()
                }

                Spacer()
            }

            if isPeriodActive {
                GentleButton("My period ended", color: .appRose.opacity(0.7), action: onEnd)
            } else {
                GentleButton("My period started", color: .appRose, action: onStart)
            }
        }
        .warmCard()
    }
}
