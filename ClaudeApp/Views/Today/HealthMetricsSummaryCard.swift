import SwiftUI

struct HealthMetricsSummaryCard: View {
    let summary: MergedDailyHealthSummary
    let phase: CyclePhase?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.text.clipboard.fill")
                    .foregroundStyle(Color.appRose)
                Text("Your Body Today")
                    .warmHeadline()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                if let sleep = summary.sleep {
                    metricTile(
                        icon: HealthMetricType.sleep.icon,
                        label: "Sleep",
                        value: String(format: "%.1f", sleep.totalDurationHours),
                        unit: "hrs",
                        color: .appRose
                    )
                }

                if let hrv = summary.hrvMs {
                    metricTile(
                        icon: HealthMetricType.hrv.icon,
                        label: "HRV",
                        value: String(format: "%.0f", hrv),
                        unit: "ms",
                        color: .appSage
                    )
                }

                if let rhr = summary.restingHeartRateBpm {
                    metricTile(
                        icon: HealthMetricType.restingHeartRate.icon,
                        label: "Resting HR",
                        value: String(format: "%.0f", rhr),
                        unit: "bpm",
                        color: .appTerracotta
                    )
                }

                if let temp = summary.basalBodyTemperatureCelsius {
                    metricTile(
                        icon: HealthMetricType.basalBodyTemperature.icon,
                        label: "Temperature",
                        value: String(format: "%.1f", temp),
                        unit: "\u{00B0}C",
                        color: .appSoftBrown
                    )
                }

                if let steps = summary.steps {
                    metricTile(
                        icon: HealthMetricType.steps.icon,
                        label: "Steps",
                        value: formatSteps(steps),
                        unit: "",
                        color: .appSage
                    )
                }
            }

            // Phase-contextual insight
            if let insight = phaseInsight {
                Text(insight)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .warmCard()
    }

    private func metricTile(icon: String, label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appSoftBrown)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                }
            }

            Text(label)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(color.opacity(0.06))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
    }

    private func formatSteps(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }

    private var phaseInsight: String? {
        guard let phase else { return nil }

        if let hrv = summary.hrvMs, hrv < 30 {
            switch phase {
            case .menstrual:
                return "HRV often dips during menstruation \u{2014} this is normal. Gentle rest supports recovery."
            case .luteal:
                return "Lower HRV in the luteal phase reflects progesterone\u{2019}s calming influence. Honor the slowdown."
            default:
                break
            }
        }

        if let sleep = summary.sleep, sleep.totalDurationHours < 7 {
            return "Less than 7 hours of sleep can affect hormonal balance. Prioritize rest tonight."
        }

        if let temp = summary.basalBodyTemperatureCelsius {
            if phase == .ovulation && temp > 36.5 {
                return "A temperature rise around ovulation confirms your body\u{2019}s natural rhythm."
            }
        }

        switch phase {
        case .menstrual:
            return "During menstruation, rest metrics matter most. Listen to your body\u{2019}s need for slowness."
        case .follicular:
            return "Rising energy in your follicular phase \u{2014} a good time for more activity."
        case .ovulation:
            return "Peak energy during ovulation. Your body is at its most resilient."
        case .luteal:
            return "The luteal phase calls for gentler movement and earlier sleep."
        }
    }
}
