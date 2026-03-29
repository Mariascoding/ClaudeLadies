import SwiftUI

// MARK: - Outer Petal Shapes

/// Classic Rose — 5 segments per side with 3 visible ruffles creating wavy, curling edges
struct ClassicPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — 5 segments with ruffled edges
        // Seg 1: base to first ruffle outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.42, y: h * 0.78),
            control1: CGPoint(x: midX + w * 0.10, y: h * 0.95),
            control2: CGPoint(x: midX + w * 0.48, y: h * 0.88)
        )
        // Seg 2: first ruffle inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.38, y: h * 0.58),
            control1: CGPoint(x: midX + w * 0.35, y: h * 0.70),
            control2: CGPoint(x: midX + w * 0.46, y: h * 0.64)
        )
        // Seg 3: second ruffle outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.36, y: h * 0.38),
            control1: CGPoint(x: midX + w * 0.30, y: h * 0.52),
            control2: CGPoint(x: midX + w * 0.44, y: h * 0.44)
        )
        // Seg 4: third ruffle inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.22, y: h * 0.18),
            control1: CGPoint(x: midX + w * 0.28, y: h * 0.32),
            control2: CGPoint(x: midX + w * 0.32, y: h * 0.22)
        )
        // Seg 5: converge to tip
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + w * 0.14, y: h * 0.10),
            control2: CGPoint(x: midX + w * 0.06, y: h * 0.02)
        )

        // Left side — mirror 5 segments
        path.addCurve(
            to: CGPoint(x: midX - w * 0.22, y: h * 0.18),
            control1: CGPoint(x: midX - w * 0.06, y: h * 0.02),
            control2: CGPoint(x: midX - w * 0.14, y: h * 0.10)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.36, y: h * 0.38),
            control1: CGPoint(x: midX - w * 0.32, y: h * 0.22),
            control2: CGPoint(x: midX - w * 0.28, y: h * 0.32)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.38, y: h * 0.58),
            control1: CGPoint(x: midX - w * 0.44, y: h * 0.44),
            control2: CGPoint(x: midX - w * 0.30, y: h * 0.52)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.42, y: h * 0.78),
            control1: CGPoint(x: midX - w * 0.46, y: h * 0.64),
            control2: CGPoint(x: midX - w * 0.35, y: h * 0.70)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.48, y: h * 0.88),
            control2: CGPoint(x: midX - w * 0.10, y: h * 0.95)
        )

        path.closeSubpath()
        return path
    }
}

/// Dahlia — quilled, 4 segments per side with slight asymmetry for twist, tubular taper
struct DahliaPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — 4 segments, slight rightward lean for twist
        // Seg 1: narrow base widens
        path.addCurve(
            to: CGPoint(x: midX + w * 0.28, y: h * 0.72),
            control1: CGPoint(x: midX + w * 0.06, y: h * 0.92),
            control2: CGPoint(x: midX + w * 0.32, y: h * 0.82)
        )
        // Seg 2: slight inward curl (quilling)
        path.addCurve(
            to: CGPoint(x: midX + w * 0.22, y: h * 0.48),
            control1: CGPoint(x: midX + w * 0.24, y: h * 0.64),
            control2: CGPoint(x: midX + w * 0.30, y: h * 0.54)
        )
        // Seg 3: tubular narrowing
        path.addCurve(
            to: CGPoint(x: midX + w * 0.14, y: h * 0.24),
            control1: CGPoint(x: midX + w * 0.16, y: h * 0.40),
            control2: CGPoint(x: midX + w * 0.20, y: h * 0.30)
        )
        // Seg 4: taper to tip (shifted right for twist)
        path.addCurve(
            to: CGPoint(x: midX + w * 0.02, y: 0),
            control1: CGPoint(x: midX + w * 0.10, y: h * 0.14),
            control2: CGPoint(x: midX + w * 0.06, y: h * 0.04)
        )

        // Left side — 4 segments, slightly narrower for asymmetric twist
        path.addCurve(
            to: CGPoint(x: midX - w * 0.10, y: h * 0.24),
            control1: CGPoint(x: midX - w * 0.04, y: h * 0.04),
            control2: CGPoint(x: midX - w * 0.06, y: h * 0.14)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.18, y: h * 0.48),
            control1: CGPoint(x: midX - w * 0.16, y: h * 0.30),
            control2: CGPoint(x: midX - w * 0.12, y: h * 0.40)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.24, y: h * 0.72),
            control1: CGPoint(x: midX - w * 0.26, y: h * 0.54),
            control2: CGPoint(x: midX - w * 0.20, y: h * 0.64)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.28, y: h * 0.82),
            control2: CGPoint(x: midX - w * 0.04, y: h * 0.92)
        )

        path.closeSubpath()
        return path
    }
}

