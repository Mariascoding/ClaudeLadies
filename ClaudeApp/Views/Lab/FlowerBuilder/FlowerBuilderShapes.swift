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

/// Round — smooth broad elliptical petal (same geometry as LotusPetalShape)
struct RoundPetalShape: Shape {
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

/// Delicate center vein for round petals — single midrib fading from base outward
struct RoundPetalVeinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let h = rect.height
        let midX = rect.width / 2

        var path = Path()
        path.move(to: CGPoint(x: midX, y: h))
        // Gentle curve from base to tip
        path.addCurve(
            to: CGPoint(x: midX, y: h * 0.1),
            control1: CGPoint(x: midX, y: h * 0.65),
            control2: CGPoint(x: midX, y: h * 0.35)
        )
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

/// Corona — 5 smooth elongated teardrop rays radiating from center (forget-me-not white star)
struct CoronaStamenView: View {
    let radius: CGFloat
    let color: Color
    let count: Int

    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            let angle = Double(i) * 360.0 / Double(count)

            CoronaRayShape()
                .fill(color.opacity(0.85))
                .frame(width: radius * 0.45, height: radius * 0.9)
                .offset(y: -radius * 0.45)
                .rotationEffect(.degrees(angle))
        }
    }
}

/// Smooth elongated teardrop ray for corona stamen
private struct CoronaRayShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2

        var path = Path()
        // Start at base (center of flower)
        path.move(to: CGPoint(x: midX, y: h))

        // Right side — smooth bulging teardrop
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + w * 0.45, y: h * 0.65),
            control2: CGPoint(x: midX + w * 0.25, y: h * 0.15)
        )

        // Left side — mirror
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX - w * 0.25, y: h * 0.15),
            control2: CGPoint(x: midX - w * 0.45, y: h * 0.65)
        )

        path.closeSubpath()
        return path
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

/// Smooth — Realistic dome of disc florets (daisy-like)
struct SmoothCenterView: View {
    let radius: CGFloat
    let color: Color

    // Disc florets in 3 concentric rings with organic offset
    private var florets: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] {
        var result: [(CGFloat, CGFloat, CGFloat, Double)] = []
        let rings: [(count: Int, radiusFraction: CGFloat, size: CGFloat, opacity: Double)] = [
            (16, 0.82, 2.8, 0.45),  // outer ring — small, dark
            (12, 0.55, 3.2, 0.55),  // middle ring
            (10, 0.30, 3.6, 0.70),  // inner ring — larger, brighter
        ]
        for ring in rings {
            for i in 0..<ring.count {
                let baseAngle = CGFloat(i) * 2 * .pi / CGFloat(ring.count)
                // Slight organic jitter using deterministic offset
                let jitter = CGFloat(i * 7 % 5) * 0.06 - 0.12
                let angle = baseAngle + jitter
                let r = radius * ring.radiusFraction + CGFloat(i % 3) * 0.8
                result.append((r * cos(angle), r * sin(angle), ring.size, ring.opacity))
            }
        }
        return result
    }

    // Pollen dust dots on the inner ring
    private var pollenDots: [(x: CGFloat, y: CGFloat)] {
        var result: [(CGFloat, CGFloat)] = []
        for i in 0..<12 {
            let angle = CGFloat(i) * 2 * .pi / 12 + CGFloat(i % 3) * 0.15
            let r = radius * 0.22 + CGFloat(i % 4) * 1.2
            result.append((r * cos(angle), r * sin(angle)))
        }
        return result
    }

    var body: some View {
        ZStack {
            // Background dome disc — 3D radial gradient (dark rim → lighter center)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.85), color.opacity(0.5), color.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Rim shadow for depth
            Circle()
                .strokeBorder(
                    RadialGradient(
                        colors: [color.opacity(0.1), color.opacity(0.5)],
                        center: .center,
                        startRadius: radius * 0.7,
                        endRadius: radius
                    ),
                    lineWidth: 3
                )
                .frame(width: radius * 2, height: radius * 2)

            // Disc florets — ~38 tiny circles in 3 concentric rings
            ForEach(0..<florets.count, id: \.self) { i in
                Circle()
                    .fill(color.opacity(florets[i].opacity))
                    .frame(width: florets[i].size, height: florets[i].size)
                    .offset(x: florets[i].x, y: florets[i].y)
            }

            // Pollen dusting — bright yellow-white specks
            ForEach(0..<pollenDots.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 1.8, height: 1.8)
                    .offset(x: pollenDots[i].x, y: pollenDots[i].y)
            }

            // Central stigma — raised dome with strong highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.7)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.18
                    )
                )
                .frame(width: radius * 0.32, height: radius * 0.32)

            // Stigma highlight — off-center white shine
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0)],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: radius * 0.18
                    )
                )
                .frame(width: radius * 0.32, height: radius * 0.32)

            // Dome-wide highlight for 3D illusion
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0)],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: radius * 0.7
                    )
                )
                .frame(width: radius * 1.6, height: radius * 1.6)
        }
    }
}

