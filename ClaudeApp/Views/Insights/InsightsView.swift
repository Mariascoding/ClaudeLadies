import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Cycle timeline
                    CycleTimelineView(
                        boundaries: viewModel.phaseBoundaries,
                        currentDay: viewModel.dayInCycle,
                        cycleLength: viewModel.cycleLength
                    )
                    .padding(.horizontal, AppTheme.Spacing.md)

                    // Phase education
                    if let phaseDesc = viewModel.phaseDescription {
                        PhaseInfoCard(description: phaseDesc)
                            .padding(.horizontal, AppTheme.Spacing.md)
                    }

                    // Symptom patterns
                    SymptomPatternView(frequencies: viewModel.symptomFrequencies)
                        .padding(.horizontal, AppTheme.Spacing.md)

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.load(modelContext: modelContext)
            }
        }
    }
}
