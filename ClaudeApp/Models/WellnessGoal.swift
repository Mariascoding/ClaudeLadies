import SwiftUI

enum WellnessGoal: String, CaseIterable, Codable, Identifiable {
    case healthyCycle
    case tryingToConceive
    case prenatal
    case postnatal
    case perimenopause
    case menopause

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .healthyCycle: "Healthy Cycle"
        case .tryingToConceive: "Trying to Conceive"
        case .prenatal: "Prenatal"
        case .postnatal: "Postnatal"
        case .perimenopause: "Perimenopause"
        case .menopause: "Menopause"
        }
    }

    var description: String {
        switch self {
        case .healthyCycle: "Support and balance my natural cycle"
        case .tryingToConceive: "Prepare my body for conception"
        case .prenatal: "Nourish myself and my growing baby"
        case .postnatal: "Recover and replenish after birth"
        case .perimenopause: "Navigate this transition with grace"
        case .menopause: "Thrive in my new season"
        }
    }

    var icon: String {
        switch self {
        case .healthyCycle: "circle.dotted"
        case .tryingToConceive: "heart.circle.fill"
        case .prenatal: "figure.and.child.holdinghands"
        case .postnatal: "leaf.circle.fill"
        case .perimenopause: "wind"
        case .menopause: "sun.and.horizon.fill"
        }
    }

    var color: Color {
        switch self {
        case .healthyCycle: .appSage
        case .tryingToConceive: .appRose
        case .prenatal: .appTerracotta
        case .postnatal: .appSage
        case .perimenopause: .appSoftBrown
        case .menopause: .appTerracotta
        }
    }
}
