import SwiftUI

struct LabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
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
            .navigationTitle("Lab")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: LabItem.self) { item in
                item.destination
            }
        }
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
