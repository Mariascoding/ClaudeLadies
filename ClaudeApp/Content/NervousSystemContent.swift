import Foundation

enum NervousSystemContent {
    static func guidance(for state: NervousSystemState, phase: CyclePhase) -> NervousSystemGuidance {
        NervousSystemGuidance(
            state: state,
            breathwork: breathwork(for: state, phase: phase),
            somaticExercise: somaticExercise(for: state, phase: phase),
            groundingPrompt: groundingPrompt(for: state, phase: phase),
            affirmation: affirmation(for: state, phase: phase)
        )
    }

    // MARK: - Breathwork

    private static func breathwork(for state: NervousSystemState, phase: CyclePhase) -> BreathworkExercise {
        switch state {
        case .regulated:
            BreathworkExercise(
                name: "Balancing Breath",
                inhaleSeconds: 4,
                holdSeconds: 4,
                exhaleSeconds: 4,
                rounds: 6,
                instruction: "Breathe in through your nose, hold gently, exhale slowly. You're maintaining your beautiful balance."
            )
        case .sensitive:
            switch phase {
            case .menstrual, .luteal:
                BreathworkExercise(
                    name: "Nurturing Breath",
                    inhaleSeconds: 4,
                    holdSeconds: 2,
                    exhaleSeconds: 6,
                    rounds: 8,
                    instruction: "A longer exhale tells your nervous system: you are safe. Let each breath be a soft landing."
                )
            case .follicular, .ovulation:
                BreathworkExercise(
                    name: "Gentle Wave Breath",
                    inhaleSeconds: 4,
                    holdSeconds: 3,
                    exhaleSeconds: 5,
                    rounds: 6,
                    instruction: "Imagine your breath as a gentle wave — rising and falling. Each cycle brings more ease."
                )
            }
        case .overstimulated:
            switch phase {
            case .menstrual:
                BreathworkExercise(
                    name: "Deep Rest Breath",
                    inhaleSeconds: 3,
                    holdSeconds: 0,
                    exhaleSeconds: 8,
                    rounds: 10,
                    instruction: "No holding needed. Just a short inhale and a long, slow release. Let your body melt."
                )
            case .luteal:
                BreathworkExercise(
                    name: "Calming Descent",
                    inhaleSeconds: 4,
                    holdSeconds: 0,
                    exhaleSeconds: 8,
                    rounds: 8,
                    instruction: "Exhale like you're fogging a mirror. Let the out-breath carry away what you don't need."
                )
            case .follicular, .ovulation:
                BreathworkExercise(
                    name: "Grounding Breath",
                    inhaleSeconds: 4,
                    holdSeconds: 2,
                    exhaleSeconds: 7,
                    rounds: 8,
                    instruction: "Feel your feet on the ground. Breathe in stability, breathe out tension."
                )
            }
        }
    }

    // MARK: - Somatic Exercises