/// Rings — Tubular floret rings (sunflower-like)
struct RingsCenterView: View {
    let radius: CGFloat
    let color: Color

    // 5 rings of radial floret tubes, getting larger toward the edge
    private struct FloretTube: Identifiable {
        let id: Int
        let ringRadius: CGFloat
        let angle: CGFloat
        let width: CGFloat
        let height: CGFloat
        let opacity: Double
    }

    private var floretTubes: [FloretTube] {
        var result: [FloretTube] = []
        var idCounter = 0
        let rings: [(count: Int, radiusFraction: CGFloat, tubeW: CGFloat, tubeH: CGFloat, opacity: Double)] = [
            (16, 0.88, 3.5, 7.0, 0.40),   // outermost — largest, lightest
            (14, 0.70, 3.0, 6.0, 0.50),
            (12, 0.53, 2.5, 5.0, 0.60),
            (12, 0.38, 2.2, 4.5, 0.70),
            (10, 0.22, 2.0, 4.0, 0.80),    // innermost — smallest, darkest
        ]
        for ring in rings {
            for i in 0..<ring.count {
                let angle = CGFloat(i) * 2 * .pi / CGFloat(ring.count)
                let r = radius * ring.radiusFraction
                result.append(FloretTube(
                    id: idCounter,
                    ringRadius: r,
                    angle: angle,
                    width: ring.tubeW,
                    height: ring.tubeH,
                    opacity: ring.opacity
                ))
                idCounter += 1
            }
        }
        return result
    }

    var body: some View {
        ZStack {
            // Warm radial gradient disc background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.75), color.opacity(0.45), color.opacity(0.2)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Ring separator circles between floret bands
            ForEach([0.95, 0.78, 0.60, 0.45, 0.30], id: \.self) { frac in
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 0.6)
                    .frame(width: radius * 2 * frac, height: radius * 2 * frac)
            }

            // Floret tubes — rounded rects arranged radially
            ForEach(floretTubes) { tube in
                RoundedRectangle(cornerRadius: tube.width * 0.4)
                    .fill(color.opacity(tube.opacity))
                    .frame(width: tube.width, height: tube.height)
                    .offset(y: -tube.ringRadius)
                    .rotationEffect(.radians(Double(tube.angle)))
            }

            // Dense core with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.9), color.opacity(0.5)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.12
                    )
                )
                .frame(width: radius * 0.2, height: radius * 0.2)

            // Pollen dot cluster on core
            ForEach(0..<6, id: \.self) { i in
                let angle = CGFloat(i) * .pi / 3
                let r: CGFloat = radius * 0.06
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 1.5, height: 1.5)
                    .offset(x: r * cos(angle), y: r * sin(angle))
            }
        }
    }
}

/// Seed Spiral — Enhanced Fibonacci spiral (sunflower seed head) with 89 teardrop seeds
struct SeedSpiralCenterView: View {
    let radius: CGFloat
    let color: Color

