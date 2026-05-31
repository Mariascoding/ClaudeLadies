import SwiftUI

struct NutritionCheckItem: View {
    let item: NutritionItem
    let isCompleted: Bool
    let accentColor: Color
    let onToggle: () -> Void
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Button(action: onToggle) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isCompleted ? accentColor : Color.appSoftBrown.opacity(0.3))

                    Text(item.name)
                        .font(.system(.body, design: AppTheme.fontFamilySerif))
                        .foregroundStyle(isCompleted ? Color.appSoftBrown.opacity(0.4) : Color.appSoftBrown.opacity(0.85))
                        .strikethrough(isCompleted, color: Color.appSoftBrown.opacity(0.3))
                        .fixedSize(horizontal: false, vertical: true)

                    if item.isPersonal {
                        Text("yours")
                            .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(accentColor.opacity(0.5))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(accentColor.opacity(0.08))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Dismiss button for protocol suggestions only
            if !item.isPersonal, let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "minus.circle")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}