/// Peony — tissue-paper ruffles, 6 segments per side with alternating in/out scallops
struct PeonyPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — 6 scalloped segments, wider ruffles near top
        // Seg 1: base outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.38, y: h * 0.82),
            control1: CGPoint(x: midX + w * 0.14, y: h * 0.96),
            control2: CGPoint(x: midX + w * 0.44, y: h * 0.90)
        )
        // Seg 2: scallop inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.32, y: h * 0.66),
            control1: CGPoint(x: midX + w * 0.30, y: h * 0.76),
            control2: CGPoint(x: midX + w * 0.40, y: h * 0.70)
        )
        // Seg 3: scallop outward (bigger ruffle)
        path.addCurve(
            to: CGPoint(x: midX + w * 0.42, y: h * 0.50),
            control1: CGPoint(x: midX + w * 0.26, y: h * 0.60),
            control2: CGPoint(x: midX + w * 0.50, y: h * 0.56)
        )
        // Seg 4: scallop inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.34, y: h * 0.34),
            control1: CGPoint(x: midX + w * 0.36, y: h * 0.44),
            control2: CGPoint(x: midX + w * 0.44, y: h * 0.38)
        )
        // Seg 5: wide ruffle outward near top
        path.addCurve(
            to: CGPoint(x: midX + w * 0.28, y: h * 0.18),
            control1: CGPoint(x: midX + w * 0.26, y: h * 0.28),
            control2: CGPoint(x: midX + w * 0.38, y: h * 0.22)
        )
        // Seg 6: converge to tip
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + w * 0.20, y: h * 0.12),
            control2: CGPoint(x: midX + w * 0.08, y: h * 0.02)
        )

        // Left side — mirror 6 scalloped segments
        path.addCurve(
            to: CGPoint(x: midX - w * 0.28, y: h * 0.18),
            control1: CGPoint(x: midX - w * 0.08, y: h * 0.02),
            control2: CGPoint(x: midX - w * 0.20, y: h * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.34, y: h * 0.34),
            control1: CGPoint(x: midX - w * 0.38, y: h * 0.22),
            control2: CGPoint(x: midX - w * 0.26, y: h * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.42, y: h * 0.50),
            control1: CGPoint(x: midX - w * 0.44, y: h * 0.38),
            control2: CGPoint(x: midX - w * 0.36, y: h * 0.44)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.32, y: h * 0.66),
            control1: CGPoint(x: midX - w * 0.50, y: h * 0.56),
            control2: CGPoint(x: midX - w * 0.26, y: h * 0.60)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.38, y: h * 0.82),
            control1: CGPoint(x: midX - w * 0.40, y: h * 0.70),
            control2: CGPoint(x: midX - w * 0.30, y: h * 0.76)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.44, y: h * 0.90),
            control2: CGPoint(x: midX - w * 0.14, y: h * 0.96)
        )

        path.closeSubpath()
        return path
    }
}

