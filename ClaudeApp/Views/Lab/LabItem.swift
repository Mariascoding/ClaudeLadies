import SwiftUI

enum LabItem: String, CaseIterable, Identifiable {
    case moonPhase
    case moonCycleDial
    case lunarMirror
    case radialPicker
    case cycleDial
    case bloom
    case flowerBuilder
    case flowerBloom
    case colorPicker
    case flowerBuilder3D
    case autoFlowerCreator
    case cycleBloom
    case dashboard
    case carousel

    var id: String { rawValue }

    var title: String {
        switch self {
        case .moonPhase: "Moon Phase"
        case .moonCycleDial: "Moon & Cycle"
        case .lunarMirror: "Lunar Mirror"
        case .radialPicker: "Radial Picker"
        case .cycleDial: "Cycle Dial"
        case .bloom: "Bloom"
        case .flowerBuilder: "Flower Builder"
        case .flowerBloom: "Flower Bloom"
        case .colorPicker: "Color Picker"
        case .flowerBuilder3D: "3D Flower"
        case .autoFlowerCreator: "Auto Flower"
        case .cycleBloom: "Cycle Bloom"
        case .dashboard: "Dashboard"
        case .carousel: "Carousel"
        }
    }

    var subtitle: String {
        switch self {
        case .moonPhase: "Interactive moon phase playground"
        case .moonCycleDial: "Lunar\u{2013}menstrual alignment & ancient wisdom"
        case .lunarMirror: "Your moon, your cycle, your wisdom"
        case .radialPicker: "Circular selector for cycle insights"
        case .cycleDial: "Interactive phase pie chart with haptic dial"
        case .bloom: "Press and hold to blossom through emotion"
        case .flowerBuilder: "Design your own flower, petal by petal"
        case .flowerBloom: "Design a flower, then press to blossom"
        case .colorPicker: "Pick any colour from a full spectrum"
        case .flowerBuilder3D: "Build a clay flower with orbit view"
        case .autoFlowerCreator: "Your moon-born flower portrait"
        case .cycleBloom: "Your flower blooming through inner seasons"
        case .dashboard: "All your cycle data at a glance"
        case .carousel: "Scroll-bar / segmented-control hybrid"
        }
    }

    var icon: String {
        switch self {
        case .moonPhase: "moon.stars.fill"
        case .moonCycleDial: "circle.circle"
        case .lunarMirror: "moonphase.full.moon"
        case .radialPicker: "circle.grid.cross.fill"
        case .cycleDial: "chart.pie.fill"
        case .bloom: "sparkle"
        case .flowerBuilder: "camera.macro"
        case .flowerBloom: "sparkles"
        case .colorPicker: "paintpalette.fill"
        case .flowerBuilder3D: "cube.fill"
        case .autoFlowerCreator: "wand.and.stars"
        case .cycleBloom: "circle.hexagongrid.fill"
        case .dashboard: "rectangle.grid.2x2.fill"
        case .carousel: "rectangle.split.3x1.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .moonPhase: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .moonCycleDial: .appRose
        case .lunarMirror: Color(red: 0.92, green: 0.78, blue: 0.55)
        case .radialPicker: .appTerracotta
        case .cycleDial: .appSage
        case .bloom: Color(red: 0.95, green: 0.78, blue: 0.40)
        case .flowerBuilder: .appRose
        case .flowerBloom: .appRose
        case .colorPicker: .appTerracotta
        case .flowerBuilder3D: .appRose
        case .autoFlowerCreator: Color(red: 0.69, green: 0.61, blue: 0.82)
        case .cycleBloom: Color(red: 0.88, green: 0.55, blue: 0.42)
        case .dashboard: Color(red: 0.50, green: 0.60, blue: 0.75)
        case .carousel: Color(red: 0.60, green: 0.55, blue: 0.70)
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
        case .bloom:
            BloomLabView()
        case .flowerBuilder:
            FlowerBuilderView()
        case .flowerBloom:
            FlowerBloomView()
        case .colorPicker:
            SpectrumColorPickerView()
        case .flowerBuilder3D:
            FlowerBuilder3DView()
        case .autoFlowerCreator:
            AutoFlowerCreatorView()
        case .cycleBloom:
            CycleBloomView()
        case .dashboard:
            DashboardView()
        case .carousel:
            CarouselDemoView()
        }
    }
}
