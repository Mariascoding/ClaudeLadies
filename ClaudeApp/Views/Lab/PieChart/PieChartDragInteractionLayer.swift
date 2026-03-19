import SwiftUI

struct PieChartDragInteractionLayer: View {
    @Binding var displayedCycleDay: Int
    let cycleLength: Int

    @State private var totalAngle: Double = 0.0

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .mechanicalDialRotation(
                totalAngle: $totalAngle,
                reversed: true,
                inertia: true,
                friction: 12.0,
                snapStep: (2 * Double.pi) / Double(cycleLength),
                tickStep: (2 * Double.pi) / Double(cycleLength),
                onAngleChanged: { newAngle in
                    totalAngle = newAngle
                    displayedCycleDay = angleToDay(newAngle)
                }
            )
            .onAppear {
                totalAngle = dayToAngle(displayedCycleDay, cycleLength: cycleLength)
            }
            .onChange(of: displayedCycleDay) { _, newDay in
                totalAngle = dayToAngle(newDay, cycleLength: cycleLength)
            }
    }

    private func angleToDay(_ angle: Double) -> Int {
        guard cycleLength > 0 else { return 1 }
        let twoPi = 2.0 * Double.pi

        var a = angle.truncatingRemainder(dividingBy: twoPi)
        if a < 0 { a += twoPi }

        let fraction = a / twoPi
        let day0 = Int((fraction * Double(cycleLength)).rounded(.down))
        return min(max(day0 + 1, 1), cycleLength)
    }

    private func dayToAngle(_ day: Int, cycleLength: Int) -> Double {
        guard cycleLength > 0 else { return 0 }
        let d = min(max(day, 1), cycleLength)
        let fraction = Double(d - 1) / Double(cycleLength)
        return fraction * (2.0 * Double.pi)
    }
}
