import SwiftUI

struct TagAnalysisView: View {
    let results: [TagPhaseResult]

    var body: some View {
        if results.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "tag.fill")
                        .foregroundStyle(Color.appTerracotta)
                    Text("Tag Patterns")
                        .warmHeadline()
                }

                VStack(spacing: 0) {
                    ForEach(results) { result in
                        tagRow(result)
                        if result.id != results.last?.id {
                            Divider()
                                .overlay(Color.appTerracotta.opacity(0.1))
                        }
                    }
                }
            }
            .warmCard()
        }
    }

    @ViewBuilder
    private func tagRow(_ result: TagPhaseResult) -> some View {
        HStack {
            Text(result.tag.capitalized)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(Color.appSoftBrown)

            Spacer()

            if result.correlation == .cyclical, let phase = result.peakPhase {
                PhaseIcon(phase: phase, size: 14)
            }

            correlationBadge(result.correlation)

            Text("\(result.totalCount)x")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    @ViewBuilder
    private func correlationBadge(_ correlation: TagCorrelation) -> some View {
        let (label, color) = badgeInfo(correlation)
        Text(label)
            .font(.system(.caption2, design: .rounded, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func badgeInfo(_ correlation: TagCorrelation) -> (String, Color) {
        switch correlation {
        case .cyclical:
            ("Cycle-linked", Color.appTerracotta)
        case .leaning:
            ("Possibly cycle-linked", Color.appSage)
        case .random:
            ("No clear pattern", Color.appSoftBrown)
        }
    }
}
