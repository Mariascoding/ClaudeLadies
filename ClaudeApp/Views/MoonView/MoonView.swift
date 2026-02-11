import SwiftUI

struct MoonView: View {
    var dayOffset: Int = 0
    @ObservedObject var moonState: MoonState

    private let moonSize: CGFloat = 200
    private let color: Color = .red

    var displayMoonDay: Int {
        moonState.moonDay + dayOffset
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
                color: color
            )
            Image("moon_full")
                .resizable()
                .scaledToFit()
                .frame(width: moonSize, height: moonSize)
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
                color: color
            )

            // 🌘 Added Brighness Layer
            MoonGlow(
                currentMoonDay: displayMoonDay,
                moonSize: moonSize,
                brightness: 2,
                blurRadius: 4,
                opacity: 0.1,
                color: color
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