/// Heartleaf — dramatic heart with deeper notch, bulbous lobes
struct HeartleafPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — 4 segments: base swell, widening body, bulbous lobe, deep notch
        // Seg 1: base swells outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.40, y: h * 0.55),
            control1: CGPoint(x: midX + w * 0.12, y: h * 0.90),
            control2: CGPoint(x: midX + w * 0.48, y: h * 0.72)
        )
        // Seg 2: body widens further
        path.addCurve(
            to: CGPoint(x: midX + w * 0.44, y: h * 0.28),
            control1: CGPoint(x: midX + w * 0.36, y: h * 0.44),
            control2: CGPoint(x: midX + w * 0.50, y: h * 0.35)
        )
        // Seg 3: bulbous right lobe curves up and over
        path.addCurve(
            to: CGPoint(x: midX + w * 0.24, y: h * 0.06),
            control1: CGPoint(x: midX + w * 0.42, y: h * 0.16),
            control2: CGPoint(x: midX + w * 0.38, y: h * 0.02)
        )
        // Seg 4: right lobe curves into deep center notch
        path.addCurve(
            to: CGPoint(x: midX, y: h * 0.16),
            control1: CGPoint(x: midX + w * 0.14, y: -h * 0.02),
            control2: CGPoint(x: midX + w * 0.03, y: h * 0.06)
        )

        // Left side — mirror 4 segments
        path.addCurve(
            to: CGPoint(x: midX - w * 0.24, y: h * 0.06),
            control1: CGPoint(x: midX - w * 0.03, y: h * 0.06),
            control2: CGPoint(x: midX - w * 0.14, y: -h * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.44, y: h * 0.28),
            control1: CGPoint(x: midX - w * 0.38, y: h * 0.02),
            control2: CGPoint(x: midX - w * 0.42, y: h * 0.16)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.40, y: h * 0.55),
            control1: CGPoint(x: midX - w * 0.50, y: h * 0.35),
            control2: CGPoint(x: midX - w * 0.36, y: h * 0.44)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.48, y: h * 0.72),
            control2: CGPoint(x: midX - w * 0.12, y: h * 0.90)
        )

        path.closeSubpath()
        return path
    }
}

/// Heartleaf vein overlay — central vein + 2 branching side veins
struct HeartleafVeinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()

        // Central vein from base to notch
        path.move(to: CGPoint(x: midX, y: h))
        path.addCurve(
            to: CGPoint(x: midX, y: h * 0.16),
            control1: CGPoint(x: midX, y: h * 0.70),
            control2: CGPoint(x: midX, y: h * 0.40)
        )

        // Right branching vein
        path.move(to: CGPoint(x: midX, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: midX + w * 0.30, y: h * 0.30),
            control1: CGPoint(x: midX + w * 0.10, y: h * 0.50),
            control2: CGPoint(x: midX + w * 0.22, y: h * 0.38)
        )

        // Left branching vein
        path.move(to: CGPoint(x: midX, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: midX - w * 0.30, y: h * 0.30),
            control1: CGPoint(x: midX - w * 0.10, y: h * 0.50),
            control2: CGPoint(x: midX - w * 0.22, y: h * 0.38)
        )

        return path
    }
}

