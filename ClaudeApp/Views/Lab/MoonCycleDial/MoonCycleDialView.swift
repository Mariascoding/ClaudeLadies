import SwiftUI

struct MoonCycleDialView: View {
    @StateObject private var moonState = MoonState()
    @State private var dayInCycle: Double = 1
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5

    private var currentLunarPhase: LunarPhase {
        LunarPhase.from(moonPhase: moonState.moonPhase)
    }

    private var currentCyclePhase: CyclePhase {
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: Int(cycleLength),
            periodLength: Int(periodLength)
        )
        let day = Int(dayInCycle)
        return boundaries.first(where: { day >= $0.startDay && day <= $0.endDay })?.phase ?? .menstrual
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Dial
                CycleDialView(
                    moonPhase: moonState.moonPhase,
                    dayInCycle: dayInCycle,
                    cycleLength: Int(cycleLength),
                    periodLength: Int(periodLength)
                )
                .animation(AppTheme.gentleAnimation, value: moonState.moonPhase)
                .animation(AppTheme.gentleAnimation, value: dayInCycle)
                .padding(.top, AppTheme.Spacing.sm)

                // Phase labels
                phaseLabels

                // Moon Phase slider
                moonSliderCard

                // Cycle Day slider + stepper
                cycleSliderCard

                // Alignment gauge (tap for wisdom)
                MoonAlignmentGaugeView(
                    moonPhase: moonState.moonPhase,
                    dayInCycle: Int(dayInCycle),
                    cycleLength: Int(cycleLength),
                    periodLength: Int(periodLength)
                )
                .animation(AppTheme.gentleAnimation, value: moonState.moonPhase)
                .animation(AppTheme.gentleAnimation, value: dayInCycle)

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Moon & Cycle")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            moonState.moonPhase = 0.5
            withAnimation(.easeInOut(duration: 0.4)) {
                moonState.isLoaded = true
            }
        }
    }

    // MARK: - Phase Labels

    private var phaseLabels: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: currentLunarPhase.icon)
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.55))
                Text(currentLunarPhase.displayName)
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }

            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: currentCyclePhase.icon)
                    .font(.title3)
                    .foregroundStyle(currentCyclePhase.accentColor)
                Text("Day \(Int(dayInCycle)) \u{2022} \(currentCyclePhase.displayName)")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }
        }
        .padding(.bottom, AppTheme.Spacing.xs)
    }

    // MARK: - Moon Slider Card

    private var moonSliderCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.55))
                Text("Moon Phase")
                    .warmHeadline()
                Spacer()
                Text(String(format: "%.2f", moonState.moonPhase))
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
            }

            Slider(value: $moonState.moonPhase, in: 0...0.99, step: 0.01)
                .tint(Color(red: 0.92, green: 0.78, blue: 0.55))

            HStack {
                Text("New Moon")
                    .captionStyle()
                Spacer()
                Text("Full Moon")
                    .captionStyle()
                Spacer()
                Text("New Moon")
                    .captionStyle()
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Cycle Slider Card

    private var cycleSliderCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "circle.circle")
                    .foregroundStyle(Color.appRose)
                Text("Cycle Day")
                    .warmHeadline()
                Spacer()
                Text("Day \(Int(dayInCycle)) of \(Int(cycleLength))")
                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
            }

            Slider(value: $dayInCycle, in: 1...cycleLength, step: 1)
                .tint(Color.appRose)

            HStack {
                Text("Day 1")
                    .captionStyle()
                Spacer()
                Text("Day \(Int(cycleLength))")
                    .captionStyle()
            }

            Divider()
                .background(Color.appSoftBrown.opacity(0.15))

            // Cycle length stepper
            HStack {
                Text("Cycle Length")
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)

                Spacer()

                HStack(spacing: AppTheme.Spacing.md) {
                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            cycleLength = max(21, cycleLength - 1)
                            dayInCycle = min(dayInCycle, cycleLength)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(cycleLength <= 21 ? Color.appSoftBrown.opacity(0.3) : Color.appRose)
                    }
                    .disabled(cycleLength <= 21)

                    Text("\(Int(cycleLength))")
                        .font(.system(.body, design: AppTheme.fontFamily, weight: .semibold))
                        .foregroundStyle(Color.appSoftBrown)
                        .frame(minWidth: 30)

                    Button {
                        withAnimation(AppTheme.gentleAnimation) {
                            cycleLength = min(40, cycleLength + 1)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(cycleLength >= 40 ? Color.appSoftBrown.opacity(0.3) : Color.appRose)
                    }
                    .disabled(cycleLength >= 40)
                }
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
