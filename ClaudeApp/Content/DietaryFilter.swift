import Foundation

/// Filters and adapts food items based on dietary preference.
/// Non-compliant foods are replaced with nutritionally equivalent alternatives.
enum DietaryFilter {

    static func apply(_ plan: DailyNutritionPlan, preference: DietaryPreference) -> DailyNutritionPlan {
        guard preference != .omnivore else { return plan }

        return DailyNutritionPlan(
            todayFocus: plan.todayFocus,
            morning: filterTimeBlock(plan.morning, preference: preference),
            afternoon: filterTimeBlock(plan.afternoon, preference: preference),
            evening: filterTimeBlock(plan.evening, preference: preference),
            avoid: plan.avoid,
            rationale: plan.rationale
        )
    }

    private static func filterTimeBlock(_ block: TimeBlock, preference: DietaryPreference) -> TimeBlock {
        TimeBlock(
            timeOfDay: block.timeOfDay,
            foods: block.foods.compactMap { filterItem($0, preference: preference) },
            supplements: block.supplements,
            rituals: block.rituals
        )
    }

    private static func filterItem(_ item: NutritionItem, preference: DietaryPreference) -> NutritionItem? {
        guard item.category == .food else { return item }

        let name = item.name.lowercased()

        switch preference {
        case .omnivore:
            return item

        case .pescatarian:
            // Remove meat/poultry, keep fish
            if containsMeat(name) {
                return replacement(for: item, preference: preference)
            }
            return item

        case .vegetarian:
            // Remove meat/poultry/fish, keep dairy and eggs
            if containsMeat(name) || containsFish(name) {
                return replacement(for: item, preference: preference)
            }
            return item

        case .vegan:
            // Remove all animal products
            if containsMeat(name) || containsFish(name) || containsDairy(name) || containsEggs(name) || containsAnimal(name) {
                return replacement(for: item, preference: preference)
            }
            return item
        }
    }

    // MARK: - Detection

    private static func containsMeat(_ name: String) -> Bool {
        let meats = ["beef", "chicken", "turkey", "lamb", "pork", "meat", "steak",
                     "grass-fed beef", "slow-cooked beef", "chicken thigh"]
        return meats.contains { name.contains($0) }
    }

    private static func containsFish(_ name: String) -> Bool {
        let fish = ["salmon", "sardine", "fish", "tuna", "mackerel", "cod",
                    "anchov", "seafood", "shrimp", "prawn"]
        return fish.contains { name.contains($0) }
    }

    private static func containsDairy(_ name: String) -> Bool {
        let dairy = ["yogurt", "yoghurt", "milk", "cheese", "ghee", "butter",
                     "cream", "kefir", "whey", "lassi"]
        return dairy.contains { name.contains($0) }
    }

    private static func containsEggs(_ name: String) -> Bool {
        let eggs = ["egg"]
        return eggs.contains { name.contains($0) }
    }

    private static func containsAnimal(_ name: String) -> Bool {
        let animal = ["bone broth", "collagen", "gelatin", "honey"]
        return animal.contains { name.contains($0) }
    }

    // MARK: - Replacements

    private static func replacement(for item: NutritionItem, preference: DietaryPreference) -> NutritionItem {
        let name = item.name.lowercased()

        // Find the explanation part after the dash
        let explanation = item.name.contains(" — ")
            ? " — " + item.name.components(separatedBy: " — ").dropFirst().joined(separator: " — ")
            : ""

        let replacementName: String

        // Meat replacements
        if containsMeat(name) {
            switch preference {
            case .pescatarian:
                if name.contains("iron") || name.contains("b12") {
                    replacementName = "Wild salmon" + explanation
                } else {
                    replacementName = "Grilled fish" + explanation
                }
            case .vegetarian:
                if name.contains("iron") || name.contains("b12") {
                    replacementName = "Lentils with nutritional yeast" + explanation
                } else if name.contains("tryptophan") || name.contains("serotonin") {
                    replacementName = "Tofu with pumpkin seeds — tryptophan for serotonin"
                } else if name.contains("protein") {
                    replacementName = "Tempeh or paneer" + explanation
                } else {
                    replacementName = "Lentils or chickpeas" + explanation
                }
            case .vegan:
                if name.contains("iron") || name.contains("b12") {
                    replacementName = "Lentils with nutritional yeast — iron + B12"
                } else if name.contains("tryptophan") || name.contains("serotonin") {
                    replacementName = "Tofu with pumpkin seeds — tryptophan for serotonin"
                } else if name.contains("protein") {
                    replacementName = "Tempeh or marinated tofu" + explanation
                } else {
                    replacementName = "Lentils, chickpeas, or tempeh" + explanation
                }
            case .omnivore:
                replacementName = item.name
            }
        }
        // Fish replacements
        else if containsFish(name) {
            if name.contains("omega") || name.contains("dha") {
                replacementName = preference == .vegan
                    ? "Walnuts + algae oil — plant-based omega-3 DHA"
                    : "Walnuts and chia seeds — omega-3 ALA"
            } else if name.contains("calcium") {
                replacementName = preference == .vegan
                    ? "White beans with tahini — calcium + protein"
                    : "Tahini with steamed greens — calcium"
            } else {
                replacementName = preference == .vegan
                    ? "Hemp seeds and tempeh" + explanation
                    : "Paneer or tempeh" + explanation
            }
        }
        // Dairy replacements
        else if containsDairy(name) {
            if name.contains("yogurt") || name.contains("yoghurt") || name.contains("kefir") {
                replacementName = "Coconut yogurt with probiotics" + explanation
            } else if name.contains("milk") || name.contains("golden milk") || name.contains("turmeric milk") {
                replacementName = item.name.replacingOccurrences(of: "milk", with: "oat milk")
            } else if name.contains("ghee") {
                replacementName = item.name.replacingOccurrences(of: "ghee", with: "coconut oil")
            } else if name.contains("cheese") || name.contains("paneer") {
                replacementName = "Nutritional yeast or cashew cream" + explanation
            } else {
                replacementName = item.name + " (use plant-based alternative)"
            }
        }
        // Egg replacements
        else if containsEggs(name) {
            if name.contains("choline") {
                replacementName = "Edamame and sunflower seeds — choline from plant sources"
            } else {
                replacementName = "Tofu scramble with nutritional yeast" + explanation
            }
        }
        // Other animal products
        else if containsAnimal(name) {
            if name.contains("bone broth") {
                replacementName = "Mushroom and seaweed broth — minerals and umami"
            } else if name.contains("collagen") {
                replacementName = "Vitamin C + silica-rich foods — support collagen synthesis"
            } else if name.contains("honey") {
                replacementName = item.name.replacingOccurrences(of: "honey", with: "maple syrup")
            } else {
                replacementName = item.name
            }
        }
        else {
            replacementName = item.name
        }

        return NutritionItem(
            name: replacementName,
            category: item.category,
            timeBlock: item.timeBlock,
            origin: item.origin
        )
    }
}
