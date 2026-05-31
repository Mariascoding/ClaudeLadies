import Foundation

enum PregnancyNutritionContent {

    static func dailyPlan(trimester: PregnancyTrimester, week: Int) -> DailyNutritionPlan {
        switch trimester {
        case .first:  firstTrimesterPlan(week: week)
        case .second: secondTrimesterPlan(week: week)
        case .third:  thirdTrimesterPlan(week: week)
        }
    }

    // MARK: - First Trimester (Weeks 1-12)

    private static func firstTrimesterPlan(week: Int) -> DailyNutritionPlan {
        let weekNote = week <= 8
            ? "Weeks 3-8 are the most critical for organ formation. Every nutrient counts now — especially folate for the neural tube and iron for the rapidly expanding blood supply."
            : "The risk of miscarriage drops significantly after week 12. Major organs are in place. Continue nourishing deeply — the placenta is still maturing."

        return DailyNutritionPlan(
            todayFocus: "Week \(week) — \(weekNote)",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Eggs — choline builds baby's brain and neural tube",
                    "Avocado on toast — folate + healthy fats for cell division",
                    "Berries — antioxidants protect rapidly dividing cells",
                    "Oats with banana — steady energy, eases morning sickness",
                    "Ginger tea — the safest nausea remedy in pregnancy"
                ]),
                supplements: items(.morning, .supplement, [
                    "Prenatal vitamin with methylfolate — neural tube closes by week 6",
                    "Ginger capsule if nauseous — safe, evidence-based",
                    "Iron if prescribed — blood volume starts increasing now"
                ]),
                rituals: items(.morning, .ritual, [
                    "Eat something small within 30 min of waking — empty stomach worsens nausea",
                    "Sip warm ginger or lemon water — settles the stomach gently",
                    "Fresh air and gentle walk — movement reduces nausea"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Leafy greens — folate for neural tube and DNA synthesis",
                    "Lentils or beans — iron + folate + plant protein",
                    "Sweet potato — beta-carotene converts to vitamin A for baby's eyes and skin",
                    "Salmon — omega-3 DHA for baby's brain development begins now",
                    "Yogurt or kefir — calcium + probiotics for your changing gut"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Small frequent meals — easier to keep down than large ones",
                    "Rest after eating if nauseous — lying on your left side helps"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Bone broth — collagen, minerals, gentle on a sensitive stomach",
                    "Chicken or tofu — lean protein for rapid cell growth",
                    "Cooked broccoli — vitamin C helps iron absorption, folate supports growth",
                    "Brown rice — B vitamins and steady energy",
                    "Warm stewed fruit — gentle natural sweetness, vitamin C"
                ]),
                supplements: items(.evening, .supplement, [
                    "Vitamin D — supports baby's bone formation and your immune system",
                    "Magnesium if cramping — safe, helps with sleep too"
                ]),
                rituals: items(.evening, .ritual, [
                    "Light dinner — progesterone slows digestion significantly now",
                    "Elevate head slightly if acid reflux — very common in first trimester",
                    "Rest deeply — your body is building a human, fatigue is not weakness"
                ])
            ),
            avoid: [
                "Raw fish, undercooked meat, soft cheese — listeria risk",
                "Alcohol — no safe amount during pregnancy",
                "Excess caffeine — limit to 200mg daily (one small coffee)",
                "Raw sprouts — high contamination risk",
                "High-mercury fish — swordfish, king mackerel, tilefish",
                "Liver and pâté — excess vitamin A can harm development",
                "Unpasteurised dairy and juice"
            ],
            rationale: "The first trimester is the most critical for organ formation. By week 8, all major organs have begun forming. Folate prevents neural tube defects, choline builds the brain, iron expands your blood supply by 50%, and DHA lays the foundation for your baby's nervous system. Nausea is a sign of strong hormones — eat what you can keep down."
        )
    }

    // MARK: - Second Trimester (Weeks 13-26)

    private static func secondTrimesterPlan(week: Int) -> DailyNutritionPlan {
        let weekNote: String
        if week <= 18 {
            weekNote = "Baby's skeleton is hardening and muscles are growing. Your appetite returns — this is when you can truly nourish deeply. Calcium and protein needs increase significantly."
        } else if week <= 22 {
            weekNote = "Baby can hear your voice now. The brain is developing at an extraordinary rate — DHA omega-3 is the building block. You may feel strong kicks and movements."
        } else {
            weekNote = "Baby's lungs are developing surfactant. Eyes are opening. Rapid growth means you need about 340 extra calories daily of nutrient-dense food, not empty calories."
        }

        return DailyNutritionPlan(
            todayFocus: "Week \(week) — \(weekNote)",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Eggs with spinach — choline + iron, both demands increase in second trimester",
                    "Greek yogurt with berries and nuts — calcium + protein + antioxidants",
                    "Oatmeal with chia seeds — fibre prevents constipation, omega-3 for brain",
                    "Avocado toast with sesame — healthy fats + calcium from seeds",
                    "Smoothie with banana, spinach, nut butter — iron, potassium, protein"
                ]),
                supplements: items(.morning, .supplement, [
                    "Prenatal vitamin — continue throughout",
                    "Omega-3 DHA — baby's brain is growing rapidly now",
                    "Iron — your blood volume peaks, anaemia risk increases"
                ]),
                rituals: items(.morning, .ritual, [
                    "Eat within 1 hour of waking — steady blood sugar protects you and baby",
                    "Prenatal yoga or swimming — safe, keeps muscles and joints strong",
                    "Warm water with lemon — supports digestion as hormones slow it"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Sardines or salmon — DHA + calcium + vitamin D in one food",
                    "Lentil soup — iron, folate, protein, fibre",
                    "Tahini with vegetables — calcium if you don't tolerate dairy",
                    "Red meat or chickpeas — iron needs are highest in second trimester",
                    "Colourful vegetables — variety ensures a wide nutrient spectrum",
                    "Almonds — vitamin E protects developing skin, magnesium for muscles"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Protein at every meal — baby is building muscle and organs rapidly",
                    "Walk after meals — prevents blood sugar spikes and gestational diabetes risk",
                    "Stay hydrated — you need 2.3 litres daily now, more if active"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Chicken or tofu with roasted vegetables — complete protein + vitamins",
                    "Sweet potato — beta-carotene for baby's developing eyes and immune system",
                    "Cooked dark greens with olive oil — calcium, iron, fat-soluble vitamins",
                    "Quinoa or brown rice — complete amino acids + B vitamins",
                    "Warm golden milk — turmeric is anti-inflammatory, calcium from milk"
                ]),
                supplements: items(.evening, .supplement, [
                    "Calcium if not getting enough from food — baby's bones are hardening",
                    "Magnesium — prevents leg cramps, supports sleep"
                ]),
                rituals: items(.evening, .ritual, [
                    "Left-side sleeping — improves blood flow to baby and kidneys",
                    "Pelvic floor exercises — preparation for birth starts now",
                    "Gentle evening walk — reduces swelling, improves sleep"
                ])
            ),
            avoid: [
                "All first trimester restrictions still apply",
                "Excess sugar — gestational diabetes risk increases mid-pregnancy",
                "Processed meats — nitrates and sodium",
                "Standing for very long periods — blood pools in legs",
                "Skipping meals — baby needs steady fuel, not feast-and-famine"
            ],
            rationale: "The second trimester is the golden period — nausea fades, energy returns, and your baby is growing rapidly. Bones are hardening (calcium), muscles are building (protein), the brain is wiring (DHA), and blood supply is expanding (iron). This is when your body can absorb nutrition most efficiently. Use this window to nourish deeply."
        )
    }

    // MARK: - Third Trimester (Weeks 27-40)

    private static func thirdTrimesterPlan(week: Int) -> DailyNutritionPlan {
        let weekNote: String
        if week <= 32 {
            weekNote = "Baby's brain is growing at its fastest rate — gaining billions of connections. DHA and choline are the most important nutrients right now. You need about 450 extra calories daily."
        } else if week <= 36 {
            weekNote = "Baby is building fat reserves for life outside. Lungs are maturing. Your body is preparing for birth — iron stores, energy reserves, and nutrient banking matter now."
        } else {
            weekNote = "Final preparations. Baby drops lower in the pelvis. Every day adds brain connections and lung surfactant. Eat well, rest deeply, and trust your body."
        }

        return DailyNutritionPlan(
            todayFocus: "Week \(week) — \(weekNote)",
            morning: TimeBlock(
                timeOfDay: .morning,
                foods: items(.morning, .food, [
                    "Eggs — choline is critical now, baby's brain is at peak growth",
                    "Oats with walnuts — omega-3, fibre, steady energy for a big body",
                    "Full-fat yogurt with berries — calcium, probiotics, antioxidants",
                    "Avocado — healthy fats for baby's brain and your hormones",
                    "Dates — from week 36, six daily dates may ease and shorten labour"
                ]),
                supplements: items(.morning, .supplement, [
                    "Prenatal vitamin — continue until birth and beyond",
                    "Omega-3 DHA — baby's brain adds 260mg DHA in the third trimester alone",
                    "Iron — your body is banking iron for blood loss at birth"
                ]),
                rituals: items(.morning, .ritual, [
                    "Eat small frequent meals — baby compresses your stomach now",
                    "Gentle stretching — eases back pain and prepares pelvis for birth",
                    "Warm water with lemon — heartburn prevention, gentle hydration"
                ])
            ),
            afternoon: TimeBlock(
                timeOfDay: .afternoon,
                foods: items(.afternoon, .food, [
                    "Salmon or sardines — DHA for final brain wiring, calcium for bones",
                    "Red meat or lentils — iron stores for birth and postpartum recovery",
                    "Sweet potato with tahini — beta-carotene + calcium + steady energy",
                    "Bone broth — collagen for your stretching tissues, minerals for baby",
                    "Beetroot — builds blood reserves for birth",
                    "Brazil nuts — selenium supports thyroid, which regulates everything"
                ]),
                supplements: items(.afternoon, .supplement, []),
                rituals: items(.afternoon, .ritual, [
                    "Protein-rich snacks every 2-3 hours — baby is gaining 230g per week",
                    "Gentle walk — prevents swelling, encourages baby into optimal position",
                    "Raspberry leaf tea from week 32 — traditionally tones the uterus for birth"
                ])
            ),
            evening: TimeBlock(
                timeOfDay: .evening,
                foods: items(.evening, .food, [
                    "Slow-cooked stew — nutrient-dense, easy to eat in smaller portions",
                    "Cooked leafy greens — calcium, iron, vitamin K for healthy blood clotting",
                    "Brown rice or quinoa — B vitamins for energy and nervous system",
                    "Warm soup — easier to digest than heavy meals as space decreases",
                    "Chamomile tea — safe, calming, helps with sleep"
                ]),
                supplements: items(.evening, .supplement, [
                    "Magnesium — prevents cramps, improves sleep, prepares muscles for birth",
                    "Vitamin D — baby's immune system is building from your stores"
                ]),
                rituals: items(.evening, .ritual, [
                    "Left-side sleeping with pillow between knees — optimal blood flow",
                    "Perineal massage from week 34 — reduces tearing risk",
                    "Birth breathing practice — slow exhale is the muscle memory you want for labour",
                    "Rest and nest — your body knows birth is coming, listen to it"
                ])
            ),
            avoid: [
                "All previous restrictions still apply",
                "Large meals — your stomach has much less space now",
                "Excess salt — swelling increases in the third trimester",
                "Lying flat on your back — compresses the vena cava, reduces blood flow",
                "Herbal supplements without provider approval — some stimulate contractions"
            ],
            rationale: "The third trimester is about brain building, fat storage, and birth preparation. Baby's brain uses 60% of total energy and requires enormous amounts of DHA. Iron stores now determine your recovery from birth. Calcium builds the final bone density. Dates from week 36 are associated with shorter labour and less need for induction. Every day of nourishment counts twice — for your baby now, and for your recovery after."
        )
    }

    // MARK: - Helpers

    private static func items(_ time: TimeOfDay, _ category: NutritionItemCategory, _ names: [String]) -> [NutritionItem] {
        names.map { NutritionItem(name: $0, category: category, timeBlock: time) }
    }
}
