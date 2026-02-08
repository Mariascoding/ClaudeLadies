import SwiftUI

struct NervousSystemGuidanceView: View {
    let guidance: NervousSystemGuidance

    @State private var expandedSection: Section?

    private enum Section: String, CaseIterable {
        case breathwork = "Breathwork"
        case somatic = "Somatic Exercise"
        case grounding = "Grounding"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: guidance.state.icon)
                    .foregroundStyle(guidance.state.color)
                Text("Nervous System Support")
                    .warmHeadline()
            }

            // Affirmation
            Text("\"\(guidance.affirmation)\"")
                .affirmationStyle()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppTheme.Spacing.sm)

            // Expandable sections
            ForEach(Section.allCases, id: \.rawValue) { section in
                expandableSection(section)
            }
        }
        .warmCard()
    }

    @ViewBuilder
    private func expandableSection(_ section: Section) -> some View {
        let isExpanded = expandedSection == section

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    expandedSection = isExpanded ? nil : section
                }
            } label: {
                HStack {
                    Image(systemName: sectionIcon(section))
                        .foregroundStyle(guidance.state.color)
                        .frame(width: 24)

                    Text(section.rawValue)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            }

            if isExpanded {
                sectionContent(section)
                    .padding(.top, AppTheme.Spacing.sm)
                    .padding(.bottom, AppTheme.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private func sectionContent(_ section: Section) -> some View {
        switch section {
        case .breathwork:
            BreathingAnimationView(exercise: guidance.breathwork)
        case .somatic:
            Text(guidance.somaticExercise)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)
        case .grounding:
            Text(guidance.groundingPrompt)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionIcon(_ section: Section) -> String {
        switch section {
        case .breathwork: "wind"
        case .somatic: "figure.mind.and.body"
        case .grounding: "mountain.2.fill"
        }
    }
}