/// Cosmos — elongated S-curve body with scalloped/notched tip, 12+ segments
struct CosmosPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — 6 segments: S-curve body + scalloped tip
        // Seg 1: narrow base curves outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.14, y: h * 0.78),
            control1: CGPoint(x: midX + w * 0.03, y: h * 0.94),
            control2: CGPoint(x: midX + w * 0.16, y: h * 0.86)
        )
        // Seg 2: S-curve inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.10, y: h * 0.55),
            control1: CGPoint(x: midX + w * 0.12, y: h * 0.70),
            control2: CGPoint(x: midX + w * 0.06, y: h * 0.62)
        )
        // Seg 3: S-curve outward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.18, y: h * 0.34),
            control1: CGPoint(x: midX + w * 0.14, y: h * 0.48),
            control2: CGPoint(x: midX + w * 0.20, y: h * 0.40)
        )
        // Seg 4: first notch at tip — outward scallop
        path.addCurve(
            to: CGPoint(x: midX + w * 0.14, y: h * 0.18),
            control1: CGPoint(x: midX + w * 0.16, y: h * 0.28),
            control2: CGPoint(x: midX + w * 0.20, y: h * 0.22)
        )
        // Seg 5: second notch — inward
        path.addCurve(
            to: CGPoint(x: midX + w * 0.10, y: h * 0.08),
            control1: CGPoint(x: midX + w * 0.08, y: h * 0.14),
            control2: CGPoint(x: midX + w * 0.14, y: h * 0.10)
        )
        // Seg 6: third notch converges to tip
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + w * 0.06, y: h * 0.04),
            control2: CGPoint(x: midX + w * 0.04, y: -h * 0.01)
        )

        // Left side — mirror 6 segments
        path.addCurve(
            to: CGPoint(x: midX - w * 0.10, y: h * 0.08),
            control1: CGPoint(x: midX - w * 0.04, y: -h * 0.01),
            control2: CGPoint(x: midX - w * 0.06, y: h * 0.04)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.14, y: h * 0.18),
            control1: CGPoint(x: midX - w * 0.14, y: h * 0.10),
            control2: CGPoint(x: midX - w * 0.08, y: h * 0.14)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.18, y: h * 0.34),
            control1: CGPoint(x: midX - w * 0.20, y: h * 0.22),
            control2: CGPoint(x: midX - w * 0.16, y: h * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.10, y: h * 0.55),
            control1: CGPoint(x: midX - w * 0.20, y: h * 0.40),
            control2: CGPoint(x: midX - w * 0.14, y: h * 0.48)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.14, y: h * 0.78),
            control1: CGPoint(x: midX - w * 0.06, y: h * 0.62),
            control2: CGPoint(x: midX - w * 0.12, y: h * 0.70)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.16, y: h * 0.86),
            control2: CGPoint(x: midX - w * 0.03, y: h * 0.94)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Inner Petal Shapes

/// Tulip — cupped, flaring outward at top
struct TulipPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right — narrow at base, flares out near top
        path.addCurve(
            to: CGPoint(x: midX + w * 0.35, y: h * 0.08),
            control1: CGPoint(x: midX + w * 0.12, y: h * 0.65),
            control2: CGPoint(x: midX + w * 0.45, y: h * 0.25)
        )

        // Top rounded edge
        path.addQuadCurve(
            to: CGPoint(x: midX - w * 0.35, y: h * 0.08),
            control: CGPoint(x: midX, y: -h * 0.05)
        )

        // Left — mirror
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.45, y: h * 0.25),
            control2: CGPoint(x: midX - w * 0.12, y: h * 0.65)
        )

        path.closeSubpath()
        return path
    }
}

/// Star — kite/diamond shape with straight edges
struct StarPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))
        path.addLine(to: CGPoint(x: midX + w * 0.35, y: h * 0.45))
        path.addLine(to: CGPoint(x: midX, y: 0))
        path.addLine(to: CGPoint(x: midX - w * 0.35, y: h * 0.45))
        path.closeSubpath()
        return path
    }
}

/// Bell — trumpet shape, narrow base, wide top
struct BellPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right — narrow base flaring dramatically at top
        path.addCurve(
            to: CGPoint(x: midX + w * 0.45, y: h * 0.05),
            control1: CGPoint(x: midX + w * 0.06, y: h * 0.7),
            control2: CGPoint(x: midX + w * 0.48, y: h * 0.3)
        )

        // Wide top edge
        path.addQuadCurve(
            to: CGPoint(x: midX - w * 0.45, y: h * 0.05),
            control: CGPoint(x: midX, y: -h * 0.02)
        )

        // Left — mirror
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.48, y: h * 0.3),
            control2: CGPoint(x: midX - w * 0.06, y: h * 0.7)
        )

        path.closeSubpath()
        return path
    }
}

