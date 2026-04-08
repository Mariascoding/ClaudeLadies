import SwiftUI

struct FlowerBuilderCanvas: View {
    let outerDesign: OuterPetalDesign
    let innerDesign: InnerPetalDesign
    let stamenDesign: StamenDesign
    let centerDesign: CenterDesign

    @State private var breathPhase: CGFloat = 0
    @State private var dancePhase: CGFloat = 0
    @State private var colorPhase: CGFloat = 0
    @State private var appeared: Bool = false
    @State private var animationTask: Task<Void, Never>?

    // Colors
    let outerColor: Color
    let innerColor: Color
    let stamenColor: Color
    let centerColor: Color

    var geometry: FlowerGeometry = .default
    var isAnimating: Bool = true

    // Paint mode
    var isPaintMode: Bool = false
    var petalColors: [String: Color] = [:]
    var selectedPart: FlowerPart = .outerPetals
    var onPetalTap: ((String) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let breathScale = 1.0 + sin(breathPhase) * 0.025 + sin(breathPhase * 0.37) * 0.010

            ZStack {
                animatedBackOuterPetals(size: size, center: center)
                animatedFrontOuterPetals(size: size, center: center)
                animatedInnerPetals(size: size, center: center)
                animatedStamen(size: size, center: center)
                animatedCenter(size: size, center: center)
            }
            .scaleEffect(breathScale)
            .allowsHitTesting(false)

            // Paint mode: transparent overlay captures taps and routes to nearest petal
            if isPaintMode {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                if let key = closestPetalKey(
                                    at: value.location,
                                    center: center,
                                    size: size,
                                    breathScale: breathScale
                                ) {
                                    onPetalTap?(key)
                                }
                            }
                    )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                appeared = true
            }
            if isAnimating { startAnimating() }
        }
        .onDisappear {
            animationTask?.cancel()
            animationTask = nil
        }
        .onChange(of: isAnimating) { _, animating in
            if animating {
                startAnimating()
            } else {
                animationTask?.cancel()
                animationTask = nil
            }
        }
        .onChange(of: outerDesign) { _, _ in retriggerGrowth() }
        .onChange(of: innerDesign) { _, _ in retriggerGrowth() }
        .onChange(of: stamenDesign) { _, _ in retriggerGrowth() }
        .onChange(of: centerDesign) { _, _ in retriggerGrowth() }
        .onChange(of: geometry) { _, _ in retriggerGrowth() }
    }

    // MARK: - Animated Layer Wrappers

    @ViewBuilder
    private func animatedBackOuterPetals(size: CGFloat, center: CGPoint) -> some View {
        outerPetalsBackLayer(size: size)
            .scaleEffect(appeared ? 1.0 : 0.01)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.00), value: appeared)
            .hueRotation(.degrees(Double(sin(colorPhase) * 10)))
            .position(center)
    }

    @ViewBuilder
    private func animatedFrontOuterPetals(size: CGFloat, center: CGPoint) -> some View {
        outerPetalsLayer(size: size)
            .scaleEffect(appeared ? 1.0 : 0.01)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.06), value: appeared)
            .hueRotation(.degrees(Double(sin(colorPhase + 0.8) * 12)))
            .position(center)
    }

    @ViewBuilder
    private func animatedInnerPetals(size: CGFloat, center: CGPoint) -> some View {
        innerPetalsLayer(size: size)
            .scaleEffect(appeared ? 1.0 : 0.01)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.75, dampingFraction: 0.6).delay(0.12), value: appeared)
            .hueRotation(.degrees(Double(sin(colorPhase + 1.6) * 14)))
            .position(center)
    }

    @ViewBuilder
    private func animatedStamen(size: CGFloat, center: CGPoint) -> some View {
        stamenLayer(size: size)
            .scaleEffect(appeared ? 1.0 : 0.01)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.20), value: appeared)
            .hueRotation(.degrees(Double(sin(colorPhase + 2.4) * 8)))
            .position(center)
    }

    @ViewBuilder
    private func animatedCenter(size: CGFloat, center: CGPoint) -> some View {
        centerLayer(size: size)
            .scaleEffect(appeared ? 1.0 : 0.01)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.65, dampingFraction: 0.55).delay(0.28), value: appeared)
            .hueRotation(.degrees(Double(sin(colorPhase + 3.2) * 6)))
            .position(center)
    }

    // MARK: - Back Outer Petals

    @ViewBuilder
    private func outerPetalsBackLayer(size: CGFloat) -> some View {
        let count = geometry.backCount
        let petalRadius = size * 0.40
        let petalHeight = petalRadius * 1.0
        let petalWidth = petalHeight * geometry.petalWidth
        let angleOffset = count > 0 ? 360.0 / Double(count) / 2.0 : 0

        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(count) + angleOffset
                let seed = Double(i) * 2.4 + 100
                let sway = sin(dancePhase * 0.8 + seed) * 2.0
                         + sin(dancePhase * 1.3 + seed * 0.4) * 1.0
                         + sin(dancePhase * 0.5 + seed * 1.7) * 0.5
                let radialPulse = sin(dancePhase * 0.6 + seed * 0.7) * 0.02
                let petalKey = "backOuter-\(i)"
                let baseColor = petalColors[petalKey] ?? outerColor
                let baseOpacity = 0.45
                let gradientOpacity = petalGradientOpacity(baseOpacity: baseOpacity, angleDegrees: angle, strength: geometry.outerGradientStrength)

                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: baseColor.opacity(gradientOpacity)
                )
                .offset(y: -petalHeight / 2 - max(petalRadius * 0.30, size * geometry.centerScale * 0.8))
                .scaleEffect(1.0 + radialPulse)
                .rotationEffect(.degrees(angle + sway))
            }
        }
    }

    // MARK: - Outer Petals

    @ViewBuilder
    private func outerPetalsLayer(size: CGFloat) -> some View {
        let count = geometry.outerCount
        let petalRadius = size * 0.35
        let petalHeight = petalRadius * 0.95
        let petalWidth = petalHeight * geometry.petalWidth

        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(count)
                let seed = Double(i) * 2.4
                let sway = sin(dancePhase * 0.8 + seed) * 2.5
                         + sin(dancePhase * 1.3 + seed * 0.4) * 1.2
                         + sin(dancePhase * 0.5 + seed * 1.7) * 0.6
                let radialPulse = sin(dancePhase * 0.6 + seed * 0.7) * 0.02
                let petalKey = "frontOuter-\(i)"
                let baseColor = petalColors[petalKey] ?? outerColor
                let baseOpacity = 0.85
                let gradientOpacity = petalGradientOpacity(baseOpacity: baseOpacity, angleDegrees: angle, strength: geometry.outerGradientStrength)

                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: baseColor.opacity(gradientOpacity)
                )
                .offset(y: -petalHeight / 2 - max(petalRadius * 0.35, size * geometry.centerScale * 0.85))
                .scaleEffect(1.0 + radialPulse)
                .rotationEffect(.degrees(angle + sway))
            }
        }
    }

    // MARK: - Inner Petals

    @ViewBuilder
    private func innerPetalsLayer(size: CGFloat) -> some View {
        let count = geometry.innerCount
        let petalRadius = size * 0.22
        let petalHeight = petalRadius * 0.75
        let petalWidth = petalHeight * geometry.innerWidth

        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(max(count, 1)) + 30 // offset from outer
                let seed = Double(i) * 3.1 + 50
                let sway = sin(dancePhase * 0.72 + seed) * 2.5
                         + sin(dancePhase * 1.35 + seed * 0.4) * 1.2
                         + sin(dancePhase * 0.36 + seed * 1.7) * 0.6
                let radialPulse = sin(dancePhase * 0.54 + seed * 0.7) * 0.02
                let petalKey = "inner-\(i)"
                let baseColor = petalColors[petalKey] ?? innerColor
                let baseOpacity = 0.8
                let gradientOpacity = petalGradientOpacity(baseOpacity: baseOpacity, angleDegrees: angle, strength: geometry.innerGradientStrength)

                innerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: baseColor.opacity(gradientOpacity)
                )
                .offset(y: -petalHeight / 2 - petalRadius * 0.25)
                .scaleEffect(1.0 + radialPulse)
                .rotationEffect(.degrees(angle + sway))
            }
        }
    }

    // MARK: - Stamen

    @ViewBuilder
    private func stamenLayer(size: CGFloat) -> some View {
        let stamenRadius = size * geometry.stamenScale
        let stamenPulse = 1.0 + sin(dancePhase * 0.7) * 0.02 + sin(dancePhase * 1.1) * 0.01

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
        .scaleEffect(stamenPulse)
    }

    // MARK: - Center

    @ViewBuilder
    private func centerLayer(size: CGFloat) -> some View {
        let centerRadius = size * geometry.centerScale
        let centerPulse = 1.0 + sin(dancePhase * 0.5) * 0.015
        let centerRotationSpeed: CGFloat = {
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
        .rotationEffect(.degrees(dancePhase * centerRotationSpeed))
        .scaleEffect(centerPulse)
    }

    // MARK: - Helpers

    private func startAnimating() {
        animationTask?.cancel()
        animationTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(33))
                guard !Task.isCancelled else { break }
                let dt: CGFloat = 1.0 / 30.0
                breathPhase += dt * 1.2
                dancePhase += dt * 0.6
                colorPhase += dt * 0.15
            }
        }
    }

    private func retriggerGrowth() {
        appeared = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                appeared = true
            }
        }
    }

    /// Computes per-petal opacity with gradient fade around the circle.
    /// At strength 0: returns baseOpacity unchanged.
    /// At strength 1: full opacity at top (0°), fades to 15% at bottom (180°).
    private func petalGradientOpacity(baseOpacity: Double, angleDegrees: Double, strength: CGFloat) -> Double {
        guard strength > 0 else { return baseOpacity }
        let angleRadians = angleDegrees * .pi / 180.0
        let gradientFactor = 1.0 - Double(strength) * (1.0 - cos(angleRadians)) / 2.0
        return max(baseOpacity * gradientFactor, 0.15)
    }

    // MARK: - Paint Hit Detection

    /// Determines the nearest petal key for a tap point.
    /// Uses `selectedPart` to route taps to the correct layer — this ensures inner petals
    /// are always reachable when the inner petal tab is active (even behind stamen).
    private func closestPetalKey(at point: CGPoint, center: CGPoint, size: CGFloat, breathScale: Double) -> String? {
        // Compensate for breathScale — petals are rendered scaled around center,
        // but the tap overlay is in unscaled space
        let dx = (point.x - center.x) / breathScale
        let dy = (point.y - center.y) / breathScale
        let distance = sqrt(dx * dx + dy * dy)

        // Angle in degrees from top (12 o'clock), clockwise
        var angleDeg = atan2(dx, -dy) * 180.0 / .pi
        if angleDeg < 0 { angleDeg += 360 }

        // Only reject taps right on the tiny center disc
        let centerDisc = size * geometry.centerScale * 0.5
        if distance < centerDisc { return nil }

        switch selectedPart {
        case .innerPetals:
            // Inner petal tab active: every tap outside center targets an inner petal
            if geometry.innerCount > 0 {
                return closestPetalInLayer(angleDeg: angleDeg, count: geometry.innerCount, angleOffset: 30, prefix: "inner")
            }
            return nil

        case .outerPetals:
            // Outer petal tab: split between front outer (closer) and back outer (further)
            let splitDistance = size * 0.38
            if distance < splitDistance && geometry.outerCount > 0 {
                return closestPetalInLayer(angleDeg: angleDeg, count: geometry.outerCount, angleOffset: 0, prefix: "frontOuter")
            } else if geometry.backCount > 0 {
                let backOffset = geometry.backCount > 0 ? 360.0 / Double(geometry.backCount) / 2.0 : 0
                return closestPetalInLayer(angleDeg: angleDeg, count: geometry.backCount, angleOffset: backOffset, prefix: "backOuter")
            } else if geometry.outerCount > 0 {
                return closestPetalInLayer(angleDeg: angleDeg, count: geometry.outerCount, angleOffset: 0, prefix: "frontOuter")
            }
            return nil

        case .stamen, .center:
            // Stamen/center tabs shouldn't normally be in paint mode,
            // but fallback to auto-detect by distance
            if geometry.outerCount > 0 {
                return closestPetalInLayer(angleDeg: angleDeg, count: geometry.outerCount, angleOffset: 0, prefix: "frontOuter")
            }
            return nil
        }
    }

    private func closestPetalInLayer(angleDeg: Double, count: Int, angleOffset: Double, prefix: String) -> String {
        guard count > 0 else { return "\(prefix)-0" }
        let anglePerPetal = 360.0 / Double(count)
        var adjusted = angleDeg - angleOffset
        // Normalize to [0, 360)
        adjusted = adjusted.truncatingRemainder(dividingBy: 360)
        if adjusted < 0 { adjusted += 360 }
        var index = Int((adjusted / anglePerPetal).rounded())
        if index >= count { index = 0 }
        return "\(prefix)-\(index)"
    }
}
