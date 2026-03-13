import SwiftUI

// MARK: - Archetype Profile

struct MoonArchetypeProfile {
    let name: String
    let anchor: Double
    let color: Color
    let traits: [String]
}

let moonArchetypeProfiles: [MoonArchetypeProfile] = [
    MoonArchetypeProfile(
        name: "White Moon",
        anchor: 0.0,
        color: Color(red: 0.82, green: 0.86, blue: 0.92),
        traits: ["Nurturing", "Intuitive", "Fertile", "Grounded"]
    ),
    MoonArchetypeProfile(
        name: "Pink Moon",
        anchor: 0.25,
        color: Color.appRose,
        traits: ["Adaptable", "Hopeful", "Renewing", "Open"]
    ),
    MoonArchetypeProfile(
        name: "Red Moon",
        anchor: 0.5,
        color: Color.appTerracotta,
        traits: ["Creative", "Magnetic", "Expressive", "Bold"]
    ),
    MoonArchetypeProfile(
        name: "Purple Moon",
        anchor: 0.75,
        color: Color(red: 0.58, green: 0.48, blue: 0.68),
        traits: ["Wise", "Reflective", "Mystical", "Transformative"]
    )
]

// MARK: - Lunar Mirror Card

struct LunarMirrorCard: View {
    @ObservedObject var moonState: MoonState
    let dayInCycle: Int
    let cycleLength: Int
    let periodLength: Int
    var scrollOffset: CGFloat = 0

    @Binding var showingWisdom: Bool

    @Environment(\.colorScheme) private var colorScheme
    @State private var showWisdomTitle = false
    @State private var showWisdomContent = false

    private var isNightMode: Bool {
        colorScheme == .dark
    }

    // MARK: - Sky Colors (theme-derived, static for parent views)

    static var nightSkyColor: Color {
        switch ColorTheme.current {
        case .classic:  return Color(red: 0.09, green: 0.08, blue: 0.14)
        case .winter:   return Color(red: 0.12, green: 0.07, blue: 0.10)
        case .spring:   return Color(red: 0.10, green: 0.08, blue: 0.14)
        case .summer:   return Color(red: 0.12, green: 0.10, blue: 0.06)
        case .autumn:   return Color(red: 0.08, green: 0.10, blue: 0.18)
        case .lux:      return Color(red: 0.10, green: 0.08, blue: 0.05)
        }
    }

    static var daySkyColors: [Color] {
        switch ColorTheme.current {
        case .classic:  return [Color(red: 0.50, green: 0.58, blue: 0.78), Color(red: 0.68, green: 0.72, blue: 0.86), Color(red: 0.85, green: 0.84, blue: 0.88)]
        case .winter:   return [Color(red: 0.55, green: 0.50, blue: 0.68), Color(red: 0.72, green: 0.65, blue: 0.78), Color(red: 0.88, green: 0.80, blue: 0.85)]
        case .spring:   return [Color(red: 0.52, green: 0.50, blue: 0.75), Color(red: 0.68, green: 0.65, blue: 0.82), Color(red: 0.84, green: 0.80, blue: 0.88)]
        case .summer:   return [Color(red: 0.55, green: 0.58, blue: 0.72), Color(red: 0.72, green: 0.72, blue: 0.80), Color(red: 0.90, green: 0.88, blue: 0.78)]
        case .autumn:   return [Color(red: 0.45, green: 0.62, blue: 0.85), Color(red: 0.62, green: 0.76, blue: 0.92), Color(red: 0.78, green: 0.87, blue: 0.95)]
        case .lux:      return [Color(red: 0.55, green: 0.48, blue: 0.38), Color(red: 0.72, green: 0.66, blue: 0.55), Color(red: 0.88, green: 0.84, blue: 0.76)]
        }
    }

    private var nightSky: Color { Self.nightSkyColor }
    private var dayTop: Color { Self.daySkyColors[0] }
    private var dayMid: Color { Self.daySkyColors[1] }
    private var dayBottom: Color { Self.daySkyColors[2] }

    private var shadowBlendColor: Color {
        isNightMode ? nightSky : dayMid
    }

    private var textPrimary: Color {
        isNightMode ? .white : Color(red: 0.18, green: 0.16, blue: 0.22)
    }

    private var textSecondary: Double {
        isNightMode ? 0.7 : 0.55
    }

    private var scrimColor: Color {
        isNightMode ? .black.opacity(0.65) : .white.opacity(0.7)
    }

    // MARK: - Computed Properties

    private var moonPhaseAtBleed: Double {
        let cycleProgress = Double(dayInCycle - 1) / Double(cycleLength)
        var result = moonState.moonPhase - cycleProgress
        result = result.truncatingRemainder(dividingBy: 1.0)
        if result < 0 { result += 1.0 }
        return result
    }

    private var currentProfile: MoonArchetypeProfile {
        nearestArchetype(to: moonPhaseAtBleed).profile
    }

    private var alignmentPercent: Int {
        let dist = nearestArchetype(to: moonPhaseAtBleed).distance
        return Int(min(100, max(0, (1.0 - dist / 0.125) * 100.0)))
    }

