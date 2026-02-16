import SwiftUI

struct PatternInsightsView: View {
    let analysis: PatternAnalysis

    @State private var expandedCluster: String?

    var body: some View {
        if !analysis.hasEnoughData {
            notEnoughDataView
        } else if analysis.clusterResults.isEmpty {
            EmptyView()
        } else {
            fullAnalysisView
        }
    }

    // MARK: - Not Enough Data

    private var notEnoughDataView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Color.appTerracotta)
                Text("Pattern Analysis")
                    .warmHeadline()
            }

            Text("Log at least \(PatternAnalysisEngine.minimumEntries) symptom entries over 2 weeks to unlock your personalized pattern analysis and protocol recommendation.")
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            let progress = Double(analysis.dataCoverage.totalEntries) / Double(PatternAnalysisEngine.minimumEntries)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("\(analysis.dataCoverage.totalEntries) of \(PatternAnalysisEngine.minimumEntries) entries")
                        .captionStyle()
                    Spacer()
                    Text("\(Int(min(progress, 1.0) * 100))%")
                        .captionStyle()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appSoftBrown.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appTerracotta.opacity(0.6))
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .warmCard()
    }

    // MARK: - Full Analysis

    private var fullAnalysisView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Color.appTerracotta)
                Text("Pattern Analysis")
                    .warmHeadline()
            }

            // Data coverage
            Text(analysis.dataCoverage.summaryText)
                .captionStyle()

            // Cluster sections
            VStack(spacing: 0) {
                ForEach(analysis.clusterResults) { result in
                    clusterSection(result: result)
                }
            }

            // Protocol recommendation
            if let recommendation = analysis.protocolRecommendation {
                recommendationSection(recommendation: recommendation)
            }
        }
        .warmCard()
    }

    // MARK: - Cluster Section

    private func clusterSection(result: ClusterResult) -> some View {
        let isExpanded = expandedCluster == result.cluster.rawValue

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    expandedCluster = isExpanded ? nil : result.cluster.rawValue
                }
            } label: {
                HStack {
                    Image(systemName: result.cluster.icon)
                        .foregroundStyle(Color.appTerracotta)
                        .frame(width: 24)

                    Text(result.cluster.displayName)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)
                        .lineLimit(1)

                    Spacer()

                    strengthBadge(result.strength)

                    if let peakDay = result.peakCycleDay {
                        Text("peaks day \(peakDay)")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(Color.appWarmWhite)
            }
            .buttonStyle(.plain)
            .zIndex(1)

            if isExpanded {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    // Symptom chips
                    FlowLayout(spacing: AppTheme.Spacing.xs) {
                        ForEach(result.matchingSymptoms) { freq in
                            symptomChip(freq: freq)
                        }
                    }

                    // Peak phase badge
                    if let phase = result.peakPhase {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            PhaseIcon(phase: phase, size: 14)
                            Text("Peaks in \(phase.displayName) phase")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(phase.accentColor)
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(phase.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    // Explanation
                    Text(result.explanation)
                        .guidanceText()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppTheme.Spacing.sm)
                .padding(.leading, 32)
                .transition(.opacity.combined(with: .identity))
            }

            Divider()
                .overlay(Color.appTerracotta.opacity(0.1))
        }
    }

    // MARK: - Symptom Chip

    private func symptomChip(freq: SymptomFrequencyInfo) -> some View {
        HStack(spacing: 4) {
            Text(freq.symptom.emoji)
                .font(.caption2)
            Text(freq.symptom.displayName)
                .font(.system(.caption2, design: .rounded))
            Text("(\(freq.count))")
                .font(.system(.caption2, design: .rounded, weight: .medium))
        }
        .foregroundStyle(Color.appSoftBrown)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(Color.appSoftBrown.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Strength Badge

    private func strengthBadge(_ strength: ClusterStrength) -> some View {
        Text(strength.displayName)
            .font(.system(.caption2, design: .rounded, weight: .medium))
            .foregroundStyle(strengthColor(strength))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(strengthColor(strength).opacity(0.12))
            .clipShape(Capsule())
    }

    private func strengthColor(_ strength: ClusterStrength) -> Color {
        switch strength {
        case .strong: .appTerracotta
        case .moderate: .appSage
        case .mild: .appSoftBrown
        case .insufficient: .appSoftBrown.opacity(0.5)
        }
    }

    // MARK: - Recommendation Section

    private func recommendationSection(recommendation: ProtocolRecommendation) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Divider()
                .overlay(Color.appTerracotta.opacity(0.2))

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: recommendation.recommended.icon)
                    .foregroundStyle(recommendation.recommended.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Recommended Protocol")
                        .captionStyle()
                    Text(recommendation.recommended.displayName)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(recommendation.recommended.color)
                }

                Spacer()

                // Confidence badge
                HStack(spacing: 4) {
                    Image(systemName: recommendation.confidence.icon)
                        .font(.caption2)
                    Text(recommendation.confidence.displayName)
                        .font(.system(.caption2, design: .rounded))
                }
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.appSoftBrown.opacity(0.06))
                .clipShape(Capsule())
            }

            Text(recommendation.reasoning)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            if let altProtocol = recommendation.alternativeProtocol,
               let altReason = recommendation.alternativeReason {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: altProtocol.icon)
                        .font(.caption)
                        .foregroundStyle(altProtocol.color)
                    Text(altReason)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                }
            }
        }
    }
}
