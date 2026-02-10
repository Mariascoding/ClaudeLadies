import SwiftUI

struct TimeBlockCard: View {
    let timeBlock: TimeBlock
    let accentColor: Color
    let completedCount: Int
    let isItemCompleted: (NutritionItem) -> Bool
    let onToggle: (NutritionItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: timeBlock.timeOfDay.icon)
                    .font(.title3)
                    .foregroundStyle(accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(timeBlock.timeOfDay.displayName)
                        .warmHeadline()
                    Text(timeBlock.timeOfDay.timeHint)
                        .captionStyle()
                }

                Spacer()

                Text("\(completedCount)/\(timeBlock.totalCount)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(completedCount == timeBlock.totalCount && timeBlock.totalCount > 0 ? accentColor : Color.appSoftBrown.opacity(0.5))
            }

            // Categorized items
            if !timeBlock.foods.isEmpty {
                categorySection(NutritionItemCategory.food, items: timeBlock.foods)
            }

            if !timeBlock.supplements.isEmpty {
                categorySection(NutritionItemCategory.supplement, items: timeBlock.supplements)
            }

            if !timeBlock.rituals.isEmpty {
                categorySection(NutritionItemCategory.ritual, items: timeBlock.rituals)
            }
        }
        .warmCard()
    }

    private func categorySection(_ category: NutritionItemCategory, items: [NutritionItem]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundStyle(accentColor.opacity(0.7))
                    .frame(width: 16)

                Text(category.displayName)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            }

            ForEach(items) { item in
                NutritionCheckItem(
                    item: item,
                    isCompleted: isItemCompleted(item),
                    accentColor: accentColor,
                    onToggle: { onToggle(item) }
                )
                .padding(.leading, 20)
            }
        }
    }
}
