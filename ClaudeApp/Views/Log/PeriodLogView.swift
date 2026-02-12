import SwiftUI

struct PeriodLogView: View {
    let isPeriodActive: Bool
    let onStart: (Date) -> Void
    let onEnd: () -> Void

    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: isPeriodActive ? "drop.fill" : "drop")
                    .foregroundStyle(Color.appRose)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isPeriodActive ? "Period Active" : "Period")
                        .warmHeadline()

                    Text(isPeriodActive ? "Tap to mark the end of your period" : "When did your period start?")
                        .captionStyle()
                }

                Spacer()
            }

            if isPeriodActive {
                GentleButton("My period ended", color: .appRose.opacity(0.7), action: onEnd)
            } else if showDatePicker {
                VStack(spacing: AppTheme.Spacing.sm) {
                    DatePicker(
                        "Start date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.appRose)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        GentleOutlineButton("Cancel", color: .appSoftBrown) {
                            withAnimation(AppTheme.gentleAnimation) {
                                showDatePicker = false
                            }
                        }

                        GentleButton("Confirm", color: .appRose) {
                            onStart(selectedDate)
                            withAnimation(AppTheme.gentleAnimation) {
                                showDatePicker = false
                            }
                        }
                    }
                }
            } else {
                GentleButton("My period started", color: .appRose) {
                    selectedDate = Date()
                    withAnimation(AppTheme.gentleAnimation) {
                        showDatePicker = true
                    }
                }
            }
        }
        .warmCard()
    }
}