/// Feather — central spine with barbs
struct FeatherPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2
        let barbCount = 5

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right barbs going up
        for i in 0..<barbCount {
            let t = CGFloat(i + 1) / CGFloat(barbCount + 1)
            let y = h * (1.0 - t)
            let barbWidth = w * 0.35 * (1.0 - t * 0.5)
            path.addLine(to: CGPoint(x: midX, y: y + h * 0.04))
            path.addLine(to: CGPoint(x: midX + barbWidth, y: y))
            path.addLine(to: CGPoint(x: midX, y: y - h * 0.01))
        }

        // Tip
        path.addLine(to: CGPoint(x: midX, y: 0))

        // Left barbs going down
        for i in (0..<barbCount).reversed() {
            let t = CGFloat(i + 1) / CGFloat(barbCount + 1)
            let y = h * (1.0 - t)
            let barbWidth = w * 0.35 * (1.0 - t * 0.5)
            path.addLine(to: CGPoint(x: midX, y: y - h * 0.01))
            path.addLine(to: CGPoint(x: midX - barbWidth, y: y))
            path.addLine(to: CGPoint(x: midX, y: y + h * 0.04))
        }

        path.closeSubpath()
        return path
    }
}

/// Lotus — broad, almost elliptical oval
struct LotusPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Right — very broad elliptical shape
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + w * 0.52, y: h * 0.75),
            control2: CGPoint(x: midX + w * 0.52, y: h * 0.25)
        )

        // Left — mirror
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.52, y: h * 0.25),
            control2: CGPoint(x: midX - w * 0.52, y: h * 0.75)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Stamen Views

/// Dewdrops — stalks with teardrop tips
struct DewdropsStamenView: View {
    let radius: CGFloat
    let color: Color
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            let angle = Double(i) * 360.0 / Double(count)
            let lengthVariation: CGFloat = (i % 2 == 0) ? 1.0 : 0.82
            let stalkLength = radius * 0.95 * lengthVariation

            ZStack {
                // Stalk — tapered capsule
                Capsule()
                    .fill(color.opacity(0.55))
                    .frame(width: 2.5, height: stalkLength)
                    .offset(y: -stalkLength / 2)

                // Dewdrop — teardrop ellipse at tip
                Ellipse()
                    .fill(color)
                    .frame(width: 7, height: 9)
                    .offset(y: -stalkLength)

                // Highlight on dewdrop
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 3, height: 3)
                    .offset(x: -1.5, y: -stalkLength - 1.5)
            }
            .rotationEffect(.degrees(angle))
        }
    }
}

/// Sunburst — radiating tapered flame wedges
struct SunburstStamenView: View {
    let radius: CGFloat
    let color: Color
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            let angle = Double(i) * 360.0 / Double(count)
            let lengthVariation: CGFloat = (i % 3 == 0) ? 1.0 : (i % 3 == 1) ? 0.88 : 0.76

            Triangle()
                .fill(color.opacity(0.8))
                .frame(width: 8, height: radius * 0.9 * lengthVariation)
                .offset(y: -radius * 0.9 * lengthVariation / 2)
                .rotationEffect(.degrees(angle))
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Tendrils — sweeping spiral curves with curled tips
struct TendrilsStamenView: View {
    let radius: CGFloat
    let color: Color
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            let angle = Double(i) * 360.0 / Double(count)
            let lengthVariation: CGFloat = (i % 2 == 0) ? 1.0 : 0.85

            TendrilShape()
                .stroke(color.opacity(0.75), lineWidth: 2.5)
                .frame(width: 14, height: radius * 0.92 * lengthVariation)
                .offset(y: -radius * 0.92 * lengthVariation / 2)
                .rotationEffect(.degrees(angle))
        }
    }
}

private struct TendrilShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))

        // Spiral curve upward with a curl at the tip
        path.addCurve(
            to: CGPoint(x: midX + w * 0.3, y: h * 0.15),
            control1: CGPoint(x: midX - w * 0.4, y: h * 0.65),
            control2: CGPoint(x: midX + w * 0.5, y: h * 0.35)
        )
        path.addQuadCurve(
            to: CGPoint(x: midX + w * 0.1, y: h * 0.05),
            control: CGPoint(x: midX + w * 0.4, y: -h * 0.02)
        )

        return path
    }
}

