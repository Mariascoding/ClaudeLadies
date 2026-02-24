import SwiftUI

struct HealthCorrelationView: View {
    let correlations: [HealthCorrelation]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "chart.bar.xaxis.ascending")
                    .foregroundStyle(Color.appSage)
                Text("Health & Cycle Patterns")
                    .warmHeadline()
            }

            Text("How your body metrics shift across cycle phases.")
                .captionStyle()
                .fixedSize(horizontal: false, vertical: true)

            ForEach(correlations) { correlation in
                correlationCard(correlation)
            }
        }
        .warmCard()
    }

    private func correlationCard(_ correlation: HealthCorrelation) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: correlation.metricType.icon)
                    .font(.caption)
                    .foregroundStyle(Color.appTerracotta)
                Text(correlation.metricType.displayName)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }

            // Mini bar chart
            phaseBarChart(correlation)

            Text(correlation.insight)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Spacing.sm)
        .background(Color.appSoftBrown.opacity(0.04))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
    }

    private func phaseBarChart(_ correlation: HealthCorrelation) -> some View {
        let maxValue = correlation.phaseAverages.values.max() ?? 1.0

        return HStack(alignment: .bottom, spacing: AppTheme.Spacing.xs) {
            ForEach(CyclePhase.allCases, id: \.self) { phase in
                let value = correlation.phaseAverages[phase]

                VStack(spacing: 4) {
                    if let value {
                        Text(formatValue(value, type: correlation.metricType))
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(phase.accentColor.opacity(value != nil ? 0.7 : 0.15))
                        .frame(height: barHeight(value: value, maxValue: maxValue))

                    Text(phaseAbbreviation(phase))
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
    }

    private func barHeight(value: Double?, maxValue: Double) -> CGFloat {
        guard let value, maxValue > 0 else { return 4 }
        return Swift.max(4, CGFloat(value / maxValue) * 50)
    }

    private func formatValue(_ value: Double, type: HealthMetricType) -> String {
        switch type {
        case .sleep: String(format: "%.1f", value)
        case .hrv: String(format: "%.0f", value)
        case .restingHeartRate: String(format: "%.0f", value)
        case .basalBodyTemperature: String(format: "%.1f", value)
        case .steps: String(format: "%.0f", value)
        }
    }

    private func phaseAbbreviation(_ phase: CyclePhase) -> String {
        switch phase {
        case .menstrual: "Men"
        case .follicular: "Fol"
        case .ovulation: "Ovu"
        case .luteal: "Lut"
        }
    }
}
