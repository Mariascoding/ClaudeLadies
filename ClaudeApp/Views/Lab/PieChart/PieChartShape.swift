import SwiftUI

struct PieChartShape: View {
    let segments: [PieSegment]
    let radius: CGFloat

    var body: some View {
        let total = segments.map { $0.units }.reduce(0, +)

        let views: [CircleView] = {
            var startAngle = 0.0
            return segments.map { segment in
                let angle = (segment.units / total) * 360
                let view = CircleView(
                    radius: radius,
                    color: segment.color,
                    startAngle: startAngle,
                    endAngle: startAngle + angle
                )
                startAngle += angle
                return view
            }
        }()

        return ZStack {
            ForEach(Array(views.enumerated()), id: \.offset) { _, view in
                view
            }
        }
    }
}
