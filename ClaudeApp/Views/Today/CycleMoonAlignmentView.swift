import SwiftUI

struct CycleMoonAlignmentView: View {
    let moonPhase: Double
    let dayInCycle: Int
    let cycleLength: Int
    let phase: CyclePhase

    private var archetype: MoonArchetype {
        MoonArchetype.calculate(moonPhase: moonPhase, dayInCycle: dayInCycle, cycleLength: cycleLength)
    }

    private var alignmentPercentage: Int {
        MoonArchetype.alignmentPercentage(moonPhase: moonPhase, dayInCycle: dayInCycle, cycleLength: cycleLength)
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Circular progress ring
            ZStack {
                Circle()
                    .stroke(phase.accentColor.opacity(0.2), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: Double(alignmentPercentage) / 100.0)
                    .stroke(phase.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(alignmentPercentage)%")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(phase.accentColor)
            }
            .frame(width: 50, height: 50)

            // Archetype name + description
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(archetype.name)
                    .warmHeadline()

                Text(archetype.description)
                    .guidanceText()
                    .font(.system(.caption, design: .serif))
            }

            Spacer(minLength: 0)
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Moon Archetype

private enum MoonArchetype {
    case whiteMoon
    case pinkMoon
    case redMoon
    case purpleMoon

    var name: String {
        switch self {
        case .whiteMoon: "White Moon Woman"
        case .pinkMoon: "Pink Moon Woman"
        case .redMoon: "Red Moon Woman"
        case .purpleMoon: "Purple Moon Woman"
        }
    }

    var description: String {
        switch self {
        case .whiteMoon: "Nurturing & intuitive energy \u{2014} bleeding with the new moon"
        case .pinkMoon: "Emerging growth & renewal \u{2014} bleeding with the waxing moon"
        case .redMoon: "Creative power & expression \u{2014} bleeding with the full moon"
        case .purpleMoon: "Inner wisdom & reflection \u{2014} bleeding with the waning moon"
        }
    }

    var anchor: Double {
        switch self {
        case .whiteMoon: 0.0
        case .pinkMoon: 0.25
        case .redMoon: 0.5
        case .purpleMoon: 0.75
        }
    }

    static let allCases: [MoonArchetype] = [.whiteMoon, .pinkMoon, .redMoon, .purpleMoon]

    static func calculate(moonPhase: Double, dayInCycle: Int, cycleLength: Int) -> MoonArchetype {
        let moonPhaseAtBleed = moonPhaseAtBleed(moonPhase: moonPhase, dayInCycle: dayInCycle, cycleLength: cycleLength)
        return nearest(to: moonPhaseAtBleed).archetype
    }

    static func alignmentPercentage(moonPhase: Double, dayInCycle: Int, cycleLength: Int) -> Int {
        let moonPhaseAtBleed = moonPhaseAtBleed(moonPhase: moonPhase, dayInCycle: dayInCycle, cycleLength: cycleLength)
        let minDist = nearest(to: moonPhaseAtBleed).distance
        let percentage = (1.0 - minDist / 0.125) * 100.0
        return Int(min(100, max(0, percentage)))
    }

    private static func moonPhaseAtBleed(moonPhase: Double, dayInCycle: Int, cycleLength: Int) -> Double {
        let cycleProgress = Double(dayInCycle - 1) / Double(cycleLength)
        var result = moonPhase - cycleProgress
        result = result.truncatingRemainder(dividingBy: 1.0)
        if result < 0 { result += 1.0 }
        return result
    }

    private static func nearest(to offset: Double) -> (archetype: MoonArchetype, distance: Double) {
        var bestArchetype = MoonArchetype.whiteMoon
        var bestDistance = Double.greatestFiniteMagnitude

        for archetype in allCases {
            let dist = circularDistance(offset, archetype.anchor)
            if dist < bestDistance {
                bestDistance = dist
                bestArchetype = archetype
            }
        }

        return (bestArchetype, bestDistance)
    }

    private static func circularDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return min(diff, 1.0 - diff)
    }
}

#Preview {
    VStack(spacing: 16) {
        CycleMoonAlignmentView(
            moonPhase: 0.0,
            dayInCycle: 1,
            cycleLength: 28,
            phase: .menstrual
        )
        CycleMoonAlignmentView(
            moonPhase: 0.5,
            dayInCycle: 1,
            cycleLength: 28,
            phase: .ovulation
        )
        CycleMoonAlignmentView(
            moonPhase: 0.3,
            dayInCycle: 10,
            cycleLength: 28,
            phase: .follicular
        )
    }
    .padding()
    .background(Color.appCream)
}
