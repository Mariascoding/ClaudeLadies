import Foundation

// MARK: - Menopause Hormone Phase

/// Even without a period, the body retains a hormonal rhythm.
/// We use the last bleed date to project a 28-day phantom cycle
/// and align nutrition to support the hormones that would naturally
/// peak in each phase — but now need dietary and lifestyle support.

enum MenopausePhase: String, CaseIterable {
    case restore     // Days 1-7: what was menstrual — focus on rebuilding, nourishing
    case build       // Days 8-14: what was follicular — estrogen-supporting foods
    case sustain     // Days 15-18: what was ovulation — antioxidants, peak nourishment
    case ground      // Days 19-28: what was luteal — progesterone support, calming

    var displayName: String {
        switch self {
        case .restore: "Restore"
        case .build: "Build"
        case .sustain: "Sustain"
        case .ground: "Ground"
        }
    }

    var description: String {
        switch self {
        case .restore: "Nourish and replenish — rebuild the reserves your body draws from"
        case .build: "Support estrogen naturally through phytoestrogen-rich foods and movement"
        case .sustain: "Peak nourishment — antioxidants, circulation, and vitality"
        case .ground: "Calm the nervous system, support progesterone pathways, rest deeply"
        }
    }

    var icon: String {
        switch self {
        case .restore: "moon.stars.fill"
        case .build: "leaf.fill"
        case .sustain: "sun.max.fill"
        case .ground: "cloud.fill"
        }
    }
}

enum MenopauseCalculator {
    struct MenopausePosition {
        let dayInCycle: Int
        let phase: MenopausePhase
        let dayInPhase: Int
        let daysSinceLastBleed: Int
    }

    static func currentPosition(lastBleedDate: Date, cycleLength: Int = 28, on date: Date = Date()) -> MenopausePosition {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: lastBleedDate)
        let today = calendar.startOfDay(for: date)
        let totalDays = calendar.dateComponents([.day], from: start, to: today).day ?? 0

        // Project a phantom cycle
        let dayInCycle = (totalDays % cycleLength) + 1

        let phase: MenopausePhase
        let dayInPhase: Int
        if dayInCycle <= 7 {
            phase = .restore
            dayInPhase = dayInCycle
        } else if dayInCycle <= 14 {
            phase = .build
            dayInPhase = dayInCycle - 7
        } else if dayInCycle <= 18 {
            phase = .sustain
            dayInPhase = dayInCycle - 14
        } else {
            phase = .ground
            dayInPhase = dayInCycle - 18
        }

        return MenopausePosition(
            dayInCycle: dayInCycle,
            phase: phase,
            dayInPhase: dayInPhase,
            daysSinceLastBleed: totalDays
        )
    }
}

// MARK: - Menopause Nutrition Content

enum MenopauseNutritionContent {

    static func dailyPlan(phase: MenopausePhase, dayInPhase: Int) -> DailyNutritionPlan {
        switch phase {
        case .restore: restorePlan(dayInPhase: dayInPhase)
        case .build: buildPlan(dayInPhase: dayInPhase)
        case .sustain: sustainPlan(dayInPhase: dayInPhase)
        case .ground: groundPlan(dayInPhase: dayInPhase)
        }
    }

    // MARK: - Restore Phase (Days 1-7)

