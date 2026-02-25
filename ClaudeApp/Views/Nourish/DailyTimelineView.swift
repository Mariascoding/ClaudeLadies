import SwiftUI

struct DailyTimelineView: View {
    let plan: DailyNutritionPlan
    let phase: CyclePhase
    let viewModel: NourishViewModel

    @State private var showAvoidSection = false

    private var totalItems: Int { plan.totalItemCount }
    private var completedItems: Int { viewModel.totalCompletedCount }
    private var progress: Double {
        totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Today's focus header
            focusCard

            // Progress bar
            progressCard

            // Timeline blocks
            ForEach(plan.timeBlocks) { block in
                TimeBlockCard(
                    timeBlock: block,
                    accentColor: phase.accentColor,
                    completedCount: viewModel.completedCount(for: block),
                    isItemCompleted: { viewModel.isItemCompleted($0) },
                    onToggle: { item in
                        withAnimation(AppTheme.gentleAnimation) {
                            viewModel.toggleItem(item)
                        }
                    }
                )
            }

            // Avoid & rationale
            avoidSection
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Focus Card

    private var focusCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(phase.accentColor)
                Text("Today's Focus")
                    .warmHeadline()
            }

            Text(plan.todayFocus)
                .guidanceText()
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Daily Progress")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)

                Spacer()

                Text("\(completedItems) of \(totalItems)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(phase.accentColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(phase.accentColor.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(phase.accentColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(AppTheme.gentleAnimation, value: progress)
                }
            }
            .frame(height: 8)
        }
        .warmCard()
    }

    // MARK: - Avoid & Rationale

    private var avoidSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    showAvoidSection.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(phase.accentColor)
                        .frame(width: 24)

                    Text("Avoid & Why This Works")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)

                    Spacer()

                    Image(systemName: showAvoidSection ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
            }

            if showAvoidSection {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Avoid list
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Avoid")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.5))

                        ForEach(plan.avoid, id: \.self) { item in
                            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(phase.accentColor.opacity(0.5))
                                    .padding(.top, 2)

                                Text(item)
                                    .guidanceText()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    // Rationale
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why This Works")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.5))

                        Text(plan.rationale)
                            .guidanceText()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, AppTheme.Spacing.sm)
                .transition(.opacity)
            }
        }
        .warmCard()
    }
}
