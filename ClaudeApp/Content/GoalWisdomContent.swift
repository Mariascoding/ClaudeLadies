import Foundation

// MARK: - Goal-Specific Wisdom

/// Phase-aware wisdom sections for TTC, prenatal, and postnatal goals.
/// Shown alongside the cycle nourish plans when the user's goal matches.

// MARK: - Wisdom Card Model

struct GoalWisdomCard: Identifiable {
    let title: String
    let icon: String
    let body: String
    let tips: [String]

    var id: String { title }
}

// MARK: - Goal Wisdom Engine

enum GoalWisdomContent {

    static func cards(for goal: WellnessGoal, phase: CyclePhase, dayInPhase: Int) -> [GoalWisdomCard] {
        switch goal {
        case .tryingToConceive:
            ttcCards(phase: phase, dayInPhase: dayInPhase)
        case .prenatal:
            prenatalCards(phase: phase)
        case .postnatal:
            postnatalCards()
        default:
            []
        }
    }

    // MARK: - Trying to Conceive

    private static func ttcCards(phase: CyclePhase, dayInPhase: Int) -> [GoalWisdomCard] {
        var cards: [GoalWisdomCard] = []

        switch phase {
        case .menstrual:
            cards.append(GoalWisdomCard(
                title: "Fertile Ground Begins Here",
                icon: "moon.stars.fill",
                body: "Menstruation is not a failed cycle — it's your body preparing fresh, nutrient-rich lining for the next opportunity. The quality of this bleed reflects the quality of the lining that will build next. A healthy, complete shed sets the foundation.",
                tips: [
                    "Warm foods and iron-rich meals rebuild the blood your uterus needs",
                    "Rest deeply — egg selection for this cycle is already underway",
                    "Avoid cold foods and iced drinks — TCM says cold contracts the uterus and slows shedding",
                    "Track your bleed: 3-7 days of moderate flow with a clear start and end is a healthy pattern"
                ]
            ))

        case .follicular:
            cards.append(GoalWisdomCard(
                title: "Building Your Fertile Window",
                icon: "leaf.fill",
                body: "Your body is selecting and maturing the dominant follicle that will become this cycle's egg. Estrogen rises, cervical fluid increases, and your lining thickens. Everything you eat now directly feeds egg quality — eggs take about 90 days to mature, but this final stretch matters most.",
                tips: [
                    "Cervical mucus check: as it becomes wetter and stretchier, fertility rises",
                    "Eat folate-rich foods daily — leafy greens, lentils, eggs",
                    "CoQ10 supports mitochondrial energy in the maturing egg",
                    "Start OPKs a few days before expected ovulation to catch the surge",
                    "Enjoy intimacy — sperm can survive up to 5 days in fertile mucus"
                ]
            ))

            cards.append(GoalWisdomCard(
                title: "Cervical Mucus Guide",
                icon: "drop.fill",
                body: "Your cervical fluid is a direct fertility signal. After your period it starts dry, becomes sticky, then creamy, then stretchy and clear like egg white. The egg-white stage is your most fertile window — sperm can travel and survive best in this mucus.",
                tips: [
                    "Dry → Sticky → Creamy → Egg-white → Dry after ovulation",
                    "Most fertile: clear, stretchy, slippery — can stretch 2+ inches between fingers",
                    "Stay hydrated — water intake directly affects mucus quality",
                    "Evening primrose oil in the follicular phase can improve mucus production",
                    "Avoid lubricants during the fertile window — most are hostile to sperm"
                ]
            ))

        case .ovulation:
            cards.append(GoalWisdomCard(
                title: "Your Fertile Peak",
                icon: "sun.max.fill",
                body: "The egg is released and viable for 12-24 hours. But your fertile window is wider — sperm deposited in the days before ovulation can be waiting. The best timing is the 2-3 days before ovulation and the day of. After ovulation, the window closes quickly.",
                tips: [
                    "OPK positive means ovulation likely within 12-36 hours",
                    "BBT rise of 0.2-0.5°C confirms ovulation happened — but only in retrospect",
                    "Intimacy every 1-2 days around this window is optimal",
                    "After ovulation: a mild twinge or cramping on one side is normal — that's the egg releasing",
                    "Antioxidant-rich foods protect egg quality at the moment of release"
                ]
            ))

            cards.append(GoalWisdomCard(
                title: "BBT — Basal Body Temperature",
                icon: "thermometer.medium",
                body: "Your temperature shifts after ovulation due to progesterone. Before ovulation it's lower (around 36.1-36.4°C), after it rises by 0.2-0.5°C and stays elevated. This shift confirms ovulation happened. Track it first thing upon waking, before moving or drinking.",
                tips: [
                    "Use a BBT thermometer — regular ones aren't precise enough",
                    "Measure at the same time daily, immediately upon waking",
                    "Three days of elevated temps confirms ovulation occurred",
                    "A sustained rise for 14+ days could indicate early pregnancy",
                    "Disrupted sleep, alcohol, and illness can skew readings"
                ]
            ))

        case .luteal:
            cards.append(GoalWisdomCard(
                title: "The Implantation Window",
                icon: "heart.circle.fill",
                body: "If fertilization occurred, the embryo travels down the fallopian tube over 6-10 days before implanting in the uterine lining. This is the two-week wait. Progesterone keeps the lining thick and receptive. Your job now is to support progesterone, stay warm, reduce stress, and nourish deeply.",
                tips: [
                    "Implantation typically happens 6-10 days after ovulation",
                    "Light spotting around this time can be an implantation sign",
                    "Progesterone-supporting foods: sweet potato, warm cooked meals, healthy fats",
                    "Avoid intense exercise — gentle movement only in the implantation window",
                    "Vitamin B6 and magnesium support progesterone naturally",
                    "Avoid alcohol, NSAIDs, and excessive heat during this window"
                ]
            ))

            cards.append(GoalWisdomCard(
                title: "The Two-Week Wait",
                icon: "hourglass",
                body: "This is often the hardest part emotionally. Your body is either nurturing a tiny embryo or preparing for the next cycle — and you can't know which yet. Both outcomes are your body working perfectly. Ancient wisdom says: live as if you are already pregnant. Warm, nourished, rested, at peace.",
                tips: [
                    "Earliest reliable pregnancy test: 12-14 days past ovulation",
                    "HCG needs time to build — testing too early causes false negatives",
                    "Breast tenderness, fatigue, and mild nausea can appear but also mimic PMS",
                    "Continue prenatal vitamins and folate regardless",
                    "Be gentle with yourself — stress hormones work against implantation"
                ]
            ))
        }

        return cards
    }

