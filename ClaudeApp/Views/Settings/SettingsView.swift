import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationService.self) private var authService
    @Query private var profiles: [UserProfile]
    @AppStorage("appColorTheme") private var selectedTheme = "classic"
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
                        cycleLengthCard(profile)
                        wellnessGoalCard(profile)
                        nutritionProtocolCard(profile)
                    }

                    // Theme
                    themeCard

                    // Health devices
                    DeviceLinkingCard()

                    // Cloud backup
                    backupCard

                    // About
                    aboutCard

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

    private var themeCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(Color.appRose)
                Text("Color Theme")
                    .warmHeadline()
            }

            HStack(spacing: 0) {
                // Auto option
                let autoSelected = selectedTheme == "auto"
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        selectedTheme = "auto"
                    }
                } label: {
                    VStack(spacing: 6) {
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
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                        Text("Auto")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
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
                        VStack(spacing: 6) {
                            Circle()
                                .fill(theme.previewColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.appSoftBrown, lineWidth: isSelected ? 2.5 : 0)
                                )
                                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                            Text(theme.displayName)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
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
                Image(systemName: isSignedIn ? "checkmark.icloud.fill" : "icloud.fill")
                    .foregroundStyle(isSignedIn ? Color.appSage : Color.appSoftBrown.opacity(0.4))
                Text("Cloud Backup")
                    .warmHeadline()
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
                        .font(.system(.caption, design: .rounded, weight: .medium))
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
                            .font(.system(.caption, design: .rounded, weight: .medium))
                    }
                    .foregroundStyle(Color.appRose)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
