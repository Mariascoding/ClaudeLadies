import SwiftUI

struct TimeBlockCard: View {
    let timeBlock: TimeBlock
    let accentColor: Color
    let completedCount: Int
    let isItemCompleted: (NutritionItem) -> Bool
    let onToggle: (NutritionItem) -> Void
    var onDismiss: ((NutritionItem) -> Void)?

    @State private var showFoods = false

    private var foodCompletedCount: Int {
        timeBlock.foods.filter { isItemCompleted($0) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: timeBlock.timeOfDay.icon)
                    .font(.body)
                    .foregroundStyle(accentColor.opacity(0.7))

                Text(timeBlock.timeOfDay.displayName)
                    .sectionLabel(color: accentColor)

                Text(timeBlock.timeOfDay.timeHint)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.35))

                Spacer()

                Text("\(completedCount)/\(timeBlock.totalCount)")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(completedCount == timeBlock.totalCount && timeBlock.totalCount > 0 ? accentColor : Color.appSoftBrown.opacity(0.35))
            }

            // Supplements — always visible
            if !timeBlock.supplements.isEmpty {
                categorySection(.supplement, items: timeBlock.supplements)
            }

            // Rituals — always visible
            if !timeBlock.rituals.isEmpty {
                categorySection(.ritual, items: timeBlock.rituals)
            }

            // Foods — collapsed by default
            if !timeBlock.foods.isEmpty {
                foodsCollapsibleSection
            }
        }
        .warmCard()
    }

    // MARK: - Foods (collapsible)

    private var foodsCollapsibleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    showFoods.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: NutritionItemCategory.food.icon)
                        .font(.caption2)
                        .foregroundStyle(accentColor.opacity(0.5))

                    Text(NutritionItemCategory.food.displayName)
                        .sectionLabel()

                    if !showFoods {
                        Text("\(foodCompletedCount)/\(timeBlock.foods.count)")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.3))
                    }

                    Spacer()

                    Image(systemName: showFoods ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.25))
                }
            }

            if showFoods {
                ForEach(timeBlock.foods) { item in
                    NutritionCheckItem(
                        item: item,
                        isCompleted: isItemCompleted(item),
                        accentColor: accentColor,
                        onToggle: { onToggle(item) },
                        onDismiss: item.isPersonal ? nil : (onDismiss != nil ? { onDismiss?(item) } : nil)
                    )
                    .padding(.leading, AppTheme.Spacing.lg)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Category Section (supplements, rituals)

    private func categorySection(_ category: NutritionItemCategory, items: [NutritionItem]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption2)
                    .foregroundStyle(accentColor.opacity(0.5))

                Text(category.displayName)
                    .sectionLabel()
            }

            ForEach(items) { item in
                NutritionCheckItem(
                    item: item,
                    isCompleted: isItemCompleted(item),
                    accentColor: accentColor,
                    onToggle: { onToggle(item) },
                    onDismiss: item.isPersonal ? nil : (onDismiss != nil ? { onDismiss?(item) } : nil)
                )
                .padding(.leading, AppTheme.Spacing.lg)
            }
        }
    }
}
