import SwiftUI

struct PhaseInfoCard: View {
    let description: PhaseDescription

    @State private var expandedSection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                PhaseIcon(phase: description.phase)
                VStack(alignment: .leading, spacing: 2) {
                    Text(description.title)
                        .warmHeadline()
                    Text(description.innerSeason)
                        .captionStyle()
                }
            }

            Text(description.overview)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                infoSection(
                    title: "Hormones",
                    icon: "waveform.path",
                    content: description.hormoneHighlight
                )
                infoSection(
                    title: "Your Superpower",
                    icon: "star.fill",
                    content: description.superpower
                )
                infoSection(
                    title: "Nourishment",
                    icon: "fork.knife",
                    content: description.nourishment
                )
                infoSection(
                    title: "Movement",
                    icon: "figure.walk",
                    content: description.movement
                )
            }
        }
        .warmCard()
    }

    private func infoSection(title: String, icon: String, content: String) -> some View {
        let isExpanded = expandedSection == title

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    expandedSection = isExpanded ? nil : title
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(description.phase.accentColor)
                        .frame(width: 24)

                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            }

            VStack(spacing: 0) {
                if isExpanded {
                    Text(content)
                        .guidanceText()
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, AppTheme.Spacing.sm)
                        .padding(.leading, 32)
                        .transition(.opacity)
                }
            }
            .clipped()

            Divider()
                .overlay(description.phase.accentColor.opacity(0.1))
        }
    }
}
