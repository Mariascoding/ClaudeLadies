import SwiftUI

enum NutritionProtocol: String, CaseIterable, Codable, Identifiable {
    case seedCycling
    case cellDetox
    case daoSt
    case hairHealth

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .seedCycling: "Seed Cycling"
        case .cellDetox: "Cell Detox"
        case .daoSt: "DAO Support"
        case .hairHealth: "Hair Health"
        }
    }

    var description: String {
        switch self {
        case .seedCycling: "Rotate specific seeds through your cycle phases to support hormone balance"
        case .cellDetox: "Support your body's natural detoxification pathways through targeted nutrition"
        case .daoSt: "Support DAO enzyme production to improve histamine tolerance"
        case .hairHealth: "Nourish hair follicles and ovarian reserve through shared hormonal pathways"
        }
    }

    var focusDescription: String {
        switch self {
        case .seedCycling: "Balance estrogen and progesterone naturally through phase-specific seeds"
        case .cellDetox: "Clear toxins and support liver pathways for hormonal clarity"
        case .daoSt: "Reduce histamine overload and calm inflammatory flare-ups"
        case .hairHealth: "Support follicles, mitochondria, and circulation across every cycle phase"
        }
    }

    var icon: String {
        switch self {
        case .seedCycling: "leaf.fill"
        case .cellDetox: "sparkles"
        case .daoSt: "shield.lefthalf.filled"
        case .hairHealth: "comb.fill"
        }
    }

    var color: Color {
        switch self {
        case .seedCycling: .appSage
        case .cellDetox: .appTerracotta
        case .daoSt: .appRose
        case .hairHealth: .appSoftBrown
        }
    }
}
