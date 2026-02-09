import SwiftUI

struct NutritionGuidanceCard: View {
    let guidance: NutritionGuidance
    let phase: CyclePhase

    @State private var expandedSection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Today's focus
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(phase.accentColor)
                    Text("Today's Focus")
                        .warmHeadline()
                }

                Text(guidance.todayFocus)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Expandable sections
            VStack(spacing: 0) {
                listSection(
                    title: "Recommended Foods",
                    icon: "fork.knife",
                    items: guidance.foods
                )
                listSection(
                    title: "Supplements",
                    icon: "pill.fill",
                    items: guidance.supplements
                )
                listSection(
                    title: "Foods to Avoid",
                    icon: "xmark.circle",
                    items: guidance.avoid
                )
                textSection(
                    title: "Meal Timing",
                    icon: "clock.fill",
                    content: guidance.mealTiming
                )
                textSection(
                    title: "Why This Works",
                    icon: "lightbulb.fill",
                    content: guidance.rationale
                )
            }
        }
        .warmCard()
    }

    private func listSection(title: String, icon: String, items: [String]) -> some View {
        let isExpanded = expandedSection == title

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    expandedSection = isExpanded ? nil : title
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(phase.accentColor)
                        .frame(width: 24)

                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)

                    Spacer()

                    Text("\(items.count)")
                        .captionStyle()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            }

            VStack(spacing: 0) {
                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(items, id: \.self) { item in
                            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                                Circle()
                                    .fill(phase.accentColor.opacity(0.5))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                Text(item)
                                    .guidanceText()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.sm)
                    .padding(.leading, 32)
                    .transition(.opacity)
                }
            }
            .clipped()

            Divider()
                .overlay(phase.accentColor.opacity(0.1))
        }
    }

    private func textSection(title: String, icon: String, content: String) -> some View {
        let isExpanded = expandedSection == title

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    expandedSection = isExpanded ? nil : title
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(phase.accentColor)
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
                .overlay(phase.accentColor.opacity(0.1))
        }
    }
}
