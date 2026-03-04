import SwiftUI

enum NutritionProtocol: String, CaseIterable, Codable, Identifiable {
    case seedCycling
    case cellDetox
    case daoSt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .seedCycling: "Seed Cycling"
        case .cellDetox: "Cell Detox"
        case .daoSt: "DAO Support"
        }
    }

    var description: String {
        switch self {
        case .seedCycling: "Rotate specific seeds through your cycle phases to support hormone balance"
        case .cellDetox: "Support your body's natural detoxification pathways through targeted nutrition"
        case .daoSt: "Support DAO enzyme production to improve histamine tolerance"
        }
    }

    var focusDescription: String {
        switch self {
        case .seedCycling: "Balance estrogen and progesterone naturally through phase-specific seeds"
        case .cellDetox: "Clear toxins and support liver pathways for hormonal clarity"
        case .daoSt: "Reduce histamine overload and calm inflammatory flare-ups"
        }
    }

    var icon: String {
        switch self {
        case .seedCycling: "leaf.fill"
        case .cellDetox: "sparkles"
        case .daoSt: "shield.lefthalf.filled"
        }
    }

    var color: Color {
        switch self {
        case .seedCycling: .appSage
        case .cellDetox: .appTerracotta
        case .daoSt: .appRose
        }
    }
}
