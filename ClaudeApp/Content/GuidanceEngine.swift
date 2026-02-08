import Foundation

struct DailyGuidance {
    let phase: CyclePhase
    let dayInCycle: Int
    let dayInPhase: Int
    let greeting: String
    let protectMessage: String
    let decisionTiming: String
    let doNothingWellDay: Bool
    let affirmation: String
    let nervousSystemGuidance: NervousSystemGuidance?
}

struct NervousSystemGuidance {
    let state: NervousSystemState
    let breathwork: BreathworkExercise
    let somaticExercise: String
    let groundingPrompt: String
    let affirmation: String
}

struct BreathworkExercise {
    let name: String
    let inhaleSeconds: Int
    let holdSeconds: Int
    let exhaleSeconds: Int
    let rounds: Int
    let instruction: String
}

enum GuidanceEngine {
    static func guidance(
        phase: CyclePhase,
        dayInCycle: Int,
        dayInPhase: Int,
        nervousSystemState: NervousSystemState?,
        hour: Int = Calendar.current.component(.hour, from: Date())
    ) -> DailyGuidance {
        let greeting = Self.greeting(for: hour)
        let content = DailyGuidanceContent.content(for: phase, dayInPhase: dayInPhase)
        let nsGuidance = nervousSystemState.map {
            NervousSystemContent.guidance(for: $0, phase: phase)
        }

        return DailyGuidance(
            phase: phase,
            dayInCycle: dayInCycle,
            dayInPhase: dayInPhase,
            greeting: greeting,
            protectMessage: content.protectMessage,
            decisionTiming: content.decisionTiming,
            doNothingWellDay: content.doNothingWellDay,
            affirmation: content.affirmation,
            nervousSystemGuidance: nsGuidance
        )
    }

    private static func greeting(for hour: Int) -> String {
        switch hour {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        case 17..<21: "Good evening"
        default: "Rest well"
        }
    }
}
