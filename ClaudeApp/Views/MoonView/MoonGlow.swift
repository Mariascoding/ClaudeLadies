import SwiftUI

struct MoonGlow: View {
    let currentMoonDay: Int
    let moonSize: CGFloat
    let brightness: Double
    let blurRadius: CGFloat
    let opacity: Double
    let color: Color

    init(
        currentMoonDay: Int,
        moonSize: CGFloat,
        brightness: Double,
        blurRadius: CGFloat,
        opacity: Double,
        color: Color = .white
    ) {
        self.currentMoonDay = currentMoonDay
        self.moonSize = moonSize
        self.brightness = brightness
        self.blurRadius = blurRadius
        self.opacity = opacity
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(opacity)) // Use dynamic color here

            Circle()
                .fill(Color.black)
                .scaleEffect(
                    x: MoonUtils.shadowScale(for: currentMoonDay),
                    y: 1,
                    anchor: MoonUtils.anchorSide(for: currentMoonDay)
                )
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .frame(width: moonSize, height: moonSize)
        .blur(radius: blurRadius)
        .brightness(brightness)
    }
}
