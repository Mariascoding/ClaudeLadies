import SwiftUI
import UIKit

// MARK: - Petal Shape (round-leafed)

struct PetalShape: Shape {
    var openness: CGFloat // 0 = tight bud, 1 = fully open

    var animatableData: CGFloat {
        get { openness }
        set { openness = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2
        // Wider spread + rounder belly for a soft leaf shape
        let spread = openness * 0.55 + 0.12
        let bulge: CGFloat = 0.75 + openness * 0.15 // controls how round the belly is

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right curve — fat rounded belly, soft rounded tip
        path.addCurve(
            to: CGPoint(x: midX, y: h * 0.03),
            control1: CGPoint(x: midX + w * spread, y: h * bulge),
            control2: CGPoint(x: midX + w * spread * 0.75, y: h * 0.22)
        )

        // Rounded tip — small arc across the top
        path.addQuadCurve(
            to: CGPoint(x: midX, y: 0),
            control: CGPoint(x: midX + w * 0.04, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: midX, y: h * 0.03),
            control: CGPoint(x: midX - w * 0.04, y: 0)
        )

        // Left curve (mirror)
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * spread * 0.75, y: h * 0.22),
            control2: CGPoint(x: midX - w * spread, y: h * bulge)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Haptics Engine (4 state transitions, escalating)

private final class BloomHapticsEngine {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)

    private var firedStates: Set<Int> = []

    // 4 bloom state boundaries — click gets stronger each time
    private static let stateThresholds: [(state: Int, progress: CGFloat, style: HapticStyle)] = [
        (1, 0.25, .light(0.5)),    // bud cracks open
        (2, 0.50, .medium(0.6)),   // petals unfurling
        (3, 0.75, .medium(0.85)),  // wide bloom
        (4, 0.98, .heavy(1.0)),    // full summer radiance
    ]

    enum HapticStyle {
        case light(CGFloat)
        case medium(CGFloat)
        case heavy(CGFloat)
    }

    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
    }

    func update(progress: CGFloat) {
        for threshold in Self.stateThresholds {
            guard progress >= threshold.progress,
                  !firedStates.contains(threshold.state) else { continue }

            firedStates.insert(threshold.state)

            switch threshold.style {
            case .light(let intensity):
                lightGenerator.impactOccurred(intensity: intensity)
                lightGenerator.prepare()
            case .medium(let intensity):
                mediumGenerator.impactOccurred(intensity: intensity)
                mediumGenerator.prepare()
            case .heavy(let intensity):
                heavyGenerator.impactOccurred(intensity: intensity)
                heavyGenerator.prepare()
            }
        }
    }

    func reset() {
        firedStates.removeAll()
    }
}

// MARK: - Color Journey (4 states)

private struct BloomColors {
    let petal: Color
    let glow: Color
    let background: Color

    // State 1 (0.00–0.25): Quiet Bud — deep indigo/violet, near-black bg
    // State 2 (0.25–0.50): Awakening — dusky rose/warm pink
    // State 3 (0.50–0.75): Blooming — rich amber/warm gold
    // State 4 (0.75–1.00): Summer Radiance — vivid sunny gold/warm white, bright bg

