import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step = 0
    @State private var selectedGoal: WellnessGoal?
    @State private var cycleLength = 28
    @State private var periodLength = 5
    @State private var lastPeriodDate = Date()

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                switch step {
                case 0:
                    welcomeStep
                case 1:
                    wellnessGoalStep
                case 2:
                    cycleLengthStep
                case 3:
                    lastPeriodStep
                default:
                    EmptyView()
                }

                Spacer()

                // Navigation
                HStack(spacing: AppTheme.Spacing.md) {
                    if step > 0 {
                        GentleOutlineButton("Back") {
                            withAnimation(AppTheme.gentleAnimation) {
                                step -= 1
                            }
                        }
                    }

                    Spacer()

                    if step < 3 {
                        GentleButton("Next", color: .appRose) {
                            withAnimation(AppTheme.gentleAnimation) {
                                step += 1
                            }
                        }
                    } else {
                        GentleButton("Begin My Journey", color: .appRose) {
                            completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appRose)

            Text("Welcome")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color.appSoftBrown)

            Text("Your body has its own rhythm.\nLet's learn to listen together.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            Text("One day. One state.\nOne clear orientation.")
                .affirmationStyle()
                .multilineTextAlignment(.center)
                .padding(.top, AppTheme.Spacing.sm)
        }
    }

    private var wellnessGoalStep: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appRose)

            Text("Your Wellness Goal")
                .warmTitle()

            Text("What brings you here? This helps us tailor your guidance.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ForEach(WellnessGoal.allCases) { goal in
                    goalCard(goal)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    private func goalCard(_ goal: WellnessGoal) -> some View {
        let isSelected = selectedGoal == goal

        return Button {
            withAnimation(AppTheme.gentleAnimation) {
                selectedGoal = goal
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : goal.color)

                Text(goal.displayName)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .background(isSelected ? goal.color : goal.color.opacity(0.08))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
        }
    }

    private var cycleLengthStep: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 48))
                .foregroundStyle(Color.appSage)

            Text("Your Cycle")
                .warmTitle()

            Text("Don't worry about being exact. We can adjust this anytime.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            CycleLengthSettingView(
                cycleLength: $cycleLength,
                periodLength: $periodLength
            )
            .warmCard()
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    private var lastPeriodStep: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appTerracotta)

            Text("Last Period")
                .warmTitle()

            Text("When did your last period start? An estimate is perfectly fine.")
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            DatePicker(
                "Last period start date",
                selection: $lastPeriodDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.appRose)
            .warmCard()
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    // MARK: - Actions

    private func completeOnboarding() {
        let profile = UserProfile(
            cycleLength: cycleLength,
            periodLength: periodLength,
            lastPeriodStartDate: lastPeriodDate,
            hasCompletedOnboarding: true,
            wellnessGoal: selectedGoal
        )
        modelContext.insert(profile)
        try? modelContext.save()
        onComplete()
    }
}
