import SwiftUI

struct DailyTimelineView: View {
    let plan: DailyNutritionPlan
    let phase: CyclePhase
    let viewModel: NourishViewModel

    @State private var showAvoidSection = false

    private var mergedPlan: DailyNutritionPlan {
        viewModel.mergedPlan(plan)
    }

    private var totalItems: Int { mergedPlan.totalItemCount }
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
            ForEach(mergedPlan.timeBlocks) { block in
                TimeBlockCard(
                    timeBlock: block,
                    accentColor: phase.accentColor,
                    completedCount: viewModel.completedCount(for: block),
                    isItemCompleted: { viewModel.isItemCompleted($0) },
                    onToggle: { item in
                        withAnimation(AppTheme.gentleAnimation) {
                            viewModel.toggleItem(item)
                        }
                    },
                    onDismiss: { item in
                        withAnimation(AppTheme.gentleAnimation) {
                            viewModel.dismissProtocolItem(item)
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
            Capsule()
                .fill(phase.accentColor.opacity(0.4))
                .frame(width: 32, height: 3)

            Text("Today's Focus")
                .sectionLabel(color: phase.accentColor)

            Text(plan.todayFocus)
                .serifBody()
                .fixedSize(horizontal: false, vertical: true)

            // Late period guidance
            if let lateNote = viewModel.latePeriodFocusNote {
                Capsule()
                    .fill(Color.appRose.opacity(0.3))
                    .frame(width: 24, height: 2)
                    .padding(.top, AppTheme.Spacing.xs)

                Text(lateNote)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.appRose.opacity(0.85))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Progress")
                    .sectionLabel()

                Spacer()

                Text("\(completedItems) of \(totalItems)")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
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
                    Text("Avoid & Rationale")
                        .sectionLabel()

                    Spacer()

                    Image(systemName: showAvoidSection ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.3))
                }
            }

            if showAvoidSection {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Avoid")
                            .sectionLabel(color: phase.accentColor)

                        ForEach(plan.avoid, id: \.self) { item in
                            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                                Circle()
                                    .fill(phase.accentColor.opacity(0.4))
                                    .frame(width: 4, height: 4)
                                    .padding(.top, 7)

                                Text(item)
                                    .serifBody()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why This Works")
                            .sectionLabel(color: phase.accentColor)

                        Text(plan.rationale)
                            .serifBody()
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
