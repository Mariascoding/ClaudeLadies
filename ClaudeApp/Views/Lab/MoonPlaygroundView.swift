import SwiftUI

struct MoonPlaygroundView: View {
    @StateObject private var moonState = MoonState()

    private var phaseName: String {
        let phase = moonState.moonPhase
        switch phase {
        case 0..<0.02: return "New Moon"
        case 0.02..<0.23: return "Waxing Crescent"
        case 0.23..<0.27: return "First Quarter"
        case 0.27..<0.48: return "Waxing Gibbous"
        case 0.48..<0.52: return "Full Moon"
        case 0.52..<0.73: return "Waning Gibbous"
        case 0.73..<0.77: return "Last Quarter"
        case 0.77..<0.98: return "Waning Crescent"
        default: return "New Moon"
        }
    }

    private var illuminationPercent: Int {
        Int(MoonUtils.illumination(for: moonState.moonDay) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Moon Preview
                ZStack {
                    Color(red: 0.08, green: 0.1, blue: 0.18)
                        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))

                    MoonView(moonState: moonState)
                        .frame(height: 280)
                }
                .padding(.horizontal, AppTheme.Spacing.md)

                // Current Values
                valuesCard

                // Phase Slider
                sliderCard

                // Preset Buttons
                presetsCard

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Moon Phase")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            moonState.moonPhase = 0.5
            withAnimation(.easeInOut(duration: 0.4)) {
                moonState.isLoaded = true
            }
        }
    }

    private var valuesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.appSage)
                Text("Current Values")
                    .warmHeadline()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                valueCell(label: "Phase", value: String(format: "%.3f", moonState.moonPhase))
                valueCell(label: "Moon Day", value: "\(moonState.moonDay)")
                valueCell(label: "Illumination", value: "\(illuminationPercent)%")
                valueCell(label: "Phase Name", value: phaseName)
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func valueCell(label: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(label)
                .captionStyle()
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.appSoftBrown)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(Color.appSoftBrown.opacity(0.06))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
    }

    private var sliderCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color.appRose)
                Text("Phase Slider")
                    .warmHeadline()
            }

            Slider(value: $moonState.moonPhase, in: 0...1, step: 0.01)
                .tint(Color.appRose)

            HStack {
                Text("0.0")
                    .captionStyle()
                Spacer()
                Text("1.0")
                    .captionStyle()
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private var presetsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.appTerracotta)
                Text("Presets")
                    .warmHeadline()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                presetButton(label: "New Moon", icon: "moon.fill", phase: 0.0)
                presetButton(label: "First Quarter", icon: "moon.stars.fill", phase: 0.25)
                presetButton(label: "Full Moon", icon: "moon.circle.fill", phase: 0.5)
                presetButton(label: "Last Quarter", icon: "moon.haze.fill", phase: 0.75)
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func presetButton(label: String, icon: String, phase: Double) -> some View {
        let isSelected = abs(moonState.moonPhase - phase) < 0.01
        return Button {
            withAnimation(AppTheme.gentleAnimation) {
                moonState.moonPhase = phase
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
                Text(label)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? Color.appRose : Color.appSoftBrown.opacity(0.06))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
        }
    }
}
