import SwiftUI

struct DayLogSummary: View {
    let symptoms: Set<Symptom>
    var tags: [String] = []

    var body: some View {
        if symptoms.isEmpty && tags.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSage)
                    Text("Logged Today")
                        .warmHeadline()
                }

                FlowLayout(spacing: AppTheme.Spacing.xs) {
                    ForEach(Array(symptoms).sorted(by: { $0.displayName < $1.displayName })) { symptom in
                        Text("\(symptom.emoji) \(symptom.displayName)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.appSoftBrown)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(Color.appSage.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    ForEach(tags, id: \.self) { tag in
                        Text(tag.capitalized)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.appTerracotta)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(Color.appTerracotta.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .warmCard()
        }
    }
}