    private static func restorePlan(dayInPhase: Int) -> DailyNutritionPlan {
        DailyNutritionPlan(
            todayFocus: "Restore phase — your body's rhythm still calls for replenishment here. Even without a bleed, this is the week to rebuild mineral stores, nourish the blood, and rest deeply. Estrogen and progesterone are at their lowest — support from the outside.",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Bone broth — collagen for joints, minerals for bones, glycine for sleep",
                    "Oats with ground flax — phytoestrogens gently support declining estrogen",
                    "Eggs — choline protects the brain as estrogen drops",
                    "Stewed prunes — iron, boron for bone density, gentle on digestion",
                    "Warm goji berry and date tea — traditional blood and Yin tonic"
                ]),
                supplements: items(.morning, .supplement, [
                    "Calcium + Vitamin D — bone density is the #1 priority in menopause",
                    "Magnesium glycinate — sleep, muscles, mood, bone density",
                    "Omega-3 DHA — protects brain, joints, and heart as estrogen declines"
                ]),
                rituals: items(.morning, .ritual, [
                    "Warm water with lemon on waking — supports liver and mineral absorption",
                    "Gentle yoga or tai chi — weight-bearing movement protects bones",
                    "Warmth — keep feet, belly, and lower back warm"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Sardines — calcium, vitamin D, omega-3 in one food",
                    "Dark leafy greens with olive oil — calcium, vitamin K for bone mineralisation",
                    "Lentils — iron, folate, plant protein",
                    "Sesame seeds or tahini — calcium-rich, supports bone density",
                    "Sweet potato — beta-carotene, gentle carbs for steady energy"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Walk after lunch — prevents bone loss, improves insulin sensitivity",
                    "Eat protein at every meal — muscle mass declines faster without estrogen"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Salmon — omega-3 for heart protection, vitamin D for bones",
                    "Cooked beetroot — supports liver, builds blood reserves",
                    "Warm turmeric milk — anti-inflammatory, supports joint comfort",
                    "Walnuts — omega-3, melatonin precursors for sleep"
                ]),
                supplements: items(.evening, .supplement, [
                    "Vitamin K2 — directs calcium into bones, not arteries",
                    "Ashwagandha — adapts to stress, supports thyroid, eases sleep"
                ]),
                rituals: items(.evening, .ritual, [
                    "Warm bath with magnesium salts — absorbs through skin, calms hot flushes",
                    "Early wind-down — melatonin production weakens without estrogen support",
                    "Legs-up-the-wall for 5 min — calms the nervous system"
                ])
            ),
            avoid: [
                "Excess caffeine — worsens hot flushes and bone calcium loss",
                "Alcohol — disrupts sleep, accelerates bone loss, triggers hot flushes",
                "Excess sugar — spikes insulin, worsens inflammation and weight gain",
                "Very spicy food — can trigger hot flushes"
            ],
            rationale: "Without menstruation, your body no longer has a monthly reset — but the hormonal rhythm echoes. This restore week is when reserves are lowest. Bone density, brain protection, and heart health now depend on what you eat rather than what your ovaries produce. Calcium, vitamin D, omega-3, and phytoestrogens become your daily medicine."
        )
    }

    // MARK: - Build Phase (Days 8-14)

    private static func buildPlan(dayInPhase: Int) -> DailyNutritionPlan {
        DailyNutritionPlan(
            todayFocus: "Build phase — in your cycling years, estrogen would be rising now. Support it with phytoestrogen-rich foods. Your body still responds to these plant compounds — they bind gently to estrogen receptors and provide the signals your ovaries no longer send.",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Ground flaxseeds in oatmeal — the richest food source of phytoestrogens",
                    "Soy milk or tempeh — isoflavones mimic estrogen gently",
                    "Berries — antioxidants protect ageing cells, support brain clarity",
                    "Pomegranate — phytoestrogens + polyphenols for heart health",
                    "Green tea — EGCG supports metabolism, protects bones"
                ]),
                supplements: items(.morning, .supplement, [
                    "Calcium + Vitamin D — continue daily",
                    "Black cohosh — traditional menopause herb, reduces hot flushes",
                    "Vitamin E — eases hot flushes, protects skin elasticity"
                ]),
                rituals: items(.morning, .ritual, [
                    "Warm lemon water with a pinch of turmeric — anti-inflammatory start",
                    "Strength training — the single best activity for bone density and metabolism",
                    "Morning sunlight — resets circadian rhythm, natural vitamin D"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Edamame or tofu — isoflavones bind to estrogen receptors",
                    "Cruciferous vegetables — support healthy estrogen metabolism",
                    "Avocado — healthy fats sustain hormone production from adrenals",
                    "Chickpeas — plant protein + phytoestrogens",
                    "Pumpkin seeds — zinc supports the adrenals' hormone production"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Weight-bearing exercise or brisk walk — builds bone, boosts mood",
                    "Social connection — isolation worsens menopause symptoms significantly"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Wild salmon — omega-3 protects heart (risk rises without estrogen)",
                    "Cooked kale with sesame — calcium from two sources",
                    "Miso soup — fermented soy, gentle phytoestrogens, gut support",
                    "Red grapes — resveratrol supports cardiovascular health"
                ]),
                supplements: items(.evening, .supplement, [
                    "Magnesium — prevents night cramps, supports deeper sleep",
                    "Evening primrose oil — GLA supports skin moisture and hormone pathways"
                ]),
                rituals: items(.evening, .ritual, [
                    "Cool bedroom — hot flushes worsen in warm rooms",
                    "Layer bedding — so you can adjust without fully waking",
                    "Meditation or breathing — calms the nervous system, reduces flush frequency"
                ])
            ),
            avoid: [
                "Hot beverages right before bed — can trigger night sweats",
                "Excess alcohol — disrupts already fragile sleep architecture",
                "Refined carbohydrates — insulin spikes accelerate aging and weight gain",
                "Smoking — doubles bone loss rate and worsens every menopause symptom"
            ],
            rationale: "Your ovaries produced estrogen for decades. Now your adrenal glands, fat tissue, and diet take over. Phytoestrogens from flax, soy, and legumes bind to estrogen receptors and provide 1/100th to 1/1000th of the signal — gentle, but meaningful. Japanese women who eat soy daily report significantly fewer hot flushes. Your body still listens to these plant hormones."
        )
    }

    // MARK: - Sustain Phase (Days 15-18)

    private static func sustainPlan(dayInPhase: Int) -> DailyNutritionPlan {
        DailyNutritionPlan(
            todayFocus: "Sustain phase — this is your peak vitality window within the rhythm. Even without ovulation, your body's energy follows this pattern. Maximise antioxidants, circulation, and nutrient density. This is the week to invest in longevity.",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Colourful fruit bowl — antioxidants protect every cell from accelerated ageing",
                    "Eggs with turmeric and vegetables — protein + anti-inflammatory",
                    "Matcha — L-theanine for calm focus, EGCG for metabolism",
                    "Nuts and seeds mix — vitamin E, zinc, selenium for hormone pathways",
                    "Fermented foods — gut health determines how well you absorb everything"
                ]),
                supplements: items(.morning, .supplement, [
                    "Calcium + Vitamin D — non-negotiable daily",
                    "CoQ10 — mitochondrial energy declines with age, CoQ10 reverses this",
                    "Collagen peptides — supports skin, joints, and bone matrix"
                ]),
                rituals: items(.morning, .ritual, [
                    "Warm water with lemon and ginger — circulation booster",
                    "Your most vigorous exercise this week — dance, hike, swim, strength train",
                    "Cold water face splash or brief cold exposure — stimulates circulation"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Wild-caught fish — omega-3 for brain and heart at their most receptive",
                    "Rainbow vegetables — each colour delivers different protective compounds",
                    "Grass-fed beef or lentils — iron and B12 for energy and brain function",
                    "Olive oil — monounsaturated fats protect the cardiovascular system",
                    "Brazil nuts — selenium supports thyroid, which governs metabolism"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Creative or social activity — your mental energy is highest this week",
                    "Walk in nature — combines movement, sunlight, and stress reduction"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Dark chocolate 85%+ — flavonoids protect blood vessels, magnesium for mood",
                    "Roasted vegetables with tahini — mineral-dense, satisfying",
                    "Bone broth soup — collagen, glucosamine for joint comfort",
                    "Tart cherry juice — natural melatonin source, helps sleep"
                ]),
                supplements: items(.evening, .supplement, [
                    "Omega-3 DHA — brain protection is a daily investment",
                    "Magnesium — sleep quality determines everything else"
                ]),
                rituals: items(.evening, .ritual, [
                    "Dry brushing before shower — lymphatic support, skin circulation",
                    "Gratitude practice — reframes the menopause narrative from loss to liberation",
                    "Prioritise joy — cortisol is the enemy of every hormone you're trying to sustain"
                ])
            ),
            avoid: [
                "Chronic stress — cortisol directly suppresses the hormones you need most",
                "Skipping protein — muscle loss accelerates without estrogen, protein counters it",
                "Isolation — social connection is hormonal medicine",
                "Crash diets — metabolic slowdown in menopause makes restriction dangerous"
            ],
            rationale: "Without ovulation, there's no progesterone surge and no estrogen peak — but your body's energy still crests here. Antioxidants protect your cells from accelerated ageing, omega-3 shields your heart (cardiovascular risk doubles after menopause), and CoQ10 keeps your mitochondria producing the energy that hormones no longer regulate automatically. This is the week to invest in longevity."
        )
    }

    // MARK: - Ground Phase (Days 19-28)

    private static func groundPlan(dayInPhase: Int) -> DailyNutritionPlan {
        let isLate = dayInPhase > 6

        let focus = isLate
            ? "Late ground phase — your body may feel the echo of pre-menstrual patterns: mood dips, sleep disruption, bloating. These are real. Support progesterone pathways and calm the nervous system. The rhythm continues even without the bleed."
            : "Ground phase — in your cycling years, progesterone would be dominant now. Without it, anxiety and sleep issues can surface. Progesterone-supporting foods and calming rituals are your best tools."

        return DailyNutritionPlan(
            todayFocus: focus,
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Oats with cinnamon and walnuts — steady blood sugar, serotonin support",
                    "Sweet potato — complex carbs boost serotonin naturally",
                    "Eggs with avocado — choline and healthy fats for brain and mood",
                    "Stewed apple with cardamom — gentle, warming, Ayurvedic comfort",
                    "Warm golden milk — turmeric calms inflammation, milk provides tryptophan"
                ]),
                supplements: items(.morning, .supplement, [
                    "Calcium + Vitamin D — continue daily",
                    "Magnesium glycinate — calms anxiety, supports sleep, prevents cramps",
                    "Vitex (chasteberry) — supports the body's progesterone memory"
                ]),
                rituals: items(.morning, .ritual, [
                    "Warm water with honey and ginger — grounding, nourishing start",
                    "Gentle yoga or walking only — intense exercise raises cortisol when you need calm",
                    "Morning sunlight for 10 min — anchors circadian rhythm for better sleep tonight"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Turkey or chicken — tryptophan converts to serotonin, then melatonin",
                    "Roasted root vegetables — grounding, blood sugar stable, mineral-rich",
                    "Pumpkin seeds — zinc and magnesium support calming neurotransmitters",
                    "Dark leafy greens with tahini — calcium + magnesium together",
                    "Warm lentil soup — easy protein, iron, steady energy"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Eat every 3-4 hours — blood sugar crashes trigger hot flushes and anxiety",
                    "Afternoon walk — daylight exposure improves night sleep quality",
                    "Reduce commitments — honour the slower rhythm this week"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Salmon — omega-3 calms inflammation, supports mood",
                    "Chamomile tea — mild sedative, calms nervous system",
                    "Warm soup with miso — tryptophan + phytoestrogens + gut support",
                    "Tart cherries or juice — natural melatonin for sleep",
                    "Dark chocolate — magnesium, serotonin, a legitimate comfort food"
                ]),
                supplements: items(.evening, .supplement, [
                    "Ashwagandha — lowers cortisol, supports thyroid, improves sleep",
                    "Melatonin if needed — production declines without estrogen"
                ]),
                rituals: items(.evening, .ritual, [
                    "Warm bath — lowers core temperature afterward, triggering sleepiness",
                    "Cool, dark bedroom — essential for hot flush management at night",
                    "Body scan meditation — releases tension accumulated through the day",
                    "Layer bedding and wear breathable fabrics — night sweats are manageable with preparation"
                ])
            ),
            avoid: [
                "Late caffeine — sleep is your most vulnerable function now",
                "Spicy food at dinner — can trigger night sweats",
                "Alcohol — feels calming but fragments sleep and triggers flushes",
                "Screen time before bed — blue light suppresses already-weakened melatonin",
                "Skipping meals — blood sugar instability amplifies every menopause symptom"
            ],
            rationale: "Without progesterone, the grounding phase can feel unmoored — anxiety rises, sleep fragments, mood dips. But your body remembers this rhythm. Tryptophan-rich foods (turkey, oats, milk) convert to serotonin and then melatonin. Magnesium calms the nervous system. Ashwagandha lowers cortisol. You can't replace the hormones with food alone — but you can give your body every building block it needs to feel its best."
        )
    }

    // MARK: - Helpers

    private static func items(_ time: TimeOfDay, _ category: NutritionItemCategory, _ names: [String]) -> [NutritionItem] {
        names.map { NutritionItem(name: $0, category: category, timeBlock: time) }
    }
}
