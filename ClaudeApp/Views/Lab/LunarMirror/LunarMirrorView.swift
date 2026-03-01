import SwiftUI

// MARK: - Lunar Mirror View (Lab)

struct LunarMirrorView: View {
    @StateObject private var moonState = MoonState()
    @State private var dayInCycle: Double = 1
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                LunarMirrorCard(
                    moonState: moonState,
                    dayInCycle: Int(dayInCycle),
                    cycleLength: Int(cycleLength),
                    periodLength: Int(periodLength)
                )
                .animation(AppTheme.gentleAnimation, value: moonState.moonPhase)
                .animation(AppTheme.gentleAnimation, value: dayInCycle)

                moonSliderCard
                cycleSliderCard
                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(SkyBackgroundView())
        .navigationTitle("Lunar Mirror")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            moonState.moonPhase = 0.5
            withAnimation(.easeInOut(duration: 0.4)) {
                moonState.isLoaded = true
            }
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

struct TwinklingStarsView: View {
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

struct DriftingCloudsView: View {
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

struct NightShadow: View {
    let currentMoonDay: Int
    let moonSize: CGFloat
    let skyColor: Color

    var body: some View {
        ZStack {
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

// MARK: - Sky Background (full-screen, reusable)

struct SkyBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var isNightMode: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            if isNightMode {
                LunarMirrorCard.nightSkyColor
            } else {
                LinearGradient(
                    colors: LunarMirrorCard.daySkyColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            if isNightMode {
                TwinklingStarsView()
            } else {
                DriftingCloudsView()
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: colorScheme)
    }
}

// Deterministic RNG so star positions are stable across redraws
private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
