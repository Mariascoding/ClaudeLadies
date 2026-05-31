import Foundation

// MARK: - Period Symptom Wisdom

/// Ancient-wisdom-grounded explanations for common cycle symptoms.
/// Each entry explains: what it means, why it matters, and what might help.

struct SymptomWisdom: Identifiable {
    let symptom: Symptom
    let whatItMeans: String
    let whyItMatters: String
    let whatHelps: [String]
    let warmRemedy: String  // One gentle, actionable remedy

    var id: String { symptom.rawValue }
}

enum PeriodSymptomWisdom {

    /// Returns wisdom cards for symptoms relevant to the current phase.
    /// Only includes symptoms that commonly appear in that phase.
    static func wisdom(for symptom: Symptom, phase: CyclePhase) -> SymptomWisdom {
        switch symptom {
        // MARK: - Physical

        case .headache:
            return SymptomWisdom(
                symptom: .headache,
                whatItMeans: phase == .menstrual
                    ? "Blood and Qi are moving downward. In TCM, headaches during menstruation often signal Blood deficiency or Liver Qi stagnation — your body is working hard to release, and the head receives less nourishment temporarily."
                    : "Hormonal shifts can trigger headaches. Estrogen fluctuations affect blood vessel dilation. In Ayurveda, this is Vata aggravation — too much upward-moving energy.",
                whyItMatters: "A headache during your cycle is your body signaling it needs more fluids, warmth, and blood-nourishing support. It's not random — it's a conversation.",
                whatHelps: [
                    "Warm honey water — nourishes Blood and prevents lightheadedness",
                    "Fresh beetroot or carrot juice (red/orange colors build blood in TCM)",
                    "Magnesium-rich foods (dark chocolate, pumpkin seeds)",
                    "Gentle pressure on Liver 3 point (between big and second toe)",
                    "Peppermint oil on temples"
                ],
                warmRemedy: "A spoon of raw honey in warm water, sipped slowly. TCM considers honey a blood tonic that gently lifts Qi to the head."
            )

        case .cramps:
            return SymptomWisdom(
                symptom: .cramps,
                whatItMeans: "In TCM, cramps signal Qi and Blood stagnation — energy isn't flowing smoothly through the uterus. In Ayurveda, this is Vata aggravation in the pelvis (apana vayu is struggling). Both traditions agree: cold and tension make it worse, warmth and movement make it better.",
                whyItMatters: "Prostaglandins cause the uterus to contract to shed its lining. Higher levels mean stronger cramps. But the ancient view adds: emotional holding and cold exposure tighten the uterus further.",
                whatHelps: [
                    "Warm ginger tea with honey (moves Qi, warms the uterus)",
                    "Warm compress on lower abdomen and lower back",
                    "Cinnamon bark tea (TCM: warms the meridians, moves Blood)",
                    "Gentle hip circles and cat-cow stretches",
                    "Magnesium glycinate (muscle relaxant)"
                ],
                warmRemedy: "Fresh ginger slices steeped in hot water with a teaspoon of honey and a pinch of cinnamon. TCM's classic formula for warming the womb and moving stagnant Blood."
            )

        case .backPain:
            return SymptomWisdom(
                symptom: .backPain,
                whatItMeans: "TCM connects lower back pain to Kidney energy — the Kidneys govern the reproductive system and the lumbar region. During menstruation, Kidney Qi can feel depleted. Ayurveda sees this as Vata accumulation in the lower body.",
                whyItMatters: "Your lower back shares nerve pathways with your uterus. As the uterus contracts, pain can radiate to the sacrum and lower back. Supporting Kidney warmth eases both.",
                whatHelps: [
                    "Warm compress on the sacrum (lower back)",
                    "Black sesame seeds (TCM Kidney tonic)",
                    "Warm bone broth with ginger",
                    "Supported child's pose or gentle spinal twists",
                    "Warm foot bath with Epsom salts (Kidney meridian starts at the feet)"
                ],
                warmRemedy: "Place a hot water bottle on your lower back and sip warm bone broth. TCM says warming the Kidneys from both inside and outside is the fastest relief."
            )

        case .bloating:
            return SymptomWisdom(
                symptom: .bloating,
                whatItMeans: "In TCM, bloating signals Spleen Qi deficiency — your digestive fire is weak. Progesterone (in luteal phase) or prostaglandins (in menstrual phase) slow gut motility. Ayurveda calls this sluggish Agni (digestive fire).",
                whyItMatters: "Water retention and slow digestion are your body conserving energy for reproductive work. Fighting it with restriction backfires — supporting digestion gently is the way.",
                whatHelps: [
                    "Warm fennel or cumin tea after meals (Ayurvedic digestive remedy)",
                    "Cooked foods only — raw foods tax weak Spleen Qi",
                    "Ginger slices before meals (ignites Agni)",
                    "Small, frequent meals instead of large ones",
                    "Gentle walking after eating (moves Qi through the middle)"
                ],
                warmRemedy: "Steep 1 tsp fennel seeds in hot water for 5 minutes. Sip after meals. This is one of Ayurveda's oldest remedies for bloating — it warms the digestive fire without aggravating anything."
            )

        case .breastTenderness:
            return SymptomWisdom(
                symptom: .breastTenderness,
                whatItMeans: "In TCM, breast tenderness is Liver Qi stagnation — the Liver meridian runs through the breasts. When Qi doesn't flow smoothly (often from stress or hormonal shifts), it accumulates and causes swelling and pain.",
                whyItMatters: "Estrogen stimulates breast tissue growth, and progesterone causes fluid retention. The combination creates tenderness. Liver support and lymphatic movement help clear the congestion.",
                whatHelps: [
                    "Dandelion root tea (TCM Liver cleanser)",
                    "Reduce caffeine (constricts lymphatic flow)",
                    "Gentle lymphatic breast massage (upward, toward armpits)",
                    "Cruciferous vegetables (help metabolize excess estrogen)",
                    "Evening primrose oil"
                ],
                warmRemedy: "Dandelion root tea twice daily. TCM considers dandelion a powerful but gentle Liver Qi mover — exactly what tender breasts need."
            )

        case .jointPain:
            return SymptomWisdom(
                symptom: .jointPain,
                whatItMeans: "Estrogen has anti-inflammatory properties. When it drops (menstrual and late luteal phases), joint inflammation can flare. TCM links this to Wind-Damp invading the channels when Qi and Blood are depleted.",
                whyItMatters: "Your joints are telling you inflammation is active. This is connected to your hormonal rhythm — not aging or weakness.",
                whatHelps: [
                    "Turmeric golden milk (powerful anti-inflammatory)",
                    "Omega-3 rich foods (wild salmon, walnuts)",
                    "Warm baths with Epsom salts",
                    "Gentle stretching — keep joints warm and mobile",
                    "Bone broth with turmeric and black pepper"
                ],
                warmRemedy: "Warm turmeric milk with a pinch of black pepper and honey before bed. Ayurveda's golden milk has been used for thousands of years to calm joint inflammation."
            )

        // MARK: - Emotional

        case .irritability:
            return SymptomWisdom(
                symptom: .irritability,
                whatItMeans: "TCM says irritability is Liver Qi stagnation — the Liver wants to flow freely, and when hormones shift rapidly (especially dropping progesterone), Qi gets stuck. You're not being difficult — your Liver is asking for movement and release.",
                whyItMatters: "Irritability is often your body's signal that it needs space, quiet, and less stimulation. Progesterone withdrawal reduces your stress buffer. Honoring this protects your nervous system.",
                whatHelps: [
                    "Sour foods (lemon, plum — TCM says sour soothes the Liver)",
                    "Rose tea or chrysanthemum tea (gentle Liver Qi movers)",
                    "Walking in nature (moves stagnant Qi)",
                    "Reduce commitments — this is not laziness, it's wisdom",
                    "Magnesium-rich foods (calm the nervous system)"
                ],
                warmRemedy: "Rose petal tea — TCM's most elegant remedy for Liver Qi stagnation. It moves energy gently without force, exactly what irritability needs."
            )

        case .anxiety:
            return SymptomWisdom(
                symptom: .anxiety,
                whatItMeans: "In TCM, anxiety often reflects Heart and Kidney disharmony — the Fire (Heart) and Water (Kidney) aren't communicating. In Ayurveda, this is excess Vata — too much air element creating ungroundedness. Hormonal drops amplify both patterns.",
                whyItMatters: "Anxiety during your cycle is not a character flaw. Progesterone is a natural anxiolytic (calming agent). When it drops, your nervous system loses its buffer. This is physiology, not psychology.",
                whatHelps: [
                    "Ashwagandha milk before bed (Ayurvedic nervine)",
                    "Warm, sweet, grounding foods (oats, sweet potato, dates)",
                    "Legs-up-the-wall pose (calms the vagus nerve)",
                    "Reduce screen time and stimulation",
                    "Jujube (red date) tea — TCM Heart-calming classic"
                ],
                warmRemedy: "Warm milk with ashwagandha and a pinch of nutmeg before bed. Ayurveda's ancient formula for calming Vata and settling the mind."
            )

        case .sadness:
            return SymptomWisdom(
                symptom: .sadness,
                whatItMeans: "TCM relates sadness to Lung and Heart Qi — these organs process grief and emotional release. Menstruation is itself a release. Ayurveda sees this as Kapha energy: heavy, watery, inward. Your body is processing — let it.",
                whyItMatters: "Serotonin levels fluctuate with estrogen. When estrogen drops, so does your mood's natural buoyancy. This is a wave — it will pass. Traditional wisdom says: don't fight the inward turn, use it.",
                whatHelps: [
                    "Saffron tea (traditional mood support in Persian and Ayurvedic medicine)",
                    "Warm, golden-colored foods (squash, turmeric, honey)",
                    "Gentle sunlight exposure in the morning",
                    "Slow, rhythmic breathing (4 counts in, 6 counts out)",
                    "Journaling or quiet creative expression"
                ],
                warmRemedy: "Saffron steeped in warm milk with honey. Saffron has been used for centuries across Persian and Indian traditions as a gentle mood brightener — modern research confirms it supports serotonin."
            )

        case .moodSwings:
            return SymptomWisdom(
                symptom: .moodSwings,
                whatItMeans: "Rapid hormonal shifts — especially the estrogen-progesterone ratio changing — create neurochemical waves. TCM sees this as Liver Qi moving erratically. Your emotions aren't wrong; they're amplified versions of truths you might normally filter out.",
                whyItMatters: "Mood swings often carry real messages. What upsets you now may be something you've been tolerating silently. The hormonal shift just removes the filter. Listen gently.",
                whatHelps: [
                    "Steady blood sugar (eat every 3-4 hours)",
                    "Rose and chamomile tea blend (smooths Liver Qi)",
                    "Omega-3 fatty acids (stabilize mood neurotransmitters)",
                    "Reduce decision-making load today",
                    "Warm bath with lavender"
                ],
                warmRemedy: "Eat a small, warm, protein-containing snack every 3 hours. Blood sugar crashes are the #1 amplifier of hormonal mood swings — steady fuel is steadier mood."
            )

        case .calm:
            return SymptomWisdom(
                symptom: .calm,
                whatItMeans: "Your Qi is flowing smoothly and your nervous system is regulated. This is the natural state your body returns to when hormones are balanced and you're well-nourished. Enjoy this — it's your body saying thank you.",
                whyItMatters: "Calm days are data points too. Notice what you ate, how you slept, what you did — this is your body showing you what works.",
                whatHelps: [
                    "Continue whatever you've been doing — it's working",
                    "Nourishing meals at regular intervals",
                    "Gentle movement you enjoy",
                    "Gratitude for your body's wisdom"
                ],
                warmRemedy: "A cup of your favorite warm tea, sipped slowly with appreciation. Your body is in harmony today."
            )

        case .joyful:
            return SymptomWisdom(
                symptom: .joyful,
                whatItMeans: "Joy often peaks when estrogen is rising (follicular) or at its height (ovulation). TCM associates joy with Heart Qi — your Heart fire is bright and warm. Ayurveda says your Ojas (vital essence) is strong.",
                whyItMatters: "This is your body at its most resourced. Channel this energy into things that matter to you — creativity, connection, movement. Your capacity is genuinely higher right now.",
                whatHelps: [
                    "Share a meal with someone you love",
                    "Move your body in ways that feel like celebration",
                    "Eat colorfully — your body is using nutrients efficiently",
                    "Create, plan, or start something new"
                ],
                warmRemedy: "Fresh fruit, bright colors on your plate, and sunlight. Feed the joy with beauty — inside and out."
            )

        // MARK: - Energy

        case .fatigue:
            return SymptomWisdom(
                symptom: .fatigue,
                whatItMeans: phase == .menstrual
                    ? "You are losing blood — and with it, iron, warmth, and Qi. TCM says fatigue during menstruation is Qi and Blood deficiency. Your body is doing enormous work. Fatigue is not failure; it's your body redirecting energy to essential processes."
                    : "Your body's energy needs shift across the cycle. In TCM, fatigue signals that Qi isn't being generated well — often from skipped meals, poor sleep, or trying to maintain the same pace all month long.",
                whyItMatters: "Fatigue is your body's most honest signal. It's not asking you to push through — it's asking you to rest and rebuild. Ignoring it creates a deficit that shows up later as worse PMS, hair thinning, or cycle irregularity.",
                whatHelps: [
                    "Red date (jujube) and goji berry tea (TCM Qi + Blood tonic)",
                    "Iron-rich foods: red meat, lentils, cooked spinach",
                    "Warm congee or bone broth (easy to digest, deeply nourishing)",
                    "10-minute rest after lunch (TCM: supports Spleen Qi)",
                    "Do less. Seriously. This is the prescription."
                ],
                warmRemedy: "Brew 5 red dates (jujubes) and a handful of goji berries in hot water for 10 minutes. Sip throughout the day. This is China's oldest blood and energy tonic for women."
            )

        case .energized:
            return SymptomWisdom(
                symptom: .energized,
                whatItMeans: "Your Qi is abundant and flowing. This typically peaks during the follicular and ovulatory phases when estrogen supports energy, clarity, and motivation. TCM says your Liver Qi is smooth and your Blood is full.",
                whyItMatters: "Use this energy wisely — it's your body's natural high-performance window. But don't overspend it. The energy you save now becomes the buffer that protects you in the luteal phase.",
                whatHelps: [
                    "Channel into strength training or creative projects",
                    "Eat protein-rich meals to sustain the energy",
                    "Stay hydrated — high energy means high metabolic demand",
                    "Plan ahead for lower-energy days"
                ],
                warmRemedy: "A vibrant smoothie with berries, protein, and greens. Fuel the fire without burning through your reserves."
            )

        case .restless:
            return SymptomWisdom(
                symptom: .restless,
                whatItMeans: "In Ayurveda, restlessness is classic Vata excess — too much air element, not enough earth. In TCM, it's Liver Qi wanting to move but finding no outlet. Common in late luteal phase when progesterone drops and nervous system activation rises.",
                whyItMatters: "Restlessness is trapped energy. Your body needs to move, but gently — forcing intense exercise when Vata is high can make it worse.",
                whatHelps: [
                    "Walking — the most Vata-balancing movement",
                    "Warm oil self-massage (Abhyanga — Ayurveda's top Vata remedy)",
                    "Warm, heavy foods (stews, root vegetables, oats)",
                    "Reduce stimulants (caffeine, screens, loud environments)",
                    "Slow, deep breathing with longer exhales"
                ],
                warmRemedy: "Warm sesame oil massaged into the soles of your feet before bed. Ayurveda's classic remedy for pulling restless energy downward and grounding it."
            )

        case .brainFog:
            return SymptomWisdom(
                symptom: .brainFog,
                whatItMeans: "TCM calls this Dampness clouding the Spleen — when digestive energy is weak, clarity suffers. Progesterone also has a mild sedative effect. Brain fog is common in the luteal and early menstrual phases when your body prioritizes reproductive work over cognitive sharpness.",
                whyItMatters: "This is not your brain failing — it's your body reallocating resources. Don't schedule your hardest thinking for your foggiest days. Work with your cycle, not against it.",
                whatHelps: [
                    "Rosemary tea (traditional European clarity herb)",
                    "Light, warm meals — avoid heavy or greasy food",
                    "Gentle movement (stimulates Qi to the brain)",
                    "Stay hydrated — dehydration worsens fog dramatically",
                    "Lion's mane mushroom (traditional clarity tonic)"
                ],
                warmRemedy: "Fresh rosemary steeped in hot water. European herbalists have used rosemary for centuries to 'clear the head.' Inhale the steam, then sip."
            )

        case .focused:
            return SymptomWisdom(
                symptom: .focused,
                whatItMeans: "Your cognitive function peaks when estrogen is rising or at its height. TCM says your Liver Qi is smooth, Blood is nourishing the brain, and your Shen (spirit-mind) is clear.",
                whyItMatters: "This is your sharpest window. Schedule important decisions, deep work, and complex tasks here. Your brain is literally working at higher capacity.",
                whatHelps: [
                    "Omega-3 rich foods (feed the focus)",
                    "Green tea (L-theanine + gentle caffeine = sustained clarity)",
                    "Complex tasks and deep work",
                    "Protein-rich meals to maintain blood sugar"
                ],
                warmRemedy: "Green tea and a handful of walnuts. The brain-shaped nut that TCM considers the ultimate Brain-Kidney tonic, paired with alert calm."
            )

        case .insomnia:
            return SymptomWisdom(
                symptom: .insomnia,
                whatItMeans: "In TCM, insomnia during the cycle reflects Yin deficiency or Heart Blood not anchoring the Shen (spirit). In Ayurveda, it's Vata disturbing sleep. Progesterone withdrawal in late luteal phase removes your natural sedative. Rising body temperature also disrupts sleep architecture.",
                whyItMatters: "Sleep is when your body repairs hormones, clears inflammation, and rebuilds blood. Poor sleep during your cycle creates a cascading deficit — prioritize it fiercely.",
                whatHelps: [
                    "Jujube seed tea (Suan Zao Ren — TCM's top sleep herb)",
                    "Tart cherry juice (natural melatonin source)",
                    "Warm milk with nutmeg and ashwagandha",
                    "Cool your bedroom slightly (counteract rising body temp)",
                    "No screens 1 hour before bed (protect melatonin)"
                ],
                warmRemedy: "Warm milk with a pinch of nutmeg. Ayurveda has used this for thousands of years — nutmeg is a gentle sedative that calms Vata and invites sleep."
            )

        // MARK: - Digestion

        case .nausea:
            return SymptomWisdom(
                symptom: .nausea,
                whatItMeans: "Prostaglandins that cause uterine contractions can also affect the gut. In TCM, nausea signals rebellious Stomach Qi — energy moving upward instead of downward. In Ayurveda, this is Pitta in the stomach aggravated by hormonal heat.",
                whyItMatters: "Nausea is your digestive system asking for simplicity. Don't force food, but don't go empty either — gentle nourishment keeps blood sugar stable.",
                whatHelps: [
                    "Fresh ginger tea (TCM's #1 anti-nausea herb)",
                    "Small sips of warm water between meals",
                    "Bland, warm foods: rice porridge, clear soup",
                    "Peppermint tea (cools rebellious Stomach Qi)",
                    "Eat small amounts frequently"
                ],
                warmRemedy: "Grate fresh ginger into hot water, add honey. Sip slowly. Ginger has been used across every ancient tradition to settle the stomach and redirect Qi downward."
            )

        case .cravings:
            return SymptomWisdom(
                symptom: .cravings,
                whatItMeans: "Cravings are intelligent signals. Chocolate cravings = magnesium need. Sugar cravings = serotonin dip (estrogen and progesterone both affect serotonin). Salt cravings = mineral depletion. Your body is asking for specific nutrients through the language of craving.",
                whyItMatters: "Fighting cravings creates stress. Understanding them transforms them into guidance. The key is answering the real need, not the processed version of it.",
                whatHelps: [
                    "Chocolate craving → dark chocolate (85%+) or cacao with magnesium",
                    "Sugar craving → sweet potato, dates, warm oats with honey",
                    "Salt craving → seaweed, mineral-rich bone broth, olives",
                    "Carb craving → complex carbs (brown rice, sweet potato, oats)",
                    "Steady meals every 3-4 hours prevent the worst cravings"
                ],
                warmRemedy: "Two Medjool dates with a square of dark chocolate. This satisfies the sweet-and-mineral need in one bite — what your body actually wanted."
            )

        case .appetiteLoss:
            return SymptomWisdom(
                symptom: .appetiteLoss,
                whatItMeans: "In TCM, appetite loss signals weak Spleen and Stomach Qi — your digestive fire is low. This is common on Day 1-2 of menstruation when Qi is directed toward the uterus. Ayurveda says Agni (digestive fire) dims when Vata rises.",
                whyItMatters: "Even without appetite, your body needs fuel — especially during menstruation when you're losing blood. Skipping food creates blood sugar crashes that worsen every other symptom.",
                whatHelps: [
                    "Warm congee or rice porridge (easiest food to digest in TCM)",
                    "Bone broth — nutrition without the burden of chewing",
                    "Warm honey water (nourishes without taxing digestion)",
                    "Small portions frequently — don't wait for hunger",
                    "Ginger before meals (sparks Agni)"
                ],
                warmRemedy: "Warm bone broth with a slice of ginger. Your body receives deep nourishment without having to work hard to digest it."
            )

        case .digestiveIssues:
            return SymptomWisdom(
                symptom: .digestiveIssues,
                whatItMeans: "Prostaglandins affect the bowel as well as the uterus — loose stools during menstruation are common and physiological. In TCM, this is Spleen Qi deficiency. In Ayurveda, Vata (apana vayu) is moving strongly, affecting everything nearby.",
                whyItMatters: "Your gut and reproductive system share nerve pathways and chemical messengers. Supporting one supports the other. This is why gut health is hormone health.",
                whatHelps: [
                    "Cooked foods only (spare your Spleen Qi)",
                    "Warm fennel and ginger tea",
                    "Probiotic-rich foods (miso soup, if not histamine-sensitive)",
                    "Avoid cold, raw, or greasy foods",
                    "Slippery elm or marshmallow root tea (soothes the gut lining)"
                ],
                warmRemedy: "Warm miso soup with ginger. The fermented warmth settles the gut while the ginger moves Qi smoothly downward."
            )

        // MARK: - Skin & Hair

        case .acne:
            return SymptomWisdom(
                symptom: .acne,
                whatItMeans: "In TCM, acne is Heat and Dampness in the Blood — the body is trying to expel toxins through the skin. Hormonally, androgens rise relative to estrogen in the late luteal phase, increasing sebum production. The skin reflects what the liver can't process internally.",
                whyItMatters: "Cycle-related acne is a hormonal pattern, not a hygiene issue. Supporting the liver and reducing internal heat addresses the root cause.",
                whatHelps: [
                    "Bitter greens (dandelion, arugula — clear Liver Heat)",
                    "Green tea (antioxidant, reduces sebum production)",
                    "Reduce dairy and sugar (both increase androgens)",
                    "Zinc-rich foods (pumpkin seeds, chickpeas)",
                    "Spearmint tea (naturally anti-androgenic)"
                ],
                warmRemedy: "Spearmint tea twice daily in the luteal phase. Traditional and modern evidence both show it gently reduces the androgens that trigger hormonal acne."
            )

        case .dryness:
            return SymptomWisdom(
                symptom: .dryness,
                whatItMeans: "In TCM, dryness signals Yin and Blood deficiency — not enough moisture and nourishment reaching the skin. Estrogen is your body's natural moisturizer. When it drops (menstrual, late luteal), skin and mucous membranes dry out.",
                whyItMatters: "Dry skin is an outer mirror of inner depletion. Your body is asking for moisture, healthy fats, and Yin-nourishing foods.",
                whatHelps: [
                    "Healthy fats: avocado, olive oil, ghee, salmon",
                    "Yin-nourishing foods: pears, honey, sesame, lily bulb",
                    "Hydrate with warm water throughout the day",
                    "Collagen-rich bone broth",
                    "External: facial oil with rosehip or jojoba"
                ],
                warmRemedy: "Stewed pear with honey and a few goji berries. TCM's classic Yin tonic — moisturizes from the inside out."
            )

        case .hairLoss:
            return SymptomWisdom(
                symptom: .hairLoss,
                whatItMeans: "In TCM, hair is the 'extension of Blood' — when Blood is deficient, hair starves. The Kidneys also govern hair: weak Kidney essence = thinning hair. Hormonally, dropping estrogen reduces the hair growth phase, and rising androgens can shrink follicles.",
                whyItMatters: "Hair loss during your cycle reflects deeper patterns: iron depletion, hormonal shifts, stress, or nutritional gaps. The hair follicle is one of your body's most metabolically active structures — it shows deficiency early.",
                whatHelps: [
                    "Black sesame seeds (TCM's top Kidney and Blood hair tonic)",
                    "Iron + vitamin C with meals",
                    "He Shou Wu tea (Fo-Ti — classical hair restoration herb in TCM)",
                    "Protein at every meal (hair is 95% keratin protein)",
                    "Daily scalp massage (improves microcirculation to follicles)"
                ],
                warmRemedy: "A tablespoon of black sesame paste in warm milk. TCM's most revered hair remedy — nourishes Kidney essence and Blood simultaneously."
            )

        case .glowingSkin:
            return SymptomWisdom(
                symptom: .glowingSkin,
                whatItMeans: "Your Blood is abundant and flowing, your Yin is full, and estrogen is supporting collagen and moisture. TCM says your inner radiance is shining outward. This typically peaks in the follicular and ovulatory phases.",
                whyItMatters: "Glowing skin means your body is well-nourished and your hormones are in a good rhythm. Notice what you've been eating and doing — this is your template for wellness.",
                whatHelps: [
                    "Continue nourishing with healthy fats and colorful vegetables",
                    "Stay hydrated — your skin is showing it appreciates it",
                    "Enjoy this phase and notice what supports it",
                    "Antioxidant-rich foods to protect the glow"
                ],
                warmRemedy: "A handful of goji berries and a cup of rose tea. Feed the glow with beauty from the inside."
            )
        }
    }

