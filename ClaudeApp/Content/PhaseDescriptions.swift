import Foundation

struct PhaseDescription {
    let phase: CyclePhase
    let title: String
    let innerSeason: String
    let overview: String
    let hormoneHighlight: String
    let superpower: String
    let nourishment: String
    let movement: String
}

enum PhaseDescriptions {
    static func description(for phase: CyclePhase) -> PhaseDescription {
        switch phase {
        case .menstrual: menstrual
        case .follicular: follicular
        case .ovulation: ovulation
        case .luteal: luteal
        }
    }

    static let menstrual = PhaseDescription(
        phase: .menstrual,
        title: "Menstrual Phase",
        innerSeason: "Inner Winter",
        overview: "Your body is shedding and renewing. Hormone levels are at their lowest, and your energy naturally turns inward. This is your body's invitation to rest, reflect, and release. Honor this phase as the foundation of your entire cycle.",
        hormoneHighlight: "Estrogen and progesterone are at their lowest. Your body is focused on release and renewal. The right and left hemispheres of your brain are most connected now — making this a time of deep intuitive insight.",
        superpower: "Intuition and vision. Your analytical mind quiets, and deeper knowing emerges. Many women report their most powerful insights during menstruation. Journal, dream, and listen inward.",
        nourishment: "Warm, iron-rich foods: soups, stews, dark leafy greens, beets, and gentle spices. Stay hydrated. Dark chocolate is not a craving — it's your body asking for magnesium.",
        movement: "Gentle stretching, restorative yoga, slow walks in nature. If it feels like effort, it's too much. Rest is the most productive thing you can do right now."
    )

    static let follicular = PhaseDescription(
        phase: .follicular,
        title: "Follicular Phase",
        innerSeason: "Inner Spring",
        overview: "Rising estrogen brings fresh energy, optimism, and mental clarity. Your body is preparing for ovulation, and you may notice increased creativity, motivation, and sociability. This is your season of new beginnings.",
        hormoneHighlight: "Estrogen is rising steadily, boosting serotonin and dopamine. Your brain is primed for learning new things and forming new neural pathways. FSH is stimulating follicle development.",
        superpower: "Creativity and initiation. Your brain loves novelty right now. Start new projects, learn new skills, brainstorm freely. You absorb information faster and think more flexibly.",
        nourishment: "Light, fresh foods: salads, fermented foods, lean proteins, and sprouted grains. Your metabolism is naturally efficient — eat to fuel your rising energy.",
        movement: "Try new workouts, dance, cardio, hiking. Your body recovers faster and builds strength more efficiently. This is the best time to challenge yourself physically."
    )

    static let ovulation = PhaseDescription(
        phase: .ovulation,
        title: "Ovulation Phase",
        innerSeason: "Inner Summer",
        overview: "You're at your peak. Estrogen surges, testosterone peaks briefly, and you may feel more confident, articulate, and magnetic. This is a short but powerful window — typically 3-4 days around ovulation.",
        hormoneHighlight: "Estrogen peaks, triggering the LH surge that releases the egg. Testosterone briefly spikes, boosting confidence and desire. You may notice enhanced verbal fluency, facial symmetry, and social magnetism.",
        superpower: "Communication and connection. Your verbal skills are at their strongest. Have important conversations, present ideas, negotiate, connect deeply with others. Your presence is naturally amplified.",
        nourishment: "Raw vegetables, fruits, lighter grains, and anti-inflammatory foods. Your body runs warm — cool, hydrating foods feel best. Support liver detoxification with cruciferous vegetables.",
        movement: "High-intensity workouts, group fitness, competitive sports. Your pain tolerance is higher and endurance peaks. This is when personal records happen."
    )

    static let luteal = PhaseDescription(
        phase: .luteal,
        title: "Luteal Phase",
        innerSeason: "Inner Autumn",
        overview: "Progesterone rises and your energy gradually turns inward. The first half may feel productive and detail-oriented; the second half calls for more rest and self-compassion. Your inner editor awakens — use it wisely.",
        hormoneHighlight: "Progesterone dominates, promoting calm but also potentially causing PMS symptoms. Serotonin levels may dip, increasing cravings and emotional sensitivity. Your metabolism speeds up — you genuinely need more calories.",
        superpower: "Discernment and completion. Your critical thinking sharpens. You notice what isn't working and can refine, edit, and improve. Channel this into completing projects rather than self-criticism.",
        nourishment: "Complex carbohydrates, root vegetables, magnesium-rich foods (dark chocolate, nuts, seeds). Your caloric needs increase by 100-300 calories. Honor your hunger — it's hormonal, not weakness.",
        movement: "Moderate exercise shifting to gentle: yoga, pilates, walking, swimming. Listen to your body day by day. Forcing intense workouts can increase cortisol and worsen PMS symptoms."
    )
}
