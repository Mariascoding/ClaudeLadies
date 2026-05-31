import SwiftUI

struct MoonWisdomCard: View {
    let wisdom: MoonPhaseWisdom

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: wisdom.lunarPhase.icon)
                    .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.55))
                Text("Ancient Moon Wisdom")
                    .warmHeadline()
            }

            // Phase name + energy
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(wisdom.lunarPhase.displayName)
                    .font(.system(.body, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(Color.appSoftBrown)

                Text("\u{2022}")
                    .foregroundStyle(Color.appSoftBrown.opacity(0.3))

                Text(wisdom.energyKeyword)
                    .font(.system(.body, design: AppTheme.fontFamilySerif))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
            }

            // Advised section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Advised")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(Color.appSage)

                ForEach(Array(wisdom.advised.enumerated()), id: \.offset) { _, activity in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        Circle()
                            .fill(Color.appSage)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.description)
                                .font(.system(.subheadline, design: AppTheme.fontFamilySerif))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.85))

                            Text(activity.tradition)
                                .font(.system(.caption2, design: AppTheme.fontFamily))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                        }
                    }
                }
            }

            // Avoid section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Avoid")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(Color.appRose)

                ForEach(Array(wisdom.avoid.enumerated()), id: \.offset) { _, activity in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        Circle()
                            .fill(Color.appRose)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.description)
                                .font(.system(.subheadline, design: AppTheme.fontFamilySerif))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.85))

                            Text(activity.tradition)
                                .font(.system(.caption2, design: AppTheme.fontFamily))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                        }
                    }
                }
            }

            // Divider + Quote
            Divider()
                .background(Color.appSoftBrown.opacity(0.15))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("\u{201C}\(wisdom.quote)\u{201D}")
                    .affirmationStyle()

                Text("— \(wisdom.quoteAttribution)")
                    .captionStyle()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
