import SwiftUI

enum DietaryPreference: String, CaseIterable, Codable, Identifiable {
    case omnivore
    case pescatarian
    case vegetarian
    case vegan

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .omnivore: "Omnivore"
        case .pescatarian: "Pescatarian"
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        }
    }

    var icon: String {
        switch self {
        case .omnivore: "fork.knife"
        case .pescatarian: "fish.fill"
        case .vegetarian: "leaf.fill"
        case .vegan: "carrot.fill"
        }
    }

    var color: Color {
        switch self {
        case .omnivore: .appSoftBrown
        case .pescatarian: Color(red: 0.35, green: 0.55, blue: 0.70)
        case .vegetarian: .appSage
        case .vegan: Color(red: 0.55, green: 0.72, blue: 0.40)
        }
    }
}
