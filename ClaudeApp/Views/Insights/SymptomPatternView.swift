import SwiftUI

struct SymptomPatternView: View {
    let frequencies: [(symptom: Symptom, count: Int)]

    var body: some View {
        if frequencies.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Color.appTerracotta)
                    Text("Your Patterns")
                        .warmHeadline()
                }

                Text("Most logged symptoms over the last 90 days")
                    .captionStyle()

                VStack(spacing: AppTheme.Spacing.sm) {
                    let maxCount = frequencies.first?.count ?? 1

                    ForEach(frequencies, id: \.symptom) { item in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Text(item.symptom.emoji)
                                .font(.caption)

                            Text(item.symptom.displayName)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.appSoftBrown)
                                .frame(width: 100, alignment: .leading)

                            GeometryReader { geo in
                                let fraction = CGFloat(item.count) / CGFloat(max(1, maxCount))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.appRose.opacity(0.3))
                                    .frame(width: geo.size.width * fraction)
                            }
                            .frame(height: 16)
                        }
                    }
                }
            }
            .warmCard()
        }
    }
}
