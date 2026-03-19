import SwiftUI
import UIKit

// MARK: - Public API

public extension View {
    func mechanicalDialRotation(
        totalAngle: Binding<Double>,
        reversed: Bool = false,
        inertia: Bool = true,
        friction: Double = 8.0,
        maxVelocity: Double = 16.0,
        snapStep: Double? = nil,
        tickStep: Double? = nil,
        debugTicks: Bool = false,
        onAngleChanged: @escaping (Double) -> Void
    ) -> some View {
        modifier(
            MechanicalDialRotationModifier(
                totalAngle: totalAngle,
                reversed: reversed,
                inertia: inertia,
                friction: friction,
                maxVelocity: maxVelocity,
                snapStep: snapStep,
                tickStep: tickStep,
                debugTicks: debugTicks,
                onAngleChanged: onAngleChanged
            )
        )
    }
}

// MARK: - Haptics engine

private final class TickHapticsEngine: ObservableObject {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)

    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }

    func tick() {
        lightGenerator.impactOccurred(intensity: 0.6)
        lightGenerator.prepare()
    }

    func heavyTick() {
        mediumGenerator.impactOccurred(intensity: 0.8)
        mediumGenerator.prepare()
    }
}

// MARK: - Modifier

private struct MechanicalDialRotationModifier: ViewModifier {

    @Binding var totalAngle: Double
    let reversed: Bool
    let inertia: Bool
    let friction: Double
    let maxVelocity: Double
    let snapStep: Double?
    let tickStep: Double?
    let debugTicks: Bool
    let onAngleChanged: (Double) -> Void

    @State private var gripOffset: Double? = nil
    @State private var lastRawTouchAngle: Double? = nil
    @State private var continuousTouchAngle: Double = 0.0
    @State private var lastTime: TimeInterval? = nil
    @State private var angularVelocity: Double = 0
    @State private var isDecelerating = false
    @State private var lastTickIndex: Int? = nil
    @StateObject private var haptics = TickHapticsEngine()

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    if isDecelerating { isDecelerating = false }
                                    if tickStep != nil { haptics.prepare() }

                                    let now = CACurrentMediaTime()
                                    let raw = angle(from: center, to: value.location)
                                    let rawDial = reversed ? -raw : raw

                                    if lastRawTouchAngle == nil {
                                        lastRawTouchAngle = rawDial
                                        continuousTouchAngle = unwrapToNearest(rawDial, reference: totalAngle)
                                        gripOffset = continuousTouchAngle - totalAngle
                                        lastTime = now
                                        angularVelocity = 0
                                        lastTickIndex = tickIndex(for: totalAngle)
                                        return
                                    }

                                    let d = unwrapDelta(rawDial - (lastRawTouchAngle ?? rawDial))
                                    continuousTouchAngle += d
                                    lastRawTouchAngle = rawDial

                                    totalAngle = continuousTouchAngle - (gripOffset ?? 0)
                                    onAngleChanged(totalAngle)
                                    tickIfCrossed()

                                    if let t0 = lastTime {
                                        let dt = max(now - t0, 1.0 / 240.0)
                                        angularVelocity = clamp(d / dt, -maxVelocity, maxVelocity)
                                        lastTime = now
                                    } else {
                                        lastTime = now
                                    }
                                }
                                .onEnded { _ in
                                    gripOffset = nil
                                    lastRawTouchAngle = nil
                                    lastTime = nil
                                    lastTickIndex = tickIndex(for: totalAngle)

                                    guard inertia else {
                                        snapIfNeeded()
                                        return
                                    }

                                    if abs(angularVelocity) < 0.12 {
                                        angularVelocity = 0
                                        snapIfNeeded()
                                    } else {
                                        isDecelerating = true
                                    }
                                }
                        )
                }
            )
            .onReceive(timer) { _ in
                guard isDecelerating else { return }

                let dt = 1.0 / 60.0
                angularVelocity *= exp(-friction * dt)

                totalAngle += angularVelocity * dt
                onAngleChanged(totalAngle)

                if abs(angularVelocity) < 0.08 {
                    angularVelocity = 0
                    isDecelerating = false
                    snapIfNeeded()
                    lastTickIndex = tickIndex(for: totalAngle)
                }
            }
    }

    private func tickIndex(for angle: Double) -> Int? {
        guard let step = tickStep, step > 0 else { return nil }
        let x = angle / step
        return Int(floor(x + 0.5))
    }

    private func tickIfCrossed() {
        guard let idx = tickIndex(for: totalAngle) else { return }

        if lastTickIndex == nil {
            lastTickIndex = idx
            return
        }

        if idx != lastTickIndex {
            haptics.tick()
            lastTickIndex = idx
        }
    }

    private func snapIfNeeded() {
        guard let step = snapStep, step > 0 else { return }
        let snapped = (totalAngle / step).rounded() * step
        withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.88)) {
            totalAngle = snapped
            onAngleChanged(totalAngle)
        }
    }

    private func angle(from center: CGPoint, to point: CGPoint) -> Double {
        atan2(Double(point.y - center.y), Double(point.x - center.x))
    }

    private func unwrapDelta(_ d: Double) -> Double {
        var delta = d
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }
        return delta
    }

    private func unwrapToNearest(_ target: Double, reference: Double) -> Double {
        let twoPi = 2.0 * Double.pi
        var t = target
        while t - reference > .pi { t -= twoPi }
        while t - reference < -.pi { t += twoPi }
        return t
    }

    private func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double {
        min(max(x, lo), hi)
    }
}
