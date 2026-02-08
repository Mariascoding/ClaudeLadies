import SwiftUI

struct CycleLengthSettingView: View {
    @Binding var cycleLength: Int
    @Binding var periodLength: Int

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Cycle length
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Cycle Length")
                    .warmHeadline()

                Text("Average number of days from the first day of one period to the first day of the next")
                    .captionStyle()
                    .multilineTextAlignment(.center)

                HStack(spacing: AppTheme.Spacing.lg) {
                    Button {
                        if cycleLength > 20 { cycleLength -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appRose)
                    }

                    Text("\(cycleLength) days")
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.appSoftBrown)
                        .frame(width: 120)

                    Button {
                        if cycleLength < 45 { cycleLength += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appRose)
                    }
                }
            }

            Divider()
                .overlay(Color.appRose.opacity(0.2))

            // Period length
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Period Length")
                    .warmHeadline()

                Text("Average number of days your period lasts")
                    .captionStyle()
                    .multilineTextAlignment(.center)

                HStack(spacing: AppTheme.Spacing.lg) {
                    Button {
                        if periodLength > 2 { periodLength -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appRose)
                    }

                    Text("\(periodLength) days")
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.appSoftBrown)
                        .frame(width: 120)

                    Button {
                        if periodLength < 10 { periodLength += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appRose)
                    }
                }
            }
        }
    }
}
