import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Cycle settings
                    if let profile {
                        cycleLengthCard(profile)
                        wellnessGoalCard(profile)
                        nutritionProtocolCard(profile)
                    }

                    // About
                    aboutCard

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func cycleLengthCard(_ profile: UserProfile) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            CycleLengthSettingView(
                cycleLength: Binding(
                    get: { profile.cycleLength },
                    set: { profile.cycleLength = $0; try? modelContext.save() }
                ),
                periodLength: Binding(
                    get: { profile.periodLength },
                    set: { profile.periodLength = $0; try? modelContext.save() }
                )
            )
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func wellnessGoalCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.circle.fill")
                    .foregroundStyle(Color.appRose)
                Text("Wellness Goal")
                    .warmHeadline()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ForEach(WellnessGoal.allCases) { goal in
                    let isSelected = profile.wellnessGoal == goal
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            profile.wellnessGoal = goal
                            try? modelContext.save()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: goal.icon)
                                .font(.body)
                                .foregroundStyle(isSelected ? .white : goal.color)
                            Text(goal.displayName)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(isSelected ? goal.color : goal.color.opacity(0.08))
                        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
                    }
                }
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func nutritionProtocolCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.appSage)
                Text("Nutrition Protocol")
                    .warmHeadline()
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NutritionProtocol.allCases) { nutritionProtocol in
                    let isSelected = profile.nutritionProtocol == nutritionProtocol
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            if isSelected {
                                profile.nutritionProtocol = nil
                            } else {
                                profile.nutritionProtocol = nutritionProtocol
                            }
                            try? modelContext.save()
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: nutritionProtocol.icon)
                                .font(.title3)
                                .foregroundStyle(isSelected ? .white : nutritionProtocol.color)
                            Text(nutritionProtocol.displayName)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(isSelected ? nutritionProtocol.color : nutritionProtocol.color.opacity(0.08))
                        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
                    }
                }
            }

            Text("Tap a selected protocol again to deselect.")
                .captionStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.appRose)
                Text("About")
                    .warmHeadline()
            }

            Text("This app is your daily companion for understanding your cycle and nurturing your wellbeing. All data stays on your device.")
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            Text("One day. One state. One clear orientation.")
                .affirmationStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
