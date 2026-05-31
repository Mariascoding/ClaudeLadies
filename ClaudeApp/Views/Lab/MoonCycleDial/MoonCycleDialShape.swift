import SwiftUI

// MARK: - Arc Segment Shape

struct ArcSegment: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()

        // Outer arc (clockwise)
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        // Inner arc (counter-clockwise back)
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Cycle Dial View

struct CycleDialView: View {
    let moonPhase: Double
    let dayInCycle: Double
    let cycleLength: Int
    let periodLength: Int

    private let dialSize: CGFloat = 300
    private let outerRingWidth: CGFloat = 28
    private let innerRingWidth: CGFloat = 24
    private let ringGap: CGFloat = 6

    // Silver-blue tones for lunar phases (darker near new moon, lighter near full)
    private let lunarColors: [Color] = [
        Color(red: 0.25, green: 0.28, blue: 0.38), // New Moon (darkest)
        Color(red: 0.40, green: 0.44, blue: 0.55), // Waxing Crescent
        Color(red: 0.55, green: 0.60, blue: 0.70), // First Quarter
        Color(red: 0.68, green: 0.73, blue: 0.82), // Waxing Gibbous
        Color(red: 0.82, green: 0.86, blue: 0.92), // Full Moon (lightest)
        Color(red: 0.68, green: 0.73, blue: 0.82), // Waning Gibbous
        Color(red: 0.55, green: 0.60, blue: 0.70), // Last Quarter
        Color(red: 0.40, green: 0.44, blue: 0.55), // Waning Crescent
    ]

    private var outerRadius: CGFloat { dialSize / 2 }
    private var outerInnerRadius: CGFloat { outerRadius - outerRingWidth }
    private var innerOuterRadius: CGFloat { outerInnerRadius - ringGap }
    private var innerInnerRadius: CGFloat { innerOuterRadius - innerRingWidth }

    private var archetypeName: String {
        archetypeResult.name
    }

    private var alignmentPercent: Int {
        archetypeResult.alignment
    }

    private var archetypeResult: (name: String, alignment: Int) {
        calculateArchetype(
            moonPhase: moonPhase,
            dayInCycle: Int(dayInCycle),
            cycleLength: cycleLength
        )
    }

    var body: some View {
        ZStack {
            // Outer ring — 8 lunar phase segments
            outerRing

            // Moon phase icons on outer ring
            moonPhaseIcons

            // Inner ring — 4 cycle phase arcs
            innerRing

            // Moon indicator (gold dot on outer ring)
            indicator(
                fraction: moonPhase,
                radius: outerInnerRadius + outerRingWidth / 2,
                color: Color(red: 0.92, green: 0.78, blue: 0.55),
                glow: true
            )

            // Cycle indicator (colored dot on inner ring)
            cycleIndicator

            // Center label
            centerLabel
        }
        .frame(width: dialSize, height: dialSize)
    }

    // MARK: - Outer Ring

    private var outerRing: some View {
        ForEach(Array(LunarPhase.allCases.enumerated()), id: \.element.id) { index, phase in
            ArcSegment(
                startAngle: angle(for: phase.startPhase),
                endAngle: angle(for: phase.endPhase),
                innerRadius: outerInnerRadius,
                outerRadius: outerRadius
            )
            .fill(lunarColors[index])
        }
    }

    // MARK: - Moon Phase Icons

    private var moonPhaseIcons: some View {
        ForEach(LunarPhase.allCases) { phase in
            let midFraction = (phase.startPhase + phase.endPhase) / 2.0
            let iconAngle = angle(for: midFraction)
            let iconRadius = outerInnerRadius + outerRingWidth / 2

            Image(systemName: phase.icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .position(
                    x: dialSize / 2 + iconRadius * cos(CGFloat(iconAngle.radians)),
                    y: dialSize / 2 + iconRadius * sin(CGFloat(iconAngle.radians))
                )
        }
    }

    // MARK: - Inner Ring

    private var innerRing: some View {
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )

        return ForEach(Array(boundaries.enumerated()), id: \.offset) { _, boundary in
            let startFraction = Double(boundary.startDay - 1) / Double(cycleLength)
            let endFraction = Double(boundary.endDay) / Double(cycleLength)

            ArcSegment(
                startAngle: angle(for: startFraction),
                endAngle: angle(for: endFraction),
                innerRadius: innerInnerRadius,
                outerRadius: innerOuterRadius
            )
            .fill(boundary.phase.accentColor.opacity(0.7))
        }
    }

    // MARK: - Indicators

    private func indicator(fraction: Double, radius: CGFloat, color: Color, glow: Bool) -> some View {
        let a = angle(for: fraction)
        let x = dialSize / 2 + radius * cos(CGFloat(a.radians))
        let y = dialSize / 2 + radius * sin(CGFloat(a.radians))

        return Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .shadow(color: glow ? color.opacity(0.8) : .clear, radius: glow ? 6 : 0)
            .position(x: x, y: y)
    }

    private var cycleIndicator: some View {
        let fraction = (dayInCycle - 1) / Double(cycleLength)
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )

        // Find current phase color
        let dayInt = Int(dayInCycle)
        let color = boundaries.first(where: { dayInt >= $0.startDay && dayInt <= $0.endDay })?.phase.accentColor ?? .appRose

        return indicator(
            fraction: fraction,
            radius: innerInnerRadius + innerRingWidth / 2,
            color: color,
            glow: false
        )
    }

    // MARK: - Center Label

    private var centerLabel: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(archetypeName)
                .font(.system(.subheadline, design: AppTheme.fontFamilySerif, weight: .medium))
                .foregroundStyle(Color.appSoftBrown)

            Text("\(alignmentPercent)% aligned")
                .font(.system(.caption2, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
        }
        .position(x: dialSize / 2, y: dialSize / 2)
    }

    // MARK: - Helpers

    private func angle(for fraction: Double) -> Angle {
        .degrees(fraction * 360 - 90)
    }

    // MARK: - Archetype Calculation (self-contained)

    private func calculateArchetype(moonPhase: Double, dayInCycle: Int, cycleLength: Int) -> (name: String, alignment: Int) {
        let cycleProgress = Double(dayInCycle - 1) / Double(cycleLength)
        var moonPhaseAtBleed = moonPhase - cycleProgress
        moonPhaseAtBleed = moonPhaseAtBleed.truncatingRemainder(dividingBy: 1.0)
        if moonPhaseAtBleed < 0 { moonPhaseAtBleed += 1.0 }

        let archetypes: [(name: String, anchor: Double)] = [
            ("White Moon", 0.0),
            ("Pink Moon", 0.25),
            ("Red Moon", 0.5),
            ("Purple Moon", 0.75)
        ]

        var bestName = archetypes[0].name
        var bestDistance = Double.greatestFiniteMagnitude

        for archetype in archetypes {
            let diff = abs(moonPhaseAtBleed - archetype.anchor)
            let dist = min(diff, 1.0 - diff)
            if dist < bestDistance {
                bestDistance = dist
                bestName = archetype.name
            }
        }

        let percentage = Int(min(100, max(0, (1.0 - bestDistance / 0.125) * 100.0)))
        return (bestName, percentage)
    }
}
