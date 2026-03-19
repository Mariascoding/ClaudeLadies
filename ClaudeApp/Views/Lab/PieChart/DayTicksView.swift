import SwiftUI

struct DayTicksView: View {
    let cycleLength: Int
    let radius: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<cycleLength, id: \.self) { day in
                let angle = Angle.degrees(Double(day) / Double(cycleLength) * 360 - 90)

                // Tick line from outer edge inward
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 1, height: 10)
                    .offset(y: -(radius - 5))
                    .rotationEffect(angle)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}
