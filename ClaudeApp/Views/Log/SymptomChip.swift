import SwiftUI

struct SymptomChip: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(symptom.emoji)
                    .font(.caption)
                Text(symptom.displayName)
                    .font(.system(.caption, design: .rounded, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
            .padding(.horizontal, AppTheme.Spacing.sm + 2)
            .padding(.vertical, AppTheme.Spacing.xs + 2)
            .background(isSelected ? Color.appRose : Color.appRose.opacity(0.08))
            .clipShape(Capsule())
        }
    }
}