    private static func somaticExercise(for state: NervousSystemState, phase: CyclePhase) -> String {
        switch state {
        case .regulated:
            switch phase {
            case .menstrual:
                "Gentle body scan: Lie down comfortably. Starting from your toes, slowly bring awareness to each part of your body. Simply notice — no need to change anything. Let each area soften as you breathe."
            case .follicular:
                "Flowing movement: Stand and gently sway side to side, letting your arms swing naturally. Feel the freedom in your body. Let the movement grow as big or stay as small as feels right."
            case .ovulation:
                "Heart-opening stretch: Stand tall, interlace your fingers behind your back, gently lift your chest to the sky. Breathe into the openness. You are expanding."
            case .luteal:
                "Self-holding: Place one hand on your heart, one on your belly. Feel the warmth of your own touch. Breathe into both hands. You are your own safe place."
            }
        case .sensitive:
            switch phase {
            case .menstrual:
                "Cocoon position: Lie on your side in a fetal position. Wrap your arms around yourself. Rock gently if it feels good. You are held."
            case .follicular:
                "Butterfly hug: Cross your arms over your chest, hands resting on opposite shoulders. Alternate tapping left and right, slowly, like butterfly wings. This bilateral stimulation soothes your nervous system."
            case .ovulation:
                "Jaw and shoulder release: Drop your jaw gently, letting your mouth hang open. Roll your shoulders back three times, then forward. Shake out your hands. Release what you're carrying."
            case .luteal:
                "Weighted comfort: If you have a blanket, wrap it around your shoulders. If not, press your palms firmly against your thighs. The deep pressure signals safety to your body."
            }
        case .overstimulated:
            switch phase {
            case .menstrual:
                "Total surrender: Lie flat with a pillow under your knees. Let gravity hold you. You don't need to do anything. Just let the ground support your full weight."
            case .follicular:
                "Shake it off: Stand and shake your hands vigorously for 30 seconds. Then your arms. Then let your whole body shake. Animals do this to discharge stress. Then be still and notice the tingling."
            case .ovulation:
                "Cold water reset: Run cold water over your wrists and the back of your neck for 30 seconds. This activates your dive reflex and immediately calms your nervous system."
            case .luteal:
                "Legs up the wall: Lie on your back and rest your legs up against a wall. Stay for 3-5 minutes. This position naturally lowers your heart rate and calms your whole system."
            }
        }
    }

    // MARK: - Grounding Prompts

    private static func groundingPrompt(for state: NervousSystemState, phase: CyclePhase) -> String {
        switch state {
        case .regulated:
            switch phase {
            case .menstrual: "Notice the softness around you. What texture feels most comforting right now?"
            case .follicular: "Look around and find three things that are growing or alive. You are in a season of growth too."
            case .ovulation: "Place your feet flat on the ground. Feel the earth supporting you. You are connected to everything."
            case .luteal: "Name five things you can see right now. Let the present moment anchor you."
            }
        case .sensitive:
            switch phase {
            case .menstrual: "Touch something soft — a blanket, your own skin. Let the sensation remind you: you are here, you are safe."
            case .follicular: "Listen for the most distant sound you can hear. Then the closest. You are present between these two points."
            case .ovulation: "Press your feet firmly into the floor. Feel the resistance. The ground is solid. You are solid."
            case .luteal: "Hold something warm — a cup of tea, your own hands. Let the warmth spread through you."
            }
        case .overstimulated:
            switch phase {
            case .menstrual: "Close your eyes. Count your breaths backward from 10. If you lose count, start again. There is no wrong way."
            case .follicular: "Name one thing you can taste, one you can smell, one you can touch. Three senses, three anchors."
            case .ovulation: "Put your hand over your heart. Feel it beating. It has beaten every moment of your life without you asking. Trust your body."
            case .luteal: "Find something to hold — a stone, a pen, a pillow. Squeeze it, then release. Squeeze, then release. You can let go."
            }
        }
    }

    // MARK: - Nervous System Affirmations

    private static func affirmation(for state: NervousSystemState, phase: CyclePhase) -> String {
        switch state {
        case .regulated:
            switch phase {
            case .menstrual: "I am at peace in my stillness."
            case .follicular: "I flow with ease through this day."
            case .ovulation: "I am grounded in my radiance."
            case .luteal: "I am anchored in my own truth."
            }
        case .sensitive:
            switch phase {
            case .menstrual: "My tenderness is not a flaw. It is how I feel the world deeply."
            case .follicular: "I can be open and protected at the same time."
            case .ovulation: "I feel everything, and I can hold it all."
            case .luteal: "My sensitivity is my compass. I trust where it points."
            }
        case .overstimulated:
            switch phase {
            case .menstrual: "I give myself full permission to withdraw. The world will wait."
            case .follicular: "I can slow down even when energy rises. I choose my pace."
            case .ovulation: "I do not need to match the world's intensity. My calm is my power."
            case .luteal: "I release the need to manage everything. I only need to manage this breath."
            }
        }
    }
}
