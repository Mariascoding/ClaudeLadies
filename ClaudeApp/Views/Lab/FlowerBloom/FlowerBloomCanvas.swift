import SwiftUI
import UIKit

// MARK: - Haptics Engine (4 state transitions)

private final class FlowerBloomHapticsEngine {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)

    private var firedStates: Set<Int> = []

    private static let stateThresholds: [(state: Int, progress: CGFloat, style: HapticStyle)] = [
        (1, 0.20, .light(0.5)),
        (2, 0.40, .medium(0.6)),
        (3, 0.65, .medium(0.85)),
        (4, 0.95, .heavy(1.0)),
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

// MARK: - Background Color Journey

private struct FlowerBloomBackground {
    static func color(at progress: CGFloat) -> Color {
        let p = min(max(progress, 0), 1)

        if p < 0.25 {
            let t = p / 0.25
            return lerp(
                UIColor(red: 0.06, green: 0.05, blue: 0.10, alpha: 1),
                UIColor(red: 0.10, green: 0.08, blue: 0.10, alpha: 1), t)
        } else if p < 0.50 {
            let t = (p - 0.25) / 0.25
            return lerp(
                UIColor(red: 0.10, green: 0.08, blue: 0.10, alpha: 1),
                UIColor(red: 0.14, green: 0.10, blue: 0.07, alpha: 1), t)
        } else if p < 0.75 {
            let t = (p - 0.50) / 0.25
            return lerp(
                UIColor(red: 0.14, green: 0.10, blue: 0.07, alpha: 1),
                UIColor(red: 0.18, green: 0.14, blue: 0.06, alpha: 1), t)
        } else {
            let t = (p - 0.75) / 0.25
            return lerp(
                UIColor(red: 0.18, green: 0.14, blue: 0.06, alpha: 1),
                UIColor(red: 0.28, green: 0.22, blue: 0.08, alpha: 1), t)
        }
    }

    private static func lerp(_ a: UIColor, _ b: UIColor, _ t: CGFloat) -> Color {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t)
        )
    }
}

// MARK: - Layer Activation

private struct LayerActivation {
    let activationStart: CGFloat
    let fullAt: CGFloat

    func progress(for holdProgress: CGFloat) -> CGFloat {
        guard holdProgress > activationStart else { return 0 }
        let range = fullAt - activationStart
        guard range > 0 else { return 1 }
        return min((holdProgress - activationStart) / range, 1.0)
    }

    static let center = LayerActivation(activationStart: 0.00, fullAt: 0.20)
    static let stamen = LayerActivation(activationStart: 0.08, fullAt: 0.30)
    static let inner  = LayerActivation(activationStart: 0.15, fullAt: 0.50)
    static let frontOuter = LayerActivation(activationStart: 0.25, fullAt: 0.65)
    static let backOuter  = LayerActivation(activationStart: 0.35, fullAt: 0.80)
}

// MARK: - Petal Data (pre-computed per frame to help type checker)

private struct PetalData: Identifiable {
    let id: Int
    let angle: Double
    let scale: CGFloat
    let offsetY: CGFloat
    let opacity: Double
}

// MARK: - Sparkle Data

private struct SparkleData: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let isWhite: Bool
    let visible: Bool
}

// MARK: - Flower Bloom Canvas

struct FlowerBloomCanvas: View {
    let outerDesign: OuterPetalDesign
    let innerDesign: InnerPetalDesign
    let stamenDesign: StamenDesign
    let centerDesign: CenterDesign
    let outerColor: Color
    let innerColor: Color
    let stamenColor: Color
    let centerColor: Color
    let geometry: FlowerGeometry

    @Binding var isHolding: Bool

    @State private var holdProgress: CGFloat = 0
    @State private var breathPhase: CGFloat = 0
    @State private var dancePhase: CGFloat = 0
    @State private var colorPhase: CGFloat = 0

    private let haptics = FlowerBloomHapticsEngine()
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    private let bloomDuration: CGFloat = 8.0

    private var danceAmount: CGFloat {
        let entry: CGFloat = 0.75
        guard holdProgress > entry else { return 0 }
        return (holdProgress - entry) / (1.0 - entry)
    }