    private struct Seed: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let angle: Double  // orientation along spiral
        let dark: Bool     // alternating two-tone pattern
    }

    private var seeds: [Seed] {
        let count = 89  // Fibonacci number for dense pattern
        var result: [Seed] = []
        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count)
            let r = radius * 0.92 * sqrt(t)
            let theta = CGFloat(i) * 2.399963  // golden angle
            let x = r * cos(theta)
            let y = r * sin(theta)
            // Size gradient: smaller at center, larger at edge
            let size: CGFloat = 1.5 + t * 3.5
            // Spiral direction for orienting the teardrop
            let spiralAngle = Double(atan2(y, x)) * 180 / .pi + 90
            // Two-tone: alternate in a Fibonacci-inspired pattern
            let dark = (i % 3 != 0)
            result.append(Seed(id: i, x: x, y: y, size: size, angle: spiralAngle, dark: dark))
        }
        return result
    }

    var body: some View {
        ZStack {
            // Background dome disc — multi-stop radial gradient for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.7), color.opacity(0.35), color.opacity(0.15)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Teardrop seeds in Fibonacci spiral
            ForEach(seeds) { seed in
                TeardropSeedShape()
                    .fill(seed.dark ? color.opacity(0.5) : color.opacity(0.8))
                    .frame(width: seed.size * 0.7, height: seed.size)
                    .rotationEffect(.degrees(seed.angle))
                    .offset(x: seed.x, y: seed.y)
            }

            // Central nub — bright circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.08
                    )
                )
                .frame(width: radius * 0.14, height: radius * 0.14)

            // Nub highlight dot
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: radius * 0.06, height: radius * 0.06)
                .offset(x: -radius * 0.01, y: -radius * 0.01)
        }
    }
}

/// Tiny pointed teardrop seed shape for seed spiral center
private struct TeardropSeedShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w / 2
        var path = Path()
        // Pointed top, rounded bottom
        path.move(to: CGPoint(x: midX, y: 0))
        path.addCurve(
            to: CGPoint(x: midX + w * 0.5, y: h * 0.55),
            control1: CGPoint(x: midX + w * 0.05, y: h * 0.15),
            control2: CGPoint(x: midX + w * 0.5, y: h * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: h),
            control1: CGPoint(x: midX + w * 0.5, y: h * 0.8),
            control2: CGPoint(x: midX + w * 0.15, y: h)
        )
        path.addCurve(
            to: CGPoint(x: midX - w * 0.5, y: h * 0.55),
            control1: CGPoint(x: midX - w * 0.15, y: h),
            control2: CGPoint(x: midX - w * 0.5, y: h * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX - w * 0.5, y: h * 0.35),
            control2: CGPoint(x: midX - w * 0.05, y: h * 0.15)
        )
        path.closeSubpath()
        return path
    }
}

/// Gem — Crystalline pistil with faceted octagon layers and light caustics
struct GemCenterView: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            // Outer soft diffuse glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.2), color.opacity(0.05), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 1.4
                    )
                )
                .frame(width: radius * 2.8, height: radius * 2.8)

            // Outer faceted ring — octagon with gradient fill
            OctagonShape()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.5), color.opacity(0.2)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Outer octagon stroke
            OctagonShape()
                .stroke(color.opacity(0.8), lineWidth: 1.5)
                .frame(width: radius * 2, height: radius * 2)

            // Facet lines — center to each vertex of outer octagon
            OctagonFacetLines()
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.45)],
                        startPoint: .center,
                        endPoint: .top
                    ),
                    lineWidth: 0.8
                )
                .frame(width: radius * 2, height: radius * 2)

            // Inner facet layer 1 — smaller octagon rotated 22.5°
            OctagonShape()
                .fill(color.opacity(0.25))
                .frame(width: radius * 1.25, height: radius * 1.25)
                .rotationEffect(.degrees(22.5))

            OctagonShape()
                .stroke(color.opacity(0.5), lineWidth: 1)
                .frame(width: radius * 1.25, height: radius * 1.25)
                .rotationEffect(.degrees(22.5))

            // Inner facet layer 2 — square rotated 45° (diamond)
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: radius * 0.7, height: radius * 0.7)
                .rotationEffect(.degrees(45))

            Rectangle()
                .stroke(color.opacity(0.45), lineWidth: 0.8)
                .frame(width: radius * 0.7, height: radius * 0.7)
                .rotationEffect(.degrees(45))

            // Light caustic — offset elliptical highlight with soft edge
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.3
                    )
                )
                .frame(width: radius * 0.55, height: radius * 0.4)
                .offset(x: -radius * 0.18, y: -radius * 0.2)

            // Inner jewel — bright center with light refraction
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.6), color, color.opacity(0.3)],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: radius * 0.2
                    )
                )
                .frame(width: radius * 0.35, height: radius * 0.35)

            // Sparkle dots at cardinal points
            ForEach(0..<4, id: \.self) { i in
                let angle = CGFloat(i) * .pi / 2
                let r = radius * 0.6
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 2.0, height: 2.0)
                    .offset(x: r * cos(angle), y: r * sin(angle))
            }
        }
    }
}

