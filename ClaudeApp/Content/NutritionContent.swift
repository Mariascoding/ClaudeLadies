import Foundation

struct NutritionGuidance {
    let todayFocus: String
    let foods: [String]
    let supplements: [String]
    let avoid: [String]
    let mealTiming: String
    let rationale: String
}

enum NutritionContent {
    static func guidance(
        for nutritionProtocol: NutritionProtocol,
        phase: CyclePhase,
        goal: WellnessGoal
    ) -> NutritionGuidance {
        switch nutritionProtocol {
        case .seedCycling:
            seedCyclingGuidance(phase: phase, goal: goal)
        case .cellDetox:
            cellDetoxGuidance(phase: phase, goal: goal)
        case .daoSt:
            daoSupportGuidance(phase: phase, goal: goal)
        }
    }

    // MARK: - Seed Cycling

    private static func seedCyclingGuidance(phase: CyclePhase, goal: WellnessGoal) -> NutritionGuidance {
        let goalNote = seedCyclingGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return NutritionGuidance(
                todayFocus: "Gentle nourishment with flax and pumpkin seeds to support estrogen during your inner winter.",
                foods: ["Ground flaxseeds (1 tbsp)", "Pumpkin seeds (1 tbsp)", "Warm soups and stews", "Iron-rich leafy greens"],
                supplements: ["Omega-3", "Iron (if needed)", "Vitamin D"],
                avoid: ["Raw cold foods", "Excess caffeine", "Refined sugar"],
                mealTiming: "Warm, cooked meals. Eat within an hour of waking. \(goalNote)",
                rationale: "Flax and pumpkin seeds contain lignans and zinc that gently support estrogen production during menstruation."
            )
        case .follicular:
            return NutritionGuidance(
                todayFocus: "Continue flax and pumpkin seeds as estrogen rises in your inner spring.",
                foods: ["Ground flaxseeds (1 tbsp)", "Pumpkin seeds (1 tbsp)", "Fermented foods", "Cruciferous vegetables"],
                supplements: ["Probiotic", "B-complex", "Vitamin E"],
                avoid: ["Excess dairy", "Processed foods", "Alcohol"],
                mealTiming: "Light, fresh meals with plenty of variety. \(goalNote)",
                rationale: "As estrogen builds, flax lignans help maintain healthy estrogen metabolism while pumpkin seeds provide zinc for progesterone preparation."
            )
        case .ovulation:
            return NutritionGuidance(
                todayFocus: "Transition to sesame and sunflower seeds to support the progesterone shift.",
                foods: ["Sesame seeds (1 tbsp)", "Sunflower seeds (1 tbsp)", "Fiber-rich vegetables", "Antioxidant-rich berries"],
                supplements: ["Vitamin C", "Zinc", "Evening primrose oil"],
                avoid: ["Inflammatory oils", "Excess sugar", "Heavy meals"],
                mealTiming: "Balanced meals with good protein. Your energy is high. \(goalNote)",
                rationale: "Sesame seeds contain lignans that modulate estrogen, while sunflower seeds are rich in selenium to support progesterone production."
            )
        case .luteal:
            return NutritionGuidance(
                todayFocus: "Sesame and sunflower seeds to sustain progesterone through your inner autumn.",
                foods: ["Sesame seeds (1 tbsp)", "Sunflower seeds (1 tbsp)", "Complex carbohydrates", "Magnesium-rich dark chocolate"],
                supplements: ["Magnesium glycinate", "Vitamin B6", "Calcium"],
                avoid: ["Excess salt", "Caffeine", "Alcohol"],
                mealTiming: "Regular meals to stabilize blood sugar. Don't skip meals. \(goalNote)",
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

    private static func cellDetoxGuidance(phase: CyclePhase, goal: WellnessGoal) -> NutritionGuidance {
        let goalNote = cellDetoxGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return NutritionGuidance(
                todayFocus: "Gentle liver support during your natural detox phase. Your body is already releasing — support it softly.",
                foods: ["Warm lemon water", "Beets and beet greens", "Bone broth", "Gentle herbs (dandelion, nettle)"],
                supplements: ["Milk thistle", "NAC", "Glutathione support"],
                avoid: ["Alcohol", "Processed foods", "Environmental toxins"],
                mealTiming: "Start with warm lemon water. Eat gentle, cooked foods. \(goalNote)",
                rationale: "During menstruation, your body is in a natural release state. Gentle liver support enhances this innate detox process."
            )
        case .follicular:
            return NutritionGuidance(
                todayFocus: "Activate phase — support estrogen metabolism with cruciferous vegetables and liver-loving foods.",
                foods: ["Broccoli sprouts", "Kale and arugula", "Cilantro", "Green tea"],
                supplements: ["DIM (diindolylmethane)", "Calcium D-glucarate", "B-complex"],
                avoid: ["Xenoestrogens (plastics)", "Conventional produce (choose organic)", "Excess caffeine"],
                mealTiming: "Fresh, raw foods are well-tolerated now. Green smoothies are great. \(goalNote)",
                rationale: "Rising estrogen needs healthy metabolism pathways. Cruciferous vegetables provide compounds like sulforaphane that support phase II liver detox."
            )
        case .ovulation:
            return NutritionGuidance(
                todayFocus: "Peak detox capacity — your liver is most efficient now. Support glutathione production.",
                foods: ["Garlic and onions", "Asparagus", "Avocado", "Sulfur-rich vegetables"],
                supplements: ["Glutathione", "Vitamin C", "Alpha-lipoic acid"],
                avoid: ["Alcohol", "Fried foods", "Artificial sweeteners"],
                mealTiming: "Your digestion is strong. Enjoy a variety of whole foods. \(goalNote)",
                rationale: "At ovulation, liver function peaks. Sulfur-rich foods boost glutathione — your body's master antioxidant and detoxifier."
            )
        case .luteal:
            return NutritionGuidance(
                todayFocus: "Maintain and support — keep detox pathways clear as progesterone rises and slows digestion.",
                foods: ["Fiber-rich foods", "Cooked greens", "Turmeric and ginger", "Warm herbal teas"],
                supplements: ["Magnesium", "Milk thistle", "Digestive enzymes"],
                avoid: ["Heavy meals", "Excess sugar", "Late-night eating"],
                mealTiming: "Smaller, more frequent meals. Digestion slows — be gentle with yourself. \(goalNote)",
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

    private static func daoSupportGuidance(phase: CyclePhase, goal: WellnessGoal) -> NutritionGuidance {
        let goalNote = daoSupportGoalNote(goal: goal)

        switch phase {
        case .menstrual:
            return NutritionGuidance(
                todayFocus: "Histamine levels peak during menstruation. Extra DAO support and low-histamine foods are key.",
                foods: ["Fresh (not leftover) proteins", "Rice and quinoa", "Fresh vegetables", "Pears and blueberries"],
                supplements: ["DAO enzyme (before meals)", "Vitamin C", "Quercetin"],
                avoid: ["Aged cheeses", "Fermented foods", "Wine and beer", "Canned fish", "Leftovers"],
                mealTiming: "Eat freshly prepared meals. Cook and eat — avoid storing. \(goalNote)",
                rationale: "Estrogen stimulates histamine release, and histamine stimulates estrogen — a cycle that peaks during menstruation. DAO enzyme support helps break this cycle."
            )
        case .follicular:
            return NutritionGuidance(
                todayFocus: "Histamine calms as estrogen stabilizes. Gradually reintroduce some foods while maintaining DAO support.",
                foods: ["Fresh meats and fish", "Sweet potatoes", "Leafy greens", "Apples and watermelon"],
                supplements: ["DAO enzyme", "Vitamin B6", "Copper"],
                avoid: ["Aged and fermented foods", "Citrus fruits", "Tomatoes", "Shellfish"],
                mealTiming: "You may tolerate slightly more variety now. Still prioritize freshness. \(goalNote)",
                rationale: "As estrogen rises steadily, histamine levels become more predictable. Continue DAO support while gently testing your tolerance window."
            )
        case .ovulation:
            return NutritionGuidance(
                todayFocus: "Estrogen peaks — watch for histamine flare. Keep DAO support strong and meals simple.",
                foods: ["Fresh chicken and turkey", "Zucchini and squash", "Rice noodles", "Mango and pear"],
                supplements: ["DAO enzyme (increase dose)", "Quercetin", "Vitamin C"],
                avoid: ["All fermented foods", "Aged meats", "Alcohol", "Vinegar-based dressings"],
                mealTiming: "Simple, fresh meals. This is a high-sensitivity window. \(goalNote)",
                rationale: "Peak estrogen triggers peak histamine release. Your DAO enzymes may be overwhelmed — supplemental support and strict low-histamine eating protect you."
            )
        case .luteal:
            return NutritionGuidance(
                todayFocus: "Progesterone rises and supports DAO production. A gentler window — but stay mindful as PMS approaches.",
                foods: ["Root vegetables", "Fresh proteins", "Ginger and turmeric", "Pears and peaches"],
                supplements: ["DAO enzyme", "Magnesium", "Vitamin B6"],
                avoid: ["Leftover foods", "Processed meats", "Soy products", "Chocolate (high histamine)"],
                mealTiming: "Regular meals to support blood sugar. Fresh preparation remains important. \(goalNote)",
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
}