/// Pollen Cloud — scattered circles in golden-angle distribution
struct PollenCloudStamenView: View {
    let radius: CGFloat
    let color: Color

    private var dots: [(CGFloat, CGFloat, CGFloat)] {
        // Deterministic positions using golden angle distribution
        let count = 28
        var result: [(CGFloat, CGFloat, CGFloat)] = []
        for i in 0..<count {
            let r = radius * 0.2 + radius * 0.75 * sqrt(CGFloat(i) / CGFloat(count))
            let theta = CGFloat(i) * 2.399963 // golden angle in radians
            let size: CGFloat = 3.5 + CGFloat(i % 4) * 1.8
            result.append((r * cos(theta), r * sin(theta), size))
        }
        return result
    }

    var body: some View {
        ForEach(0..<dots.count, id: \.self) { i in
            Circle()
                .fill(color.opacity(0.45 + Double(i % 4) * 0.12))
                .frame(width: dots[i].2, height: dots[i].2)
                .offset(x: dots[i].0, y: dots[i].1)
        }
    }
}

/// Crown — paired filaments with oval anthers, splayed outward
struct CrownStamenView: View {
    let radius: CGFloat
    let color: Color
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            let angle = Double(i) * 360.0 / Double(count)
            let stalkLength = radius * 0.9

            ZStack {
                // Left filament — splayed outward
                Capsule()
                    .fill(color.opacity(0.5))
                    .frame(width: 2, height: stalkLength)
                    .offset(x: -4, y: -stalkLength / 2)
                    .rotationEffect(.degrees(5))

                // Right filament — splayed outward
                Capsule()
                    .fill(color.opacity(0.5))
                    .frame(width: 2, height: stalkLength)
                    .offset(x: 4, y: -stalkLength / 2)
                    .rotationEffect(.degrees(-5))

                // Left anther — larger, tilted
                Ellipse()
                    .fill(color)
                    .frame(width: 6, height: 9)
                    .rotationEffect(.degrees(15))
                    .offset(x: -5.5, y: -stalkLength)

                // Right anther — larger, tilted
                Ellipse()
                    .fill(color)
                    .frame(width: 6, height: 9)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 5.5, y: -stalkLength)
            }
            .rotationEffect(.degrees(angle))
        }
    }
}

// MARK: - Center Views

/// Smooth — radial gradient dome with highlight and subtle rim
struct SmoothCenterView: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            // Base disc
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Rim shadow
            Circle()
                .strokeBorder(color.opacity(0.3), lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)

            // Highlight — off-center dome shine
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0)],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: radius * 0.6
                    )
                )
                .frame(width: radius * 1.4, height: radius * 1.4)

            // Tiny textured dots for realism
            ForEach(0..<8, id: \.self) { i in
                let angle = CGFloat(i) * .pi / 4
                let r = radius * 0.45
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 2.5, height: 2.5)
                    .offset(x: r * cos(angle), y: r * sin(angle))
            }
        }
    }
}

/// Rings — 5 concentric rings with gradient fill and textured inner core
struct RingsCenterView: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            // Outermost soft glow
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: radius * 2.3, height: radius * 2.3)

            // Ring 1 — outer
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)

            // Ring 2
            Circle()
                .stroke(color.opacity(0.7), lineWidth: 1.5)
                .frame(width: radius * 1.55, height: radius * 1.55)

            // Ring 3
            Circle()
                .stroke(color.opacity(0.55), lineWidth: 1.2)
                .frame(width: radius * 1.15, height: radius * 1.15)

            // Ring 4
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 1)
                .frame(width: radius * 0.8, height: radius * 0.8)

            // Filled core with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), color.opacity(0.4)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.3
                    )
                )
                .frame(width: radius * 0.5, height: radius * 0.5)
        }
    }
}

/// Seed Spiral — dense Fibonacci golden-angle seeds with background disc
struct SeedSpiralCenterView: View {
    let radius: CGFloat
    let color: Color

