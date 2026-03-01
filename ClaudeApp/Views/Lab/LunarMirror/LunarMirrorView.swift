import SwiftUI

// MARK: - Archetype Profile (local mirror)

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

// MARK: - Lunar Mirror View

struct LunarMirrorView: View {
    @StateObject private var moonState = MoonState()
    @State private var dayInCycle: Double = 1
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    @State private var showingWisdom = false
    @State private var showWisdomTitle = false
    @State private var showWisdomContent = false
    @State private var isNightMode = true

    // MARK: - Sky Colors

    private static let nightSky = Color(red: 0.08, green: 0.1, blue: 0.18)
    private static let dayTop = Color(red: 0.45, green: 0.62, blue: 0.85)
    private static let dayMid = Color(red: 0.62, green: 0.76, blue: 0.92)
    private static let dayBottom = Color(red: 0.78, green: 0.87, blue: 0.95)

    private var shadowBlendColor: Color {
        isNightMode ? Self.nightSky : Self.dayMid
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
        let cycleProgress = Double(Int(dayInCycle) - 1) / Double(Int(cycleLength))
        var result = moonState.moonPhase - cycleProgress
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
            cycleLength: Int(cycleLength),
            periodLength: Int(periodLength)
        )
        let day = Int(dayInCycle)
        return boundaries.first(where: { day >= $0.startDay && day <= $0.endDay })?.phase ?? .menstrual
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
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                moonContainer
                moonSliderCard
                cycleSliderCard
                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Lunar Mirror")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            moonState.moonPhase = 0.5
            withAnimation(.easeInOut(duration: 0.4)) {
                moonState.isLoaded = true
            }
        }
    }

    // MARK: - Moon Container

    private var moonContainer: some View {
        ZStack {
            // Sky background
            if isNightMode {
                Self.nightSky
            } else {
                LinearGradient(
                    colors: [Self.dayTop, Self.dayMid, Self.dayBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            // Stars (night) or clouds (day)
            if isNightMode {
                TwinklingStarsView()
            } else {
                DriftingCloudsView()
            }

            // Moon + alignment stacked vertically so text is below the moon
            VStack(spacing: AppTheme.Spacing.md) {
                // 3D Moon with sky-blend shadow
                ZStack {
                    MoonView(moonState: moonState)

                    // Extra shadow that matches the sky so the dark side dissolves
                    NightShadow(
                        currentMoonDay: moonState.moonDay,
                        moonSize: 200,
                        skyColor: shadowBlendColor
                    )
                }
                .frame(height: 240)

                // Alignment text below the moon
                alignmentOverlay
                    .padding(.bottom, AppTheme.Spacing.md)
            }

            // Wisdom overlay (tap to toggle)
            if showingWisdom {
                wisdomOverlay
                    .transition(.opacity)
            }

            // Day/night toggle
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isNightMode.toggle()
                        }
                    } label: {
                        Image(systemName: isNightMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(isNightMode ? Color(red: 0.92, green: 0.78, blue: 0.55) : Color(red: 0.35, green: 0.35, blue: 0.55))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding(AppTheme.Spacing.sm)
        }
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))
        .animation(.easeInOut(duration: 0.5), value: isNightMode)
        .contentShape(Rectangle())
        .onTapGesture {
            if showingWisdom {
                withAnimation(.easeIn(duration: 0.25)) {
                    showWisdomTitle = false
                    showWisdomContent = false
                }
                withAnimation(.easeOut(duration: 0.3)) {
                    showingWisdom = false
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    showingWisdom = true
                }
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 1.0).delay(0.05)) {
                    showWisdomTitle = true
                }
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 1.0).delay(0.25)) {
                    showWisdomContent = true
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .animation(AppTheme.gentleAnimation, value: moonState.moonPhase)
        .animation(AppTheme.gentleAnimation, value: dayInCycle)
    }

    // MARK: - Alignment Overlay

    private var alignmentOverlay: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            // Line 1: cycle state + moon phase
            Text("\(cycleStateVerb) with the \(currentLunarPhase.displayName)")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(textPrimary.opacity(textSecondary))

            // Line 2: percentage + archetype name
            HStack(spacing: AppTheme.Spacing.xs) {
                Text("\(alignmentPercent)%")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(currentProfile.color)
                Text("\(currentProfile.name) Woman")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(textPrimary.opacity(0.9))
            }

            // Line 3: trait capsules
            HStack(spacing: AppTheme.Spacing.xs) {
                ForEach(Array(currentProfile.traits.prefix(3).enumerated()), id: \.offset) { _, trait in
                    Text(trait)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(currentProfile.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(currentProfile.color.opacity(isNightMode ? 0.2 : 0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .opacity(showingWisdom ? 0.15 : 1)
    }

    // MARK: - Wisdom Overlay

    private var wisdomOverlay: some View {
        ZStack {
            // Scrim
            scrimColor

            VStack(spacing: AppTheme.Spacing.sm) {
                // Title: Phase name + energy
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(wisdom.lunarPhase.displayName)
                        .font(.system(.headline, design: .serif, weight: .semibold))
                        .foregroundStyle(textPrimary)
                    Text(wisdom.energyKeyword.uppercased())
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(textPrimary.opacity(0.5))
                        .tracking(1.2)
                }
                .opacity(showWisdomTitle ? 1 : 0)
                .offset(y: showWisdomTitle ? 0 : 40)

                // Content: Advised + Avoid
                VStack(spacing: AppTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ADVISED")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(textPrimary.opacity(0.4))
                            .tracking(1)
                        Text(wisdom.advised.map(\.description).joined(separator: "  \u{00B7}  "))
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(textPrimary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AVOID")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(textPrimary.opacity(0.3))
                            .tracking(1)
                        Text(wisdom.avoid.map(\.description).joined(separator: "  \u{00B7}  "))
                            .font(.system(.caption2, design: .serif))
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
                    .font(.system(.caption, design: .rounded, weight: .medium))
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
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
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
                        .font(.system(.body, design: .rounded, weight: .semibold))
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

// MARK: - Twinkling Stars

private struct Star: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let baseOpacity: Double
    let twinkleSpeed: Double
    let twinkleDelay: Double
}

private struct TwinklingStarsView: View {
    @State private var twinkle = false

    private let stars: [Star] = {
        var rng = SeededRandomGenerator(seed: 42)
        return (0..<60).map { i in
            Star(
                id: i,
                x: CGFloat.random(in: 0...1, using: &rng),
                y: CGFloat.random(in: 0...1, using: &rng),
                size: CGFloat.random(in: 1.0...2.5, using: &rng),
                baseOpacity: Double.random(in: 0.3...0.8, using: &rng),
                twinkleSpeed: Double.random(in: 1.5...4.0, using: &rng),
                twinkleDelay: Double.random(in: 0...3.0, using: &rng)
            )
        }
    }()

    var body: some View {
        GeometryReader { geo in
            ForEach(stars) { star in
                Circle()
                    .fill(.white)
                    .frame(width: star.size, height: star.size)
                    .opacity(twinkle ? star.baseOpacity : star.baseOpacity * 0.3)
                    .animation(
                        .easeInOut(duration: star.twinkleSpeed)
                            .repeatForever(autoreverses: true)
                            .delay(star.twinkleDelay),
                        value: twinkle
                    )
                    .position(
                        x: star.x * geo.size.width,
                        y: star.y * geo.size.height
                    )
            }
        }
        .onAppear { twinkle = true }
    }
}

// MARK: - Drifting Clouds

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        // Organic blobby cloud shape
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.55))
        path.addQuadCurve(to: CGPoint(x: w * 0.3, y: h * 0.3), control: CGPoint(x: w * 0.1, y: h * 0.25))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.2), control: CGPoint(x: w * 0.35, y: h * 0.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.28), control: CGPoint(x: w * 0.62, y: h * 0.08))
        path.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.45), control: CGPoint(x: w * 0.9, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.65), control: CGPoint(x: w * 0.95, y: h * 0.58))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.65), control: CGPoint(x: w * 0.5, y: h * 0.75))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.55), control: CGPoint(x: w * 0.05, y: h * 0.6))
        path.closeSubpath()
        return path
    }
}