    // MARK: - Prenatal

    private static func prenatalCards(phase: CyclePhase) -> [GoalWisdomCard] {
        // During pregnancy, cycle phases aren't relevant in the same way,
        // but the user may still have this goal set. Show trimester-agnostic wisdom.
        [
            GoalWisdomCard(
                title: "Nourishing Two",
                icon: "figure.and.child.holdinghands",
                body: "Your body is doing the most extraordinary work it will ever do. Every nutrient you eat is building organs, bones, a brain, a heart. You need about 300 extra calories daily — but the quality matters more than the quantity. Think nutrient-dense, not just more food.",
                tips: [
                    "Folate is critical — especially in the first 12 weeks for neural tube development",
                    "Iron needs nearly double — your blood volume increases by 50%",
                    "Omega-3 DHA builds your baby's brain and eyes — wild salmon, walnuts, algae oil",
                    "Choline is essential for brain development — eggs are the best source",
                    "Eat protein at every meal — your baby is building rapidly"
                ]
            ),
            GoalWisdomCard(
                title: "What Ancient Traditions Say",
                icon: "books.vertical.fill",
                body: "TCM says pregnancy is a time of abundant Blood and Yin — warm, nourishing foods protect both mother and baby. Ayurveda says the mother's Ojas (vital essence) feeds the baby directly. Both traditions agree: rest is not optional, warmth is protective, and emotional peace is as important as nutrition.",
                tips: [
                    "Warm, cooked foods are easier to digest and absorb during pregnancy",
                    "Bone broth is the traditional cross-cultural pregnancy food — collagen, minerals, gelatin",
                    "Ginger tea helps with nausea — TCM's oldest pregnancy remedy",
                    "Avoid raw and cold foods when possible — your digestive fire is shared with baby",
                    "Rest when tired — growing a human is the most energy-intensive work your body does"
                ]
            ),
            GoalWisdomCard(
                title: "Key Nutrients to Prioritize",
                icon: "leaf.circle.fill",
                body: "Some nutrients become critically important during pregnancy. Deficiency in any of these can affect both your health and your baby's development. Your prenatal vitamin is a safety net — but food sources are better absorbed and more bioavailable.",
                tips: [
                    "Folate: dark leafy greens, lentils, asparagus, avocado",
                    "Iron: red meat, lentils, spinach — pair with vitamin C for absorption",
                    "Calcium: dairy, tahini, sardines, leafy greens",
                    "DHA: wild salmon, sardines, walnuts, chia seeds",
                    "Choline: eggs, liver, salmon — most prenatal vitamins don't include enough",
                    "Vitamin D: sunlight, fortified foods, supplement if levels are low"
                ]
            )
        ]
    }