/// Regular 8-sided polygon for gem center design
private struct OctagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// Facet lines from center to each octagon vertex
private struct OctagonFacetLines: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle)))
        }
        return path
    }
}

/// Swirl — Organic stigma spiral (rose/ranunculus-like) with triple arms and pollen scatter
struct SwirlCenterView: View {
    let radius: CGFloat
    let color: Color

    // Pollen dots distributed along spiral arms
    private var pollenDots: [(x: CGFloat, y: CGFloat)] {
        var result: [(CGFloat, CGFloat)] = []
        let turns: CGFloat = 4.5
        let steps = 15
        for i in 0..<steps {
            let t = CGFloat(i + 3) / CGFloat(steps + 3)
            let angle = t * turns * 2 * .pi + CGFloat(i % 3) * 2 * .pi / 3
            let r = radius * 0.9 * t
            result.append((r * cos(angle), r * sin(angle)))
        }
        return result
    }

    var body: some View {
        ZStack {
            // Background disc — multi-stop radial gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.6), color.opacity(0.3), color.opacity(0.12)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)

            // Tertiary spiral — lightest weight, 120° offset
            SpiralShape(turns: 4.5)
                .stroke(color.opacity(0.25), lineWidth: 1.2)
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(240))

            // Secondary spiral — counter-rotated, slightly offset for 3D depth
            SpiralShape(turns: 4.5)
                .stroke(color.opacity(0.45), lineWidth: 2)
                .frame(width: radius * 1.9, height: radius * 1.9)
                .rotationEffect(.degrees(180))

            // Primary spiral — thickest stroke with bold presence
            SpiralShape(turns: 4.5)
                .stroke(color.opacity(0.85), lineWidth: 3)
                .frame(width: radius * 2, height: radius * 2)

            // Pollen scatter along spiral arms
            ForEach(0..<pollenDots.count, id: \.self) { i in
                Circle()
                    .fill(color.opacity(0.55))
                    .frame(width: 2.0, height: 2.0)
                    .offset(x: pollenDots[i].x, y: pollenDots[i].y)
            }

            // Central mound — multi-layered core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.9), color.opacity(0.5)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius * 0.15
                    )
                )
                .frame(width: radius * 0.28, height: radius * 0.28)

            // Highlight dome on central mound
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0)],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: radius * 0.12
                    )
                )
                .frame(width: radius * 0.24, height: radius * 0.24)

            // Tiny stigma tip dot
            Circle()
                .fill(color)
                .frame(width: radius * 0.07, height: radius * 0.07)
        }
    }
}

private struct SpiralShape: Shape {
    let turns: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxR = min(rect.width, rect.height) / 2
        let steps = 120

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
        let strokeStyle = Color.black.opacity(0.35)
        let strokeWidth: CGFloat = 0.5

        switch self {
        case .classic:
            ClassicPetalShape().fill(color)
                .overlay(ClassicPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .dahlia:
            DahliaPetalShape().fill(color)
                .overlay(DahliaPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .peony:
            PeonyPetalShape().fill(color)
                .overlay(PeonyPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .heartleaf:
            ZStack {
                HeartleafPetalShape().fill(color)
                    .overlay(HeartleafPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                    .frame(width: size.width, height: size.height)
                HeartleafVeinShape()
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: size.width, height: size.height)
            }
        case .cosmos:
            CosmosPetalShape().fill(color)
                .overlay(CosmosPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .round:
            ZStack {
                RoundPetalShape().fill(color)
                    .overlay(RoundPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                    .frame(width: size.width, height: size.height)
                RoundPetalVeinShape()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: 1.2
                    )
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

extension InnerPetalDesign {
    @ViewBuilder
    func shape(in size: CGSize, color: Color) -> some View {
        let strokeStyle = Color.black.opacity(0.35)
        let strokeWidth: CGFloat = 0.5

        switch self {
        case .tulip:
            TulipPetalShape().fill(color)
                .overlay(TulipPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .star:
            StarPetalShape().fill(color)
                .overlay(StarPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .bell:
            BellPetalShape().fill(color)
                .overlay(BellPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .feather:
            FeatherPetalShape().fill(color)
                .overlay(FeatherPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        case .lotus:
            LotusPetalShape().fill(color)
                .overlay(LotusPetalShape().stroke(strokeStyle, lineWidth: strokeWidth))
                .frame(width: size.width, height: size.height)
        }
    }
}
