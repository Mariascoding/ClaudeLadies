import Foundation

// MARK: - Time of Day

enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: "Morning"
        case .afternoon: "Afternoon"
        case .evening: "Evening"
        }
    }

    var icon: String {
        switch self {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "moon.stars.fill"
        }
    }

    var timeHint: String {
        switch self {
        case .morning: "6 AM – 12 PM"
        case .afternoon: "12 PM – 6 PM"
        case .evening: "6 PM – 10 PM"
        }
    }
}

// MARK: - Item Category

enum NutritionItemCategory: String, CaseIterable {
    case food
    case supplement
    case ritual

    var displayName: String {
        switch self {
        case .food: "Foods & Herbs"
        case .supplement: "Supplements"
        case .ritual: "Rituals"
        }
    }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .supplement: "pill.fill"
        case .ritual: "sparkles"
        }
    }
}

// MARK: - Item Origin

enum NutritionItemOrigin {
    case personal
    case protocolSuggestion
}

// MARK: - Nutrition Item

struct NutritionItem: Identifiable {
    let name: String
    let category: NutritionItemCategory
    let timeBlock: TimeOfDay
    var origin: NutritionItemOrigin = .protocolSuggestion

    var id: String {
        "\(timeBlock.rawValue).\(category.rawValue).\(name)"
    }

    var isPersonal: Bool { origin == .personal }
}

// MARK: - Time Block

struct TimeBlock: Identifiable {
    let timeOfDay: TimeOfDay
    let foods: [NutritionItem]
    let supplements: [NutritionItem]
    let rituals: [NutritionItem]

    var id: String { timeOfDay.rawValue }

    var allItems: [NutritionItem] {
        foods + supplements + rituals
    }

    var totalCount: Int { allItems.count }
}

// MARK: - Daily Nutrition Plan

struct DailyNutritionPlan {
    let todayFocus: String
    let morning: TimeBlock
    let afternoon: TimeBlock
    let evening: TimeBlock
    let avoid: [String]
    let rationale: String

    var timeBlocks: [TimeBlock] { [morning, afternoon, evening] }

    var totalItemCount: Int {
        timeBlocks.reduce(0) { $0 + $1.totalCount }
    }
}

// MARK: - Content Engine

enum NutritionContent {
    static func dailyPlan(
        for nutritionProtocol: NutritionProtocol,
        phase: CyclePhase,
        goal: WellnessGoal
    ) -> DailyNutritionPlan {
        switch nutritionProtocol {
        case .seedCycling:
            seedCyclingPlan(phase: phase, goal: goal)
        case .cellDetox:
            cellDetoxPlan(phase: phase, goal: goal)
        case .daoSt:
            daoSupportPlan(phase: phase, goal: goal)
        case .hairHealth:
            hairHealthPlan(phase: phase, goal: goal)
        case .gutHeal:
            gutHealPlan(phase: phase, goal: goal)
        }
    }

    // MARK: - Seed Cycling