    var body: some View {
        let bgColor = FlowerBloomBackground.color(at: holdProgress)
        let dance = danceAmount

        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let breathScale: CGFloat = 1.0 + sin(breathPhase) * 0.015

            ZStack {
                bgColor.ignoresSafeArea()

                glowLayer(size: size, center: center, dance: dance)

                bloomBackOuterPetals(size: size, center: center)
                bloomFrontOuterPetals(size: size, center: center)
                bloomInnerPetals(size: size, center: center)
                bloomStamen(size: size, center: center)
                bloomCenter(size: size, center: center)

                if dance > 0 {
                    sparkleLayer(size: size, center: center, dance: dance)
                }
            }
            .scaleEffect(breathScale)
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
            breathPhase += dt * 2.0
            dancePhase += dt * 0.6
            colorPhase += dt * 0.15

            if isHolding {
                holdProgress = min(holdProgress + dt / bloomDuration, 1.0)
                haptics.update(progress: holdProgress)
            } else if holdProgress > 0.001 {
                holdProgress -= holdProgress * 2.5 * dt
                if holdProgress < 0.001 { holdProgress = 0 }
            }
        }
    }

    // MARK: - Glow

    @ViewBuilder
    private func glowLayer(size: CGFloat, center: CGPoint, dance: CGFloat) -> some View {
        let glowRadius: CGFloat = size * 0.15 + holdProgress * size * 0.35 + dance * size * 0.15
        let glowOpacity: Double = Double(0.2 + holdProgress * 0.4 + dance * 0.3)
        let warmGold = Color(red: 1.0, green: 0.85, blue: 0.45)

        Circle()
            .fill(
                RadialGradient(
                    colors: [warmGold.opacity(glowOpacity), warmGold.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: glowRadius
                )
            )
            .frame(width: glowRadius * 2, height: glowRadius * 2)
            .position(center)
    }

    // MARK: - Back Outer Petals

    private func backOuterPetalData(size: CGFloat) -> [PetalData] {
        let layerProg = LayerActivation.backOuter.progress(for: holdProgress)
        let dance = danceAmount
        let count = geometry.backCount
        let petalRadius: CGFloat = size * 0.40
        let petalHeight: CGFloat = petalRadius
        let angleOffset: Double = count > 0 ? 360.0 / Double(count) / 2.0 : 0
        let swayMul: Double = Double(1.0 + dance * 2.0)
        let layerScale: CGFloat = 0.1 + layerProg * 0.9
        let layerOpacity: Double = Double(0.3 + layerProg * 0.7)
        let offMul: CGFloat = 0.2 + layerProg * 0.8
        let baseOff: CGFloat = -petalHeight / 2 - max(petalRadius * 0.30, size * geometry.centerScale * 0.8)
        let dp = Double(dancePhase)

        return (0..<count).map { i in
            let angle: Double = Double(i) * 360.0 / Double(count) + angleOffset
            let seed: Double = Double(i) * 2.4 + 100
            let w1 = sin(dp * 0.8 + seed) * 2.0
            let w2 = sin(dp * 1.3 + seed * 0.4) * 1.0
            let w3 = sin(dp * 0.5 + seed * 1.7) * 0.5
            let sway: Double = (w1 + w2 + w3) * swayMul
            let radPulse: CGFloat = CGFloat(sin(dp * 0.6 + seed * 0.7)) * 0.02
            let scale: CGFloat = (1.0 + radPulse) * layerScale
            return PetalData(id: i, angle: angle + sway, scale: scale,
                             offsetY: baseOff * offMul, opacity: 0.45 * layerOpacity)
        }
    }

    @ViewBuilder
    private func bloomBackOuterPetals(size: CGFloat, center: CGPoint) -> some View {
        let petals = backOuterPetalData(size: size)
        let petalRadius: CGFloat = size * 0.40
        let petalHeight: CGFloat = petalRadius
        let petalWidth: CGFloat = petalHeight * geometry.petalWidth
        let hueAmp: Double = Double(10.0 + danceAmount * 15.0)
        let hueVal: Double = sin(Double(colorPhase)) * hueAmp

        ZStack {
            ForEach(petals) { p in
                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: outerColor.opacity(p.opacity)
                )
                .offset(y: p.offsetY)
                .scaleEffect(p.scale)
                .rotationEffect(.degrees(p.angle))
            }
        }
        .hueRotation(.degrees(hueVal))
        .position(center)
    }

    // MARK: - Front Outer Petals

    private func frontOuterPetalData(size: CGFloat) -> [PetalData] {
        let layerProg = LayerActivation.frontOuter.progress(for: holdProgress)
        let dance = danceAmount
        let count = geometry.outerCount
        let petalRadius: CGFloat = size * 0.35
        let petalHeight: CGFloat = petalRadius * 0.95
        let swayMul: Double = Double(1.0 + dance * 2.0)
        let layerScale: CGFloat = 0.1 + layerProg * 0.9
        let layerOpacity: Double = Double(0.3 + layerProg * 0.7)
        let offMul: CGFloat = 0.2 + layerProg * 0.8
        let baseOff: CGFloat = -petalHeight / 2 - max(petalRadius * 0.35, size * geometry.centerScale * 0.85)
        let dp = Double(dancePhase)

        return (0..<count).map { i in
            let angle: Double = Double(i) * 360.0 / Double(count)
            let seed: Double = Double(i) * 2.4
            let w1 = sin(dp * 0.8 + seed) * 2.5
            let w2 = sin(dp * 1.3 + seed * 0.4) * 1.2
            let w3 = sin(dp * 0.5 + seed * 1.7) * 0.6
            let sway: Double = (w1 + w2 + w3) * swayMul
            let radPulse: CGFloat = CGFloat(sin(dp * 0.6 + seed * 0.7)) * 0.02
            let scale: CGFloat = (1.0 + radPulse) * layerScale
            return PetalData(id: i, angle: angle + sway, scale: scale,
                             offsetY: baseOff * offMul, opacity: 0.85 * layerOpacity)
        }
    }

    @ViewBuilder
    private func bloomFrontOuterPetals(size: CGFloat, center: CGPoint) -> some View {
        let petals = frontOuterPetalData(size: size)
        let petalRadius: CGFloat = size * 0.35
        let petalHeight: CGFloat = petalRadius * 0.95
        let petalWidth: CGFloat = petalHeight * geometry.petalWidth
        let hueAmp: Double = Double(10.0 + danceAmount * 15.0)
        let hueVal: Double = sin(Double(colorPhase) + 0.8) * hueAmp

        ZStack {
            ForEach(petals) { p in
                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: outerColor.opacity(p.opacity)
                )
                .offset(y: p.offsetY)
                .scaleEffect(p.scale)
                .rotationEffect(.degrees(p.angle))
            }
        }
        .hueRotation(.degrees(hueVal))
        .position(center)
    }

    // MARK: - Inner Petals

    private func innerPetalData(size: CGFloat) -> [PetalData] {
        let layerProg = LayerActivation.inner.progress(for: holdProgress)
        let dance = danceAmount
        let count = geometry.innerCount
        let petalRadius: CGFloat = size * 0.22
        let petalHeight: CGFloat = petalRadius * 0.75
        let swayMul: Double = Double(1.0 + dance * 2.0)
        let layerScale: CGFloat = 0.1 + layerProg * 0.9
        let layerOpacity: Double = Double(0.3 + layerProg * 0.7)
        let offMul: CGFloat = 0.2 + layerProg * 0.8
        let baseOff: CGFloat = -petalHeight / 2 - petalRadius * 0.25
        let dp = Double(dancePhase)
        let safeCount = max(count, 1)

        return (0..<count).map { i in
            let angle: Double = Double(i) * 360.0 / Double(safeCount) + 30.0
            let seed: Double = Double(i) * 3.1 + 50.0
            let w1 = sin(dp * 0.72 + seed) * 2.5
            let w2 = sin(dp * 1.35 + seed * 0.4) * 1.2
            let w3 = sin(dp * 0.36 + seed * 1.7) * 0.6
            let sway: Double = (w1 + w2 + w3) * swayMul
            let radPulse: CGFloat = CGFloat(sin(dp * 0.54 + seed * 0.7)) * 0.02
            let scale: CGFloat = (1.0 + radPulse) * layerScale
            return PetalData(id: i, angle: angle + sway, scale: scale,
                             offsetY: baseOff * offMul, opacity: 0.8 * layerOpacity)
        }
    }

    @ViewBuilder
    private func bloomInnerPetals(size: CGFloat, center: CGPoint) -> some View {
        let petals = innerPetalData(size: size)
        let petalRadius: CGFloat = size * 0.22
        let petalHeight: CGFloat = petalRadius * 0.75
        let petalWidth: CGFloat = petalHeight * geometry.innerWidth
        let hueAmp: Double = Double(10.0 + danceAmount * 15.0)
        let hueVal: Double = sin(Double(colorPhase) + 1.6) * hueAmp

        ZStack {
            ForEach(petals) { p in
                innerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: innerColor.opacity(p.opacity)
                )
                .offset(y: p.offsetY)
                .scaleEffect(p.scale)
                .rotationEffect(.degrees(p.angle))
            }
        }
        .hueRotation(.degrees(hueVal))
        .position(center)
    }

    // MARK: - Stamen

    @ViewBuilder
    private func bloomStamen(size: CGFloat, center: CGPoint) -> some View {
        let layerProg = LayerActivation.stamen.progress(for: holdProgress)
        let layerScale: CGFloat = 0.1 + layerProg * 0.9
        let layerOpacity: Double = Double(0.3 + layerProg * 0.7)
        let stamenRadius: CGFloat = size * geometry.stamenScale
        let dp = Double(dancePhase)
        let stamenPulse: CGFloat = CGFloat(1.0 + sin(dp * 0.7) * 0.02 + sin(dp * 1.1) * 0.01)
        let hueAmp: Double = Double(10.0 + danceAmount * 15.0)
        let hueVal: Double = sin(Double(colorPhase) + 2.4) * hueAmp * 0.6

        Group {
            switch stamenDesign {
            case .dewdrops:
                DewdropsStamenView(radius: stamenRadius, color: stamenColor, count: 14)
            case .fairyDust:
                FairyDustStamenView(radius: stamenRadius, color: stamenColor, count: 12)
            case .sunburst:
                SunburstStamenView(radius: stamenRadius, color: stamenColor, count: 16)
            case .tendrils:
                TendrilsStamenView(radius: stamenRadius, color: stamenColor, count: 10)
            case .pollenCloud:
                PollenCloudStamenView(radius: stamenRadius, color: stamenColor)
            case .crown:
                CrownStamenView(radius: stamenRadius, color: stamenColor, count: 8)
            case .corona:
                CoronaStamenView(radius: stamenRadius, color: stamenColor, count: 5)
            }
        }
        .scaleEffect(stamenPulse * layerScale)
        .opacity(layerOpacity)
        .hueRotation(.degrees(hueVal))
        .position(center)
    }

    // MARK: - Center

    @ViewBuilder
    private func bloomCenter(size: CGFloat, center: CGPoint) -> some View {
        let layerProg = LayerActivation.center.progress(for: holdProgress)
        let layerScale: CGFloat = 0.1 + layerProg * 0.9
        let layerOpacity: Double = Double(0.3 + layerProg * 0.7)
        let centerRadius: CGFloat = size * geometry.centerScale
        let dp = Double(dancePhase)
        let centerPulse: CGFloat = CGFloat(1.0 + sin(dp * 0.5) * 0.015)
        let hueAmp: Double = Double(10.0 + danceAmount * 15.0)
        let hueVal: Double = sin(Double(colorPhase) + 3.2) * hueAmp * 0.4
        let centerRotationSpeed: Double = {
            switch centerDesign {
            case .smooth: return 2.0
            case .rings: return 1.5
            case .seedSpiral: return 3.0
            case .gem: return -1.0
            case .swirl: return 4.0
            }
        }()

        Group {
            switch centerDesign {
            case .smooth:
                SmoothCenterView(radius: centerRadius, color: centerColor)
            case .rings:
                RingsCenterView(radius: centerRadius, color: centerColor)
            case .seedSpiral:
                SeedSpiralCenterView(radius: centerRadius, color: centerColor)
            case .gem:
                GemCenterView(radius: centerRadius, color: centerColor)
            case .swirl:
                SwirlCenterView(radius: centerRadius, color: centerColor)
            }
        }
        .rotationEffect(.degrees(dp * centerRotationSpeed))
        .scaleEffect(centerPulse * layerScale)
        .opacity(layerOpacity)
        .hueRotation(.degrees(hueVal))
        .position(center)
    }

    // MARK: - Sparkles

    private func sparkleData(size: CGFloat, center: CGPoint, dance: CGFloat) -> [SparkleData] {
        let baseRadius: CGFloat = size * 0.38
        let dp = Double(dancePhase)

        return (0..<20).map { i in
            let theta: Double = Double(i) * 2.399963
            let radiusFrac: CGFloat = 1.1 + CGFloat(i % 5) * 0.1
            let r: CGFloat = baseRadius * radiusFrac
            let drift: CGFloat = CGFloat(sin(dp * 0.4 + Double(i) * 0.7)) * 8.0
            let rPlusDrift: CGFloat = r + drift
            let x: CGFloat = center.x + rPlusDrift * CGFloat(cos(theta))
            let y: CGFloat = center.y + rPlusDrift * CGFloat(sin(theta))
            let phase: Double = sin(dp * 1.5 + Double(i) * 2.399963)
            let visible = phase > 0
            let sparkleSize: CGFloat = 2.0 + CGFloat(i % 4)
            return SparkleData(id: i, x: x, y: y, size: sparkleSize,
                               isWhite: i % 3 == 0, visible: visible)
        }
    }

    @ViewBuilder
    private func sparkleLayer(size: CGFloat, center: CGPoint, dance: CGFloat) -> some View {
        let sparkles = sparkleData(size: size, center: center, dance: dance)
        let danceOpacity: Double = Double(dance)
        let whiteColor = Color.white
        let goldColor = Color(red: 1.0, green: 0.90, blue: 0.55)

        ForEach(sparkles) { s in
            Circle()
                .fill(s.isWhite
                      ? whiteColor.opacity(0.9 * danceOpacity)
                      : goldColor.opacity(0.8 * danceOpacity))
                .frame(width: s.size, height: s.size)
                .scaleEffect(s.visible ? 1.0 : 0.0)
                .position(x: s.x, y: s.y)
                .animation(.easeInOut(duration: 0.3), value: s.visible)
        }
    }
}