    /// Returns all symptoms, with the most likely ones for the phase listed first
    static func commonSymptoms(for phase: CyclePhase) -> [Symptom] {
        let prioritised: [Symptom]
        switch phase {
        case .menstrual:
            prioritised = [.cramps, .fatigue, .headache, .backPain, .bloating, .nausea, .appetiteLoss, .sadness, .insomnia, .hairLoss]
        case .follicular:
            prioritised = [.energized, .focused, .glowingSkin, .joyful, .cravings, .acne, .bloating]
        case .ovulation:
            prioritised = [.energized, .joyful, .glowingSkin, .bloating, .breastTenderness, .headache]
        case .luteal:
            prioritised = [.irritability, .anxiety, .moodSwings, .cravings, .bloating, .breastTenderness, .fatigue, .brainFog, .acne, .insomnia, .restless, .headache, .digestiveIssues, .dryness]
        }
        // Append any remaining symptoms not already in the prioritised list
        let remaining = Symptom.allCases.filter { !prioritised.contains($0) }
        return prioritised + remaining
    }

    /// Returns all symptoms, with goal-appropriate ones first
    static func symptoms(for goal: WellnessGoal) -> [Symptom] {
        let prioritised: [Symptom]
        switch goal {
        case .prenatal:
            prioritised = [.nausea, .fatigue, .cravings, .headache, .bloating, .backPain, .insomnia, .anxiety, .moodSwings, .digestiveIssues, .dryness, .glowingSkin]
        case .postnatal:
            prioritised = [.fatigue, .sadness, .anxiety, .hairLoss, .brainFog, .insomnia, .moodSwings, .backPain, .appetiteLoss, .dryness]
        case .menopause:
            prioritised = [.insomnia, .fatigue, .anxiety, .moodSwings, .jointPain, .brainFog, .dryness, .hairLoss, .irritability, .bloating, .headache, .restless]
        default:
            return Symptom.allCases
        }
        let remaining = Symptom.allCases.filter { !prioritised.contains($0) }
        return prioritised + remaining
    }
}
