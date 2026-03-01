import SwiftUI

enum LabItem: String, CaseIterable, Identifiable {
    case moonPhase
    case moonCycleDial
    case lunarMirror

    var id: String { rawValue }

    var title: String {
        switch self {
        case .moonPhase: "Moon Phase"
        case .moonCycleDial: "Moon & Cycle"
        case .lunarMirror: "Lunar Mirror"
        }
    }

    var subtitle: String {
        switch self {
        case .moonPhase: "Interactive moon phase playground"
        case .moonCycleDial: "Lunar\u{2013}menstrual alignment & ancient wisdom"
        case .lunarMirror: "Your moon, your cycle, your wisdom"
        }
    }

    var icon: String {
        switch self {
        case .moonPhase: "moon.stars.fill"
        case .moonCycleDial: "circle.circle"
        case .lunarMirror: "moonphase.full.moon"
        }
    }

    var iconColor: Color {
        switch self {
        case .moonPhase: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .moonCycleDial: .appRose
        case .lunarMirror: Color(red: 0.92, green: 0.78, blue: 0.55)
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .moonPhase:
            MoonPlaygroundView()
        case .moonCycleDial:
            MoonCycleDialView()
        case .lunarMirror:
            LunarMirrorView()
        }
    }
}
