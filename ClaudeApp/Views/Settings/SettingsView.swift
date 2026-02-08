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
