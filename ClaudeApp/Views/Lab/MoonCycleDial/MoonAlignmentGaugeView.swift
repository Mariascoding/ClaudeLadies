import SwiftUI

// MARK: - Archetype Traits

private struct ArchetypeProfile {
    let name: String
    let anchor: Double
    let color: Color
    let traits: [String]
}

private let archetypeProfiles: [ArchetypeProfile] = [
    ArchetypeProfile(
        name: "White Moon",
        anchor: 0.0,
        color: Color(red: 0.82, green: 0.86, blue: 0.92),
        traits: ["Nurturing", "Intuitive", "Fertile", "Grounded"]
    ),
    ArchetypeProfile(
        name: "Pink Moon",
        anchor: 0.25,
        color: Color.appRose,
        traits: ["Adaptable", "Hopeful", "Renewing", "Open"]
    ),
    ArchetypeProfile(
        name: "Red Moon",
        anchor: 0.5,
        color: Color.appTerracotta,
        traits: ["Creative", "Magnetic", "Expressive", "Bold"]
    ),
    ArchetypeProfile(
        name: "Purple Moon",
        anchor: 0.75,
        color: Color(red: 0.58, green: 0.48, blue: 0.68),
        traits: ["Wise", "Reflective", "Mystical", "Transformative"]
    )
]

// MARK: - Mini Gauge Arc

private struct MiniGaugeArc: Shape {
    let startFraction: Double
    let endFraction: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width / 2, rect.height) - 2
        let startAngle = Angle.degrees(180 + startFraction * 180)
        let endAngle = Angle.degrees(180 + endFraction * 180)

        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

// MARK: - Moon Alignment Gauge View

struct MoonAlignmentGaugeView: View {
    let moonPhase: Double
    let dayInCycle: Int
    let cycleLength: Int
    let periodLength: Int

    @State private var showingWisdom = false

    private var moonPhaseAtBleed: Double {
        let cycleProgress = Double(dayInCycle - 1) / Double(cycleLength)
        var result = moonPhase - cycleProgress
        result = result.truncatingRemainder(dividingBy: 1.0)
        if result < 0 { result += 1.0 }
        return result
    }

    private var currentProfile: ArchetypeProfile {
        nearest(to: moonPhaseAtBleed).profile
    }

    private var alignmentPercent: Int {
        let dist = nearest(to: moonPhaseAtBleed).distance
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
        LunarPhase.from(moonPhase: moonPhase)
    }

    private var cycleStateVerb: String {
        switch currentCyclePhase {
        case .menstrual: "Bleeding"
        case .follicular: "In your follicular phase"
        case .ovulation: "Ovulating"
        case .luteal: "In your luteal phase"
        }
    }

    var body: some View {
        Button {
            showingWisdom = true
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // Mini gauge on the left
                miniGauge
                    .frame(width: 64, height: 36)

                // Text on the right
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("\(cycleStateVerb) with the \(currentLunarPhase.displayName)")
                        .font(.system(.caption, design: AppTheme.fontFamilySerif))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.85))

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("\(alignmentPercent)%")
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .bold))
                            .foregroundStyle(currentProfile.color)

                        Text(currentProfile.name + " Woman")
                            .font(.system(.subheadline, design: AppTheme.fontFamilySerif, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown)
                    }

                    // Trait tags inline
                    HStack(spacing: AppTheme.Spacing.xs) {
                        ForEach(Array(currentProfile.traits.prefix(3).enumerated()), id: \.offset) { _, trait in
                            Text(trait)
                                .font(.system(size: 10, weight: .medium, design: AppTheme.fontFamily))
                                .foregroundStyle(currentProfile.color)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, AppTheme.Spacing.xxs)
                                .background(currentProfile.color.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.3))
            }
            .warmCard()
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingWisdom) {
            wisdomSheet
        }
    }

    // MARK: - Mini Gauge

    private var miniGauge: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height
            let radius = min(size.width / 2, size.height) - 2
            let lineWidth: CGFloat = 6

            // Draw 4 arc segments
            for i in 0..<4 {
                let startAngle = Angle.degrees(180 + Double(i) * 45)
                let endAngle = Angle.degrees(180 + Double(i + 1) * 45)
                let isActive = currentProfile.name == archetypeProfiles[i].name

                let arcPath = Path { path in
                    path.addArc(
                        center: CGPoint(x: centerX, y: centerY),
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )
                }

                context.stroke(
                    arcPath,
                    with: .color(archetypeProfiles[i].color.opacity(isActive ? 1.0 : 0.25)),
                    style: StrokeStyle(lineWidth: isActive ? lineWidth + 1 : lineWidth, lineCap: .butt)
                )
            }

            // Needle
            let needleAngle = Angle.degrees(180 + moonPhaseAtBleed * 180)
            let needleLen = radius - 10
            let tipX = centerX + needleLen * cos(CGFloat(needleAngle.radians))
            let tipY = centerY + needleLen * sin(CGFloat(needleAngle.radians))

            var needlePath = Path()
            needlePath.move(to: CGPoint(x: centerX, y: centerY))
            needlePath.addLine(to: CGPoint(x: tipX, y: tipY))

            context.stroke(
                needlePath,
                with: .color(Color.appSoftBrown.opacity(0.7)),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )

            // Tip dot
            let dotRect = CGRect(x: tipX - 3, y: tipY - 3, width: 6, height: 6)
            context.fill(Path(ellipseIn: dotRect), with: .color(currentProfile.color))

            // Pivot
            let pivotRect = CGRect(x: centerX - 3, y: centerY - 3, width: 6, height: 6)
            context.fill(Path(ellipseIn: pivotRect), with: .color(Color.appSoftBrown))
        }
    }

    // MARK: - Wisdom Sheet

    private var wisdomSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    MoonWisdomCard(
                        wisdom: MoonWisdomContent.wisdom(for: moonPhase)
                    )

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Moon Wisdom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWisdom = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private func nearest(to offset: Double) -> (profile: ArchetypeProfile, distance: Double) {
        var best = archetypeProfiles[0]
        var bestDist = Double.greatestFiniteMagnitude

        for profile in archetypeProfiles {
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
