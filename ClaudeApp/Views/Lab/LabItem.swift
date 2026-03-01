import SwiftUI

enum LabItem: String, CaseIterable, Identifiable {
    case moonPhase

    var id: String { rawValue }

    var title: String {
        switch self {
        case .moonPhase: "Moon Phase"
        }
    }

    var subtitle: String {
        switch self {
        case .moonPhase: "Interactive moon phase playground"
        }
    }

    var icon: String {
        switch self {
        case .moonPhase: "moon.stars.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .moonPhase: Color(red: 0.92, green: 0.78, blue: 0.55)
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .moonPhase:
            MoonPlaygroundView()
        }
    }
}
