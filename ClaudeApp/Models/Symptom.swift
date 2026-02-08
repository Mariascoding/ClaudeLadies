import Foundation

enum SymptomCategory: String, CaseIterable, Codable {
    case physical
    case emotional
    case energy
    case digestion
    case skin

    var displayName: String {
        switch self {
        case .physical: "Physical"
        case .emotional: "Emotional"
        case .energy: "Energy"
        case .digestion: "Digestion"
        case .skin: "Skin & Hair"
        }
    }
}

enum Symptom: String, CaseIterable, Codable, Identifiable {
    // Physical
    case cramps
    case headache
    case backPain
    case breastTenderness
    case bloating
    case jointPain

    // Emotional
    case irritability
    case anxiety
    case sadness
    case moodSwings
    case calm
    case joyful

    // Energy
    case fatigue
    case energized
    case restless
    case brainFog
    case focused
    case insomnia

    // Digestion
    case nausea
    case cravings
    case appetiteLoss
    case digestiveIssues

    // Skin & Hair
    case acne
    case dryness
    case hairLoss
    case glowingSkin

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cramps: "Cramps"
        case .headache: "Headache"
        case .backPain: "Back Pain"
        case .breastTenderness: "Breast Tenderness"
        case .bloating: "Bloating"
        case .jointPain: "Joint Pain"
        case .irritability: "Irritability"
        case .anxiety: "Anxiety"
        case .sadness: "Sadness"
        case .moodSwings: "Mood Swings"
        case .calm: "Calm"
        case .joyful: "Joyful"
        case .fatigue: "Fatigue"
        case .energized: "Energized"
        case .restless: "Restless"
        case .brainFog: "Brain Fog"
        case .focused: "Focused"
        case .insomnia: "Insomnia"
        case .nausea: "Nausea"
        case .cravings: "Cravings"
        case .appetiteLoss: "Appetite Loss"
        case .digestiveIssues: "Digestive Issues"
        case .acne: "Acne"
        case .dryness: "Dryness"
        case .hairLoss: "Hair Loss"
        case .glowingSkin: "Glowing Skin"
        }
    }

    var emoji: String {
        switch self {
        case .cramps: "🩹"
        case .headache: "🤕"
        case .backPain: "💆"
        case .breastTenderness: "🫧"
        case .bloating: "🎈"
        case .jointPain: "🦴"
        case .irritability: "😤"
        case .anxiety: "😰"
        case .sadness: "😢"
        case .moodSwings: "🎭"
        case .calm: "😌"
        case .joyful: "😊"
        case .fatigue: "😴"
        case .energized: "⚡"
        case .restless: "🌀"
        case .brainFog: "🌫️"
        case .focused: "🎯"
        case .insomnia: "🌙"
        case .nausea: "🤢"
        case .cravings: "🍫"
        case .appetiteLoss: "🍽️"
        case .digestiveIssues: "🫃"
        case .acne: "✨"
        case .dryness: "🏜️"
        case .hairLoss: "💇"
        case .glowingSkin: "🌟"
        }
    }

    var category: SymptomCategory {
        switch self {
        case .cramps, .headache, .backPain, .breastTenderness, .bloating, .jointPain:
            .physical
        case .irritability, .anxiety, .sadness, .moodSwings, .calm, .joyful:
            .emotional
        case .fatigue, .energized, .restless, .brainFog, .focused, .insomnia:
            .energy
        case .nausea, .cravings, .appetiteLoss, .digestiveIssues:
            .digestion
        case .acne, .dryness, .hairLoss, .glowingSkin:
            .skin
        }
    }

    static func symptoms(for category: SymptomCategory) -> [Symptom] {
        allCases.filter { $0.category == category }
    }
}
