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

            Tab("Nourish", systemImage: "leaf.fill") {
                NourishView()
            }

            Tab("Insights", systemImage: "chart.xyaxis.line") {
                InsightsView()
            }

            Tab("Lab", systemImage: "flask.fill") {
                LabView()
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