    private static func seedCyclingPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = seedCyclingGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            // First half seeds: flax + pumpkin (estrogen support)
            return DailyNutritionPlan(
                todayFocus: "Flax and pumpkin seeds support gentle estrogen rebuilding during your inner winter. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Cooked spinach — iron to rebuild blood loss",
                        "Oats — warm, grounding, steady blood sugar",
                        "Beetroot — builds blood, supports liver detox",
                        "Goji berries — traditional blood tonic, rich in iron"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "1 tbsp ground flaxseeds — lignans support estrogen",
                        "1 tbsp pumpkin seeds — zinc prepares progesterone pathways"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon on waking — gentle liver flush, supports estrogen clearance",
                        "Warm ginger tea — warms the uterus, improves blood flow to pelvis",
                        "Gentle walk or stretch — moves blood without depleting energy",
                        "Warm compress on lower belly — relaxes uterine muscles, eases cramps"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Dark leafy greens — iron and folate for blood rebuilding",
                        "Lentils — plant protein + iron without heaviness",
                        "Bone broth — collagen and minerals for recovery",
                        "Cooked carrots — beta-carotene supports uterine lining",
                        "Black beans — iron, magnesium, and folate"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Rest after eating — digestion needs energy during menstruation",
                        "Warm cinnamon or turmeric tea — anti-inflammatory, eases cramps"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Sweet potato — complex carbs stabilise mood and blood sugar",
                        "Salmon — omega-3 reduces period inflammation",
                        "Turmeric with black pepper — anti-inflammatory, eases cramping",
                        "Red dates — traditional blood tonic",
                        "Cooked root vegetables — warming, easy to digest"
                    ]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, [
                        "Raspberry leaf tea — tones the uterus, supports healthy shedding",
                        "Warm foot soak — draws energy downward, promotes restful sleep",
                        "Early bedtime — sleep rebuilds the blood you are losing"
                    ])
                ),
                avoid: ["Raw cold foods — constrict uterine blood flow", "Excess caffeine — tightens blood vessels", "Refined sugar — spikes cortisol"],
                rationale: "Flax lignans bind to estrogen receptors and support healthy estrogen metabolism. Pumpkin seeds provide zinc, magnesium, and omega-3s that prime progesterone pathways for later in the cycle."
            )

        case .follicular:
            // First half seeds: flax + pumpkin (estrogen support)
            return DailyNutritionPlan(
                todayFocus: "Flax and pumpkin seeds continue building estrogen as your body enters inner spring. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Eggs — choline supports estrogen metabolism",
                        "Berries — antioxidants protect growing follicles",
                        "Broccoli sprouts — sulforaphane clears excess estrogen",
                        "Avocado — healthy fats fuel hormone production",
                        "Citrus — vitamin C boosts iron absorption and estrogen pathways"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "1 tbsp ground flaxseeds — lignans modulate rising estrogen",
                        "1 tbsp pumpkin seeds — zinc and magnesium for ovulation prep"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon on waking — liver support for estrogen metabolism",
                        "Green smoothie with seeds — delivers phytoestrogens with fibre",
                        "Morning movement — strength training, dancing, or brisk walking to match rising energy",
                        "Cold water face splash — stimulates circulation, matches spring energy"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Cruciferous vegetables — DIM compound balances estrogen",
                        "Wild salmon — omega-3 reduces inflammation, feeds follicles",
                        "Fermented foods — gut bacteria metabolise estrogen",
                        "Quinoa — complete protein supports tissue building",
                        "Sprouts — enzymes and phytonutrients peak in raw form now"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat a fermented food — sauerkraut, kimchi, or kefir support estrogen clearance",
                        "Social meal — your energy and sociability rise with estrogen"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Asparagus — folate supports cell division",
                        "Olive oil — monounsaturated fats for hormone synthesis",
                        "Chickpeas — plant protein + B6 for progesterone prep",
                        "Artichoke — prebiotic fibre supports estrogen clearance",
                        "Fresh herbs — parsley is rich in iron and vitamin C"
                    ]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, [
                        "Prepare tomorrow's seeds — consistency builds the habit",
                        "Dry brushing before shower — boosts lymphatic flow, supports detox"
                    ])
                ),
                avoid: ["Excess dairy — can compete with estrogen receptors", "Processed foods", "Alcohol — stresses estrogen metabolism"],
                rationale: "As estrogen rises, flax lignans ensure healthy metabolism so estrogen doesn't accumulate. Pumpkin seeds build the zinc stores your body will need for progesterone production after ovulation."
            )

        case .ovulation:
            // Second half seeds: sesame + sunflower (progesterone support)
            return DailyNutritionPlan(
                todayFocus: "Switch to sesame and sunflower seeds to support the progesterone shift at ovulation. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Citrus fruits — vitamin C supports the corpus luteum",
                        "Pomegranate — antioxidants protect egg quality at release",
                        "Eggs with tomato — lycopene supports reproductive tissue",
                        "Walnuts — omega-3 and vitamin E for peak fertility",
                        "Mango or papaya — enzymes support digestion at peak metabolism"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "1 tbsp sesame seeds — lignans modulate peak estrogen",
                        "1 tbsp sunflower seeds — selenium + vitamin E for progesterone"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon and a pinch of cayenne — boosts circulation at your peak",
                        "Breakfast within 1 hour of waking — fuel your highest energy window",
                        "Peak workout — your body can handle intensity now, use it",
                        "Hydrate generously — cervical fluid production increases"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Leafy greens — folate for cell division and egg quality",
                        "Grass-fed beef or lentils — B12 and iron at peak metabolic demand",
                        "Bell peppers — vitamin C supports progesterone production",
                        "Tahini — concentrated sesame, calcium for hormone signalling",
                        "Raw vegetables — your digestion is strongest now, raw works well"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat fibre-rich meal — clears estrogen through the gut as levels peak",
                        "Walk in sunlight — vitamin D supports progesterone transition"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Bitter greens — arugula, dandelion support liver clearing peak estrogen",
                        "Sardines — omega-3, calcium, vitamin D in one food",
                        "Brazil nuts — selenium supports progesterone",
                        "Fresh herbs — parsley and cilantro support detoxification",
                        "Light grain bowl — keep dinner light, your metabolism is fast"
                    ]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, [
                        "Peppermint or rose tea — cools ovulatory heat, soothes the liver",
                        "Gentle stretching — transition from peak energy toward calm"
                    ])
                ),
                avoid: ["Inflammatory oils — protect egg quality", "Excess sugar — disrupts the hormone shift", "Heavy late meals — metabolism slows in the evening"],
                rationale: "Sesame lignans help modulate the estrogen peak so the transition to progesterone is smooth. Sunflower seeds deliver selenium and vitamin E — both critical for corpus luteum function and progesterone production."
            )

        case .luteal:
            // Second half seeds: sesame + sunflower (progesterone support)
            return DailyNutritionPlan(
                todayFocus: "Sesame and sunflower seeds sustain progesterone through your inner autumn. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Oats with banana — complex carbs boost serotonin naturally",
                        "Eggs — choline and B vitamins support progesterone",
                        "Sweet potato — complex carbs prevent cortisol spikes",
                        "Cinnamon — stabilises blood sugar, reduces cravings",
                        "Nut butter — healthy fats sustain energy and hormone production"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "1 tbsp sesame seeds — zinc and calcium support progesterone",
                        "1 tbsp sunflower seeds — vitamin E sustains corpus luteum"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with honey — nourishes blood, prevents morning lightheadedness",
                        "Eat within an hour of waking — blood sugar crashes spike cortisol which lowers progesterone",
                        "Gentle morning walk — moderate movement supports progesterone, intense exercise depletes it",
                        "Deep belly breathing — activates parasympathetic system, protects progesterone"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Dark chocolate 85%+ — magnesium eases PMS, satisfies cravings",
                        "Turkey — tryptophan boosts serotonin for mood stability",
                        "Roasted root vegetables — grounding, blood sugar friendly",
                        "Pumpkin — fibre helps clear used hormones via the gut",
                        "Brown rice — slow-release carbs sustain serotonin all afternoon"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat every 3-4 hours — skipping meals is the fastest way to crash progesterone",
                        "Walk after lunch — improves insulin sensitivity and reduces bloating"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Salmon — omega-3 calms pre-menstrual inflammation",
                        "Cooked greens with ghee — fat-soluble vitamins absorb better",
                        "Squash — magnesium and potassium reduce bloating",
                        "Warm stew or curry — comforting, easy to digest, nutrient-dense",
                        "Stewed pears with cinnamon — gentle sweetness without sugar spikes"
                    ]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, [
                        "Chamomile or valerian tea — calms the nervous system, supports sleep",
                        "Warm bath with magnesium salts — absorbs magnesium through skin, eases tension",
                        "Early wind-down — progesterone makes you sleepy for a reason, honour it"
                    ])
                ),
                avoid: ["Excess salt — worsens bloating", "Caffeine — amplifies anxiety and breast tenderness", "Alcohol — disrupts progesterone and sleep quality"],
                rationale: "Sunflower seeds provide selenium and vitamin E to sustain the corpus luteum and progesterone output. Sesame seeds add zinc and calcium — both shown to reduce PMS symptoms significantly."
            )
        }
    }

    private static func seedCyclingGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "Focus on consistency for cycle balance."
        case .tryingToConceive: "Zinc from pumpkin seeds supports progesterone and implantation. Add folate-rich greens alongside seeds — folate is critical in the weeks before and after conception. Flax lignans in the first half help build a healthy estrogen pattern for ovulation quality."
        case .prenatal: "Continue seeds for gentle hormone support. Prioritize folate and iron-rich foods alongside — your baby's neural tube forms in the first weeks. Ground flaxseeds also support healthy digestion, which slows during pregnancy."
        case .postnatal: "Your body gave everything to grow your baby. Sesame seeds are rich in calcium for bone recovery, pumpkin seeds provide zinc for tissue repair, and flaxseeds support hormonal recalibration as your cycle returns. Eat seeds with warm meals for better absorption."
        case .perimenopause: "Flax lignans especially supportive during this transition."
        case .menopause: "Seeds provide gentle phytoestrogen support."
        }
    }

    // MARK: - Cell Detox

    private static func cellDetoxPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = cellDetoxGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return DailyNutritionPlan(
                todayFocus: "Gentle liver support during your natural detox phase. Your body is already releasing — support it softly. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Warm lemon water", "Beet and ginger smoothie"]),
                    supplements: items(.morning, .supplement, ["Milk thistle", "NAC"]),
                    rituals: items(.morning, .ritual, ["Start day with warm lemon water"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Beet greens salad", "Bone broth"]),
                    supplements: items(.afternoon, .supplement, ["Glutathione support"]),
                    rituals: items(.afternoon, .ritual, ["Rest and digest — eat slowly"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Dandelion and nettle tea", "Cooked warm vegetables"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Epsom salt bath"])
                ),
                avoid: ["Alcohol", "Processed foods", "Environmental toxins"],
                rationale: "During menstruation, your body is in a natural release state. Gentle liver support enhances this innate detox process."
            )

        case .follicular:
            return DailyNutritionPlan(
                todayFocus: "Activate phase — support estrogen metabolism with cruciferous vegetables and liver-loving foods. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Green smoothie with broccoli sprouts", "Cilantro"]),
                    supplements: items(.morning, .supplement, ["DIM — diindolylmethane", "B-complex"]),
                    rituals: items(.morning, .ritual, ["Green juice or smoothie ritual"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Kale and arugula salad", "Green tea"]),
                    supplements: items(.afternoon, .supplement, ["Calcium D-glucarate"]),
                    rituals: items(.afternoon, .ritual, ["Choose organic produce today"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Steamed cruciferous vegetables", "Light protein"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Dry brushing before shower"])
                ),
                avoid: ["Xenoestrogens from plastics", "Conventional produce — choose organic", "Excess caffeine"],
                rationale: "Rising estrogen needs healthy metabolism pathways. Cruciferous vegetables provide compounds like sulforaphane that support phase II liver detox."
            )

        case .ovulation:
            return DailyNutritionPlan(
                todayFocus: "Peak detox capacity — your liver is most efficient now. Support glutathione production. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Garlic and onion scramble", "Avocado"]),
                    supplements: items(.morning, .supplement, ["Glutathione", "Vitamin C"]),
                    rituals: items(.morning, .ritual, ["Hydrate well — start with 16oz water"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Asparagus and sulfur-rich vegetables", "Fresh herbs"]),
                    supplements: items(.afternoon, .supplement, ["Alpha-lipoic acid"]),
                    rituals: items(.afternoon, .ritual, ["Sweaty movement — your body can handle it"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Whole food dinner with variety", "Garlic and ginger"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Sauna or hot bath for detox support"])
                ),
                avoid: ["Alcohol", "Fried foods", "Artificial sweeteners"],
                rationale: "At ovulation, liver function peaks. Sulfur-rich foods boost glutathione — your body's master antioxidant and detoxifier."
            )

        case .luteal:
            return DailyNutritionPlan(
                todayFocus: "Maintain and support — keep detox pathways clear as progesterone rises and slows digestion. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Fiber-rich oatmeal", "Warm turmeric latte"]),
                    supplements: items(.morning, .supplement, ["Magnesium", "Milk thistle"]),
                    rituals: items(.morning, .ritual, ["Gentle morning movement"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Cooked greens", "Ginger tea"]),
                    supplements: items(.afternoon, .supplement, ["Digestive enzymes"]),
                    rituals: items(.afternoon, .ritual, ["Smaller, mindful meals"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Light early dinner", "Warm herbal tea"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["No eating 2-3 hours before bed"])
                ),
                avoid: ["Heavy meals", "Excess sugar", "Late-night eating"],
                rationale: "Progesterone slows gut motility. Fiber and gentle liver support help your body continue to clear metabolized hormones efficiently."
            )
        }
    }

    private static func cellDetoxGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "Gentle, sustainable detox supports cycle regularity."
        case .tryingToConceive: "Reducing your toxin load before conception gives your egg and future embryo the cleanest environment possible. Focus on liver-supporting foods and choose organic where you can — xenoestrogens from plastics and pesticides can disrupt implantation. Ideally begin 3 months before trying, as eggs mature over 90 days."
        case .prenatal: "Gentle food-based support only during pregnancy — your liver is already working harder. Emphasize cruciferous vegetables and fiber for natural estrogen clearance. Avoid supplement-based detox protocols and always consult your provider before adding new supplements."
        case .postnatal: "Your body accumulated extra load during pregnancy and birth. Gentle liver support through whole foods — beets, greens, lemon water, bone broth — helps your body clear stored hormones and metabolic byproducts as it recovers. Go slowly; nourishment first, cleansing second."
        case .perimenopause: "Efficient estrogen clearance is especially important now."
        case .menopause: "Support your liver as hormone ratios shift."
        }
    }

    // MARK: - DAO Support

    private static func daoSupportPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = daoSupportGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return DailyNutritionPlan(
                todayFocus: "Histamine levels peak during menstruation. Extra DAO support and low-histamine foods are key. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Eggs cooked to order", "Rice with pear"]),
                    supplements: items(.morning, .supplement, ["DAO enzyme before meals", "Vitamin C"]),
                    rituals: items(.morning, .ritual, ["Cook and eat fresh today — avoid leftovers"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Chicken or turkey", "Quinoa and vegetables"]),
                    supplements: items(.afternoon, .supplement, ["Quercetin"]),
                    rituals: items(.afternoon, .ritual, ["Eat slowly — rest and digest"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Rice and steamed vegetables", "Blueberries"]),
                    supplements: items(.evening, .supplement, ["DAO enzyme before dinner"]),
                    rituals: items(.evening, .ritual, ["Early, light dinner"])
                ),
                avoid: ["Aged cheeses", "Fermented foods", "Wine and beer", "Canned fish", "Leftovers"],
                rationale: "Estrogen stimulates histamine release, and histamine stimulates estrogen — a cycle that peaks during menstruation. DAO enzyme support helps break this cycle."
            )

        case .follicular:
            return DailyNutritionPlan(
                todayFocus: "Histamine calms as estrogen stabilizes. Gradually reintroduce some foods while maintaining DAO support. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Protein with sweet potato", "Apple slices"]),
                    supplements: items(.morning, .supplement, ["DAO enzyme", "Vitamin B6"]),
                    rituals: items(.morning, .ritual, ["Note any new food reactions"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Lean meats or fish", "Leafy greens"]),
                    supplements: items(.afternoon, .supplement, ["Copper"]),
                    rituals: items(.afternoon, .ritual, ["Test tolerance with small portions"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Vegetables and rice", "Watermelon or pear"]),
                    supplements: items(.evening, .supplement, ["DAO enzyme before dinner"]),
                    rituals: items(.evening, .ritual, ["Prepare meals same-day when possible"])
                ),
                avoid: ["Aged and fermented foods", "Citrus fruits", "Tomatoes", "Shellfish"],
                rationale: "As estrogen rises steadily, histamine levels become more predictable. Continue DAO support while gently testing your tolerance window."
            )

        case .ovulation:
            return DailyNutritionPlan(
                todayFocus: "Estrogen peaks — watch for histamine flare. Keep DAO support strong and meals simple. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Chicken or turkey", "Zucchini"]),
                    supplements: items(.morning, .supplement, ["DAO enzyme — consider increasing dose", "Quercetin"]),
                    rituals: items(.morning, .ritual, ["Keep meals simple and low-histamine"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Rice noodles", "Squash with herbs"]),
                    supplements: items(.afternoon, .supplement, ["Vitamin C"]),
                    rituals: items(.afternoon, .ritual, ["Avoid eating out — control ingredients"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Mango or pear", "Steamed vegetables"]),
                    supplements: items(.evening, .supplement, ["DAO enzyme before dinner"]),
                    rituals: items(.evening, .ritual, ["Calm evening — stress raises histamine"])
                ),
                avoid: ["All fermented foods", "Aged meats", "Alcohol", "Vinegar-based dressings"],
                rationale: "Peak estrogen triggers peak histamine release. Your DAO enzymes may be overwhelmed — supplemental support and strict low-histamine eating protect you."
            )

        case .luteal:
            return DailyNutritionPlan(
                todayFocus: "Progesterone rises and supports DAO production. A gentler window — but stay mindful as PMS approaches. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Root vegetables hash", "Protein of choice"]),
                    supplements: items(.morning, .supplement, ["DAO enzyme", "Magnesium"]),
                    rituals: items(.morning, .ritual, ["Regular meals to support blood sugar"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Ginger and turmeric tea", "Warm cooked lunch"]),
                    supplements: items(.afternoon, .supplement, ["Vitamin B6"]),
                    rituals: items(.afternoon, .ritual, ["Same-day preparation — avoid stored meals"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Pears and peaches", "Simple dinner"]),
                    supplements: items(.evening, .supplement, ["DAO enzyme before dinner"]),
                    rituals: items(.evening, .ritual, ["Wind down early — rest supports DAO"])
                ),
                avoid: ["Leftover foods", "Processed meats", "Soy products", "Chocolate — high histamine"],
                rationale: "Progesterone naturally supports DAO enzyme production, giving you a wider tolerance window. But as progesterone drops pre-menstrually, sensitivity returns."
            )
        }
    }

    private static func daoSupportGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "DAO support can significantly improve cycle comfort."
        case .tryingToConceive: "Histamine balance supports a healthy uterine environment for implantation. High histamine can trigger uterine contractions and inflammation that work against conception. Keep meals low-histamine around ovulation and the implantation window especially. Vitamin B6 and copper support natural DAO production."
        case .prenatal: "Pregnancy naturally increases DAO production — many women feel histamine relief. However, some experience new sensitivities. Continue low-histamine eating if it helps and consult your provider before continuing DAO enzyme supplements during pregnancy."
        case .postnatal: "Histamine sensitivity often shifts dramatically postpartum as estrogen drops and fluctuates. Breastfeeding can either improve or worsen it. Pay attention to how your baby responds to your diet — some infants are sensitive to histamine in breast milk. Reintroduce foods slowly and track reactions."
        case .perimenopause: "Fluctuating estrogen can worsen histamine intolerance."
        case .menopause: "As estrogen stabilizes, histamine issues often improve."
        }
    }

    // MARK: - Hair Health

    private static func hairHealthPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = hairHealthGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return DailyNutritionPlan(
                todayFocus: "Replenish iron and rebuild stores. Hair follicles and ovaries both need rich blood flow now. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Soft-cooked eggs", "Oatmeal with stewed berries"]),
                    supplements: items(.morning, .supplement, ["Iron + Vitamin C", "B-complex"]),
                    rituals: items(.morning, .ritual, ["3 min scalp massage with warm oil"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Slow-cooked beef or lentil stew", "Cooked leafy greens"]),
                    supplements: items(.afternoon, .supplement, ["Magnesium glycinate"]),
                    rituals: items(.afternoon, .ritual, ["Restorative walk after lunch"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Bone broth", "Sweet potato with tahini"]),
                    supplements: items(.evening, .supplement, ["Omega-3"]),
                    rituals: items(.evening, .ritual, ["Legs-up-the-wall for 5 min — pelvic circulation"])
                ),
                avoid: ["Calorie restriction", "High-intensity training", "Skipped meals"],
                rationale: "Menstruation depletes iron and ferritin — both critical for follicle and ovarian function. Gentle movement protects cortisol while warming foods restore the body."
            )

        case .follicular:
            return DailyNutritionPlan(
                todayFocus: "Estrogen rises and hair enters its growth phase. Build proteins, fats, and mitochondrial nutrients. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Greek yogurt with pumpkin seeds", "Berries and walnuts"]),
                    supplements: items(.morning, .supplement, ["CoQ10", "Biotin"]),
                    rituals: items(.morning, .ritual, ["Inversion stretch — head below heart for 1 min"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Wild salmon or sardines", "Avocado with leafy greens"]),
                    supplements: items(.afternoon, .supplement, ["Zinc", "Vitamin D"]),
                    rituals: items(.afternoon, .ritual, ["Strength training — your phase supports it"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Quinoa bowl with eggs", "Brazil nuts for selenium"]),
                    supplements: items(.evening, .supplement, ["Collagen peptides"]),
                    rituals: items(.evening, .ritual, ["5 min scalp massage with rosemary oil"])
                ),
                avoid: ["Crash diets", "Hair-tight styles all day", "Excess caffeine"],
                rationale: "Rising estrogen prolongs the hair growth phase. Mitochondrial nutrients like CoQ10 and B vitamins feed both hair follicles and ovaries during this build-up window."
            )

        case .ovulation:
            return DailyNutritionPlan(
                todayFocus: "Peak estrogen and circulation. Maximize antioxidants and protein for follicle and egg quality. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Eggs with spinach and tomato", "Citrus or kiwi"]),
                    supplements: items(.morning, .supplement, ["CoQ10", "Vitamin C + E"]),
                    rituals: items(.morning, .ritual, ["Hip mobility flow for 5 min"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Grass-fed beef or lentils", "Colorful raw veggies"]),
                    supplements: items(.afternoon, .supplement, ["Selenium"]),
                    rituals: items(.afternoon, .ritual, ["Peak workout — channel the energy"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Salmon with olive oil", "Roasted vegetables"]),
                    supplements: items(.evening, .supplement, ["Omega-3"]),
                    rituals: items(.evening, .ritual, ["Scalp and jaw release massage"])
                ),
                avoid: ["Inflammatory seed oils", "Late-night sugar", "Chronic stress spikes"],
                rationale: "Ovulation showcases the strongest blood flow of the cycle. Antioxidants protect mitochondria in both ovaries and hair follicles when oxygen demand peaks."
            )

        case .luteal:
            return DailyNutritionPlan(
                todayFocus: "Progesterone supports retention. Steady blood sugar protects cortisol — and cortisol protects hair. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["Eggs with sourdough and avocado", "Pumpkin seeds"]),
                    supplements: items(.morning, .supplement, ["Magnesium glycinate", "B6"]),
                    rituals: items(.morning, .ritual, ["Eat within 1 hour of waking"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["Chicken thigh or chickpeas", "Roasted root vegetables"]),
                    supplements: items(.afternoon, .supplement, ["Inositol", "Vitamin D"]),
                    rituals: items(.afternoon, .ritual, ["Walk after meals — steady insulin"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Sweet potato with salmon", "Dark leafy greens with olive oil"]),
                    supplements: items(.evening, .supplement, ["Omega-3", "Collagen"]),
                    rituals: items(.evening, .ritual, ["Slow scalp massage and early wind-down"])
                ),
                avoid: ["Skipped meals", "HIIT or heavy training", "Alcohol"],
                rationale: "Progesterone buffers androgens that shrink follicles. Sugar dips spike cortisol — which raises androgen sensitivity and accelerates shedding — so steady fuel is the protective strategy."
            )
        }
    }

    private static func hairHealthGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "Hair density and cycle regularity rise together — patience pays off."
        case .tryingToConceive: "The same nutrients that thicken hair also support egg quality and ovarian reserve. CoQ10 feeds mitochondria in both hair follicles and eggs. Iron and ferritin above 40 ng/mL support both hair growth and a healthy pregnancy. Invest in your hair now — it's investing in your fertility simultaneously."
        case .prenatal: "Pregnancy estrogen keeps hair in its growth phase — enjoy the fullness. Keep iron and protein generous to support both your baby and your hair reserves. The nutrients you bank now buffer against postpartum shedding later."
        case .postnatal: "Postpartum shedding typically peaks around 3-4 months after birth. This is estrogen withdrawal — not permanent loss. Your hair is releasing what pregnancy held in place. Focus on iron, protein, B vitamins, and zinc to speed the regrowth cycle. It can take 6-12 months to fully recover. Be patient with your body."
        case .perimenopause: "Estrogen dips first show up in hair. Mitochondrial support is especially important now."
        case .menopause: "Protein, healthy fats, and circulation become the core hair strategy."
        }
    }

    // MARK: - Gut Heal

    private static func gutHealPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = gutHealGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return DailyNutritionPlan(
                todayFocus: "Your gut lining is most sensitive now — prostaglandins affect the bowel alongside the uterus. Eat the simplest, warmest, most nourishing foods. Your digestive fire is low — honour it. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Rice porridge (congee) on water — the gentlest food for a healing gut",
                        "Stewed apple with cinnamon — pectin soothes the gut lining",
                        "Warm mung bean soup — Ayurveda's easiest-to-digest protein",
                        "Cooked pumpkin — gentle fibre, calming to inflamed tissue"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "L-glutamine on empty stomach — primary fuel for gut lining cells",
                        "Turmeric with black pepper — calms gut inflammation",
                        "Liposomal glutathione on empty stomach — master antioxidant, repairs mucosal tissue"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon on waking — gentle digestive fire starter",
                        "Warm compress on belly — relaxes the gut and uterus together",
                        "5 min belly breathing — activates parasympathetic, gut heals only in rest state",
                        "Keep feet warm — cold feet constrict blood flow to the abdomen"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Simple kitchari — rice, mung dal, ghee, gentle spices — Ayurveda's healing meal",
                        "Warm lentil soup — easy protein, soothing texture",
                        "Cooked zucchini with ghee — one of the least irritating vegetables",
                        "Warm bone or vegetable broth — minerals and collagen for gut repair"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat one food at a time when possible — simplifies digestion",
                        "Rest 10 min after eating — blood stays in the gut for absorption",
                        "Sip warm ginger tea between meals — stokes digestive fire without food"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Warm vegetable stew — soft-cooked root vegetables with mild spices",
                        "Rice and dal — simple, complete, easy to digest",
                        "Cooked beetroot soup — rebuilds blood while healing the gut",
                        "Stewed pears — gentle sweetness, soothing pectin"
                    ]),
                    supplements: items(.evening, .supplement, [
                        "Glutathione suppository at bedtime — deep tissue repair overnight"
                    ]),
                    rituals: items(.evening, .ritual, [
                        "Castor oil on belly button — traditional Ayurvedic gut healing ritual",
                        "Warm castor oil compress on abdomen — draws inflammation, promotes repair",
                        "Legs-up-the-wall for 5 min — calms the nervous system, aids digestion",
                        "No eating 3 hours before bed — gut repairs best during fasting sleep"
                    ])
                ),
                avoid: [
                    "Raw vegetables — too taxing for a healing gut during menstruation",
                    "Cold drinks and iced water — extinguish digestive fire",
                    "Cold yogurt — fermentation can irritate inflamed gut lining",
                    "Mixing many foods together — simplify to reduce digestive burden",
                    "Caffeine — irritates the gut lining and increases motility",
                    "Stress and rushing meals — the gut cannot heal in a stressed state"
                ],
                rationale: "During menstruation your gut is especially reactive — the same prostaglandins that cause cramps also stimulate the bowel. Ayurveda calls this the lowest point of Agni (digestive fire). TCM says the Spleen Qi is weakest now. The simplest, warmest foods give your gut the best chance to repair."
            )

        case .follicular:
            return DailyNutritionPlan(
                todayFocus: "Digestive fire rebuilds as estrogen rises. Gently expand variety but keep everything cooked and warm. Your gut lining is regenerating — feed the repair. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Warm rice porridge with stewed fruit — gentle start, nourishing",
                        "Kitchari with seasonal vegetables — Ayurveda's restoration meal",
                        "Soft-cooked eggs — easy protein if tolerated, rich in choline",
                        "Cooked oats with ghee and cinnamon — warm, soothing, steady energy"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "L-glutamine on empty stomach — continues gut lining repair",
                        "Turmeric with black pepper — anti-inflammatory support",
                        "Liposomal glutathione on empty stomach — antioxidant protection for new tissue"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon and ginger — awakens Agni as it rebuilds",
                        "10 min morning walk — gentle movement stimulates peristalsis naturally",
                        "Abhyanga (warm oil self-massage) — calms Vata, improves gut motility",
                        "Keep feet warm throughout the day"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Mung bean and vegetable stew — protein + fibre without irritation",
                        "Rice with cooked greens and ghee — simple combinations, easy to process",
                        "Warm lentil and carrot soup — folate, iron, and gentle fibre",
                        "Steamed sweet potato with tahini — soothing, mineral-rich"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat your largest meal at midday — Agni is strongest between 12-2pm",
                        "Cumin-coriander-fennel tea after lunch — Ayurveda's classic digestive trio",
                        "Chew thoroughly — digestion begins in the mouth"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Light vegetable soup — keep evening meals smaller than midday",
                        "Rice and beans — complete protein, gentle, warming",
                        "Cooked fennel — reduces gas and bloating naturally",
                        "Warm stewed apple or pear — dessert that heals"
                    ]),
                    supplements: items(.evening, .supplement, [
                        "Glutathione suppository at bedtime — overnight repair continues"
                    ]),
                    rituals: items(.evening, .ritual, [
                        "Castor oil in belly button — nourishes the gut overnight",
                        "Warm compress on abdomen — 15 min before bed",
                        "Meditation or body scan — healing occurs in a peaceful body and mind",
                        "Early dinner — aim to finish eating by 7pm"
                    ])
                ),
                avoid: [
                    "Raw vegetables — continue cooking everything during healing",
                    "Cold drinks and cold foods — protect rebuilding digestive fire",
                    "Complex food combinations — eat one or two foods at a time",
                    "Cold yogurt — if craving dairy, use warm spiced milk or lassi instead",
                    "Processed or fried foods — inflame healing tissue"
                ],
                rationale: "As estrogen rises, your gut lining regenerates faster — estrogen supports mucosal repair. Ayurveda says Agni slowly rebuilds in this phase. TCM says Spleen Qi strengthens. Support this upswing with warm, simple foods that don't challenge the healing process."
            )

        case .ovulation:
            return DailyNutritionPlan(
                todayFocus: "Digestive fire is at its strongest. Your gut can handle slightly more variety now — but maintain warmth and simplicity. This is the window where repair accelerates. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Warm porridge with seeds — digestive fire can handle seeds now",
                        "Kitchari with more vegetables — expand variety gently",
                        "Warm grain bowl with soft-cooked vegetables — nourishing and diverse",
                        "Stewed seasonal fruit — if craving fruit, eat warm and alone"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "L-glutamine on empty stomach — maintain gut lining support",
                        "Turmeric with black pepper — ongoing anti-inflammatory",
                        "Liposomal glutathione on empty stomach — protects new gut tissue"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with lemon, ginger, and pinch of turmeric — peak digestive support",
                        "Your strongest exercise window — movement improves gut motility",
                        "Pranayama (breath of fire gently) — stimulates Agni at its peak",
                        "Sunlight exposure — vitamin D supports gut immune function"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Larger kitchari with seasonal vegetables — your biggest meal of the day",
                        "Warm chickpea and vegetable curry — more complex proteins tolerated now",
                        "Cooked grain and lentil bowl — fibre supports healthy transit",
                        "Warm vegetable and bean stew — hearty, healing, hormone-supporting"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Eat mindfully — chew 20-30 times per bite",
                        "Digestive walk after lunch — 10-15 minutes",
                        "If craving raw fruit, eat it alone as afternoon snack — separate from meals"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Light dal soup — warm, protein-rich, easy",
                        "Rice with cooked vegetables and ghee — simple and satisfying",
                        "Warm golden milk — turmeric, cinnamon, cardamom in warm milk or plant milk",
                        "Cooked asparagus — prebiotic fibre feeds beneficial gut bacteria"
                    ]),
                    supplements: items(.evening, .supplement, [
                        "Glutathione suppository at bedtime — deep overnight repair"
                    ]),
                    rituals: items(.evening, .ritual, [
                        "Castor oil compress on abdomen — 20 min with warm towel",
                        "Evening breathwork — alternate nostril breathing calms the gut-brain axis",
                        "Journaling or quiet reflection — emotional digestion supports physical digestion"
                    ])
                ),
                avoid: [
                    "Raw salads — even at peak digestion, cooked is safer during healing",
                    "Cold smoothies — blend warm instead if craving smoothies",
                    "Alcohol — directly damages gut lining",
                    "Spicy chilli — gentle spices yes, aggressive heat no",
                    "Rushed meals — your gut reads stress as danger"
                ],
                rationale: "Ovulation is when Agni (digestive fire) peaks — Ayurveda says this is your strongest digestive window. TCM agrees: Yang energy is at its height. Use this strength to nourish deeply, but don't overload. The gut is healing, not healed — respect the process even when you feel strong."
            )

        case .luteal:
            return DailyNutritionPlan(
                todayFocus: "Progesterone slows gut motility. Return to the simplest, warmest foods. Bloating and sluggish digestion are normal — work with your body, not against it. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, [
                        "Warm rice porridge — the most soothing food as digestion slows",
                        "Stewed apple with ghee and cardamom — gentle, warming, anti-bloat",
                        "Simple mung dal — Ayurveda's lightest protein",
                        "Cooked oats with warming spices — cinnamon, ginger, cardamom"
                    ]),
                    supplements: items(.morning, .supplement, [
                        "L-glutamine on empty stomach — gut lining support especially important as motility slows",
                        "Turmeric with black pepper — progesterone increases inflammation sensitivity",
                        "Liposomal glutathione on empty stomach — antioxidant support for hormonal clearing"
                    ]),
                    rituals: items(.morning, .ritual, [
                        "Warm water with honey and ginger — nourishes blood, wakes digestion gently",
                        "Eat within 1 hour of waking — blood sugar stability protects both gut and hormones",
                        "Gentle yoga or walking only — intense exercise diverts blood away from healing gut",
                        "Keep feet and belly warm — cold aggravates both Vata and sluggish digestion"
                    ])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, [
                        "Kitchari — return to the simplest version as digestion slows",
                        "Warm pumpkin soup — magnesium and fibre ease bloating",
                        "Rice with well-cooked dal — simple combination, easy transit",
                        "Cooked root vegetable stew — grounding, satisfying, blood sugar stable"
                    ]),
                    supplements: items(.afternoon, .supplement, []),
                    rituals: items(.afternoon, .ritual, [
                        "Fennel tea after meals — the best natural anti-bloating remedy",
                        "Eat every 3-4 hours — small regular meals prevent gas buildup",
                        "Walk after eating — the single most effective thing for luteal bloating"
                    ])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, [
                        "Light warm soup — the lightest meal of the day",
                        "Steamed vegetables with rice — minimal combinations",
                        "Warm spiced milk or golden milk — calms both gut and nervous system",
                        "Cooked beetroot — supports liver clearing hormones, gentle on the gut"
                    ]),
                    supplements: items(.evening, .supplement, [
                        "Glutathione suppository at bedtime — overnight repair and detox support"
                    ]),
                    rituals: items(.evening, .ritual, [
                        "Castor oil compress on abdomen — especially helpful for luteal bloating",
                        "Warm bath with ginger or Epsom salts — relaxes the gut wall",
                        "Body scan meditation — release tension held in the belly",
                        "No eating 3 hours before bed — sluggish digestion needs extra time",
                        "Early, quiet evening — healing occurs in a peaceful body and mind"
                    ])
                ),
                avoid: [
                    "Raw vegetables and salads — progesterone slows digestion, raw foods sit and ferment",
                    "Cold drinks, ice, cold yogurt — extinguish weakening digestive fire",
                    "Complex food combinations — one or two foods per sitting",
                    "Large meals — smaller portions, more often",
                    "Stress, rushing, eating while distracted — the gut-brain axis is most sensitive now",
                    "Raw fruit unless eaten alone and with strong desire — ferments in a slow gut"
                ],
                rationale: "Progesterone slows gut motility by 30-40%. Ayurveda says Vata rises in the luteal phase, creating gas, bloating, and irregular digestion. TCM says the Spleen weakens again. Returning to the simplest, warmest foods — congee, kitchari, stews — gives your healing gut the gentlest possible environment as your body prepares for the next cycle."
            )
        }
    }

    private static func gutHealGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "A healthy gut is the foundation of hormone balance — estrogen, progesterone, and serotonin all depend on gut function."
        case .tryingToConceive: "Gut health directly affects nutrient absorption, inflammation levels, and the estrobolome — the gut bacteria that regulate estrogen for fertility. Heal the gut first, and hormonal balance often follows."
        case .prenatal: "Gentle gut support during pregnancy is important — avoid strong detox protocols. Focus on warm, cooked foods and consult your provider about supplements. Your baby's microbiome begins forming from yours."
        case .postnatal: "Your gut microbiome shifts dramatically after birth. Warm, simple foods rebuild both your gut lining and your energy. If breastfeeding, your gut health directly shapes your baby's immune development through breast milk."
        case .perimenopause: "As hormones fluctuate, gut symptoms often worsen. The estrobolome — gut bacteria that process estrogen — becomes especially important now. Healing the gut helps stabilise the hormonal transition."
        case .menopause: "Gut health remains central to wellbeing after menopause. Nutrient absorption, immune function, and mood all depend on a healthy gut lining."
        }
    }

    // MARK: - Helpers

    private static func items(_ time: TimeOfDay, _ category: NutritionItemCategory, _ names: [String]) -> [NutritionItem] {
        names.map { NutritionItem(name: $0, category: category, timeBlock: time) }
    }
}
