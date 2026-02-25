import SwiftUI

struct MoonView: View {
    var dayOffset: Int = 0
    @ObservedObject var moonState: MoonState

    private let moonSize: CGFloat = 200

    var displayMoonDay: Int {
        moonState.moonDay + dayOffset
    }

    /// Warm amber-gold glow matching the mineral moon palette
    private var glowColor: Color {
        Color(red: 0.92, green: 0.78, blue: 0.55)
    }

    var body: some View {
        ZStack {
            // 🌕 Full Moon Image
            // 🌘 Realistic Light `Glow` Layer
            MoonGlow(
                currentMoonDay: displayMoonDay,
                moonSize: moonSize,
                brightness: 1.0,
                blurRadius: 80,
                opacity: 0.9,
                color: glowColor
            )

            // Moon image with lavender-peach mineral tint
            Image("moon_full")
                .resizable()
                .scaledToFit()
                .frame(width: moonSize, height: moonSize)
                .saturation(1.4)
                .overlay(
                    ZStack {
                        // Lavender wash for the maria regions
                        Circle()
                            .fill(Color(red: 0.75, green: 0.65, blue: 0.88).opacity(0.18))
                            .blendMode(.plusLighter)

                        // Warm peach highlights
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.98, green: 0.88, blue: 0.78).opacity(0.12),
                                        Color(red: 0.85, green: 0.72, blue: 0.85).opacity(0.15)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: moonSize / 2
                                )
                            )
                            .blendMode(.overlay)
                    }
                )
                .clipShape(Circle())

            // 🌘 Realistic Shadow Layer
            MoonShadow(
                currentMoonDay: displayMoonDay,
                moonSize: moonSize,
                blurRadius: 4,
                opacity: 0.5
            )

            // 🌘 Primary Light Layer
            MoonGlow(
                currentMoonDay: displayMoonDay,
                moonSize: moonSize,
                brightness: 0,
                blurRadius: 4,
                opacity: 0.4,
                color: glowColor
            )

            // 🌘 Added Brighness Layer
            MoonGlow(
                currentMoonDay: displayMoonDay,
                moonSize: moonSize,
                brightness: 2,
                blurRadius: 4,
                opacity: 0.1,
                color: glowColor
            )


        }
        .opacity(moonState.isLoaded ? 1 : 0)
    }

    /// Calculate today's moon phase (0–29) based on a reference new moon
    private func moonDay(for date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let referenceNewMoon = calendar.date(from: DateComponents(year: 2025, month: 5, day: 28))!
        let daysSince = calendar.dateComponents([.day], from: referenceNewMoon, to: date).day ?? 0
        return daysSince % 30
    }
}

#Preview {
    ZStack {
        Color(red: 0.15, green: 0.2, blue: 0.3)
        MoonView(moonState: {
            let state = MoonState()
            return state
        }())
    }
}