    static func at(progress: CGFloat) -> BloomColors {
        let p = min(max(progress, 0), 1)

        if p < 0.25 {
            let t = p / 0.25
            return BloomColors(
                petal: lerp(
                    UIColor(red: 0.22, green: 0.12, blue: 0.42, alpha: 1),
                    UIColor(red: 0.50, green: 0.25, blue: 0.45, alpha: 1), t),
                glow: lerp(
                    UIColor(red: 0.18, green: 0.08, blue: 0.30, alpha: 0.5),
                    UIColor(red: 0.40, green: 0.18, blue: 0.38, alpha: 0.6), t),
                background: lerp(
                    UIColor(red: 0.05, green: 0.03, blue: 0.09, alpha: 1),
                    UIColor(red: 0.10, green: 0.06, blue: 0.12, alpha: 1), t)
            )
        } else if p < 0.50 {
            let t = (p - 0.25) / 0.25
            return BloomColors(
                petal: lerp(
                    UIColor(red: 0.50, green: 0.25, blue: 0.45, alpha: 1),
                    UIColor(red: 0.78, green: 0.45, blue: 0.38, alpha: 1), t),
                glow: lerp(
                    UIColor(red: 0.40, green: 0.18, blue: 0.38, alpha: 0.6),
                    UIColor(red: 0.65, green: 0.35, blue: 0.30, alpha: 0.7), t),
                background: lerp(
                    UIColor(red: 0.10, green: 0.06, blue: 0.12, alpha: 1),
                    UIColor(red: 0.14, green: 0.08, blue: 0.08, alpha: 1), t)
            )
        } else if p < 0.75 {
            let t = (p - 0.50) / 0.25
            return BloomColors(
                petal: lerp(
                    UIColor(red: 0.78, green: 0.45, blue: 0.38, alpha: 1),
                    UIColor(red: 0.92, green: 0.72, blue: 0.32, alpha: 1), t),
                glow: lerp(
                    UIColor(red: 0.65, green: 0.35, blue: 0.30, alpha: 0.7),
                    UIColor(red: 0.85, green: 0.60, blue: 0.25, alpha: 0.8), t),
                background: lerp(
                    UIColor(red: 0.14, green: 0.08, blue: 0.08, alpha: 1),
                    UIColor(red: 0.18, green: 0.12, blue: 0.05, alpha: 1), t)
            )
        } else {
            let t = (p - 0.75) / 0.25
            return BloomColors(
                petal: lerp(
                    UIColor(red: 0.92, green: 0.72, blue: 0.32, alpha: 1),
                    UIColor(red: 1.00, green: 0.92, blue: 0.50, alpha: 1), t),
                glow: lerp(
                    UIColor(red: 0.85, green: 0.60, blue: 0.25, alpha: 0.8),
                    UIColor(red: 1.00, green: 0.90, blue: 0.45, alpha: 0.95), t),
                background: lerp(
                    UIColor(red: 0.18, green: 0.12, blue: 0.05, alpha: 1),
                    UIColor(red: 0.30, green: 0.22, blue: 0.08, alpha: 1), t)
            )
        }
    }

    private static func lerp(_ a: UIColor, _ b: UIColor, _ t: CGFloat) -> Color {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            opacity: a1 + (a2 - a1) * t
        )
    }
}

// MARK: - Ring Configuration

private struct RingConfig {
    let petalCount: Int
    let baseRadius: CGFloat
    let activationDelay: CGFloat

    static let rings: [RingConfig] = [
        RingConfig(petalCount: 5, baseRadius: 0, activationDelay: 0.0),
        RingConfig(petalCount: 8, baseRadius: 35, activationDelay: 0.08),
        RingConfig(petalCount: 12, baseRadius: 70, activationDelay: 0.18),
        RingConfig(petalCount: 16, baseRadius: 110, activationDelay: 0.30),
        RingConfig(petalCount: 20, baseRadius: 150, activationDelay: 0.42),
    ]

    func ringProgress(for holdProgress: CGFloat) -> CGFloat {
        let effective = holdProgress - activationDelay
        guard effective > 0 else { return 0 }
        return min(effective / (1.0 - activationDelay), 1.0)
    }
}

// MARK: - Canvas View

struct BloomCanvas: View {
    @Binding var isHolding: Bool

    @State private var holdProgress: CGFloat = 0
    @State private var breathPhase: CGFloat = 0
    @State private var dancePhase: CGFloat = 0

    private let haptics = BloomHapticsEngine()
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private let bloomDuration: CGFloat = 7.0

    // How much "summer dance" is active (ramps up in state 4)
    private var danceAmount: CGFloat {
        let entry: CGFloat = 0.75
        guard holdProgress > entry else { return 0 }
        return (holdProgress - entry) / (1.0 - entry)
    }