private struct DriftingCloudsView: View {
    @State private var drift = false

    private struct CloudInfo: Identifiable {
        let id: Int
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
        let opacity: Double
        let speed: Double
        let startOffset: CGFloat
    }

    private let clouds: [CloudInfo] = [
        CloudInfo(id: 0, y: 0.18, width: 120, height: 36, opacity: 0.45, speed: 28, startOffset: -0.1),
        CloudInfo(id: 1, y: 0.42, width: 90, height: 28, opacity: 0.3, speed: 36, startOffset: 0.35),
        CloudInfo(id: 2, y: 0.7, width: 140, height: 40, opacity: 0.35, speed: 32, startOffset: 0.6),
        CloudInfo(id: 3, y: 0.28, width: 70, height: 22, opacity: 0.25, speed: 42, startOffset: 0.85),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(clouds) { cloud in
                CloudShape()
                    .fill(.white.opacity(cloud.opacity))
                    .frame(width: cloud.width, height: cloud.height)
                    .blur(radius: 6)
                    .position(
                        x: drift
                            ? geo.size.width + cloud.width
                            : cloud.startOffset * geo.size.width - cloud.width / 2,
                        y: cloud.y * geo.size.height
                    )
                    .animation(
                        .linear(duration: cloud.speed)
                            .repeatForever(autoreverses: false)
                            .delay(cloud.startOffset * cloud.speed),
                        value: drift
                    )
            }
        }
        .onAppear { drift = true }
    }
}

// MARK: - Night Shadow (blends dark side into sky)

private struct NightShadow: View {
    let currentMoonDay: Int
    let moonSize: CGFloat
    let skyColor: Color

    var body: some View {
        ZStack {
            // Primary sky-colored shadow — partially hides the dark side
            Circle()
                .fill(skyColor.opacity(0.55))
                .mask(
                    Circle()
                        .fill(Color.black)
                        .scaleEffect(
                            x: MoonUtils.shadowScale(for: currentMoonDay),
                            y: 1,
                            anchor: MoonUtils.anchorSide(for: currentMoonDay)
                        )
                )
                .blur(radius: 3)

            // Soft feathered edge to smooth the terminator
            Circle()
                .fill(skyColor.opacity(0.4))
                .mask(
                    Circle()
                        .fill(Color.black)
                        .scaleEffect(
                            x: max(0, MoonUtils.shadowScale(for: currentMoonDay) - 0.08),
                            y: 1,
                            anchor: MoonUtils.anchorSide(for: currentMoonDay)
                        )
                )
                .blur(radius: 12)
        }
        .frame(width: moonSize, height: moonSize)
    }
}

// Deterministic RNG so star positions are stable across redraws
private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
