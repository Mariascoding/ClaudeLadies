import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                TodayView()
            }

            Tab("Log", systemImage: "heart.text.square") {
                LogView()
            }

            Tab("Insights", systemImage: "chart.xyaxis.line") {
                InsightsView()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tint(.appRose)
    }
}

#Preview {
    ContentView()
}
