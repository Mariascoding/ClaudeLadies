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

// MARK: - Nutrition Item

struct NutritionItem: Identifiable {
    let name: String
    let category: NutritionItemCategory
    let timeBlock: TimeOfDay

    var id: String {
        "\(timeBlock.rawValue).\(category.rawValue).\(name)"
    }
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
        }
    }

    // MARK: - Seed Cycling

    private static func seedCyclingPlan(phase: CyclePhase, goal: WellnessGoal) -> DailyNutritionPlan {
        let goalNote = seedCyclingGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return DailyNutritionPlan(
                todayFocus: "Gentle nourishment with flax and pumpkin seeds to support estrogen during your inner winter. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["1 tbsp ground flaxseeds", "Warm oatmeal with cinnamon"]),
                    supplements: items(.morning, .supplement, ["Omega-3", "Vitamin D"]),
                    rituals: items(.morning, .ritual, ["Warm lemon water on waking"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["1 tbsp pumpkin seeds", "Iron-rich leafy greens salad"]),
                    supplements: items(.afternoon, .supplement, ["Iron if needed"]),
                    rituals: items(.afternoon, .ritual, ["Gentle walk after lunch"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Warm soup or stew", "Cooked root vegetables"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Herbal tea before bed"])
                ),
                avoid: ["Raw cold foods", "Excess caffeine", "Refined sugar"],
                rationale: "Flax and pumpkin seeds contain lignans and zinc that gently support estrogen production during menstruation."
            )

        case .follicular:
            return DailyNutritionPlan(
                todayFocus: "Continue flax and pumpkin seeds as estrogen rises in your inner spring. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["1 tbsp ground flaxseeds", "Fresh berries and yogurt"]),
                    supplements: items(.morning, .supplement, ["B-complex", "Vitamin E"]),
                    rituals: items(.morning, .ritual, ["Morning smoothie ritual"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["1 tbsp pumpkin seeds", "Cruciferous vegetables"]),
                    supplements: items(.afternoon, .supplement, ["Probiotic"]),
                    rituals: items(.afternoon, .ritual, ["Fermented food with lunch"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Light grain bowl", "Fresh seasonal vegetables"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Prepare tomorrow's seeds"])
                ),
                avoid: ["Excess dairy", "Processed foods", "Alcohol"],
                rationale: "As estrogen builds, flax lignans help maintain healthy estrogen metabolism while pumpkin seeds provide zinc for progesterone preparation."
            )

        case .ovulation:
            return DailyNutritionPlan(
                todayFocus: "Transition to sesame and sunflower seeds to support the progesterone shift. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["1 tbsp sesame seeds", "Antioxidant-rich berries"]),
                    supplements: items(.morning, .supplement, ["Vitamin C", "Zinc"]),
                    rituals: items(.morning, .ritual, ["Energizing breakfast within 1 hour of waking"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["1 tbsp sunflower seeds", "Fiber-rich vegetables"]),
                    supplements: items(.afternoon, .supplement, ["Evening primrose oil"]),
                    rituals: items(.afternoon, .ritual, ["Balanced protein-rich lunch"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Light dinner with tahini dressing", "Fresh salad"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Gentle evening stretch"])
                ),
                avoid: ["Inflammatory oils", "Excess sugar", "Heavy meals"],
                rationale: "Sesame seeds contain lignans that modulate estrogen, while sunflower seeds are rich in selenium to support progesterone production."
            )

        case .luteal:
            return DailyNutritionPlan(
                todayFocus: "Sesame and sunflower seeds to sustain progesterone through your inner autumn. \(goalNote)",
                morning: TimeBlock(
                    timeOfDay: .morning,
                    foods: items(.morning, .food, ["1 tbsp sesame seeds", "Complex carb breakfast"]),
                    supplements: items(.morning, .supplement, ["Magnesium glycinate", "Vitamin B6"]),
                    rituals: items(.morning, .ritual, ["Eat within an hour of waking"])
                ),
                afternoon: TimeBlock(
                    timeOfDay: .afternoon,
                    foods: items(.afternoon, .food, ["1 tbsp sunflower seeds", "Magnesium-rich dark chocolate"]),
                    supplements: items(.afternoon, .supplement, ["Calcium"]),
                    rituals: items(.afternoon, .ritual, ["Steady blood sugar — don't skip meals"])
                ),
                evening: TimeBlock(
                    timeOfDay: .evening,
                    foods: items(.evening, .food, ["Warm comforting dinner", "Sweet potato or squash"]),
                    supplements: items(.evening, .supplement, []),
                    rituals: items(.evening, .ritual, ["Calming herbal tea"])
                ),
                avoid: ["Excess salt", "Caffeine", "Alcohol"],
                rationale: "Sunflower seeds provide selenium and vitamin E to support progesterone, while sesame seeds offer zinc and healthy fats for hormonal balance."
            )
        }
    }

    private static func seedCyclingGoalNote(goal: WellnessGoal) -> String {
        switch goal {
        case .healthyCycle: "Focus on consistency for cycle balance."
        case .tryingToConceive: "Extra focus on zinc and folate-rich foods."
        case .prenatal: "Ensure adequate folate and iron alongside seeds."
        case .postnatal: "Prioritize nutrient density for recovery."
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
        case .tryingToConceive: "Focus on reducing toxin load before conception."
        case .prenatal: "Very gentle support only — consult your provider."
        case .postnatal: "Support your body's recovery with nourishing detox foods."
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
        case .tryingToConceive: "Histamine balance supports a healthy uterine environment."
        case .prenatal: "Consult your provider about DAO supplementation during pregnancy."
        case .postnatal: "Histamine sensitivity often shifts postpartum — listen to your body."
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
        case .tryingToConceive: "The same nutrients that thicken hair also support egg quality and ovarian reserve."
        case .prenatal: "Estrogen is high — hair feels its best now. Keep iron and protein generous."
        case .postnatal: "Postpartum shedding is normal — focus on iron, protein, and rest to rebuild."
        case .perimenopause: "Estrogen dips first show up in hair. Mitochondrial support is especially important now."
        case .menopause: "Protein, healthy fats, and circulation become the core hair strategy."
        }
    }

    // MARK: - Helpers

    private static func items(_ time: TimeOfDay, _ category: NutritionItemCategory, _ names: [String]) -> [NutritionItem] {
        names.map { NutritionItem(name: $0, category: category, timeBlock: time) }
    }
}
