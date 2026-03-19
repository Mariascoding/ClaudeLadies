import SwiftUI

struct CircleView: View {
    let radius: CGFloat
    let color: Color
    let startAngle: Double
    let endAngle: Double

    var body: some View {
        CircleSegment(startAngle: .degrees(startAngle), endAngle: .degrees(endAngle))
            .fill(color)
            .frame(width: radius * 2, height: radius * 2)
    }
}
