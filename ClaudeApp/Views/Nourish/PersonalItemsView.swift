import SwiftUI
import SwiftData

struct PersonalItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PersonalItem.name) private var items: [PersonalItem]

    @State private var newName = ""
    @State private var newCategory: NutritionItemCategory = .supplement
    @State private var newTimeOfDay: TimeOfDay = .morning

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    addItemCard
                    currentItemsCard
                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("My Supplements & Routines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appSoftBrown)
                }
            }
        }
    }

    // MARK: - Add Item

    private var addItemCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.appSage)
                Text("Add Item")
                    .sectionLabel()
            }

            // Category picker
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach([NutritionItemCategory.supplement, .ritual, .food], id: \.rawValue) { cat in
                    let isSelected = newCategory == cat
                    Button {
                        withAnimation(AppTheme.gentleAnimation) { newCategory = cat }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cat.icon)
                                .font(.caption)
                            Text(cat == .food ? "Food" : cat == .supplement ? "Supplement" : "Ritual")
                                .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        }
                        .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(isSelected ? Color.appSage : Color.appSage.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }

            // Time of day picker
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(TimeOfDay.allCases) { time in
                    let isSelected = newTimeOfDay == time
                    Button {
                        withAnimation(AppTheme.gentleAnimation) { newTimeOfDay = time }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: time.icon)
                                .font(.caption)
                            Text(time.displayName)
                                .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        }
                        .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(isSelected ? Color.appSoftBrown : Color.appSoftBrown.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }

            // Name input + add button
            HStack(spacing: AppTheme.Spacing.sm) {
                TextField(placeholder, text: $newName)
                    .font(.system(.body, design: AppTheme.fontFamilySerif))
                    .textFieldStyle(.plain)
                    .padding(AppTheme.Spacing.sm)
                    .background(Color.appSoftBrown.opacity(0.05))
                    .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))

                Button {
                    addItem()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(newName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.appSoftBrown.opacity(0.2) : Color.appSage)
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var placeholder: String {
        switch newCategory {
        case .supplement: "e.g. Vitamin D, Magnesium..."
        case .ritual: "e.g. Morning walk, Evening yoga..."
        case .food: "e.g. Green smoothie, Bone broth..."
        }
    }

    private func addItem() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let item = PersonalItem(name: trimmed, category: newCategory, timeOfDay: newTimeOfDay)
        modelContext.insert(item)
        try? modelContext.save()
        newName = ""
    }

    // MARK: - Current Items

    private var currentItemsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(Color.appSoftBrown)
                Text("Current Routine")
                    .sectionLabel()
            }

            if items.isEmpty {
                Text("No supplements or routines added yet. Your personal items will appear in every protocol plan alongside the recommended additions.")
                    .captionStyle()
            } else {
                ForEach(TimeOfDay.allCases) { time in
                    let timeItems = items.filter { $0.timeOfDay == time }
                    if !timeItems.isEmpty {
                        timeSection(time: time, items: timeItems)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func timeSection(time: TimeOfDay, items: [PersonalItem]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: time.icon)
                    .font(.caption)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                Text(time.displayName)
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            }

            ForEach(items) { item in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: item.category.icon)
                        .font(.caption)
                        .foregroundStyle(Color.appSage.opacity(0.7))
                        .frame(width: 16)

                    Text(item.name)
                        .font(.system(.body, design: AppTheme.fontFamilySerif))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.85))

                    Spacer()

                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            modelContext.delete(item)
                            try? modelContext.save()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appSoftBrown.opacity(0.25))
                    }
                }
                .padding(.vertical, 2)
                .padding(.leading, AppTheme.Spacing.lg)
            }
        }
    }
}
