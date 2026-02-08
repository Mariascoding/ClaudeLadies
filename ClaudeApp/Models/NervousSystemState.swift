import SwiftUI

enum NervousSystemState: String, CaseIterable, Codable, Identifiable {
    case regulated
    case sensitive
    case overstimulated

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .regulated: "Regulated"
        case .sensitive: "Sensitive"
        case .overstimulated: "Overstimulated"
        }
    }

    var description: String {
        switch self {
        case .regulated: "I feel grounded and present"
        case .sensitive: "I feel tender and easily affected"
        case .overstimulated: "I feel overwhelmed and need to retreat"
        }
    }

    var icon: String {
        switch self {
        case .regulated: "circle.circle.fill"
        case .sensitive: "heart.circle.fill"
        case .overstimulated: "tornado"
        }
    }

    var color: Color {
        switch self {
        case .regulated: .appSage
        case .sensitive: .appRose
        case .overstimulated: .appTerracotta
        }
    }
}