    var body: some View {
        let colors = BloomColors.at(progress: holdProgress)
        let dance = danceAmount

        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Background
                colors.background.ignoresSafeArea()

                // Central glow — grows larger and brighter in summer state
                let glowRadius = 50 + holdProgress * 160 + dance * 60
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [colors.glow, colors.glow.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: glowRadius
                        )
                    )
                    .frame(width: glowRadius * 2, height: glowRadius * 2)
                    .position(center)

                // Outer warm haze in summer state
                if dance > 0 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.92, blue: 0.50).opacity(0.12 * dance),
                                    Color.clear,
                                ],
                                center: .center,
                                startRadius: glowRadius * 0.5,
                                endRadius: glowRadius * 1.8
                            )
                        )
                        .frame(width: glowRadius * 4, height: glowRadius * 4)
                        .position(center)
                }

                // Petal rings (back to front)
                ForEach(Array(RingConfig.rings.enumerated().reversed()), id: \.offset) { ringIndex, ring in
                    let ringProg = ring.ringProgress(for: holdProgress)
                    let rotationOffset = Angle.degrees(Double(ringIndex) * 12.0 * holdProgress)
                    let breathAmount = sin(breathPhase) * 0.03 * (1.0 - holdProgress)

                    ForEach(0..<ring.petalCount, id: \.self) { petalIndex in
                        let baseAngle = Double(petalIndex) * 360.0 / Double(ring.petalCount)

                        // Organic dance: layered slow sine waves like a gentle breeze
                        let seed = Double(ringIndex * 31 + petalIndex * 7)
                        let wave1 = sin(dancePhase * 0.8 + seed)
                        let wave2 = sin(dancePhase * 1.3 + seed * 0.4) * 0.6
                        let wave3 = sin(dancePhase * 0.5 + seed * 1.7) * 0.3
                        let sway = wave1 + wave2 + wave3 // -1.9 … +1.9
                        let ringEase = 0.6 + Double(ringIndex) * 0.2 // outer rings drift more
                        let swayAngle = dance * sway * ringEase * 1.6

                        // Gentle breathing scale — slow, out of phase per petal
                        let scaleWave = sin(dancePhase * 0.6 + seed * 0.3) * 0.5
                                      + sin(dancePhase * 1.1 + seed * 0.8) * 0.3
                        let swayScale = 1.0 + dance * scaleWave * 0.035

                        // Subtle radial drift — petals gently reach outward and pull back
                        let driftWave = sin(dancePhase * 0.7 + seed * 0.5)
                        let radialDrift = dance * driftWave * 3.0

                        let angle = Angle.degrees(baseAngle + swayAngle) + rotationOffset
                        let openness = min(max(ringProg + (ringIndex == 0 ? breathAmount : 0), 0), 1)
                        let radius = ring.baseRadius * (0.3 + ringProg * 0.7) + radialDrift
                        let petalLength: CGFloat = 40 + ringProg * 28 + CGFloat(ringIndex) * 7
                        let petalWidth: CGFloat = 26 + ringProg * 6

                        PetalShape(openness: openness)
                            .fill(colors.petal.opacity(0.7 + ringProg * 0.3))
                            .frame(width: petalWidth, height: petalLength)
                            .scaleEffect(swayScale)
                            .offset(y: -petalLength / 2 - radius)
                            .rotationEffect(angle)
                            .position(center)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding {
                            isHolding = true
                            haptics.prepare()
                        }
                    }
                    .onEnded { _ in
                        isHolding = false
                        haptics.reset()
                    }
            )
        }
        .onReceive(timer) { _ in
            let dt: CGFloat = 1.0 / 60.0

            // Breathing + dance phase always advance
            breathPhase += dt * 2.5
            dancePhase += dt * 0.6

            if isHolding {
                holdProgress = min(holdProgress + dt / bloomDuration, 1.0)
                haptics.update(progress: holdProgress)
            } else {
                if holdProgress > 0.001 {
                    holdProgress -= holdProgress * 2.5 * dt
                    if holdProgress < 0.001 { holdProgress = 0 }
                }
            }
        }
    }
}
