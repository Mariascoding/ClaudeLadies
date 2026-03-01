import Foundation

struct PhaseGuidance {
    let protectMessage: String
    let decisionTiming: String
    let doNothingWellDay: Bool
    let affirmation: String
}

enum DailyGuidanceContent {
    static func content(for phase: CyclePhase, dayInPhase: Int) -> PhaseGuidance {
        switch phase {
        case .menstrual:
            menstrualGuidance(dayInPhase: dayInPhase)
        case .follicular:
            follicularGuidance(dayInPhase: dayInPhase)
        case .ovulation:
            ovulationGuidance(dayInPhase: dayInPhase)
        case .luteal:
            lutealGuidance(dayInPhase: dayInPhase)
        }
    }

    // MARK: - Menstrual Phase (Inner Winter)

    private static func menstrualGuidance(dayInPhase: Int) -> PhaseGuidance {
        let protectMessages = [
            "Today, protect your energy. Your body is doing deep work — release is an act of power.",
            "Today, protect your rest. You are not falling behind. You are gathering strength.",
            "Today, protect your silence. Every answer will come in its own time.",
            "Today, protect your softness. The world can wait. Fill your vessel first.",
            "Today, protect your boundaries. A gentle 'no' is a loving 'yes' to yourself."
        ]

        let affirmations = [
            "I make space for what truly serves me.",
            "Rest is my birthright. I claim it freely.",
            "I trust the wisdom of slowing down.",
            "My body knows how to heal. I let it.",
            "I am whole, even in stillness."
        ]

        let idx = dayInPhase % protectMessages.count

        return PhaseGuidance(
            protectMessage: protectMessages[idx],
            decisionTiming: "Let ideas simmer gently. Trust that clarity will come in its own time.",
            doNothingWellDay: true,
            affirmation: affirmations[idx]
        )
    }

    // MARK: - Follicular Phase (Inner Spring)

    private static func follicularGuidance(dayInPhase: Int) -> PhaseGuidance {
        let protectMessages = [
            "Today, protect your curiosity. New ideas are sprouting — give them sunlight.",
            "Today, protect your creative impulse. Start before you feel ready.",
            "Today, protect your optimism. This rising energy is real. Ride it gently.",
            "Today, protect your playfulness. Everything you explore has worth, simply because you chose it.",
            "Today, protect your momentum. Small steps forward are still forward.",
            "Today, protect your openness. Your mind is sharp and receptive — use it wisely.",
            "Today, protect your fresh perspective. You're seeing things with new eyes."
        ]

        let affirmations = [
            "I am ready for new beginnings.",
            "My creativity is waking up, and I welcome it.",
            "I plant seeds with trust and patience.",
            "I am free to explore and enjoy the journey.",
            "My energy is rising, and I direct it with intention.",
            "I welcome the new with an open heart.",
            "I trust my emerging vision."
        ]

        let idx = dayInPhase % protectMessages.count

        return PhaseGuidance(
            protectMessage: protectMessages[idx],
            decisionTiming: "Good time to brainstorm, plan, and start new projects. Your brain is wiring for novelty.",
            doNothingWellDay: false,
            affirmation: affirmations[idx]
        )
    }

    // MARK: - Ovulation Phase (Inner Summer)

    private static func ovulationGuidance(dayInPhase: Int) -> PhaseGuidance {
        let protectMessages = [
            "Today, protect your radiance. You're magnetic — choose where you shine.",
            "Today, protect your voice. Speak your truth. You'll be heard.",
            "Today, protect your connections. Meaningful conversations can change everything today.",
            "Today, protect your joy. Let yourself be seen, fully and unapologetically."
        ]

        let affirmations = [
            "I am at my fullest expression, and that is beautiful.",
            "I communicate with clarity and warmth.",
            "My presence is a gift — to myself and others.",
            "I shine fully and let my light inspire others."
        ]

        let idx = dayInPhase % protectMessages.count

        return PhaseGuidance(
            protectMessage: protectMessages[idx],
            decisionTiming: "Peak communication energy. Great for important conversations, negotiations, and social events.",
            doNothingWellDay: false,
            affirmation: affirmations[idx]
        )
    }

    // MARK: - Luteal Phase (Inner Autumn)

    private static func lutealGuidance(dayInPhase: Int) -> PhaseGuidance {
        let protectMessages = [
            "Today, protect your discernment. Your inner editor is awake — use it wisely, with compassion.",
            "Today, protect your nesting instinct. Creating comfort around you is productive work.",
            "Today, protect your sensitivity. What you're feeling is your body asking for gentleness.",
            "Today, protect your truth-telling. You see through fog right now — honor what you notice.",
            "Today, protect your slower pace. The world's urgency is not your emergency.",
            "Today, protect your need for completion. Finishing what you started feels deeply satisfying now.",
            "Today, protect your emotional depth. These feelings are messengers, not problems.",
            "Today, protect your inward turn. Turning inward is pure wisdom.",
            "Today, protect your appetite. Nourish yourself fully and without guilt.",
            "Today, protect your boundaries. Pre-menstrual clarity is a superpower."
        ]

        let affirmations = [
            "I honor my need for space.",
            "My sensitivity is intelligence — it is my strength.",
            "I complete with grace what I began with enthusiasm.",
            "I trust my instinct to turn inward.",
            "I nourish myself fully and freely.",
            "I lead with compassion, and my clarity deepens.",
            "I am allowed to need more right now.",
            "Slowing down is gathering strength.",
            "I release perfection and embrace what is real.",
            "I am preparing for renewal. This is sacred work."
        ]

        let doNothingDays = dayInPhase >= 8

        let idx = dayInPhase % protectMessages.count

        return PhaseGuidance(
            protectMessage: protectMessages[idx],
            decisionTiming: doNothingDays
                ? "Delay non-urgent decisions. Your perspective will shift soon — let it."
                : "Good for detail work, editing, and refining. Your critical eye is sharp.",
            doNothingWellDay: doNothingDays,
            affirmation: affirmations[idx]
        )
    }
}
