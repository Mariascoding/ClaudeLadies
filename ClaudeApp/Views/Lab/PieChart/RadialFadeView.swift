import SwiftUI

struct RadialFadeView: View {
    let color: Color
    let radius: CGFloat

    var body: some View {
        ZStack {
            color

            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: .white.opacity(0), location: 1.0)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: radius
            )
            .blendMode(.destinationOut)
        }
        .compositingGroup()
        .frame(width: radius * 2, height: radius * 2)
    }
}