    // MARK: - Postnatal

    private static func postnatalCards() -> [GoalWisdomCard] {
        [
            GoalWisdomCard(
                title: "The Fourth Trimester",
                icon: "heart.fill",
                body: "Every ancient culture has a tradition of postpartum care — 40 days of rest, warming foods, and community support. Modern life often skips this. But your body just performed a marathon: it grew an organ (the placenta), expanded its blood volume by 50%, and delivered a human being. Recovery is not optional — it's biological.",
                tips: [
                    "Rest as much as humanly possible in the first 6 weeks",
                    "Accept every offer of help — this is wisdom, not weakness",
                    "Warm, slow-cooked meals are ideal — stews, soups, congee, bone broth",
                    "Keep your feet and belly warm — TCM says cold enters through the feet postpartum",
                    "Delay vigorous exercise until at least 6 weeks, longer if you had complications"
                ]
            ),
            GoalWisdomCard(
                title: "Rebuilding Your Blood",
                icon: "drop.fill",
                body: "Birth involves significant blood loss — even uncomplicated births. Your iron stores, ferritin, and overall blood volume need active rebuilding. Fatigue, brain fog, dizziness, and hair loss in the postpartum months are often iron depletion, not just sleep deprivation. Get your ferritin tested.",
                tips: [
                    "Iron-rich foods daily: red meat, liver, lentils, dark leafy greens",
                    "Pair iron with vitamin C for absorption — avoid tea and coffee with iron meals",
                    "Bone broth is a traditional blood-builder across TCM, Ayurveda, and European traditions",
                    "Red date and goji berry tea — TCM's classic postpartum Blood tonic",
                    "Target ferritin above 40 ng/mL — below 30 is associated with hair loss and fatigue",
                    "B12 and folate support red blood cell production"
                ]
            ),
            GoalWisdomCard(
                title: "Breastfeeding Nutrition",
                icon: "cup.and.saucer.fill",
                body: "If you're breastfeeding, your body prioritizes your baby's milk supply — even at your own expense. You need 400-500 extra calories daily of nutrient-dense food. If you undereat, your body will pull calcium from your bones, iron from your stores, and DHA from your brain to make milk.",
                tips: [
                    "Eat enough — this is not the time for calorie restriction",
                    "Healthy fats are essential: avocado, olive oil, nuts, salmon",
                    "Oats, fennel, and brewer's yeast traditionally support milk supply",
                    "Stay well hydrated — drink to thirst, and then a bit more",
                    "Calcium-rich foods protect your bones: dairy, sardines, tahini, leafy greens",
                    "Some babies react to dairy, caffeine, or strong flavors in breast milk — observe and adjust"
                ]
            ),
            GoalWisdomCard(
                title: "Your Nervous System After Birth",
                icon: "brain.head.profile",
                body: "Your nervous system has been through an extraordinary event. Hormones shift dramatically after birth — estrogen and progesterone crash, prolactin and oxytocin surge. This hormonal earthquake can bring weeping, anxiety, rage, or numbness. These are physiological, not psychological failures. They usually stabilize by 2-3 weeks.",
                tips: [
                    "Mood changes in the first 2 weeks are the 'baby blues' — hormonal, not personal",
                    "If feelings of despair, anxiety, or disconnection persist past 2-3 weeks, reach out for support",
                    "Omega-3 DHA supports brain recovery and mood regulation",
                    "Magnesium before bed helps with sleep quality in the windows you get",
                    "Ashwagandha and chamomile are gentle nervine herbs safe for most postpartum women",
                    "You are not failing. You are recovering from the biggest event your body has ever done."
                ]
            ),
            GoalWisdomCard(
                title: "When Your Cycle Returns",
                icon: "arrow.triangle.2.circlepath",
                body: "If not breastfeeding, your period may return within 6-8 weeks. With breastfeeding, it can take months or over a year. Your first cycles back may be irregular, heavier, or different than before — this is normal. Your body is recalibrating its entire hormonal axis.",
                tips: [
                    "First postpartum periods are often anovulatory — your body is practicing",
                    "Heavier or more painful periods initially are common and usually improve",
                    "You can ovulate before your first period — contraception matters if not planning another pregnancy",
                    "Iron supplements may be needed if periods are heavy on top of postpartum depletion",
                    "It can take 6-12 months for your cycle to fully regulate again",
                    "Track your cycles when they return — the data helps you understand your new baseline"
                ]
            )
        ]
    }
}