    private var seeds: [(CGFloat, CGFloat, CGFloat, Double)] {
        let count = 55
        var result: [(CGFloat, CGFloat, CGFloat, Double)] = []
        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count)
            let r = radius * 0.9 * sqrt(t)
            let theta = CGFloat(i) * 2.399963
            let size: CGFloat = 1.8 + t * 2.8
            let opacity = 0.35 + Double(t) * 0.55
            result.append((r * cos(theta), r * sin(theta), size, opacity))
        }
        return result
    }

    var body: some View {
        ZStack {
            // Background disc
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: radius * 2, height: radius * 2)

            // Seeds
            ForEach(0..<seeds.count, id: \.self) { i in
                Ellipse()
                    .fill(color.opacity(seeds[i].3))
                    .frame(width: seeds[i].2, height: seeds[i].2 * 1.3)
                    .rotationEffect(.degrees(Double(i) * 137.508))
                    .offset(x: seeds[i].0, y: seeds[i].1)
            }

            // Center pip
            Circle()
                .fill(color)
                .frame(width: 3.5, height: 3.5)
        }
    }
}

/// Gem — layered faceted hexagons with inner star and glow
struct GemCenterView: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            // Soft glow behind
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: radius * 2.4, height: radius * 2.4)

            // Outer hexagon filled
            HexagonShape()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.45), color.opacity(0.15)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Outer hexagon stroke
            HexagonShape()
                .stroke(color, lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)

            // Facet lines — center to vertices
            GemFacetLines()
                .stroke(color.opacity(0.4), lineWidth: 0.8)
                .frame(width: radius * 2, height: radius * 2)

            // Mid hexagon
            HexagonShape()
                .stroke(color.opacity(0.6), lineWidth: 1.2)
                .frame(width: radius * 1.2, height: radius * 1.2)

            // Inner hexagon filled
            HexagonShape()
                .fill(color.opacity(0.5))
                .frame(width: radius * 0.6, height: radius * 0.6)

            // Star highlight
            GemStarShape()
                .fill(Color.white.opacity(0.25))
                .frame(width: radius * 1.4, height: radius * 1.4)
        }
    }
}

private struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

private struct GemFacetLines: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle)))
        }
        return path
    }
}

/// 6-pointed star highlight for gem center
private struct GemStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.35
        var path = Path()
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi / 6 - .pi / 2
            let r = (i % 2 == 0) ? outerR : innerR
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// Swirl — double logarithmic spiral with filled core
struct SwirlCenterView: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            // Background disc
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: radius * 2, height: radius * 2)

            // Primary spiral
            SpiralShape(turns: 3.5)
                .stroke(color.opacity(0.85), lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)

            // Secondary spiral — counter-rotated for depth
            SpiralShape(turns: 3.5)
                .stroke(color.opacity(0.4), lineWidth: 1.2)
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(180))

            // Core dot
            Circle()
                .fill(color)
                .frame(width: 4, height: 4)
        }
    }
}

private struct SpiralShape: Shape {
    let turns: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxR = min(rect.width, rect.height) / 2
        let steps = 100

        var path = Path()
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let angle = t * turns * 2 * .pi
            let r = maxR * t
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }
}

// MARK: - Shape Resolvers

extension OuterPetalDesign {
    @ViewBuilder
    func shape(in size: CGSize, color: Color) -> some View {
        switch self {
        case .classic:
            ClassicPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .dahlia:
            DahliaPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .peony:
            PeonyPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .heartleaf:
            ZStack {
                HeartleafPetalShape().fill(color)
                    .frame(width: size.width, height: size.height)
                HeartleafVeinShape()
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: size.width, height: size.height)
            }
        case .cosmos:
            CosmosPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        }
    }
}

extension InnerPetalDesign {
    @ViewBuilder
    func shape(in size: CGSize, color: Color) -> some View {
        switch self {
        case .tulip:
            TulipPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .star:
            StarPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .bell:
            BellPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .feather:
            FeatherPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        case .lotus:
            LotusPetalShape().fill(color)
                .frame(width: size.width, height: size.height)
        }
    }
}
