import SwiftUI

struct FadedPieChartView: View {
    let segments: [PieSegment]
    let radius: CGFloat
    let focusUnit: Double

    var body: some View {
        var cumulative: Double = 0
        let backgroundColor = segments.first(where: { segment in
            let nextCumulative = cumulative + segment.units
            let containsUnit = focusUnit > cumulative && focusUnit <= nextCumulative
            cumulative = nextCumulative
            return containsUnit
        })?.color ?? .clear

        return ZStack {
            RotatedPieChartView(segments: segments, radius: radius, focusUnit: focusUnit)
            RadialFadeView(color: backgroundColor, radius: radius)
                .opacity(0.5)
        }
    }
}
