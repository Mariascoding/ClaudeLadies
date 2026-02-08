import SwiftUI

struct SymptomPickerView: View {
    let selectedSymptoms: Set<Symptom>
    let onToggle: (Symptom) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            ForEach(SymptomCategory.allCases, id: \.rawValue) { category in
                categorySection(category)
            }
        }
    }

    private func categorySection(_ category: SymptomCategory) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(category.displayName)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))

            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(Symptom.symptoms(for: category)) { symptom in
                    SymptomChip(
                        symptom: symptom,
                        isSelected: selectedSymptoms.contains(symptom)
                    ) {
                        onToggle(symptom)
                    }
                }
            }
        }
    }
}
