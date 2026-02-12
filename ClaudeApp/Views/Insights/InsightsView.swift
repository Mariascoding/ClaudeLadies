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

                    // Period calendar
                    PeriodCalendarView(
                        cycleLogs: viewModel.cycleLogs,
                        cycleLength: viewModel.cycleLength,
                        periodLength: viewModel.periodLength,
                        expectedNextPeriodStart: viewModel.expectedNextPeriodStart,
                        delayDays: viewModel.delayDays,
                        lastPeriodStartDate: viewModel.lastPeriodStartDate,
                        phaseBoundaries: viewModel.phaseBoundaries,
                        onAddPeriod: { date in
                            viewModel.addPeriod(on: date)
                        },
                        onExtendPeriod: { date in
                            viewModel.extendPeriod(to: date)
                        },
                        onRemovePeriod: { date in
                            viewModel.removePeriod(containing: date)
                        },
                        onAddOvulation: { date in
                            viewModel.addOvulation(on: date)
                        },
                        onRemoveOvulation: { date in
                            viewModel.removeOvulation(on: date)
                        },
                        manualOvulationDates: viewModel.manualOvulationDates,
                        canExtendPeriod: { date in
                            viewModel.nearestExtendableLog(for: date) != nil
                        },
                        canRemovePeriod: { date in
                            viewModel.logContaining(date: date) != nil
                        },
                        isManualOvulation: { date in
                            viewModel.isManualOvulation(date)
                        }
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
            .onReceive(NotificationCenter.default.publisher(for: .cycleDataDidChange)) { _ in
                viewModel.refresh()
            }
        }
    }
}
