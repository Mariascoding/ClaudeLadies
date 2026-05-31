import SwiftUI

struct SymptomPatternView: View {
    let frequencies: [(symptom: Symptom, count: Int)]

    var body: some View {
        if frequencies.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("Your Patterns")
                    .sectionLabel(color: Color.appTerracotta)

                Text("Most logged symptoms over the last 90 days")
                    .serifCaption()

                VStack(spacing: AppTheme.Spacing.sm) {
                    let maxCount = frequencies.first?.count ?? 1

                    ForEach(frequencies, id: \.symptom) { item in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Text(item.symptom.emoji)
                                .font(.caption)

                            Text(item.symptom.displayName)
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.8))
                                .frame(width: 100, alignment: .leading)

                            GeometryReader { geo in
                                let fraction = CGFloat(item.count) / CGFloat(max(1, maxCount))
                                Capsule()
                                    .fill(Color.appRose.opacity(0.25))
                                    .frame(width: geo.size.width * fraction)
                            }
                            .frame(height: 14)
                        }
                    }
                }
            }
            .warmCard()
        }
    }
}
