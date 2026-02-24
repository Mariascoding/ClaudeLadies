import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LogViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Period tracking
                    PeriodLogView(
                        isPeriodActive: viewModel.isPeriodActive,
                        onStart: { date in viewModel.startPeriod(on: date) },
                        onEnd: { viewModel.endPeriod() }
                    )
                    .padding(.horizontal, AppTheme.Spacing.md)

                    // Day log summary
                    DayLogSummary(symptoms: viewModel.todaySymptoms, tags: viewModel.todayTags)
                        .padding(.horizontal, AppTheme.Spacing.md)

                    // Symptom picker
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "heart.text.square")
                                .foregroundStyle(Color.appRose)
                            Text("How are you feeling?")
                                .warmHeadline()
                        }

                        SymptomPickerView(
                            selectedSymptoms: viewModel.todaySymptoms,
                            onToggle: { symptom in
                                withAnimation(AppTheme.gentleAnimation) {
                                    viewModel.toggleSymptom(symptom)
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .warmCard()
                    .padding(.horizontal, AppTheme.Spacing.md)

                    // Custom tags
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "tag")
                                .foregroundStyle(Color.appTerracotta)
                            Text("Custom Tags")
                                .warmHeadline()
                        }

                        TagInputView(
                            currentTags: viewModel.todayTags,
                            suggestions: viewModel.allKnownTags,
                            onAdd: { tag in
                                withAnimation(AppTheme.gentleAnimation) {
                                    viewModel.addTag(tag)
                                }
                            },
                            onRemove: { tag in
                                withAnimation(AppTheme.gentleAnimation) {
                                    viewModel.removeTag(tag)
                                }
                            }
                        )
                    }
                    .warmCard()
                    .padding(.horizontal, AppTheme.Spacing.md)

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Log")
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
