import SwiftUI

struct FlowerBuilderCanvas: View {
    let outerDesign: OuterPetalDesign
    let innerDesign: InnerPetalDesign
    let stamenDesign: StamenDesign
    let centerDesign: CenterDesign

    @State private var breathPhase: CGFloat = 0

    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    // Colors
    let outerColor: Color
    let innerColor: Color
    let stamenColor: Color
    let centerColor: Color

    private let outerPetalCount = 8
    private let backPetalCount = 8
    private let innerPetalCount = 6

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let breathScale = 1.0 + sin(breathPhase) * 0.015

            ZStack {
                // Layer 0: Back outer petals (peeking through gaps)
                outerPetalsBackLayer(size: size)
                    .position(center)

                // Layer 1: Front outer petals
                outerPetalsLayer(size: size)
                    .position(center)

                // Layer 2: Inner petals
                innerPetalsLayer(size: size)
                    .position(center)

                // Layer 3: Stamen
                stamenLayer(size: size)
                    .position(center)

                // Layer 4: Center
                centerLayer(size: size)
                    .position(center)
            }
            .scaleEffect(breathScale)
        }
        .onReceive(timer) { _ in
            breathPhase += 1.0 / 30.0 * 1.2
        }
    }

    // MARK: - Back Outer Petals

    @ViewBuilder
    private func outerPetalsBackLayer(size: CGFloat) -> some View {
        let petalRadius = size * 0.40
        let petalHeight = petalRadius * 1.0
        let petalWidth = petalHeight * 0.55
        let angleOffset = 360.0 / Double(backPetalCount) / 2.0 // half-step rotation

        ZStack {
            ForEach(0..<backPetalCount, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(backPetalCount) + angleOffset

                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: outerColor.opacity(0.45)
                )
                .offset(y: -petalHeight / 2 - petalRadius * 0.30)
                .rotationEffect(.degrees(angle))
            }
        }
    }

    // MARK: - Outer Petals

    @ViewBuilder
    private func outerPetalsLayer(size: CGFloat) -> some View {
        let petalRadius = size * 0.35
        let petalHeight = petalRadius * 0.95
        let petalWidth = petalHeight * 0.6

        ZStack {
            ForEach(0..<outerPetalCount, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(outerPetalCount)

                outerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: outerColor.opacity(0.85)
                )
                .offset(y: -petalHeight / 2 - petalRadius * 0.35)
                .rotationEffect(.degrees(angle))
            }
        }
    }

    // MARK: - Inner Petals

    @ViewBuilder
    private func innerPetalsLayer(size: CGFloat) -> some View {
        let petalRadius = size * 0.22
        let petalHeight = petalRadius * 0.75
        let petalWidth = petalHeight * 0.5

        ZStack {
            ForEach(0..<innerPetalCount, id: \.self) { i in
                let angle = Double(i) * 360.0 / Double(innerPetalCount) + 30 // offset from outer

                innerDesign.shape(
                    in: CGSize(width: petalWidth, height: petalHeight),
                    color: innerColor.opacity(0.8)
                )
                .offset(y: -petalHeight / 2 - petalRadius * 0.25)
                .rotationEffect(.degrees(angle))
            }
        }
    }

    // MARK: - Stamen

    @ViewBuilder
    private func stamenLayer(size: CGFloat) -> some View {
        let stamenRadius = size * 0.22

        switch stamenDesign {
        case .dewdrops:
            DewdropsStamenView(radius: stamenRadius, color: stamenColor, count: 14)
        case .sunburst:
            SunburstStamenView(radius: stamenRadius, color: stamenColor, count: 16)
        case .tendrils:
            TendrilsStamenView(radius: stamenRadius, color: stamenColor, count: 10)
        case .pollenCloud:
            PollenCloudStamenView(radius: stamenRadius, color: stamenColor)
        case .crown:
            CrownStamenView(radius: stamenRadius, color: stamenColor, count: 8)
        }
    }

    // MARK: - Center

    @ViewBuilder
    private func centerLayer(size: CGFloat) -> some View {
        let centerRadius = size * 0.11

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
}
