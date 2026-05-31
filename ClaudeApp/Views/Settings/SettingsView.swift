import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationService.self) private var authService
    @Query private var profiles: [UserProfile]
    @AppStorage("appColorTheme") private var selectedTheme = "classic"
    @AppStorage("devConsoleEnabled") private var devConsoleEnabled = false
    @State private var showSignIn = false

    private var profile: UserProfile? { profiles.first }

    private var isSignedIn: Bool {
        if case .authenticated = authService.state { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Cycle settings
                    if let profile {
                        if profile.wellnessGoal == .prenatal {
                            pregnancyDateCard(profile)
                        } else if profile.wellnessGoal == .menopause {
                            menopauseDateCard(profile)
                        } else {
                            cycleLengthCard(profile)
                        }
                        wellnessGoalCard(profile)
                        dietaryPreferenceCard(profile)
                        if profile.wellnessGoal != .prenatal && profile.wellnessGoal != .menopause {
                            nutritionProtocolCard(profile)
                        }
                    }

                    // Theme
                    themeCard

                    // Health devices
                    DeviceLinkingCard()

                    // Cloud backup
                    backupCard

                    // About
                    aboutCard

                    // Developer
                    developerCard

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSignIn) {
                AuthenticationView(onDismiss: { showSignIn = false })
                    .environment(authService)
            }
        }
    }

    private func pregnancyDateCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Pregnancy")
                .sectionLabel(color: Color.appRose)

            DatePicker(
                "Pregnancy started",
                selection: Binding(
                    get: { profile.pregnancyStartDate ?? Date() },
                    set: {
                        profile.pregnancyStartDate = $0
                        try? modelContext.save()
                    }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .font(.system(.body, design: AppTheme.fontFamily))
            .tint(Color.appRose)

            if let start = profile.pregnancyStartDate {
                let pos = PregnancyCalculator.currentPosition(pregnancyStart: start)
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text("Week \(pos.week)")
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appRose)
                    Text("·")
                        .foregroundStyle(Color.appSoftBrown.opacity(0.3))
                    Text("Due \(pos.dueDate, format: .dateTime.day().month(.abbreviated).year())")
                        .captionStyle()
                }
            }

            Text("Set the date your pregnancy began or your last menstrual period. This replaces cycle tracking while in prenatal mode.")
                .captionStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func menopauseDateCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Menopause")
                .sectionLabel(color: Color.appTerracotta)

            DatePicker(
                "Last bleed started",
                selection: Binding(
                    get: { profile.menopauseLastBleedDate ?? Date() },
                    set: {
                        profile.menopauseLastBleedDate = $0
                        try? modelContext.save()
                    }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .font(.system(.body, design: AppTheme.fontFamily))
            .tint(Color.appTerracotta)

            if let lastBleed = profile.menopauseLastBleedDate {
                let pos = MenopauseCalculator.currentPosition(lastBleedDate: lastBleed)
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(pos.phase.displayName)
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appTerracotta)
                    Text("·")
                        .foregroundStyle(Color.appSoftBrown.opacity(0.3))
                    Text("\(pos.daysSinceLastBleed) days since last bleed")
                        .captionStyle()
                }
            }

            Text("Your body still follows a hormonal rhythm. We use your last bleed date to align nutrition with your natural cycle — supporting the hormones your body needs most.")
                .captionStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
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
            Text("Life Stage")
                .sectionLabel(color: Color.appRose)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ForEach(WellnessGoal.allCases) { goal in
                    let isSelected = profile.wellnessGoal == goal
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            profile.wellnessGoal = goal
                            try? modelContext.save()
                        }
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: goal.icon)
                                .font(.body)
                                .foregroundStyle(isSelected ? .white : goal.color)
                            Text(goal.displayName)
                                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
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

    private func dietaryPreferenceCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Dietary Preference")
                .sectionLabel(color: profile.dietaryPreference.color)

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(DietaryPreference.allCases) { pref in
                    let isSelected = profile.dietaryPreference == pref
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            profile.dietaryPreference = pref
                            try? modelContext.save()
                        }
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: pref.icon)
                                .font(.body)
                                .foregroundStyle(isSelected ? .white : pref.color)
                            Text(pref.displayName)
                                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(isSelected ? pref.color : pref.color.opacity(0.08))
                        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
                    }
                }
            }

            Text("Food suggestions adapt automatically to your preference.")
                .captionStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func nutritionProtocolCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Protocol")
                .sectionLabel(color: Color.appSage)

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NutritionProtocol.allCases) { nutritionProtocol in
                    let isSelected = profile.nutritionProtocol == nutritionProtocol
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            if isSelected {
                                profile.nutritionProtocol = .daoSt
                            } else {
                                profile.nutritionProtocol = nutritionProtocol
                            }
                            try? modelContext.save()
                        }
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: nutritionProtocol.icon)
                                .font(.title3)
                                .foregroundStyle(isSelected ? .white : nutritionProtocol.color)
                            Text(nutritionProtocol.displayName)
                                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
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

            Text("Tap a selected protocol to return to DAO Support.")
                .captionStyle()
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var themeCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Color Theme")
                .sectionLabel(color: Color.appRose)

            HStack(spacing: 0) {
                // Auto option
                let autoSelected = selectedTheme == "auto"
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        selectedTheme = "auto"
                    }
                } label: {
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [
                                        ColorTheme.winter.previewColor,
                                        ColorTheme.spring.previewColor,
                                        ColorTheme.summer.previewColor,
                                        ColorTheme.autumn.previewColor,
                                        ColorTheme.winter.previewColor
                                    ],
                                    center: .center
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.appSoftBrown, lineWidth: autoSelected ? 2.5 : 0)
                            )
                            .shadow(color: AppTheme.softShadow, radius: AppTheme.softShadowRadius, y: AppTheme.softShadowY)
                        Text("Auto")
                            .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(autoSelected ? Color.appSoftBrown : Color.appSoftBrown.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }

                // Manual themes
                ForEach(ColorTheme.allCases) { theme in
                    let isSelected = selectedTheme == theme.rawValue
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            selectedTheme = theme.rawValue
                        }
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Circle()
                                .fill(theme.previewColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.appSoftBrown, lineWidth: isSelected ? 2.5 : 0)
                                )
                                .shadow(color: AppTheme.softShadow, radius: AppTheme.softShadowRadius, y: AppTheme.softShadowY)
                            Text(theme.displayName)
                                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                                .foregroundStyle(isSelected ? Color.appSoftBrown : Color.appSoftBrown.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var backupCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text("Cloud Backup")
                    .sectionLabel(color: isSignedIn ? Color.appSage : Color.appSoftBrown.opacity(0.4))
            }

            if isSignedIn {
                if let email = authService.currentUserEmail {
                    Text("Signed in as \(email)")
                        .captionStyle()
                }

                Button {
                    Task { await authService.signOut() }
                } label: {
                    Text("Sign Out")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                }
            } else {
                Text("Sign in to back up your data and keep your history safe across devices.")
                    .captionStyle()

                Button {
                    showSignIn = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "person.crop.circle")
                            .font(.caption)
                        Text("Sign In")
                            .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    }
                    .foregroundStyle(Color.appRose)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var developerCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Toggle(isOn: $devConsoleEnabled) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text("Developer Console")
                        .sectionLabel(color: Color.appTerracotta)
                }
            }
            .tint(Color.appTerracotta)

            Text("Live theme editor for colors, typography, spacing, radius, and shadows.")
                .captionStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text("About")
                    .sectionLabel(color: Color.appRose)
            }

            Text("This app is your daily companion for understanding your cycle and nurturing your wellbeing. All data stays on your device.")
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            Text("One day. One state. One clear orientation.")
                .affirmationStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
