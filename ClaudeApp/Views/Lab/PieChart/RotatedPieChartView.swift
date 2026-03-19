import SwiftUI

struct RotatedPieChartView: View {
    let segments: [PieSegment]
    let radius: CGFloat
    let focusUnit: Double

    var body: some View {
        let total = segments.map { $0.units }.reduce(0, +)
        let unitAngle = 360.0 / total
        let rotationAngle: Double = (focusUnit * unitAngle) - (unitAngle / 2)

        return PieChartShape(segments: segments, radius: radius)
            .rotationEffect(.degrees(-rotationAngle))
    }
}
