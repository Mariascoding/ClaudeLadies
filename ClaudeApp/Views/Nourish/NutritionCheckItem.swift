import SwiftUI

struct NutritionCheckItem: View {
    let item: NutritionItem
    let isCompleted: Bool
    let accentColor: Color
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isCompleted ? accentColor : Color.appSoftBrown.opacity(0.3))

                Text(item.name)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(isCompleted ? Color.appSoftBrown.opacity(0.4) : Color.appSoftBrown.opacity(0.85))
                    .strikethrough(isCompleted, color: Color.appSoftBrown.opacity(0.3))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
