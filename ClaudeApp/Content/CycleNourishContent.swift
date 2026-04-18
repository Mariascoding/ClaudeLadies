import Foundation

// MARK: - Cycle Nourish Wisdom

/// Default nourishment guidance for each cycle phase, grounded in Traditional Chinese Medicine,
/// Ayurveda, and ancestral women's health traditions. Shown when no protocol is selected.

enum CycleNourishContent {

    static func dailyPlan(phase: CyclePhase, dayInPhase: Int, goal: WellnessGoal) -> DailyNutritionPlan {
        switch phase {
        case .menstrual:
            menstrualPlan(dayInPhase: dayInPhase, goal: goal)
        case .follicular:
            follicularPlan(dayInPhase: dayInPhase, goal: goal)
        case .ovulation:
            ovulationPlan(dayInPhase: dayInPhase, goal: goal)
        case .luteal:
            lutealPlan(dayInPhase: dayInPhase, goal: goal)
        }
    }

    // MARK: - Menstrual Phase

    private static func menstrualPlan(dayInPhase: Int, goal: WellnessGoal) -> DailyNutritionPlan {
        // TCM: Blood is moving — warm the center, support Spleen Qi, nourish Blood
        // Ayurveda: Apana Vayu (downward flow) is active — ground with warmth, avoid cold/raw
        // Day 1 is most sensitive: body loses fluids, iron, warmth

        let isDay1 = dayInPhase == 1
        let isEarlyDays = dayInPhase <= 2

        let focus: String
        if isDay1 {
            focus = "Day 1 — Your body is releasing. In Chinese Medicine this is the time of 'letting go.' Eat warm food within 45 minutes of waking to support your Spleen Qi and prevent blood sugar drops. Warm fluids are essential — you are losing blood and warmth together."
        } else if isEarlyDays {
            focus = "Day \(dayInPhase) — Flow is active. Ancient traditions agree: warm the center, nourish the blood, and rest deeply. Your body is doing sacred work. Eat regularly and keep your feet and lower belly warm."
        } else {
            focus = "Day \(dayInPhase) — Flow is easing. Continue warm, blood-building foods. In TCM this is the bridge between release and renewal — gently rebuild your reserves with iron-rich broths and cooked vegetables."
        }

        let morningFoods: [String]
        let morningSupps: [String]
        let morningRituals: [String]

        if isDay1 {
            morningFoods = [
                "Warm honey water on waking (nourishes Blood, prevents lightheadedness)",
                "Congee or warm oatmeal with dates and goji berries",
                "Soft-cooked eggs with gentle spices (turmeric, ginger)"
            ]
            morningSupps = [
                "Iron with vitamin C (rebuild what you lose)",
                "Warm ginger or cinnamon tisane"
            ]
            morningRituals = [
                "Eat within 45 min of waking — do not fast today",
                "Place a warm compress on your lower belly"
            ]
        } else {
            morningFoods = [
                "Warm honey + lemon water on waking",
                "Red date (jujube) and goji berry porridge",
                "Stewed fruit with warming spices"
            ]
            morningSupps = [
                "B-complex for energy support",
                "Warm raspberry leaf tea"
            ]
            morningRituals = [
                "Eat within 1 hour of waking",
                "Gentle stretching — nothing intense"
            ]
        }

        return DailyNutritionPlan(
            todayFocus: focus,
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, morningFoods),
                supplements: items(.morning, .supplement, morningSupps),
                rituals: items(.morning, .ritual, morningRituals)
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Slow-cooked bone broth or red lentil soup",
                    "Cooked beets with olive oil (blood-building in TCM)",
                    isDay1 ? "Fresh beetroot or carrot juice (red/orange to nourish blood)" : "Dark leafy greens cooked with ghee"
                ]),
                supplements: items(.afternoon, .supplement, [
                    "Magnesium (eases cramps, calms nervous system)"
                ]),
                rituals: items(.afternoon, .ritual, [
                    "Short walk if energy allows — no pressure",
                    isDay1 ? "Sip warm fluids throughout — dehydration worsens cramps" : "Keep meals warm and well-spiced"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Warm stew with root vegetables and lamb or tofu",
                    "Red date and longan tea (TCM blood tonic)",
                    "Cooked sweet potato with cinnamon"
                ]),
                supplements: items(.evening, .supplement, [
                    "Omega-3 (soothes inflammation)",
                    isDay1 ? "Nettle or chamomile tisane before bed" : "Warm turmeric milk (golden milk)"
                ]),
                rituals: items(.evening, .ritual, [
                    "Warm feet before bed (TCM: cold feet = stagnation)",
                    "Early rest — sleep is medicine during menstruation"
                ])
            ),
            avoid: [
                "Cold or iced drinks (constrict blood flow — TCM and Ayurveda agree)",
                "Raw salads and cold fruit (weaken digestive fire)",
                "Fasting or skipping meals (depletes already-moving energy)",
                "Intense exercise (diverts blood upward, away from the uterus)",
                "Excess caffeine (tightens blood vessels when flow needs openness)"
            ],
            rationale: isDay1
                ? "Day 1 wisdom across traditions: TCM says warm the Spleen to hold Blood, Ayurveda says honor apana vayu's downward flow, and ancestral practice says eat early, eat warm, stay soft. Your body is losing iron, fluids, and warmth — replace all three gently."
                : "Ancient traditions — Chinese Medicine, Ayurveda, and European herbalism — all agree: menstruation requires warmth, rest, and blood-nourishing foods. Cold contracts the uterus; warmth opens it. Cooked foods spare your digestive energy so your body can focus on release and renewal."
        )
    }

    // MARK: - Follicular Phase

    private static func follicularPlan(dayInPhase: Int, goal: WellnessGoal) -> DailyNutritionPlan {
        // TCM: Yin is building — nourish Yin, support Blood, eat fresh and lightly cooked
        // Ayurveda: Kapha clearing into Pitta — lighter foods, sprouted, fermented

        let isEarly = dayInPhase <= 3

        let focus = isEarly
            ? "Your inner spring begins. Estrogen rises and energy returns. TCM says this is the time to nourish Yin — eat fresh, lightly cooked foods. Introduce more variety and movement as your body rebuilds."
            : "Yin is building beautifully. Your body craves freshness and lightness now. Ayurveda says this is your creative window — feed it with colorful, nutrient-dense foods and enjoy your rising energy."

        return DailyNutritionPlan(
            todayFocus: focus,
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Fresh berries with seeds and yogurt",
                    "Sprouts and avocado on sourdough",
                    "Green smoothie with spinach, banana, flax"
                ]),
                supplements: items(.morning, .supplement, [
                    "B-complex (supports rising energy)",
                    "Vitamin E (nourishes growing follicles)"
                ]),
                rituals: items(.morning, .ritual, [
                    "Movement you enjoy — strength, dance, walking",
                    "Fermented food with breakfast (kimchi, sauerkraut)"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Colorful grain bowl with fresh vegetables",
                    "Wild salmon or tempeh for protein",
                    "Cruciferous vegetables (broccoli, kale — support estrogen metabolism)"
                ]),
                supplements: items(.afternoon, .supplement, [
                    "Probiotic (gut health supports hormone clearance)"
                ]),
                rituals: items(.afternoon, .ritual, [
                    "This is your best phase for social meals",
                    "Try new recipes — your curiosity peaks now"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Light grain and vegetable dinner",
                    "Pumpkin seeds (zinc for upcoming ovulation)",
                    "Goji berry and chrysanthemum tea (TCM Yin tonic)"
                ]),
                supplements: items(.evening, .supplement, [
                    "Zinc (prepares for progesterone production)"
                ]),
                rituals: items(.evening, .ritual, [
                    "Lighter evening meals than menstrual phase",
                    "Journal or plan — your mind is sharp now"
                ])
            ),
            avoid: [
                "Heavy, greasy foods (your body wants lightness now)",
                "Excess sugar (disrupts the estrogen build)",
                "Overtraining without recovery"
            ],
            rationale: "In TCM, the follicular phase is Yin-building time — the body prepares a rich lining and grows a dominant follicle. Ayurveda sees this as Kapha transitioning to Pitta: heavy clears, fire builds. Fresh foods, ferments, and movement match your body's natural upswing."
        )
    }

    // MARK: - Ovulation Phase

    private static func ovulationPlan(dayInPhase: Int, goal: WellnessGoal) -> DailyNutritionPlan {
        // TCM: Yang rises, Qi and Blood are abundant — support the transformation
        // Ayurveda: Pitta is at its peak — cool slightly but keep fire strong

        return DailyNutritionPlan(
            todayFocus: "Peak energy — your inner summer. TCM says Yin transforms into Yang now: Qi and Blood are abundant. Ayurveda says Pitta peaks. Eat antioxidant-rich foods to protect egg quality and fiber to support healthy estrogen clearance.",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Antioxidant-rich berries and pomegranate",
                    "Eggs with fresh herbs and tomato",
                    "Citrus or kiwi (vitamin C supports the Yin-Yang shift)"
                ]),
                supplements: items(.morning, .supplement, [
                    "CoQ10 (mitochondrial support for egg quality)",
                    "Vitamin C + E (antioxidant protection)"
                ]),
                rituals: items(.morning, .ritual, [
                    "Your peak workout window — use it",
                    "Hydrate generously — cervical fluid increases"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Raw or lightly cooked colorful vegetables",
                    "Quality protein (grass-fed, wild-caught, organic)",
                    "Fiber-rich foods (support estrogen metabolism)"
                ]),
                supplements: items(.afternoon, .supplement, [
                    "Selenium (Brazil nuts — supports progesterone transition)"
                ]),
                rituals: items(.afternoon, .ritual, [
                    "Social connection — your communication peaks",
                    "Walk in sunlight for vitamin D"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Light dinner — your body digests quickly now",
                    "Bitter greens (arugula, dandelion — liver support)",
                    "Cooling herbs: mint tea, rose water"
                ]),
                supplements: items(.evening, .supplement, [
                    "Omega-3 (anti-inflammatory support)"
                ]),
                rituals: items(.evening, .ritual, [
                    "Slightly lighter dinner portions — trust your body",
                    "Cooling self-care (cucumber eye pads, face mist)"
                ])
            ),
            avoid: [
                "Inflammatory foods (fried, processed)",
                "Alcohol (stresses the liver during peak hormone processing)",
                "Overheating (your body temp rises naturally)"
            ],
            rationale: "Ovulation is the crescendo of your cycle. TCM describes it as Yin transforming into Yang — the egg releases, and progesterone begins. Your liver works overtime to process peak estrogen. Antioxidants, fiber, and bitter greens protect this delicate transition."
        )
    }

    // MARK: - Luteal Phase

    private static func lutealPlan(dayInPhase: Int, goal: WellnessGoal) -> DailyNutritionPlan {
        // TCM: Yang phase — warm, support Qi, prepare for next bleed
        // Ayurveda: Vata begins to rise — ground with warmth and routine

        let isLateLuteal = dayInPhase > 7

        let focus = isLateLuteal
            ? "Late luteal — progesterone drops and Vata rises. Cravings, mood shifts, and tension are your body asking for grounding. Eat regularly, choose complex carbs, and keep your routine steady. Warmth returns as your guide."
            : "Your inner autumn. Progesterone is high — TCM says Yang energy dominates. Eat warm, grounding foods. Steady blood sugar is your biggest protection against PMS. Ayurveda says pacify rising Vata with routine and nourishment."

        return DailyNutritionPlan(
            todayFocus: focus,
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Warm oatmeal with nut butter and banana",
                    "Eggs with sweet potato and avocado",
                    "Complex carbs first — prevent the cortisol spike"
                ]),
                supplements: items(.morning, .supplement, [
                    "Magnesium glycinate (calms, prevents cramps)",
                    "B6 (supports progesterone, reduces PMS)"
                ]),
                rituals: items(.morning, .ritual, [
                    "Eat within 1 hour of waking — blood sugar matters most now",
                    "Gentle morning — no rushing"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Roasted root vegetables with tahini",
                    "Slow-cooked meals with warming spices",
                    isLateLuteal ? "Dark chocolate (magnesium, serotonin — trust this craving)" : "Brown rice with cooked greens and ghee"
                ]),
                supplements: items(.afternoon, .supplement, [
                    "Calcium (proven to reduce PMS symptoms)"
                ]),
                rituals: items(.afternoon, .ritual, [
                    "Walk after meals (insulin regulation)",
                    "Do not skip meals — your body reads it as stress"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Warm, comforting dinner (stews, curries, soups)",
                    "Sweet potato with cinnamon (satisfies sweet cravings naturally)",
                    "Chamomile or ashwagandha milk before bed"
                ]),
                supplements: items(.evening, .supplement, [
                    "Omega-3 (anti-inflammatory as body prepares for bleed)"
                ]),
                rituals: items(.evening, .ritual, [
                    "Earlier bedtime — progesterone makes you sleepy for a reason",
                    "Warm bath with magnesium salts"
                ])
            ),
            avoid: [
                "Skipping meals (cortisol spikes worsen PMS dramatically)",
                "Excess caffeine (amplifies anxiety and breast tenderness)",
                "Alcohol (disrupts progesterone and sleep)",
                "Cold, raw foods (Vata is rising — warmth grounds)"
            ],
            rationale: isLateLuteal
                ? "As progesterone drops, Vata (air and space energy) rises in Ayurveda. TCM says Qi may stagnate. Cravings for carbs and chocolate are your body requesting serotonin and magnesium — honor them wisely with whole food versions. Steady meals prevent the cortisol cascade that worsens PMS."
                : "The luteal phase is Yang time in TCM — your body temperature rises, metabolism speeds up, and you need 200-300 more calories daily. Ayurveda warns that Vata accumulates here. Warm, regular, grounding meals prevent the blood sugar crashes that trigger PMS symptoms."
        )
    }

    // MARK: - Helpers

    private static func items(_ time: TimeOfDay, _ category: NutritionItemCategory, _ names: [String]) -> [NutritionItem] {
        names.map { NutritionItem(name: $0, category: category, timeBlock: time) }
    }
}
