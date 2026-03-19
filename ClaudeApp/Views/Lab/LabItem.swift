import SwiftUI

enum LabItem: String, CaseIterable, Identifiable {
    case moonPhase
    case moonCycleDial
    case lunarMirror
    case radialPicker
    case cycleDial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .moonPhase: "Moon Phase"
        case .moonCycleDial: "Moon & Cycle"
        case .lunarMirror: "Lunar Mirror"
        case .radialPicker: "Radial Picker"
        case .cycleDial: "Cycle Dial"
        }
    }

    var subtitle: String {
        switch self {
        case .moonPhase: "Interactive moon phase playground"
        case .moonCycleDial: "Lunar\u{2013}menstrual alignment & ancient wisdom"
        case .lunarMirror: "Your moon, your cycle, your wisdom"
        case .radialPicker: "Circular selector for cycle insights"
        case .cycleDial: "Interactive phase pie chart with haptic dial"
        }
    }

    var icon: String {
        switch self {
        case .moonPhase: "moon.stars.fill"
        case .moonCycleDial: "circle.circle"
        case .lunarMirror: "moonphase.full.moon"
        case .radialPicker: "circle.grid.cross.fill"
        case .cycleDial: "chart.pie.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .moonPhase: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .moonCycleDial: .appRose
        case .lunarMirror: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .radialPicker: .appTerracotta
        case .cycleDial: .appSage
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
        case .radialPicker:
            RadialPickerView()
        case .cycleDial:
            PieChartLabView()
        }
    }
}
