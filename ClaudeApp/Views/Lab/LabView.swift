import SwiftUI

struct LabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Settings — highlighted at top
                    NavigationLink {
                        SettingsView()
                    } label: {
                        settingsRow
                    }
                    .buttonStyle(.plain)

                    // Lab items
                    ForEach(LabItem.allCases) { item in
                        NavigationLink(value: item) {
                            labRow(item)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: LabItem.self) { item in
                item.destination
            }
        }
    }

    private var settingsRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundStyle(Color.appRose)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Settings")
                    .warmHeadline()
                Text("Life stage, protocols, theme, and devices")
                    .captionStyle()
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.appRose.opacity(0.06))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))
        .overlay(
            SoftRoundedRectangle(radius: AppTheme.Radius.lg)
                .stroke(Color.appRose.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func labRow(_ item: LabItem) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: item.icon)
                .font(.title2)
                .foregroundStyle(item.iconColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.title)
                    .warmHeadline()
                Text(item.subtitle)
                    .captionStyle()
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