    private var currentCyclePhase: CyclePhase {
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )
        return boundaries.first(where: { dayInCycle >= $0.startDay && dayInCycle <= $0.endDay })?.phase ?? .menstrual
    }

    private var currentLunarPhase: LunarPhase {
        LunarPhase.from(moonPhase: moonState.moonPhase)
    }

    private var cycleStateVerb: String {
        switch currentCyclePhase {
        case .menstrual: "Bleeding"
        case .follicular: "In your follicular phase"
        case .ovulation: "Ovulating"
        case .luteal: "In your luteal phase"
        }
    }

    private var wisdom: MoonPhaseWisdom {
        MoonWisdomContent.wisdom(for: moonState.moonPhase)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                MoonView(moonState: moonState)

                // Wisdom overlay
                wisdomOverlay
                    .opacity(showingWisdom ? 1 : 0)
                    .allowsHitTesting(showingWisdom)
            }
            .frame(height: 240)

            Color.clear
                .frame(height: AppTheme.Spacing.md)
        }
        .animation(.easeInOut(duration: 0.5), value: colorScheme)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                showingWisdom.toggle()
            }
        }
        .onChange(of: showingWisdom) { _, newValue in
            if newValue {
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 1.0).delay(0.05)) {
                    showWisdomTitle = true
                }
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 1.0).delay(0.25)) {
                    showWisdomContent = true
                }
            } else {
                withAnimation(.easeIn(duration: 0.25)) {
                    showWisdomTitle = false
                    showWisdomContent = false
                }
            }
        }
    }

    // MARK: - Alignment Overlay

    // MARK: - Wisdom Overlay

    private var wisdomOverlay: some View {
        ZStack {
            scrimColor

            VStack(spacing: AppTheme.Spacing.sm) {
                VStack(spacing: AppTheme.Spacing.xs) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(wisdom.lunarPhase.displayName)
                            .font(.system(.headline, design: AppTheme.fontFamilySerif, weight: .semibold))
                            .foregroundStyle(textPrimary)
                        Text("\(Int(MoonUtils.illumination(for: moonState.moonDay) * 100))%")
                            .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(textPrimary.opacity(0.45))
                    }
                    Text(wisdom.energyKeyword.uppercased())
                        .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(textPrimary.opacity(0.5))
                        .tracking(1.2)
                }
                .opacity(showWisdomTitle ? 1 : 0)
                .offset(y: showWisdomTitle ? 0 : 40)

                // Cycle + archetype alignment
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(cycleStateVerb) with the \(currentLunarPhase.displayName)")
                        .font(.system(.caption, design: AppTheme.fontFamilySerif))
                        .foregroundStyle(textPrimary.opacity(textSecondary))

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("\(alignmentPercent)%")
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .bold))
                            .foregroundStyle(textPrimary.opacity(0.85))
                        Text("\(currentProfile.name) Woman")
                            .font(.system(.subheadline, design: AppTheme.fontFamilySerif, weight: .medium))
                            .foregroundStyle(textPrimary.opacity(0.9))
                    }

                    HStack(spacing: AppTheme.Spacing.xs) {
                        ForEach(Array(currentProfile.traits.prefix(3).enumerated()), id: \.offset) { _, trait in
                            Text(trait)
                                .font(.system(size: 10, weight: .medium, design: AppTheme.fontFamily))
                                .foregroundStyle(textPrimary.opacity(0.8))
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, AppTheme.Spacing.xxs)
                                .background(textPrimary.opacity(isNightMode ? 0.15 : 0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .opacity(showWisdomTitle ? 1 : 0)
                .offset(y: showWisdomTitle ? 0 : 40)

                VStack(spacing: AppTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ADVISED")
                            .font(.system(size: 9, weight: .semibold, design: AppTheme.fontFamily))
                            .foregroundStyle(textPrimary.opacity(0.4))
                            .tracking(1)
                        Text(wisdom.advised.map(\.description).joined(separator: "  \u{00B7}  "))
                            .font(.system(.caption2, design: AppTheme.fontFamilySerif))
                            .foregroundStyle(textPrimary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AVOID")
                            .font(.system(size: 9, weight: .semibold, design: AppTheme.fontFamily))
                            .foregroundStyle(textPrimary.opacity(0.3))
                            .tracking(1)
                        Text(wisdom.avoid.map(\.description).joined(separator: "  \u{00B7}  "))
                            .font(.system(.caption2, design: AppTheme.fontFamilySerif))
                            .foregroundStyle(textPrimary.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showWisdomContent ? 1 : 0)
                .offset(y: showWisdomContent ? 0 : 40)
            }
            .frame(maxWidth: 216)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    // MARK: - Helpers

    private func nearestArchetype(to offset: Double) -> (profile: MoonArchetypeProfile, distance: Double) {
        var best = moonArchetypeProfiles[0]
        var bestDist = Double.greatestFiniteMagnitude

        for profile in moonArchetypeProfiles {
            let diff = abs(offset - profile.anchor)
            let dist = min(diff, 1.0 - diff)
            if dist < bestDist {
                bestDist = dist
                best = profile
            }
        }

        return (best, bestDist)
    }
}
