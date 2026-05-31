import SwiftUI
import SwiftData

// MARK: - Auto Flower Creator View

struct AutoFlowerCreatorView: View {

    /// Optional callback fired the first time the view reaches the
    /// `.noted` phase — i.e. the user has completed the full Auto
    /// Flower experience (intake → bloom → press-and-hold → shrink to
    /// mini flower). The Carousel lab uses this to hand control back
    /// to itself after the elaborate setup sequence.
    var onNoted: (() -> Void)? = nil

    /// Background colour for the whole view. Defaults to `.appCream`
    /// so the Auto Flower lab stays exactly as it was; the Carousel
    /// lab passes a custom warmer tone for visual harmony.
    var backgroundColor: Color = .appCream

    // MARK: - Phase

    private enum Phase: Equatable {
        case input
        case building(step: Int)
        case complete
        case interactive   // press-and-hold mode after the reveal settles
        case captured      // user let go — state saved, flower stays big, tap to continue
        case noted         // state noted; flower is a mini widget, guidance shown

        var isInput: Bool {
            if case .input = self { return true }
            return false
        }

        var isBuilding: Bool {
            if case .building = self { return true }
            return false
        }

        var isComplete: Bool { self == .complete }
        var isInteractive: Bool { self == .interactive }
        var isCaptured: Bool { self == .captured }
        var isNoted: Bool { self == .noted }

        /// Phases where the big flower is on-screen and has bloomed at
        /// least partway — used to gate sparkles and the press/tap affordances.
        var isBloomedScene: Bool {
            self == .complete || self == .interactive || self == .captured
        }
    }

    // MARK: - Re-entry Stage
    //
    // When the user presses the mini flower in `.noted`, we layer a
    // fullscreen white overlay on top of the noted screen: the big flower
    // rises from the bottom and re-grows while the finger stays pressed on
    // the dot. On release we show a short comparison message + subtle
    // history graph, then fade the overlay away.

    private enum ReentryStage: Equatable {
        case active     // white overlay visible; user is (or was) pressing
        case released   // user let go; comparison + graph visible
        case closing    // overlay fading back out to the noted screen
    }

    // MARK: - Generated Flower

    private struct GeneratedFlower: Equatable {
        let displayName: String       // literal input name, trimmed + title-cased
        let flowerName: String        // from FlowerNamingEngine
        let archetype: MoonWomanArchetype
        let config: AutoFlowerConfig

        static func == (lhs: GeneratedFlower, rhs: GeneratedFlower) -> Bool {
            lhs.displayName == rhs.displayName
                && lhs.flowerName == rhs.flowerName
                && lhs.archetype == rhs.archetype
        }
    }

    // MARK: - Story Step

    private struct StoryStep {
        let text: String
        let bloomTarget: CGFloat
        let duration: Double
    }

    // MARK: - Resting Bud (shown while user is filling out the form)

    private static let restingConfig = AutoFlowerConfig(
        outerDesign: .round,
        innerDesign: .lotus,
        stamenDesign: .corona,
        centerDesign: .smooth,
        outerColor:  Color(red: 0.92, green: 0.78, blue: 0.82),
        innerColor:  Color(red: 0.95, green: 0.85, blue: 0.78),
        stamenColor: Color(red: 0.96, green: 0.85, blue: 0.55),
        centerColor: Color(red: 0.85, green: 0.55, blue: 0.55),
        geometry: FlowerGeometry(
            outerCount: 8, backCount: 8, innerCount: 6,
            petalWidth: 0.65, innerWidth: 0.55,
            centerScale: 0.16, stamenScale: 0.20,
            outerGradientStrength: 0, innerGradientStrength: 0
        )
    )

    private static let restingBudProgress: CGFloat = 0.11

    // Default cycle math when no UserProfile exists yet.
    private static let defaultCycleLength: Int = 28
    private static let defaultPeriodLength: Int = 5

    // MARK: - Input State

    @State private var periodDate: Date = .now
    @State private var hasPeriod: Bool = true
    @State private var ageSelection: Int = 28
    @State private var nameInput: String = ""

    /// 0=period, 1=age, 2=name
    @State private var inputStep: Int = 0
    private static let totalInputSteps: Int = 3

    // MARK: - Generation State

    @State private var phase: Phase = .input
    @State private var generated: GeneratedFlower? = nil
    @State private var holdProgress: CGFloat = restingBudProgress
    @State private var isHolding: Bool = false
    @State private var bloomState: BloomState = .bud
    @State private var storyTask: Task<Void, Never>? = nil
    @State private var interactiveTransitionTask: Task<Void, Never>? = nil
    @State private var noteStateTask: Task<Void, Never>? = nil
    @State private var budPulse: CGFloat = 1.0

    // Noted-phase state
    @State private var notedBloomState: BloomState? = nil
    @State private var cyclePosition: CycleCalculator.CyclePosition? = nil
    @State private var dailyGuidance: DailyGuidance? = nil
    @State private var showNervousSystem: Bool = false
    @State private var toastMessage: String? = nil
    @State private var toastTask: Task<Void, Never>? = nil

    // Mini-flower hold tracking (legacy — no longer used for tap/hold diff)
    @State private var miniHoldStartTime: Date? = nil
    @State private var miniHoldResetTask: Task<Void, Never>? = nil

    /// Cumulative committed rotation of the LARGE state-page flower
    /// (advances by a step on each horizontal swipe inside the state
    /// page overlay).
    @State private var flowerRotation: Double = 0
    /// 0 = compact state ribbon, 1 = breathwork practice — driven by
    /// horizontal swipes on the large flower in the state page.
    @State private var notedCardIndex: Int = 0
    /// Live drag rotation while the user is swiping the large flower
    /// inside the state page (resets to 0 on release).
    @State private var stateFlowerDragRotation: Double = 0
    @State private var stateFlowerDidSwipe: Bool = false

    // Re-entry overlay state
    @State private var reentryStage: ReentryStage? = nil
    @State private var reentryFadeInTask: Task<Void, Never>? = nil
    @State private var reentryCloseTask: Task<Void, Never>? = nil
    @State private var reentryCompareMessage: String? = nil
    @State private var reentryPreviousEntry: FlowerStateEntry? = nil

    // Read-only state progression page (quick tap on mini flower)
    @State private var showStatePage: Bool = false
    @State private var statePageZoom: CGFloat = 0.85

    // Nutrition overlay (Sun → protocol cards + symptoms)
    @State private var showNutritionPage: Bool = false
    @State private var showFullProtocol: Bool = false
    @State private var showSymptomPage: Bool = false
    @State private var symptomQuery: String = ""
    @State private var revealedSymptom: Symptom? = nil

    // Moon overlay (Moon widget → today's moon view + wisdom)
    @State private var showMoonPage: Bool = false
    @StateObject private var moonState = MoonState()

    // Intro marketing page shown before the period question.
    @State private var showingIntro: Bool = true

    @Query(sort: \FlowerStateEntry.timestamp, order: .reverse)
    private var stateHistory: [FlowerStateEntry]

    @Query(sort: \ShinedustEvent.timestamp, order: .reverse)
    private var shinedustEvents: [ShinedustEvent]

    @Query(sort: \AutoFlowerProfile.createdDate, order: .reverse)
    private var savedProfiles: [AutoFlowerProfile]

    private var savedProfile: AutoFlowerProfile? { savedProfiles.first }

    @Query(sort: \NutritionLog.date, order: .reverse)
    private var allNutritionLogs: [NutritionLog]

    @Query(sort: \SymptomEntry.date, order: .reverse)
    private var symptomEntries: [SymptomEntry]

    @Query(sort: \CycleLog.startDate, order: .reverse)
    private var cycleLogs: [CycleLog]

    private var todayNutritionLog: NutritionLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return allNutritionLogs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private var totalShinedust: Int {
        shinedustEvents.reduce(0) { $0 + $1.amount }
    }

    private var growthLevel: CGFloat {
        GrowthLevel.level(for: totalShinedust)
    }

    private var growthTier: GrowthLevel.Tier {
        GrowthLevel.Tier.tier(for: totalShinedust)
    }

    // MARK: - Nutrition / Symptom Helpers

    /// Active daily nutrition plan, derived from the current cycle phase
    /// and the user's selected protocol (defaulting to DAO support if no
    /// profile / protocol exists yet). Returns nil only before the user
    /// has noted a state, since cyclePosition isn't available yet.
    private var activeNutritionPlan: DailyNutritionPlan? {
        guard let position = cyclePosition else { return nil }
        let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first
        let proto = profile?.nutritionProtocol ?? .daoSt
        let goal = profile?.wellnessGoal ?? .healthyCycle
        return NutritionContent.dailyPlan(
            for: proto,
            phase: position.phase,
            goal: goal
        )
    }

    /// Time block matching the current hour — drives which card we open
    /// the nutrition page on.
    private var currentTimeBlock: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 6..<12:  return .morning
        case 12..<18: return .afternoon
        default:      return .evening
        }
    }

    private func isNutritionItemCompleted(_ item: NutritionItem) -> Bool {
        todayNutritionLog?.hasCompleted(item.id) ?? false
    }

    private func toggleNutritionItem(_ item: NutritionItem) {
        let log: NutritionLog
        if let existing = todayNutritionLog {
            log = existing
        } else {
            log = NutritionLog(date: .now)
            modelContext.insert(log)
        }
        let wasCompleted = log.hasCompleted(item.id)
        log.toggleItem(item.id)
        try? modelContext.save()
        if !wasCompleted {
            Shinedust.award(.nutritionItem, in: modelContext)
        }
    }

    @Environment(\.modelContext) private var modelContext

    @FocusState private var nameFieldFocused: Bool

    private let stepHaptic = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            if phase.isNoted {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            generatedHeader
                            notedContentStage
                        }
                        .padding(.top, AppTheme.Spacing.md)
                        .padding(.bottom, 160)
                        .frame(minHeight: geo.size.height + 1)
                        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: showNervousSystem)
                    }
                }
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            generatedHeader
                                .padding(.top, AppTheme.Spacing.md)

                            Spacer(minLength: 0)

                            flowerStage
                            storyText

                            Spacer(minLength: 0)

                            VStack(spacing: AppTheme.Spacing.lg) {
                                if phase.isInput, showingIntro {
                                    introStage
                                } else {
                                    inputStage
                                    stepIndicator
                                }
                                footerButton
                            }
                            .padding(.bottom, AppTheme.Spacing.xl)
                        }
                        .frame(minHeight: geo.size.height + 1)
                        .animation(.spring(response: 0.7, dampingFraction: 0.78), value: phase)
                        .animation(.easeInOut(duration: 0.45), value: showingIntro)
                    }
                }
            }

            if phase.isNoted,
               let config = generated?.config {
                VStack(spacing: AppTheme.Spacing.sm) {
                    if let message = toastMessage, reentryStage == nil {
                        Text(message)
                            .font(.system(.footnote, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(Color.appWarmWhite.opacity(0.95))
                                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .id(message)
                    }

                    HStack(spacing: AppTheme.Spacing.sm) {
                        SunWidget(
                            isHidden: reentryStage != nil
                        ) {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                showNutritionPage = true
                            }
                        }

                        MiniFlowerWidget(
                            config: config,
                            holdProgress: $holdProgress,
                            bloomState: $bloomState,
                            flowerHidden: reentryStage != nil,
                            isChannelling: reentryStage == .active,
                            growthLevel: growthLevel,
                            growthTier: growthTier,
                            onPressChange: handleMiniFlowerPress
                        )

                        MoonWidget(
                            isHidden: reentryStage != nil
                        ) {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                showMoonPage = true
                            }
                        }
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xl)
                .animation(.easeInOut(duration: 0.35), value: toastMessage)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    )
                )
            }

            if phase.isNoted,
               let stage = reentryStage,
               let config = generated?.config {
                reentryOverlay(config: config, stage: stage)
                    .transition(.opacity)
            }

            if phase.isNoted, showStatePage {
                statePageOverlay
                    .transition(.opacity)
            }

            if phase.isNoted, showNutritionPage {
                nutritionOverlay
                    .transition(.opacity)
            }

            if phase.isNoted, showSymptomPage {
                symptomOverlay
                    .transition(.opacity)
            }

            if phase.isNoted, showMoonPage {
                moonOverlay
                    .transition(.opacity)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            if !phase.isNoted {
                Button(action: skipToNoted) {
                    HStack(spacing: 3) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 8))
                        Text("skip")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(0.5)
                    }
                    .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.appSoftBrown.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, AppTheme.Spacing.xs)
                .padding(.trailing, AppTheme.Spacing.md)
            }
        }
        .navigationTitle("Auto Flower")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startBudPulse()
            Task { await moonState.load() }
        }
        .onDisappear {
            storyTask?.cancel()
            storyTask = nil
            interactiveTransitionTask?.cancel()
            interactiveTransitionTask = nil
            noteStateTask?.cancel()
            noteStateTask = nil
            toastTask?.cancel()
            toastTask = nil
            miniHoldResetTask?.cancel()
            miniHoldResetTask = nil
            reentryFadeInTask?.cancel()
            reentryFadeInTask = nil
            reentryCloseTask?.cancel()
            reentryCloseTask = nil
        }
        .onChange(of: isHolding) { oldValue, newValue in
            if phase.isInteractive, oldValue, !newValue {
                noteEmotionalState()
                return
            }
            if phase.isNoted, reentryStage == .active, oldValue, !newValue {
                finishReentry()
            }
        }
    }

    // MARK: - Header (only after generation begins)

    @ViewBuilder
    private var generatedHeader: some View {
        if let g = generated, !phase.isInput {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(g.displayName)
                    .font(.custom("SnellRoundhand-Bold", size: 40))
                    .foregroundStyle(g.config.outerColor)
                    .shadow(color: g.config.outerColor.opacity(0.18), radius: 6, y: 2)
                if phase.isBloomedScene {
                    Text(g.flowerName.uppercased())
                        .font(.system(.caption, design: .serif, weight: .light))
                        .tracking(3)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, AppTheme.Spacing.md)
            .transition(.opacity)
        }
    }

    // MARK: - Intro Stage
    //
    // Dedicated intro screen that sits in the same bottom slot as the
    // input questions — so the bud flower above stays pinned in place
    // as the user moves from intro → period → age → name. A "Begin"
    // button below advances the flow.

    @ViewBuilder
    private var introStage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Hormones govern emotional and physical wellbeing and beauty.")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.90))
                Text("Feed your hormones at every stage of your life.")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(Color.appRose)
            }
            .multilineTextAlignment(.center)

            if let profile = savedProfile {
                Button {
                    loadFlower(from: profile)
                } label: {
                    VStack(spacing: 2) {
                        Text("CONTINUE AS")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                        Text(profile.displayName)
                            .font(.custom("SnellRoundhand-Bold", size: 26))
                            .foregroundStyle(Color.appRose)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity.combined(with: .move(edge: .top))
            )
        )
    }

    // MARK: - Flower Stage

    private var flowerStage: some View {
        let config = generated?.config ?? Self.restingConfig
        let showSparkles = phase.isBloomedScene && holdProgress >= 0.88
        // Single canvas size used for both input bud and building flower
        // so the bud is rendered at the exact same dimensions in both
        // phases. The flower grows inside that canvas via scaleEffect,
        // and the outer layout container grows in lockstep.
        let canvasSize: CGFloat = 300
        // 0 while the bud is at resting size, 1 at full bloom.
        let growthRange = max(1 - Self.restingBudProgress, 0.0001)
        let growthProgress: CGFloat = min(
            max((holdProgress - Self.restingBudProgress) / growthRange, 0),
            1
        )
        // Visual size of the flower: 150pt (small bud) → 300pt (full bloom).
        let flowerScale: CGFloat = 0.5 + 0.5 * growthProgress
        // Layout container grows in step with the flower so the bud has
        // the same tight surroundings everywhere (240pt) and the full
        // bloom gets enough room to breathe (360pt).
        let outerSize: CGFloat = 240 + 120 * growthProgress

        return ZStack {
            if phase.isInput {
                // Organic lotus bud during intake — matches the Cycle
                // Bloom winter stage so the resting bud looks like a
                // real closed lotus rather than a smooth circle.
                CycleBloomFlower(composition: intakeBudComposition)
                    .frame(width: canvasSize, height: canvasSize)
                    .scaleEffect(flowerScale * budPulse)
                    .allowsHitTesting(false)
            } else if phase.isBuilding || phase.isComplete {
                // Two-layer bud→bloom crossfade so the flower visibly
                // opens *from its centre*: the closed bud shrinks and
                // fades while the blooming flower grows out from the
                // same centre and fades in. Lotus pads naturally
                // shrink with the bud, and the flower's leaves grow
                // in with the bloom, giving the illusion of the green
                // bud turning into the leaves of the flower.
                let bloomOpacity: Double = Double(
                    min(max((growthProgress - 0.05) * 1.8, 0), 1)
                )
                let bloomLayerScale: CGFloat = 0.20 + 0.80 * growthProgress
                let budOpacity: Double = Double(
                    min(max(1 - growthProgress * 1.9, 0), 1)
                )
                let budLayerScale: CGFloat = max(0.35, 1 - growthProgress * 0.7)
                let intensity = 0.65 + 0.35 * growthProgress

                ZStack {
                    // Bud layer — visible at start, shrinks toward the
                    // centre and fades out as the flower opens.
                    CycleBloomFlower(composition: buildingBudComposition)
                        .frame(width: canvasSize, height: canvasSize)
                        .scaleEffect(budLayerScale)
                        .opacity(budOpacity)

                    // Bloom layer — appears from the centre and grows
                    // outward, season morphing from spring blossom to
                    // a full flourishing flower.
                    CycleBloomFlower(composition: buildingComposition)
                        .frame(width: canvasSize, height: canvasSize)
                        .scaleEffect(bloomLayerScale)
                        .opacity(bloomOpacity)
                }
                .saturation(intensity)
                .scaleEffect(flowerScale)
                .allowsHitTesting(false)
            } else {
                FlowerBloomCanvas(
                    outerDesign: config.outerDesign,
                    innerDesign: config.innerDesign,
                    stamenDesign: config.stamenDesign,
                    centerDesign: config.centerDesign,
                    outerColor: config.outerColor,
                    innerColor: config.innerColor,
                    stamenColor: config.stamenColor,
                    centerColor: config.centerColor,
                    geometry: config.geometry,
                    isHolding: $isHolding,
                    holdProgress: $holdProgress,
                    bloomState: $bloomState,
                    showBackground: false,
                    interactive: phase.isInteractive
                )
                .frame(width: canvasSize, height: canvasSize)
            }

            if showSparkles {
                SparkleEmitter()
                    .frame(width: outerSize, height: outerSize)
                    .allowsHitTesting(false)
                    .transition(.opacity.animation(.easeInOut(duration: 1.2)))
            }
        }
        .frame(width: outerSize, height: outerSize)
        .padding(.vertical, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.6), value: showSparkles)
        .contentShape(Rectangle())
        .onTapGesture {
            if phase.isCaptured {
                beginShrinkToNoted()
            }
        }
    }

    /// Composition used for the intake bud — forces the menstrual /
    /// winter season so CycleBloomFlower renders its layered lotus
    /// bud (closed petals + green leaves) regardless of what the user
    /// has typed in so far.
    private var intakeBudComposition: CycleBloomView.Composition {
        let name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Bud"
            : nameInput.capitalized
        let base = CycleBloomView.Composition.build(
            displayName: name,
            ageSelection: ageSelection,
            periodDate: .now
        )
        return base.season == .winter ? base : base.withSeason(.winter)
    }

    /// Composition for the *blooming* layer during auto-generation —
    /// season morphs spring → summer as the bud opens (we let winter
    /// be the bud-layer's job below, so the bloom layer starts at
    /// spring and grows into a full flourishing summer flower). The
    /// cycle-phase colour palette stays locked across all seasons so
    /// the single picked colour only intensifies, never switches.
    private var buildingComposition: CycleBloomView.Composition {
        let base = baseBuildingComposition
        let season: InnerSeason = holdProgress < 0.65 ? .spring : .summer
        return base.season == season ? base : base.withSeasonKeepingTint(season)
    }

    /// Composition for the *bud* layer during auto-generation —
    /// always winter (closed lotus bud + lotus pads), with the same
    /// locked-in cycle-phase tint as the bloom layer so the colour
    /// stays consistent as the bud fades out into the flower.
    private var buildingBudComposition: CycleBloomView.Composition {
        let base = baseBuildingComposition
        return base.season == .winter ? base : base.withSeasonKeepingTint(.winter)
    }

    /// Shared base composition for the building layers — same seeded
    /// petal type, same cycle-phase colour palette, same flower
    /// identity. Each layer overlays its own season on top.
    private var baseBuildingComposition: CycleBloomView.Composition {
        let name = (generated?.displayName).flatMap {
            $0.isEmpty ? nil : $0
        } ?? (nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              ? "Bud" : nameInput.capitalized)
        return CycleBloomView.Composition.build(
            displayName: name,
            ageSelection: ageSelection,
            periodDate: periodDate
        )
    }

    /// Story snippets shown *underneath* the flower while it builds — soft
    /// serif italic, no chrome, fades between steps.
    @ViewBuilder
    private var storyText: some View {
        if case .building(let step) = phase {
            let script = generated.map { storyScript(for: $0) } ?? []
            let text = script.indices.contains(step) ? script[step].text : ""

            Text(text)
                .font(.system(.title3, design: .serif))
                .italic()
                .fontWeight(.medium)
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .frame(maxWidth: 320, minHeight: 60)
                .id("story-\(step)")
                .transition(.opacity.animation(.easeInOut(duration: 0.6)))
        }
    }

    // MARK: - Noted Content Stage
    //
    // When the user has pressed & held and released, the big flower is
    // replaced by a calm daily-guidance layout: phase header (inner season +
    // date + phase name + greeting) and a borderless version of the
    // "Today's Guidance" card — the same data the main Today tab shows,
    // but computed from the *input* period date so it links to the moon
    // this flower was born under. The mini flower widget lives in an
    // overlay at the bottom of the screen.

    @ViewBuilder
    private var notedContentStage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            notedPhaseHeader
            notedGuidanceSection
        }
        .transition(.opacity)
    }

    /// Editorial-styled phase header used only on the noted screen — kept
    /// inline (rather than reusing the rounded `PhaseHeaderView` that the
    /// Today tab uses) so this surface can read more like a luxury
    /// skincare brand: thin serif display, uppercase metadata with
    /// tracking, restrained colour use.
    @ViewBuilder
    private var notedPhaseHeader: some View {
        if let position = cyclePosition, let g = dailyGuidance {
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(g.greeting.uppercased())
                    .font(.system(.caption, design: .serif, weight: .light))
                    .tracking(3)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))

                HStack(spacing: AppTheme.Spacing.sm) {
                    PhaseIcon(phase: position.phase, size: 26)
                    Text(position.phase.innerSeason)
                        .font(.system(size: 34, weight: .light, design: .serif))
                        .tracking(0.5)
                        .foregroundStyle(Color.appSoftBrown)
                }

                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(.caption, design: .serif, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))

                HStack(spacing: 6) {
                    Capsule()
                        .fill(position.phase.accentColor.opacity(0.4))
                        .frame(width: 18, height: 1)
                    Text("\(position.phase.displayName.uppercased()) PHASE   ·   DAY \(position.dayInCycle) / \(Self.defaultCycleLength)")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .tracking(2)
                        .foregroundStyle(position.phase.accentColor.opacity(0.85))
                    Capsule()
                        .fill(position.phase.accentColor.opacity(0.4))
                        .frame(width: 18, height: 1)
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
    }

    /// Editorial styling of the daily guidance section: clean and box-
    /// less — heading and body painted in the flower's outer colour so
    /// it visually rhymes with the user's name at the top of the page.
    @ViewBuilder
    private var notedGuidanceSection: some View {
        if let g = dailyGuidance {
            let accent = generated?.config.outerColor ?? Color.appRose

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("TODAY'S GUIDANCE")
                    .font(.system(size: 11, weight: .medium, design: .default))
                    .tracking(3.5)
                    .foregroundStyle(accent)

                Text(g.protectMessage)
                    .font(.system(.title3, design: .serif, weight: .regular))
                    .italic()
                    .lineSpacing(5)
                    .foregroundStyle(accent.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "clock")
                        .foregroundStyle(accent.opacity(0.55))
                        .font(.system(size: 10))
                    Text(g.decisionTiming.uppercased())
                        .font(.system(size: 10, weight: .light, design: .default))
                        .tracking(2)
                        .foregroundStyle(accent.opacity(0.7))
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .id(g.phase)  // re-render colour cleanly when phase swaps
        }
    }

    // MARK: - Re-entry Overlay
    //
    // Full-screen white layer shown when the user presses the mini flower
    // in `.noted`. The big flower is re-rendered centred in the overlay
    // (sharing the same bloom bindings as the mini, so both move in
    // lockstep), energy sparkles stream from the dot below toward it,
    // and on release a short comparison message + subtle history graph
    // take over before the overlay fades back out.

    @ViewBuilder
    private func reentryOverlay(config: AutoFlowerConfig, stage: ReentryStage) -> some View {
        ZStack {
            Color.white
                .opacity(stage == .closing ? 0 : 1)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.55), value: stage)

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer(minLength: 0)

                ZStack {
                    GrowthOverlay(
                        level: growthLevel,
                        tier: growthTier,
                        size: 280,
                        accentColor: config.outerColor
                    )
                    .frame(width: 360, height: 360)

                    FlowerBloomCanvas(
                        outerDesign: config.outerDesign,
                        innerDesign: config.innerDesign,
                        stamenDesign: config.stamenDesign,
                        centerDesign: config.centerDesign,
                        outerColor: config.outerColor,
                        innerColor: config.innerColor,
                        stamenColor: config.stamenColor,
                        centerColor: config.centerColor,
                        geometry: config.geometry,
                        isHolding: $isHolding,
                        holdProgress: $holdProgress,
                        bloomState: $bloomState,
                        showBackground: false,
                        interactive: false
                    )
                    .frame(width: 280, height: 280)
                    .saturation(1.0 + Double(growthLevel) * 0.35)
                }
                .scaleEffect(stage == .closing ? 0.25 : 1.0)
                .opacity(stage == .closing ? 0 : 1)
                .animation(.easeInOut(duration: 0.7), value: stage)

                if stage == .released, let message = reentryCompareMessage {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Text(currentDisplayState.displayName)
                            .font(.system(.title3, design: .serif).italic())
                            .fontWeight(.medium)
                            .foregroundStyle(currentDisplayState.color)

                        Text(message)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundStyle(Color.appSoftBrown.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        StateHistoryGraph(entries: stateHistory)
                            .frame(height: 56)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.sm)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else if stage == .active {
                    Text("Hold the light to honour how you feel")
                        .font(.system(.footnote, design: .serif).italic())
                        .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                        .transition(.opacity)
                }

                Spacer(minLength: 0)

                // Leave room for the halo that stays pinned at the bottom.
                Color.clear.frame(height: 180)
            }

            if stage == .active {
                EnergyStream(isActive: isHolding)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: stage == .released)
    }

    // MARK: - State Page Overlay
    //
    // Read-only progression view shown on a quick tap of the mini
    // flower. Lists recent entries with timestamps alongside the subtle
    // history graph. Tapping anywhere dismisses.

    private var statePageOverlay: some View {
        let config = generated?.config ?? Self.restingConfig
        let g = generated
        let current = notedBloomState ?? bloomState
        let recent = Array(stateHistory.prefix(12).reversed())

        return ZStack {
            Color.appCream
                .opacity(0.98)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismissStatePage() }

            VStack(spacing: AppTheme.Spacing.md) {
                Spacer(minLength: 0)

                if let g {
                    Text(g.displayName)
                        .font(.custom("SnellRoundhand-Bold", size: 28))
                        .foregroundStyle(g.config.outerColor)
                        .shadow(color: g.config.outerColor.opacity(0.18), radius: 5, y: 2)
                }

                ZStack {
                    StateRingDots(entries: recent, radius: 178)
                        .frame(width: 360, height: 360)
                        .opacity(0.95)

                    FlowerBloomCanvas(
                        outerDesign: config.outerDesign,
                        innerDesign: config.innerDesign,
                        stamenDesign: config.stamenDesign,
                        centerDesign: config.centerDesign,
                        outerColor: config.outerColor,
                        innerColor: config.innerColor,
                        stamenColor: config.stamenColor,
                        centerColor: config.centerColor,
                        geometry: config.geometry,
                        isHolding: .constant(false),
                        holdProgress: .constant(1.0),
                        bloomState: .constant(.flourishing),
                        showBackground: false,
                        interactive: false
                    )
                    .frame(width: 300, height: 300)
                    .saturation(1.0 + Double(growthLevel) * 0.35)
                    .rotationEffect(.degrees(flowerRotation + stateFlowerDragRotation))
                    .scaleEffect(statePageZoom)
                    .onAppear { startStatePageZoom() }
                    .onDisappear { resetStatePageZoom() }

                    GrowthOverlay(
                        level: growthLevel,
                        tier: growthTier,
                        size: 300,
                        accentColor: config.outerColor
                    )
                    .frame(width: 360, height: 360)
                    .scaleEffect(statePageZoom)
                }
                .contentShape(Circle())
                .gesture(stateFlowerSwipeGesture)

                ZStack {
                    Group {
                        switch notedCardIndex {
                        case 0:
                            compactStateRibbon(current: current)
                        case 1:
                            patternCard
                        case 2:
                            phaseDataCard
                        case 3:
                            cycleCalendarCard
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(notedCardIndex)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(0..<Self.stateCardCount, id: \.self) { i in
                        Capsule()
                            .fill(notedCardIndex == i
                                  ? (generated?.config.outerColor ?? Color.appRose)
                                  : Color.appSoftBrown.opacity(0.2))
                            .frame(width: notedCardIndex == i ? 18 : 6, height: 4)
                    }
                }

                Spacer(minLength: 0)

                Text("TAP TO CLOSE   ·   PRESS & HOLD THE FLOWER TO NOTE A NEW STATE")
                    .font(.system(size: 9, weight: .light, design: .default))
                    .tracking(1.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppTheme.Spacing.xl)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }

    /// Compact data ribbon stitched under the flower: current state +
    /// shinedust drops + growth tier, all in tracked editorial captions
    /// so the data fits in a single line and reads as part of the page.
    @ViewBuilder
    private func compactStateRibbon(current: BloomState) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: 2) {
                Text("STATE")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                Text(current.displayName.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.8)
                    .foregroundStyle(current.color)
            }

            divider()

            VStack(spacing: 2) {
                Text("SHINEDUST")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                Text("\(totalShinedust)")
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)
            }

            divider()

            VStack(spacing: 2) {
                Text("TIER")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                Text(growthTier.displayName.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.8)
                    .foregroundStyle(Color(red: 0.78, green: 0.55, blue: 0.30))
            }

            divider()

            VStack(spacing: 2) {
                Text("ENTRIES")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                Text("\(stateHistory.count)")
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)
            }
        }
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color.appSoftBrown.opacity(0.18))
            .frame(width: 0.5, height: 22)
    }

    // MARK: - State Page Card 1: Pattern Analysis

    @ViewBuilder
    private var patternCard: some View {
        let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first
        let cycleLength = profile?.cycleLength ?? Self.defaultCycleLength
        let periodLength = profile?.periodLength ?? Self.defaultPeriodLength
        let lastPeriod = profile?.lastPeriodStartDate ?? periodDate
        let analysis = PatternAnalysisEngine.analyze(
            entries: symptomEntries,
            cycleLength: cycleLength,
            periodLength: periodLength,
            lastPeriodStartDate: lastPeriod
        )

        PatternInsightsView(analysis: analysis)
            .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - State Page Card 2: Phase Data
    //
    // Custom phase info card — same content as PhaseInfoCard but with
    // Nourishment removed (so we don't duplicate the dedicated nutrition
    // page) and the surrounding chrome lightened to match the editorial
    // typography of the rest of the noted screen.

    @ViewBuilder
    private var phaseDataCard: some View {
        if let position = cyclePosition {
            let desc = PhaseDescriptions.description(for: position.phase)
            let accent = position.phase.accentColor

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    PhaseIcon(phase: desc.phase, size: 26)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(desc.title.uppercased())
                            .font(.system(size: 11, weight: .medium))
                            .tracking(2.5)
                            .foregroundStyle(accent.opacity(0.85))
                        Text(desc.innerSeason)
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundStyle(Color.appSoftBrown)
                    }
                }

                Text(desc.overview)
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .lineSpacing(3)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView {
                    VStack(spacing: 0) {
                        phaseDataRow(label: "HORMONES",   icon: "waveform.path", body: desc.hormoneHighlight, accent: accent)
                        phaseDataRow(label: "SUPERPOWER", icon: "star.fill",     body: desc.superpower,       accent: accent)
                        phaseDataRow(label: "MOVEMENT",   icon: "figure.walk",   body: desc.movement,         accent: accent)
                        phaseDataRow(label: "DETOX",      icon: "leaf.fill",     body: desc.detox,            accent: accent)
                    }
                }
                .frame(maxHeight: 280)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    @ViewBuilder
    private func phaseDataRow(label: String, icon: String, body: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(accent)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(accent.opacity(0.85))
            }
            Text(body)
                .font(.system(.subheadline, design: .serif, weight: .light))
                .lineSpacing(3)
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Rectangle()
                .fill(Color.appSoftBrown.opacity(0.08))
                .frame(height: 0.5)
                .padding(.top, AppTheme.Spacing.xs)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: - State Page Card 3: Cycle Calendar
    //
    // Read-only embed of the existing PeriodCalendarView with no-op
    // mutation callbacks — the user manages cycle data on the main
    // Insights tab; this is a glance.

    @ViewBuilder
    private var cycleCalendarCard: some View {
        let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first
        let cycleLength = profile?.cycleLength ?? Self.defaultCycleLength
        let periodLength = profile?.periodLength ?? Self.defaultPeriodLength
        let lastPeriod = profile?.lastPeriodStartDate ?? periodDate
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: cycleLength,
            periodLength: periodLength
        )

        ScrollView {
            PeriodCalendarView(
                cycleLogs: cycleLogs,
                cycleLength: cycleLength,
                periodLength: periodLength,
                expectedNextPeriodStart: nil,
                delayDays: 0,
                lastPeriodStartDate: lastPeriod,
                phaseBoundaries: boundaries,
                onAddPeriod: { _ in },
                onExtendPeriod: { _ in },
                onRemovePeriod: { _ in },
                onAddOvulation: { _ in },
                onRemoveOvulation: { _ in },
                manualOvulationDates: [],
                canExtendPeriod: { _ in false },
                canRemovePeriod: { _ in false },
                isManualOvulation: { _ in false }
            )
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .frame(maxHeight: 360)
    }

    private func dismissStatePage() {
        withAnimation(.easeInOut(duration: 0.35)) {
            showStatePage = false
        }
    }

    /// Slow expansion + zoom-in. The flower opens to ~95% then drifts
    /// inward to ~107% over several seconds, creating the feeling of
    /// leaning in closer.
    private func startStatePageZoom() {
        statePageZoom = 0.85
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            statePageZoom = 1.0
        }
        withAnimation(.easeInOut(duration: 9.0).delay(1.0)) {
            statePageZoom = 1.07
        }
    }

    private func resetStatePageZoom() {
        statePageZoom = 0.85
    }

    // MARK: - Nutrition Overlay
    //
    // Sun-tap entry into a focused nutrition page. By default we show
    // only the time block matching the current hour — supplements,
    // rituals, and foods rendered as three distinct compact sections on
    // a single card. Toggling "view full protocol" switches the swipe
    // pager from a single card to all three time blocks. A symptoms
    // button at the bottom fades into the how-do-you-feel overlay.

    private var nutritionOverlay: some View {
        let plan = activeNutritionPlan
        let cards = nutritionCards(for: plan)
        let phaseColor = cyclePosition?.phase.accentColor ?? .appRose

        return ZStack(alignment: .top) {
            Color.appCream.opacity(0.98)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismissNutritionPage() }

            VStack(spacing: AppTheme.Spacing.md) {
                nutritionHeader(plan: plan, accent: phaseColor)
                    .padding(.top, AppTheme.Spacing.xxl)

                if cards.isEmpty {
                    Text("Note your state to see today's nourishment.")
                        .font(.system(.footnote, design: .serif).italic())
                        .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .frame(maxHeight: .infinity)
                } else {
                    TabView(selection: $selectedNutritionCardId) {
                        ForEach(cards) { card in
                            NutritionCategoryCard(
                                card: card,
                                accent: phaseColor,
                                isCompleted: { isNutritionItemCompleted($0) },
                                onToggle: { toggleNutritionItem($0) }
                            )
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .tag(card.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(maxHeight: .infinity)
                }

                viewFullProtocolToggle(accent: phaseColor)

                symptomsButton(accent: phaseColor)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }

            HStack {
                Spacer()
                Button(action: dismissNutritionPage) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                        .padding(AppTheme.Spacing.md)
                }
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .onAppear { ensureSelectedNutritionCard(plan: plan) }
        .onChange(of: showFullProtocol) { _, _ in ensureSelectedNutritionCard(plan: plan) }
    }

    /// Closes the nutrition overlay (back to the main noted screen).
    private func dismissNutritionPage() {
        withAnimation(.easeInOut(duration: 0.35)) {
            showNutritionPage = false
            showFullProtocol = false
        }
    }

    /// Closes the symptom overlay (back to the nutrition overlay below).
    private func dismissSymptomPage() {
        withAnimation(.easeInOut(duration: 0.35)) {
            showSymptomPage = false
            symptomQuery = ""
            revealedSymptom = nil
        }
    }

    // MARK: - Moon Overlay
    //
    // Tapping the moon widget fades the cream of the noted screen into a
    // moonlit night sky. We render the same MoonView the main app uses
    // (so the phase image and glow are exactly as elsewhere), then show
    // the MoonWisdomCard with today's "advised / avoid / quote"
    // guidance keyed to the lunar phase. Tap-to-dismiss like the other
    // overlays.

    private var moonOverlay: some View {
        let phase = LunarPhase.from(moonPhase: moonState.moonPhase)
        let wisdom = MoonWisdomContent.wisdom(for: moonState.moonPhase)

        return ZStack(alignment: .top) {
            SkyBackgroundView()
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismissMoonPage() }

            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text("TONIGHT'S MOON")
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .tracking(3.5)
                            .foregroundStyle(Color(red: 0.92, green: 0.78, blue: 0.55).opacity(0.85))
                        Text(phase.displayName)
                            .font(.system(size: 30, weight: .light, design: .serif))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .padding(.top, AppTheme.Spacing.xxl)

                    MoonView(moonState: moonState)
                        .frame(height: 240)

                    MoonWisdomCard(wisdom: wisdom)
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { dismissMoonPage() }
            }

            HStack {
                Spacer()
                Button(action: dismissMoonPage) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(AppTheme.Spacing.md)
                }
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }

    /// Closes the moon overlay (back to the main noted screen).
    private func dismissMoonPage() {
        withAnimation(.easeInOut(duration: 0.45)) {
            showMoonPage = false
        }
    }

    @State private var selectedNutritionCardId: String = ""

    /// Builds one card per (time block × category) — supplements / rituals
    /// / foods. With "view full protocol" off, only the current time
    /// block's three cards are surfaced; with it on, all nine cards in
    /// chronological order across the day.
    private func nutritionCards(for plan: DailyNutritionPlan?) -> [NutritionCardModel] {
        guard let plan else { return [] }
        let blocks: [TimeBlock] = showFullProtocol
            ? plan.timeBlocks
            : [plan.timeBlocks.first(where: { $0.timeOfDay == currentTimeBlock }) ?? plan.morning]
        return blocks.flatMap { block in
            [
                NutritionCardModel(block: block, category: .supplement, items: block.supplements),
                NutritionCardModel(block: block, category: .ritual,     items: block.rituals),
                NutritionCardModel(block: block, category: .food,       items: block.foods)
            ]
        }
    }

    /// Resets the selected card whenever the card set changes, picking
    /// the supplements card of the current time block as the default.
    private func ensureSelectedNutritionCard(plan: DailyNutritionPlan?) {
        let cards = nutritionCards(for: plan)
        guard !cards.isEmpty else { return }
        if !cards.contains(where: { $0.id == selectedNutritionCardId }) {
            let preferred = cards.first {
                $0.block.timeOfDay == currentTimeBlock && $0.category == .supplement
            } ?? cards.first
            selectedNutritionCardId = preferred?.id ?? ""
        }
    }

    @ViewBuilder
    private func nutritionHeader(plan: DailyNutritionPlan?, accent: Color) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text("NOURISHMENT")
                .font(.system(size: 11, weight: .medium, design: .default))
                .tracking(3.5)
                .foregroundStyle(accent.opacity(0.85))

            if let phase = cyclePosition?.phase {
                Text(phase.innerSeason)
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .tracking(0.4)
                    .foregroundStyle(Color.appSoftBrown)
            }

            if let plan {
                Text(plan.todayFocus)
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, 2)
            }
        }
    }

    @ViewBuilder
    private func viewFullProtocolToggle(accent: Color) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.35)) {
                showFullProtocol.toggle()
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: showFullProtocol ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .medium))
                Text(showFullProtocol ? "HIDE FULL PROTOCOL" : "VIEW FULL PROTOCOL")
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .tracking(2)
            }
            .foregroundStyle(accent.opacity(0.85))
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(accent.opacity(0.35), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func symptomsButton(accent: Color) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.45)) {
                showSymptomPage = true
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 13, weight: .light))
                Text("IMPROVE THIS")
                    .font(.system(size: 11, weight: .medium, design: .default))
                    .tracking(3)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .fill(accent.opacity(0.85))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Symptom Overlay
    //
    // Free-text input + suggestion list of the existing Symptom enum.
    // Picking a suggestion reveals a wisdom card (what it means / why
    // it matters / what might help) keyed by the current cycle phase.

    private var symptomOverlay: some View {
        let phase = cyclePosition?.phase ?? .follicular
        let accent = phase.accentColor
        let match = matchedSymptom

        return ZStack(alignment: .top) {
            Color.appCream.opacity(0.98)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismissSymptomPage() }

            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("IMPROVE THIS")
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .tracking(3.5)
                        .foregroundStyle(accent.opacity(0.85))
                    Text(revealedSymptom == nil
                         ? "type what's moving in you"
                         : "in your \(phase.innerSeason.lowercased())")
                        .font(.system(.footnote, design: .serif, weight: .light))
                        .italic()
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                }
                .padding(.top, AppTheme.Spacing.xxl)

                if let symptom = revealedSymptom {
                    creativeWisdomReveal(
                        wisdom: PeriodSymptomWisdom.wisdom(for: symptom, phase: phase),
                        phase: phase,
                        accent: accent
                    )
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    symptomInputField(match: match, phase: phase, accent: accent)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .transition(.opacity)
                }

                Spacer(minLength: 0)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)

            HStack {
                Button(action: dismissSymptomPage) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                        .padding(AppTheme.Spacing.md)
                }
                Spacer()
                if revealedSymptom != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            revealedSymptom = nil
                            symptomQuery = ""
                        }
                    } label: {
                        Text("ANOTHER")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(accent.opacity(0.75))
                            .padding(AppTheme.Spacing.md)
                    }
                }
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }

    /// Best-matching symptom for the current query. Tries exact display
    /// name first, then a substring contains.
    private var matchedSymptom: Symptom? {
        let trimmed = symptomQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }
        if let exact = Symptom.allCases.first(where: { $0.displayName.lowercased() == trimmed }) {
            return exact
        }
        return Symptom.allCases.first { $0.displayName.lowercased().contains(trimmed) }
    }

    /// Single-field input with a live "matches: …" hint. Submitting the
    /// field reveals the wisdom for the matched symptom.
    @ViewBuilder
    private func symptomInputField(match: Symptom?, phase: CyclePhase, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(accent.opacity(0.5))
                TextField("a feeling, a sensation, a tension…", text: $symptomQuery)
                    .font(.system(.title3, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { confirmSymptom(match) }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(accent.opacity(0.4))
                    .frame(height: 0.5)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                if let match {
                    Text(match.emoji)
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MATCHES")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(accent.opacity(0.6))
                        Text(match.displayName)
                            .font(.system(.subheadline, design: .serif, weight: .light))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    }
                    Spacer()
                    Button {
                        confirmSymptom(match)
                    } label: {
                        HStack(spacing: 6) {
                            Text("REVEAL")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(accent.opacity(0.85)))
                    }
                    .buttonStyle(.plain)
                } else if !symptomQuery.isEmpty {
                    Text("no match yet — try cramps, fatigue, bloating…")
                        .font(.system(.caption, design: .serif, weight: .light))
                        .italic()
                        .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                } else {
                    Text("e.g. cramps · fatigue · bloating · headache · cravings")
                        .font(.system(.caption, design: .serif, weight: .light))
                        .italic()
                        .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                }
            }
            .frame(minHeight: 38)
            .animation(.easeInOut(duration: 0.25), value: match)
        }
    }

    private func confirmSymptom(_ symptom: Symptom?) {
        guard let symptom else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            revealedSymptom = symptom
        }
    }

    /// Phase-themed dramatic reveal of the wisdom for a confirmed symptom.
    /// Symptom name in cursive (matching the flower header), phase-tinted
    /// "what it means" panel, "what might help" as pill chips, and warm
    /// remedy as an italic accented callout.
    @ViewBuilder
    private func creativeWisdomReveal(
        wisdom: SymptomWisdom,
        phase: CyclePhase,
        accent: Color
    ) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(wisdom.symptom.emoji)
                    .font(.system(size: 38))
                Text(wisdom.symptom.displayName)
                    .font(.custom("SnellRoundhand-Bold", size: 38))
                    .foregroundStyle(accent)
                    .shadow(color: accent.opacity(0.18), radius: 5, y: 2)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(accent.opacity(0.6))
                        .frame(width: 18, height: 1)
                    Text("WHY IT'S HAPPENING NOW")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(accent.opacity(0.85))
                }
                Text(wisdom.whatItMeans)
                    .font(.system(.body, design: .serif, weight: .light))
                    .italic()
                    .lineSpacing(4)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(0.08))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(accent.opacity(0.6))
                        .frame(width: 18, height: 1)
                    Text("WHAT CAN BE DONE")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(accent.opacity(0.85))
                }

                FlowLayout(spacing: 8) {
                    ForEach(wisdom.whatHelps, id: \.self) { tip in
                        Text(tip)
                            .font(.system(.footnote, design: .serif, weight: .light))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.92))
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.appWarmWhite.opacity(0.9))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(accent.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(accent.opacity(0.7))
                    .padding(.top, 3)
                Text(wisdom.warmRemedy)
                    .font(.system(.subheadline, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accent.opacity(0.6))
                    .frame(width: 2)
            }
            .background(accent.opacity(0.04))
        }
    }

    // MARK: - Growth Section (in state page)
    //
    // Shows the current growth tier, total shinedust collected, progress
    // toward the next milestone, and a ledger of recent earning events.

    @ViewBuilder
    private func growthSection(recent: [ShinedustEvent]) -> some View {
        let tier = growthTier
        let total = totalShinedust
        let floor = tier.floor
        let next = tier.nextThreshold
        let progress: CGFloat = {
            guard let next else { return 1.0 }
            let span = max(CGFloat(next - floor), 1)
            return min(max((CGFloat(total) - CGFloat(floor)) / span, 0), 1)
        }()

        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Your garden")
                    .warmTitle()
                Text("each act of care makes the flower more magical")
                    .captionStyle()
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppTheme.Spacing.lg)

            VStack(spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(red: 1.0, green: 0.78, blue: 0.42))
                    Text(tier.displayName)
                        .font(.system(.title3, design: .serif).italic())
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appSoftBrown)
                    Spacer()
                    Text("\(total) shinedust")
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.appSoftBrown.opacity(0.12))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.82, blue: 0.55),
                                        Color(red: 1.0, green: 0.92, blue: 0.72)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, AppTheme.Spacing.lg)

                if let next {
                    Text("\(max(next - total, 0)) more until \(GrowthLevel.Tier(rawValue: tier.rawValue + 1)?.displayName ?? "the next tier")")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                } else {
                    Text("you've reached the magical tier — the flower keeps growing forever")
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }

            if recent.isEmpty {
                Text("No drops yet — complete a breath practice, tick a nourishment item, or log a day to earn your first.")
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(recent) { event in
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: event.source.iconName)
                                .foregroundStyle(event.source.accentColor)
                                .frame(width: 18)
                            Text(event.source.displayName)
                                .font(.system(.subheadline, design: .serif))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                            Spacer()
                            Text("+\(event.amount)")
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(red: 0.82, green: 0.60, blue: 0.30))
                            Text(Self.relativeTimeString(from: event.timestamp, to: .now))
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                }
            }
        }
    }

    // MARK: - Input Stage (floating, card-less)

    @ViewBuilder
    private var inputStage: some View {
        switch phase {
        case .input:
            Group {
                switch inputStep {
                case 0: periodFloating
                case 1: ageFloating
                case 2: nameFloating
                default: EmptyView()
                }
            }
            .id("input-\(inputStep)")
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity.combined(with: .move(edge: .top))
                )
            )
        case .building:
            EmptyView()
        case .complete:
            if let g = generated {
                CompleteArchetypeCard(archetype: g.archetype)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
            }
        case .interactive:
            interactivePrompt
                .transition(.opacity.animation(.easeInOut(duration: 1.0)))
        case .captured:
            interactivePrompt
                .transition(.opacity.animation(.easeInOut(duration: 0.5)))
        case .noted:
            EmptyView()
        }
    }

    // MARK: - Interactive Prompt
    //
    // Same live badge pattern as the FlowerBloom lab: while the finger is
    // on the flower the label tracks the closest BloomState in real time,
    // and once the user lets go the snapped state stays visible. We also
    // show a soft hint under the label so the user knows what to do next.

    /// The state to display in the badge: while holding we track the
    /// nearest bloom rung live; once released or in `.captured` we show
    /// the snapped value.
    private var currentDisplayState: BloomState {
        isHolding ? BloomState.closest(to: holdProgress) : bloomState
    }

    @ViewBuilder
    private var interactivePrompt: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if isHolding || phase.isCaptured {
                bloomStateBadge
                    .transition(.opacity)
            } else {
                Text("Press & hold your flower to honour how you feel")
                    .font(.system(.title3, design: .serif))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }

            if phase.isCaptured {
                Text("Tap your flower to continue")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .frame(maxWidth: 320)
        .animation(.easeInOut(duration: 0.35), value: isHolding)
        .animation(.easeInOut(duration: 0.35), value: currentDisplayState)
        .animation(.easeInOut(duration: 0.35), value: phase)
    }

    /// Matches the FlowerBloom lab badge: icon + display name in the
    /// state's accent color, with the emotional label underneath.
    private var bloomStateBadge: some View {
        let state = currentDisplayState
        return VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: state.icon)
                    .font(.system(.subheadline, weight: .medium))
                Text(state.displayName)
                    .font(.system(.title3, design: .serif).italic())
                    .fontWeight(.medium)
            }
            .foregroundStyle(state.color)

            Text(state.emotionalLabel)
                .font(.system(.footnote, design: .serif).italic())
                .foregroundStyle(Color.appSoftBrown.opacity(0.55))
        }
    }

    // MARK: - Period (floating)

    private var periodFloating: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("When did your moon last bleed?")
                .font(.system(.title3, design: .serif))
                .italic()
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .multilineTextAlignment(.center)

            VStack(spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.xl) {
                    softChoice("yes", isSelected: hasPeriod) {
                        withAnimation(.easeInOut(duration: 0.25)) { hasPeriod = true }
                    }
                    softChoice("no", isSelected: !hasPeriod) {
                        withAnimation(.easeInOut(duration: 0.25)) { hasPeriod = false }
                    }
                }

                if hasPeriod {
                    DatePicker(
                        "Last period date",
                        selection: $periodDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.appRose)
                    .transition(.opacity)
                }
            }
        }
    }

    private func softChoice(_ text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(text)
                    .font(.system(.title3, design: .serif))
                    .italic()
                    .foregroundStyle(isSelected ? Color.appRose : Color.appSoftBrown.opacity(0.5))
                Capsule()
                    .fill(isSelected ? Color.appRose : Color.clear)
                    .frame(width: 28, height: 2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Age (floating)

    private var ageFloating: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("How many seasons have you walked?")
                .font(.system(.title3, design: .serif))
                .italic()
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .multilineTextAlignment(.center)

            VStack(spacing: AppTheme.Spacing.sm) {
                Menu {
                    Picker("Age", selection: $ageSelection) {
                        ForEach(Self.ageRange, id: \.self) { age in
                            Text("\(age) years").tag(age)
                        }
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("\(ageSelection) years")
                            .font(.system(.title2, design: .serif).italic())
                            .foregroundStyle(Color.appSoftBrown)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, 6)
                    .overlay(alignment: .bottom) {
                        Capsule()
                            .fill(Color.appRose.opacity(0.4))
                            .frame(height: 1)
                    }
                }
                .tint(Color.appRose)

                Text(phaseOfLifeHint ?? " ")
                    .font(.system(.footnote, design: .serif))
                    .italic()
                    .foregroundStyle(Color.appRose.opacity(0.85))
                    .opacity(phaseOfLifeHint == nil ? 0 : 1)
                    .frame(height: 20)
                    .animation(.easeInOut(duration: 0.25), value: phaseOfLifeHint)
            }
        }
    }

    private static let ageRange: ClosedRange<Int> = 10...80

    /// Soft acknowledgement when the user is outside her bleeding years.
    private var phaseOfLifeHint: String? {
        let n = ageSelection
        if n < 13 { return "Maiden \u{2014} your bleed has yet to come" }
        if n >= 50 { return "Wise woman \u{2014} beyond the bleed" }
        return nil
    }

    // MARK: - Name (floating)

    private var nameFloating: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("What name shall we whisper?")
                .font(.system(.title3, design: .serif))
                .italic()
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .multilineTextAlignment(.center)

            TextField(
                "",
                text: $nameInput,
                prompt: Text("your name")
                    .font(.system(.title2, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.35))
            )
            .font(.system(.title2, design: .serif).italic())
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.appSoftBrown)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($nameFieldFocused)
            .frame(maxWidth: 240)
            .padding(.bottom, 6)
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(Color.appRose.opacity(0.4))
                    .frame(height: 1)
            }
            .submitLabel(.done)
            .onSubmit(handleKeyboardSubmit)
            .toolbar { keyboardSubmitToolbar }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                nameFieldFocused = true
            }
        }
    }

    // MARK: - Keyboard Toolbar (Continue / Express)

    @ToolbarContentBuilder
    private var keyboardSubmitToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button(action: handleKeyboardSubmit) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(inputStep < Self.totalInputSteps - 1 ? "Continue" : "Express")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    Image(systemName: inputStep < Self.totalInputSteps - 1
                          ? "arrow.right"
                          : "wand.and.stars")
                }
                .foregroundStyle(currentStepValid ? Color.appRose : Color.appSoftBrown.opacity(0.4))
            }
            .disabled(!currentStepValid)
        }
    }

    /// Called from the keyboard's Continue / Express button and from the
    /// name field's return key — advances steps or kicks off generation.
    private func handleKeyboardSubmit() {
        guard currentStepValid else { return }
        if inputStep < Self.totalInputSteps - 1 {
            advanceStep()
        } else {
            startGeneration()
        }
    }

    // (CompleteArchetypeCard is defined as a separate subview below)

    // MARK: - Step Indicator

    @ViewBuilder
    private var stepIndicator: some View {
        if phase.isInput {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<Self.totalInputSteps, id: \.self) { i in
                    Capsule(style: .continuous)
                        .fill(i == inputStep ? Color.appRose : Color.appSoftBrown.opacity(0.25))
                        .frame(width: i == inputStep ? 22 : 8, height: 8)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.78), value: inputStep)
            .transition(.opacity)
        }
    }

    // MARK: - Footer Button

    @ViewBuilder
    private var footerButton: some View {
        switch phase {
        case .input:
            if showingIntro {
                beginButton
                    .transition(.opacity)
            } else if inputStep < Self.totalInputSteps - 1 {
                continueButton
                    .transition(.opacity)
            } else {
                expressButton
                    .transition(.opacity)
            }
        case .building:
            buildingIndicator
                .transition(.opacity)
        case .complete:
            createAnotherButton
                .transition(.opacity)
        case .interactive:
            createAnotherButton
                .transition(.opacity)
        case .captured:
            createAnotherButton
                .transition(.opacity)
        case .noted:
            createAnotherButton
                .transition(.opacity)
        }
    }

    private var beginButton: some View {
        let hasSaved = savedProfile != nil
        return Button {
            withAnimation(.easeInOut(duration: 0.55)) {
                showingIntro = false
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(hasSaved ? "Build new flower" : "Begin")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(hasSaved ? Color.appRose : .white)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .fill(hasSaved ? Color.clear : Color.appRose)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(hasSaved ? Color.appRose : Color.clear, lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var continueButton: some View {
        let isDisabled = !currentStepValid

        return Button {
            advanceStep()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text("Continue")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .fill(isDisabled ? Color.appSoftBrown.opacity(0.3) : Color.appRose)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var expressButton: some View {
        let isDisabled = !currentStepValid

        return Button {
            startGeneration()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "wand.and.stars")
                Text("Express")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .fill(isDisabled ? Color.appSoftBrown.opacity(0.3) : Color.appRose)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var buildingIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text("Growing your flower")
                .font(.system(.headline, design: .rounded, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.75))
            Image(systemName: "ellipsis")
                .foregroundStyle(Color.appRose)
                .symbolEffect(.pulse, options: .repeating)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            Capsule(style: .continuous)
                .fill(Color.appWarmWhite)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.appSoftBrown.opacity(0.15), lineWidth: 1)
        )
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var createAnotherButton: some View {
        Button {
            reset()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "arrow.counterclockwise")
                Text("Create Another")
                    .font(.system(.headline, design: .rounded, weight: .medium))
            }
            .foregroundStyle(Color.appRose)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .stroke(Color.appRose, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Step Validation & Advance

    private var currentStepValid: Bool {
        switch inputStep {
        case 0:
            return true  // period choice + optional date are always valid
        case 1:
            return Self.ageRange.contains(ageSelection)
        case 2:
            return !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return false
        }
    }

    private func advanceStep() {
        guard currentStepValid, inputStep < Self.totalInputSteps - 1 else { return }
        nameFieldFocused = false
        withAnimation(.easeInOut(duration: 0.55)) {
            inputStep += 1
        }
    }

    // MARK: - Bud Pulse

    /// Drives a soft, continuous "waiting" pulse on the bud while the user
    /// is filling out the form. The repeatForever animation runs independently
    /// of phase changes; the conditional in `flowerStage` chooses whether to
    /// apply it visually.
    private func startBudPulse() {
        budPulse = 1.0
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            budPulse = 1.07
        }
    }

    // MARK: - Generation

    private func startGeneration() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        nameFieldFocused = false

        let date = hasPeriod ? periodDate : Date()
        let archetype = MoonWomanArchetypeEngine.archetype(for: date)
        // Seed combines all user inputs so two women with different ages or
        // names get different flowers even if they share an archetype.
        let seed = "\(trimmed)|\(ageSelection)|\(Int(date.timeIntervalSinceReferenceDate))"
        let config = MoonWomanArchetypeEngine.flowerConfig(for: archetype, seed: seed)
        let flowerName = FlowerNamingEngine.flowerName(for: trimmed)

        persistAutoFlowerProfile(
            displayName: trimmed.capitalized,
            ageSelection: ageSelection,
            hasPeriod: hasPeriod,
            periodDate: date
        )
        let g = GeneratedFlower(
            displayName: trimmed.capitalized,
            flowerName: flowerName,
            archetype: archetype,
            config: config
        )

        bloomState = .bud
        generated = g

        let script = storyScript(for: g)

        withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
            phase = .building(step: 0)
        }
        animateBloom(to: script[0].bloomTarget, duration: script[0].duration * 0.9)
        stepHaptic.prepare()
        stepHaptic.impactOccurred(intensity: 0.5)

        storyTask?.cancel()
        storyTask = Task { @MainActor in
            for index in 0..<script.count {
                let stepDuration = script[index].duration
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                if Task.isCancelled { return }

                let nextIndex = index + 1
                if nextIndex < script.count {
                    let next = script[nextIndex]
                    withAnimation(.easeInOut(duration: 0.55)) {
                        phase = .building(step: nextIndex)
                    }
                    animateBloom(to: next.bloomTarget, duration: next.duration * 0.9)
                    stepHaptic.impactOccurred(intensity: 0.45)
                    stepHaptic.prepare()
                } else {
                    withAnimation(.spring(response: 0.9, dampingFraction: 0.72)) {
                        holdProgress = 1.0
                        bloomState = .flourishing
                        phase = .complete
                    }
                    stepHaptic.impactOccurred(intensity: 0.7)
                    scheduleInteractiveTransition()
                }
            }
        }
    }

    private func animateBloom(to target: CGFloat, duration: Double) {
        withAnimation(.easeInOut(duration: duration)) {
            holdProgress = target
        }
    }

    /// After the full bloom settles, linger briefly so the user can
    /// take it in, then hand off to whatever comes next — in the
    /// carousel this is the first slide via `onNoted`; standalone it
    /// drops the flower into the mini-widget noted state.
    private func scheduleInteractiveTransition() {
        interactiveTransitionTask?.cancel()
        interactiveTransitionTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if Task.isCancelled { return }
            transitionFromCompleteToNoted()
        }
    }

    private func transitionFromCompleteToNoted() {
        let finalState: BloomState = .flourishing
        prepareDailyContext(for: finalState)
        saveStateEntry(finalState)

        withAnimation(.spring(response: 0.9, dampingFraction: 0.78)) {
            notedBloomState = finalState
            bloomState = finalState
            phase = .noted
        }
        onNoted?()
    }

    // MARK: - Noting the Emotional State
    //
    // Two-step user flow mirroring the FlowerBloom lab:
    //
    //   1. Press & hold → on release, the canvas's internal snap spring
    //      catches `bloomState` to the nearest of the four stages
    //      (bud / budding / blooming / flourishing). We flip to
    //      `.captured` so the state label stays visible under the still-
    //      large flower and prompts the user to tap to continue.
    //
    //   2. Tap the big flower → `beginShrinkToNoted()` transitions to
    //      `.noted`, where the flower shrinks into the mini widget at
    //      the bottom of the screen and the daily guidance layout fills
    //      the space above.

    private func noteEmotionalState() {
        noteStateTask?.cancel()
        noteStateTask = Task { @MainActor in
            // Let the snap spring inside the canvas fully settle so the
            // user visually registers the bloom rung they landed on
            // before the prompt swaps to the "Tap to continue" hint.
            try? await Task.sleep(nanoseconds: 650_000_000)
            if Task.isCancelled { return }
            guard phase.isInteractive else { return }

            withAnimation(.easeInOut(duration: 0.5)) {
                phase = .captured
            }
        }
    }

    /// Second step: user taps the big flower in `.captured`. We now
    /// compute the cycle-linked guidance (using the snapped state) and
    /// animate the flower shrinking into the bottom-pinned widget.
    private func beginShrinkToNoted() {
        guard phase.isCaptured else { return }
        let captured = bloomState
        prepareDailyContext(for: captured)
        saveStateEntry(captured)

        withAnimation(.spring(response: 0.9, dampingFraction: 0.78)) {
            notedBloomState = captured
            phase = .noted
        }

        scheduleHoldToast()
        onNoted?()
    }

    /// Briefly surfaces a "Hold to update state" hint beneath the mini
    /// flower after the shrink animation settles, then fades it out.
    private func scheduleHoldToast() {
        toastTask?.cancel()
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            if Task.isCancelled { return }
            showToast("Hold to update state", duration: 2.6)
        }
    }

    /// Shows a small toast above the mini flower for the given duration.
    private func showToast(_ message: String, duration: TimeInterval) {
        toastTask?.cancel()
        toastTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.35)) {
                toastMessage = message
            }
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                toastMessage = nil
            }
        }
    }

    // MARK: - Mini Flower Press Handling
    //
    // The mini flower distinguishes a quick tap from a sustained hold:
    // • Quick tap → opens the read-only state progression page.
    // • Sustained hold (≥ holdThreshold) → kicks off the full re-entry
    //   flow (white screen, flower regrows, new state noted on release).
    //
    // During the ambiguity window we deliberately do NOT drive
    // `isHolding`, so the canvas timer doesn't silently advance progress
    // — that advance is what used to make a tap look like a tiny bloom.

    private static let reentryHoldThreshold: TimeInterval = 0.35

    private static let stateCardCount: Int = 4

    /// Horizontal swipe on the LARGE state-page flower → rotate it a
    /// step and advance the data card beneath: state ribbon →
    /// pattern analysis → phase data → cycle calendar (and wraps).
    private func handleStateFlowerSwipe(_ direction: Int) {
        let count = Self.stateCardCount
        let next = (notedCardIndex + direction + count) % count
        withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) {
            notedCardIndex = next
            flowerRotation += Double(direction) * 60
        }
    }

    /// Drag gesture attached to the large state-page flower. Live drag
    /// rotates the flower for tactile feedback; once the user passes
    /// the swipe threshold, the gesture is "committed" and the content
    /// beneath toggles on release.
    private var stateFlowerSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let dx = value.translation.width
                stateFlowerDragRotation = Double(dx) * 0.4
                if !stateFlowerDidSwipe, abs(dx) > 35 {
                    stateFlowerDidSwipe = true
                }
            }
            .onEnded { value in
                let dx = value.translation.width
                if stateFlowerDidSwipe {
                    handleStateFlowerSwipe(dx > 0 ? 1 : -1)
                    stateFlowerDidSwipe = false
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                    stateFlowerDragRotation = 0
                }
            }
    }

    private func handleMiniFlowerPress(_ pressed: Bool) {
        if pressed {
            // Ignore presses while an overlay is already on screen — we
            // want the user to interact with that, not re-trigger.
            guard reentryStage == nil, !showStatePage else { return }

            if toastMessage != nil {
                toastTask?.cancel()
                withAnimation(.easeOut(duration: 0.2)) { toastMessage = nil }
            }

            miniHoldStartTime = Date()
            miniHoldResetTask?.cancel()
            miniHoldResetTask = Task { @MainActor in
                try? await Task.sleep(
                    nanoseconds: UInt64(Self.reentryHoldThreshold * 1_000_000_000)
                )
                if Task.isCancelled { return }
                // Threshold reached while finger is still down — promote
                // this press to a re-entry hold and let the canvas start
                // feeding the flower.
                startReentry()
                isHolding = true
            }
        } else {
            let threshold = Self.reentryHoldThreshold
            let elapsed = miniHoldStartTime.map { Date().timeIntervalSince($0) } ?? 0
            miniHoldStartTime = nil
            miniHoldResetTask?.cancel()
            miniHoldResetTask = nil

            if elapsed < threshold {
                // Short tap — open the state page instead of editing.
                withAnimation(.easeInOut(duration: 0.45)) {
                    showStatePage = true
                }
            } else {
                // Sustained hold was promoted already; finish through
                // the canvas's isHolding → false snap path.
                if isHolding { isHolding = false }
                // `finishReentry` also runs via onChange(of: isHolding)
                // when reentryStage == .active, so nothing more needed
                // here.
            }
        }
    }

    /// Begins the re-entry overlay: dismiss lingering toasts, reset the
    /// flower to bud so the user visibly regrows it, flip the stage so
    /// the white overlay fades in over the noted screen.
    private func startReentry() {
        if toastMessage != nil {
            toastTask?.cancel()
            withAnimation(.easeOut(duration: 0.2)) { toastMessage = nil }
        }
        reentryFadeInTask?.cancel()
        reentryCloseTask?.cancel()

        // Snapshot the previous entry so we can compare on release even
        // after the new one is saved.
        reentryPreviousEntry = stateHistory.first
        reentryCompareMessage = nil

        withAnimation(.easeOut(duration: 0.35)) {
            holdProgress = Self.restingBudProgress
            bloomState = .bud
        }
        withAnimation(.easeInOut(duration: 0.55)) {
            reentryStage = .active
        }
    }

    /// User released during the active stage. Snap to the nearest bloom
    /// state (the canvas already did), persist a new FlowerStateEntry,
    /// build a comparison line, and move to .released so the comparison
    /// + subtle graph appear over the white overlay.
    private func finishReentry() {
        let snapped = BloomState.closest(to: holdProgress)
        let previous = reentryPreviousEntry
        saveStateEntry(snapped)
        reentryCompareMessage = Self.comparisonMessage(
            previous: previous,
            new: snapped,
            now: .now
        )
        notedBloomState = snapped
        prepareDailyContext(for: snapped)

        withAnimation(.easeInOut(duration: 0.55)) {
            reentryStage = .released
        }
        scheduleReentryClose()
    }

    /// After the comparison has been on screen long enough to read, fade
    /// the overlay back out and return to the plain noted view.
    private func scheduleReentryClose() {
        reentryCloseTask?.cancel()
        reentryCloseTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.7)) {
                reentryStage = .closing
            }
            try? await Task.sleep(nanoseconds: 750_000_000)
            if Task.isCancelled { return }
            reentryStage = nil
            reentryCompareMessage = nil
            reentryPreviousEntry = nil
        }
    }

    /// Persists a FlowerStateEntry for the given bloom state. Used both
    /// for the first-time note and subsequent re-entries.
    private func saveStateEntry(_ bloom: BloomState) {
        let entry = FlowerStateEntry(timestamp: .now, bloomState: bloom)
        modelContext.insert(entry)
        try? modelContext.save()
    }

    /// Computes cycle position + daily guidance from the entered period
    /// date (or today, if the user tapped "no"). Falls back to default
    /// cycle/period lengths when no UserProfile exists.
    private func prepareDailyContext(for noted: BloomState) {
        var cycleLength = Self.defaultCycleLength
        var periodLength = Self.defaultPeriodLength

        if let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first {
            cycleLength = profile.cycleLength
            periodLength = profile.periodLength
        }

        let referenceDate = hasPeriod ? periodDate : Date()
        let position = CycleCalculator.currentPosition(
            lastPeriodStart: referenceDate,
            cycleLength: cycleLength,
            periodLength: periodLength
        )

        let nsState = Self.nervousSystemState(for: noted)
        let guidance = GuidanceEngine.guidance(
            phase: position.phase,
            dayInCycle: position.dayInCycle,
            dayInPhase: position.dayInPhase,
            nervousSystemState: nsState
        )

        cyclePosition = position
        dailyGuidance = guidance
    }

    /// Maps the four BloomState rungs to the three NervousSystemState
    /// categories so `GuidanceEngine` can produce breathwork, somatic,
    /// and grounding content matched to how the user feels today.
    private static func nervousSystemState(for bloom: BloomState) -> NervousSystemState {
        switch bloom {
        case .bud:         return .overstimulated
        case .budding:     return .sensitive
        case .blooming:    return .regulated
        case .flourishing: return .regulated
        }
    }

    /// Builds a short encouraging line that names the shift from the
    /// previous entry to the new one — indirect, never judgemental.
    /// Falls back to a welcoming line when there is no prior entry.
    private static func comparisonMessage(
        previous: FlowerStateEntry?,
        new: BloomState,
        now: Date
    ) -> String {
        guard let previous else {
            return "Your first bloom noted — welcome"
        }

        let prior = previous.bloomState
        let delta = new.bloomAmount - prior.bloomAmount
        let elapsed = relativeTimeString(from: previous.timestamp, to: now)

        if delta > 0 {
            return "Your inner state is harmonising — \(elapsed)"
        } else if delta < 0 {
            return "Softer than \(elapsed) — be tender with yourself"
        } else {
            return "Holding steady since \(elapsed)"
        }
    }

    /// Short human-readable elapsed string — "4 hours ago", "yesterday",
    /// etc. Kept deliberately compact so it fits one line on the overlay.
    private static func relativeTimeString(from past: Date, to now: Date) -> String {
        let seconds = now.timeIntervalSince(past)
        if seconds < 90 { return "a moment ago" }
        let minutes = Int(seconds / 60)
        if minutes < 60 { return "\(minutes) minutes ago" }
        let hours = Int(seconds / 3600)
        if hours < 24 { return hours == 1 ? "1 hour ago" : "\(hours) hours ago" }
        let days = Int(seconds / 86_400)
        if days == 1 { return "yesterday" }
        if days < 7 { return "\(days) days ago" }
        return "a while ago"
    }

    /// Persists / updates the single AutoFlowerProfile record. We keep
    /// only one — the most recently completed setup — so "continue with
    /// my flower" always resolves the same flower across launches.
    private func persistAutoFlowerProfile(
        displayName: String,
        ageSelection: Int,
        hasPeriod: Bool,
        periodDate: Date
    ) {
        if let existing = savedProfiles.first {
            existing.displayName = displayName
            existing.ageSelection = ageSelection
            existing.hasPeriod = hasPeriod
            existing.periodDate = periodDate
            existing.createdDate = .now
        } else {
            let profile = AutoFlowerProfile(
                displayName: displayName,
                ageSelection: ageSelection,
                hasPeriod: hasPeriod,
                periodDate: periodDate
            )
            modelContext.insert(profile)
        }
        try? modelContext.save()
    }

    /// Rebuilds the in-memory flower from a persisted profile and lands
    /// on the noted screen. Cycle position + daily guidance are computed
    /// fresh for today, so the flower is the same but the guidance
    /// reflects where the user is in her cycle now.
    private func loadFlower(from profile: AutoFlowerProfile) {
        let date = profile.hasPeriod ? profile.periodDate : Date()
        let archetype = MoonWomanArchetypeEngine.archetype(for: date)
        let seed = "\(profile.displayName)|\(profile.ageSelection)|\(Int(date.timeIntervalSinceReferenceDate))"
        let config = MoonWomanArchetypeEngine.flowerConfig(for: archetype, seed: seed)
        let flowerName = FlowerNamingEngine.flowerName(for: profile.displayName)

        nameInput = profile.displayName
        ageSelection = profile.ageSelection
        hasPeriod = profile.hasPeriod
        periodDate = profile.periodDate

        generated = GeneratedFlower(
            displayName: profile.displayName,
            flowerName: flowerName,
            archetype: archetype,
            config: config
        )

        let snapped: BloomState = .blooming
        bloomState = snapped
        holdProgress = snapped.bloomAmount
        notedBloomState = snapped
        showingIntro = false
        prepareDailyContext(for: snapped)

        withAnimation(.easeInOut(duration: 0.45)) {
            phase = .noted
        }
        onNoted?()
    }

    /// Dev fast-forward: continues with the saved profile if one exists,
    /// otherwise builds a default "Dev" flower so the noted UI is
    /// reachable without running the full intake.
    private func skipToNoted() {
        if let profile = savedProfile {
            loadFlower(from: profile)
            return
        }
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmed.isEmpty ? "Dev" : trimmed.capitalized
        let date = hasPeriod ? periodDate : Date()
        let archetype = MoonWomanArchetypeEngine.archetype(for: date)
        let seed = "\(displayName)|\(ageSelection)|\(Int(date.timeIntervalSinceReferenceDate))"
        let config = MoonWomanArchetypeEngine.flowerConfig(for: archetype, seed: seed)
        let flowerName = FlowerNamingEngine.flowerName(for: displayName)

        generated = GeneratedFlower(
            displayName: displayName,
            flowerName: flowerName,
            archetype: archetype,
            config: config
        )

        let snapped: BloomState = .blooming
        bloomState = snapped
        holdProgress = snapped.bloomAmount
        notedBloomState = snapped
        showingIntro = false
        prepareDailyContext(for: snapped)

        withAnimation(.easeInOut(duration: 0.35)) {
            phase = .noted
        }
        onNoted?()
    }

    private func reset() {
        storyTask?.cancel()
        storyTask = nil
        interactiveTransitionTask?.cancel()
        interactiveTransitionTask = nil
        noteStateTask?.cancel()
        noteStateTask = nil
        toastTask?.cancel()
        toastTask = nil
        miniHoldResetTask?.cancel()
        miniHoldResetTask = nil
        miniHoldStartTime = nil
        reentryFadeInTask?.cancel()
        reentryFadeInTask = nil
        reentryCloseTask?.cancel()
        reentryCloseTask = nil
        reentryStage = nil
        reentryCompareMessage = nil
        reentryPreviousEntry = nil
        showStatePage = false
        showNutritionPage = false
        showFullProtocol = false
        showSymptomPage = false
        showMoonPage = false
        symptomQuery = ""
        revealedSymptom = nil
        notedCardIndex = 0
        flowerRotation = 0
        withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
            phase = .input
            showingIntro = true
            generated = nil
            holdProgress = Self.restingBudProgress
            bloomState = .bud
            inputStep = 0
            ageSelection = 28
            notedBloomState = nil
            cyclePosition = nil
            dailyGuidance = nil
            showNervousSystem = false
            toastMessage = nil
        }
    }

    // MARK: - Story Script

    private func storyScript(for g: GeneratedFlower) -> [StoryStep] {
        let parts = g.archetype.storyParts
        return [
            StoryStep(text: "\(g.displayName)\u{2026}", bloomTarget: 0.16, duration: 1.8),
            StoryStep(text: "Your flower is awakening", bloomTarget: 0.22, duration: 1.8),
            StoryStep(text: parts.opening, bloomTarget: 0.30, duration: 2.2),
            StoryStep(text: "\(g.archetype.symbol)  \(g.archetype.title)", bloomTarget: 0.40, duration: 2.0),
            StoryStep(text: g.archetype.subtitle, bloomTarget: 0.48, duration: 1.6),
            StoryStep(text: parts.centerLine, bloomTarget: 0.58, duration: 1.8),
            StoryStep(text: parts.stamenLine, bloomTarget: 0.68, duration: 1.8),
            StoryStep(text: parts.innerLine, bloomTarget: 0.80, duration: 1.8),
            StoryStep(text: parts.outerLine, bloomTarget: 0.92, duration: 2.0)
        ]
    }
}

// MARK: - Complete Archetype Card (staggered fade-in)

/// Renders the archetype reveal as a soft, brief title — just the archetype
/// name fades in gently. Kept intentionally short so the press-and-hold
/// prompt can take over the same slot a moment later.
private struct CompleteArchetypeCard: View {
    let archetype: MoonWomanArchetype

    @State private var titleIn = false

    var body: some View {
        Text(archetype.title)
            .font(.system(.title3, design: .serif))
            .italic()
            .fontWeight(.regular)
            .foregroundStyle(Color.appSoftBrown.opacity(0.65))
            .multilineTextAlignment(.center)
            .opacity(titleIn ? 1 : 0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.3).delay(0.2)) { titleIn = true }
            }
    }
}

// MARK: - Mini Flower Widget
//
// Soft shiny halo + small flower pinned at the bottom of the noted
// screen. The halo reports raw press/release to the parent via
// `onPressChange` — the parent decides whether that press is a quick
// tap (open the state page) or a sustained hold (kick off re-entry),
// and only then drives the shared `isHolding` binding. This keeps the
// canvas from silently advancing progress during the tap-vs-hold
// ambiguity window.
private struct MiniFlowerWidget: View {
    let config: AutoFlowerConfig
    @Binding var holdProgress: CGFloat
    @Binding var bloomState: BloomState

    /// When true we dim the small flower so the big flower in the
    /// re-entry overlay feels like the same flower that "flew up".
    var flowerHidden: Bool = false

    /// True once the parent has decided this press is a sustained hold
    /// (i.e. re-entry is active). Used purely for visual feedback on
    /// the halo — brighter flare when the flower is actually feeding.
    var isChannelling: Bool = false

    /// 0…1 cumulative growth from accumulated shinedust.
    var growthLevel: CGFloat = 0

    /// Discrete tier unlocking layered decorations (halo ring → twinkles →
    /// accent petal ring → magical aura).
    var growthTier: GrowthLevel.Tier = .seed

    var onPressChange: (Bool) -> Void

    @State private var isPressed: Bool = false
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            ShinyHalo(isHolding: isPressed || isChannelling)
                .frame(width: 140, height: 140)

            GrowthOverlay(
                level: growthLevel,
                tier: growthTier,
                size: 76,
                accentColor: config.outerColor,
                showHaloRing: false
            )
            .frame(width: 140, height: 140)
            .opacity(flowerHidden ? 0 : 1)

            FlowerBloomCanvas(
                outerDesign: config.outerDesign,
                innerDesign: config.innerDesign,
                stamenDesign: config.stamenDesign,
                centerDesign: config.centerDesign,
                outerColor: config.outerColor,
                innerColor: config.innerColor,
                stamenColor: config.stamenColor,
                centerColor: config.centerColor,
                geometry: config.geometry,
                isHolding: .constant(false),  // mini never drives progress
                holdProgress: $holdProgress,
                bloomState: $bloomState,
                showBackground: false,
                interactive: false
            )
            .frame(width: 76, height: 76)
            .saturation(1.0 + Double(growthLevel) * 0.35)
            .scaleEffect(isPressed ? 1.0 : pulse)
            .opacity(flowerHidden ? 0 : 1)
            .animation(.easeInOut(duration: 0.25), value: isPressed)
            .animation(.easeInOut(duration: 0.6), value: flowerHidden)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onPressChange(true)
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onPressChange(false)
                }
        )
        .onAppear {
            pulse = 1.0
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulse = 1.1
            }
        }
    }
}

// MARK: - Shiny Halo
//
// MARK: - Nutrition Card (one category × one time block)

struct NutritionCardModel: Identifiable {
    let block: TimeBlock
    let category: NutritionItemCategory
    let items: [NutritionItem]

    var id: String { "\(block.timeOfDay.rawValue).\(category.rawValue)" }
}

// Compact rendering of one (time block × category) tile — Supplements,
// Rituals, or Foods of e.g. the morning block, on a single card with a
// tickable list of items. Designed to fit the visible area without
// scrolling: small height items + generous spacing.
private struct NutritionCategoryCard: View {
    let card: NutritionCardModel
    let accent: Color
    let isCompleted: (NutritionItem) -> Bool
    let onToggle: (NutritionItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: card.block.timeOfDay.icon)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(accent.opacity(0.65))
                Text(card.block.timeOfDay.displayName.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(accent.opacity(0.7))
                Spacer()
                Text(card.block.timeOfDay.timeHint.uppercased())
                    .font(.system(size: 9, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: card.category.icon)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(accent)
                Text(card.category.displayName)
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)
            }

            Rectangle()
                .fill(accent.opacity(0.25))
                .frame(height: 0.5)

            if card.items.isEmpty {
                Text("nothing for this rhythm")
                    .font(.system(.subheadline, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                    .padding(.top, AppTheme.Spacing.sm)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(card.items) { item in
                        let done = isCompleted(item)
                        Button {
                            onToggle(item)
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                ZStack {
                                    Circle()
                                        .stroke(accent.opacity(done ? 0 : 0.4), lineWidth: 1)
                                        .frame(width: 22, height: 22)
                                    if done {
                                        Circle()
                                            .fill(accent.opacity(0.85))
                                            .frame(width: 22, height: 22)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                                }

                                Text(item.name)
                                    .font(.system(.subheadline, design: .serif, weight: .light))
                                    .foregroundStyle(Color.appSoftBrown.opacity(done ? 0.5 : 0.9))
                                    .strikethrough(done, color: Color.appSoftBrown.opacity(0.45))
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .fill(Color.appWarmWhite.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 0.5)
        )
    }
}

// MARK: - State Ring Dots
//
// Compressed visualization of recent FlowerStateEntry records placed
// circularly around the flower. Each dot's angular position encodes
// recency (oldest at top, newest going clockwise) and its colour
// encodes the bloom state. Subtle so the flower stays the hero.
private struct StateRingDots: View {
    let entries: [FlowerStateEntry]
    let radius: CGFloat

    var body: some View {
        ZStack {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                let count = max(entries.count, 1)
                let angle = (Double(index) / Double(count)) * 360.0 - 90
                let r = radius
                let x = cos(angle * .pi / 180) * r
                let y = sin(angle * .pi / 180) * r
                let amount = Double(entry.bloomState.bloomAmount)

                Circle()
                    .fill(entry.bloomState.color.opacity(0.35 + amount * 0.45))
                    .frame(width: 4 + CGFloat(amount) * 6, height: 4 + CGFloat(amount) * 6)
                    .offset(x: x, y: y)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Symptom Wisdom Card
//
// Renders a SymptomWisdom (what it means / why it matters / what helps
// + warm remedy) in the editorial typography of the noted screen.
private struct SymptomWisdomCard: View {
    let wisdom: SymptomWisdom
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(wisdom.symptom.emoji)
                    .font(.system(size: 22))
                Text(wisdom.symptom.displayName)
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)
            }

            block(label: "WHAT IT MEANS", body: wisdom.whatItMeans, accent: accent)
            block(label: "WHY IT MATTERS", body: wisdom.whyItMatters, accent: accent)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(accent.opacity(0.6))
                        .frame(width: 14, height: 1)
                    Text("WHAT MIGHT HELP")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(accent.opacity(0.85))
                }
                ForEach(wisdom.whatHelps, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("·")
                            .font(.system(.body, design: .serif, weight: .light))
                            .foregroundStyle(accent.opacity(0.7))
                        Text(item)
                            .font(.system(.subheadline, design: .serif, weight: .light))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(accent.opacity(0.7))
                    .padding(.top, 3)
                Text(wisdom.warmRemedy)
                    .font(.system(.subheadline, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.md)
            .background(accent.opacity(0.08))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func block(label: String, body: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(accent.opacity(0.6))
                    .frame(width: 14, height: 1)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(accent.opacity(0.85))
            }
            Text(body)
                .font(.system(.subheadline, design: .serif, weight: .light))
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Sun Widget
//
// Companion to the mini flower: a small luminous sun pinned to the
// flower's left side. Same visual vocabulary as the flower (radial
// gradient core + soft halo + breath pulse), but rendered as a
// stylised sun with a gentle ray ring. Tapping it opens the nutrition
// page — sunlight feeds the flower in the same way nourishment does.
private struct SunWidget: View {
    var isHidden: Bool = false
    var onTap: () -> Void

    @State private var breathPhase: CGFloat = 0
    @State private var rayPhase: CGFloat = 0

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private let core = Color(red: 1.0, green: 0.86, blue: 0.45)
    private let outer = Color(red: 1.0, green: 0.72, blue: 0.36)

    var body: some View {
        let breath: CGFloat = 1.0 + sin(breathPhase) * 0.05

        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            core.opacity(0.35),
                            outer.opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: 3,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)

            // Rays
            ForEach(0..<12, id: \.self) { i in
                Capsule()
                    .fill(core.opacity(0.45))
                    .frame(width: 1.8, height: 9)
                    .offset(y: -34)
                    .rotationEffect(.degrees(Double(i) * 30 + Double(rayPhase) * 12))
            }

            // Sun face
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            core,
                            outer
                        ],
                        center: .init(x: 0.4, y: 0.35),
                        startRadius: 1,
                        endRadius: 28
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(outer.opacity(0.4), lineWidth: 0.5)
                )
        }
        .frame(width: 100, height: 100)
        .scaleEffect(breath)
        .opacity(isHidden ? 0 : 1)
        .animation(.easeInOut(duration: 0.4), value: isHidden)
        .contentShape(Circle())
        .onTapGesture(perform: onTap)
        .onReceive(timer) { _ in
            breathPhase += 1.0 / 60.0 * 1.4
            rayPhase    += 1.0 / 60.0
        }
    }
}

// MARK: - Moon Widget
//
// Companion to the flower on the right: small mineral moon (the same
// "moon_full" asset the main app uses, with the lavender + peach tint
// overlays from MoonView) sitting inside a shiny halo so it shares the
// flower's visual vocabulary.
private struct MoonWidget: View {
    var isHidden: Bool = false
    var onTap: () -> Void = {}

    @State private var breathPhase: CGFloat = 0
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        let breath: CGFloat = 1.0 + sin(breathPhase) * 0.05

        ZStack {
            ShinyHalo(isHolding: false)
                .frame(width: 100, height: 100)

            Image("moon_full")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .saturation(1.4)
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.75, green: 0.65, blue: 0.88).opacity(0.18))
                            .blendMode(.plusLighter)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.98, green: 0.88, blue: 0.78).opacity(0.18),
                                        Color(red: 0.85, green: 0.72, blue: 0.85).opacity(0.18)
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 22
                                )
                            )
                            .blendMode(.overlay)
                    }
                )
                .clipShape(Circle())
        }
        .frame(width: 100, height: 100)
        .scaleEffect(breath)
        .opacity(isHidden ? 0 : 1)
        .animation(.easeInOut(duration: 0.4), value: isHidden)
        .contentShape(Circle())
        .onTapGesture(perform: onTap)
        .onReceive(timer) { _ in
            breathPhase += 1.0 / 60.0 * 1.2
        }
    }
}

// MARK: - Shiny Halo
//
// Soft luminous disc that sits behind the mini flower (and stays pinned
// at the bottom of the screen during re-entry). Pulses gently when idle
// and flares brighter while the user is pressing — visually suggesting
// the halo is the energy source feeding the flower's bloom.
private struct ShinyHalo: View {
    var isHolding: Bool

    @State private var breathPhase: CGFloat = 0
    @State private var shimmerPhase: CGFloat = 0

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        let intensity: CGFloat = isHolding ? 1.15 : 0.85
        let breath: CGFloat = 1.0 + sin(breathPhase) * 0.06
        let shimmer: CGFloat = 0.55 + 0.25 * sin(shimmerPhase)
        let warmGold = Color(red: 1.0, green: 0.88, blue: 0.58)
        let paleRose = Color(red: 1.0, green: 0.82, blue: 0.78)

        ZStack {
            // Outer soft glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            warmGold.opacity(0.45 * Double(intensity)),
                            warmGold.opacity(0.10 * Double(intensity)),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 70
                    )
                )
                .scaleEffect(breath)

            // Mid shimmer ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            paleRose.opacity(0.55 * Double(intensity) * Double(shimmer)),
                            paleRose.opacity(0.15 * Double(intensity) * Double(shimmer)),
                            .clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 44
                    )
                )
                .blendMode(.plusLighter)
                .scaleEffect(breath * 0.95)

            // Core hotspot
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.85 * Double(intensity)),
                            warmGold.opacity(0.55 * Double(intensity)),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 36, height: 36)
                .blur(radius: isHolding ? 1.5 : 2.0)
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.35), value: isHolding)
        .onReceive(timer) { _ in
            breathPhase += 1.0 / 60.0 * 1.6
            shimmerPhase += 1.0 / 60.0 * 2.4
        }
    }
}

// MARK: - Growth Overlay
//
// Layered decorations that sit behind / around the flower and unlock as
// the user accumulates shinedust. Early tiers are subtle (a glow ring);
// later tiers add orbiting twinkles, a decorative accent-petal ring,
// and a magical aura. Everything is kept low-contrast so the flower
// itself remains the hero — this is "the flower is becoming special",
// not "look at all these effects".
private struct GrowthOverlay: View {
    let level: CGFloat
    let tier: GrowthLevel.Tier
    let size: CGFloat
    let accentColor: Color
    /// Suppresses the angular halo ring — used by the mini flower so it
    /// only shows the soft ShinyHalo, not a hard outline.
    var showHaloRing: Bool = true

    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            if showHaloRing, tier >= .sprouting {
                haloRing
            }
            if tier >= .radiant {
                accentPetalRing
            }
            if tier >= .budding {
                twinkles
            }
            if tier >= .magical {
                magicalAura
            }
        }
        .allowsHitTesting(false)
        .onReceive(timer) { _ in
            phase += 1.0 / 30.0
        }
    }

    // Tier 1: soft luminous ring framing the flower.
    private var haloRing: some View {
        let intensity = Double(min(1.0, (level - 0.05) * 3))
        let pulseR: CGFloat = 1.0 + CGFloat(sin(phase * 1.6)) * 0.015
        return Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        Color(red: 1.0, green: 0.90, blue: 0.58).opacity(0.30 * intensity),
                        Color(red: 1.0, green: 0.96, blue: 0.82).opacity(0.55 * intensity),
                        Color(red: 1.0, green: 0.85, blue: 0.65).opacity(0.30 * intensity),
                        Color(red: 1.0, green: 0.90, blue: 0.58).opacity(0.30 * intensity)
                    ],
                    center: .center,
                    angle: .degrees(Double(phase) * 18)
                ),
                lineWidth: 2.0
            )
            .frame(width: size * 1.05, height: size * 1.05)
            .scaleEffect(pulseR)
            .blur(radius: 0.6)
    }

    // Tier 2: small stars drifting in a slow orbit around the flower.
    private var twinkles: some View {
        let count = tier >= .magical ? 14 : (tier >= .radiant ? 10 : 6)
        let radius = size * 0.62
        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                twinkle(index: i, total: count, radius: radius)
            }
        }
    }

    private func twinkle(index: Int, total: Int, radius: CGFloat) -> some View {
        let seed = CGFloat(index) * 3.1
        let orbitSpeed: CGFloat = 0.35
        let angle = CGFloat(index) * (2 * .pi / CGFloat(total))
            + phase * orbitSpeed
            + sin(phase * 0.6 + seed) * 0.12
        let r = radius + sin(phase * 1.1 + seed * 0.7) * 4
        let x = cos(angle) * r
        let y = sin(angle) * r
        let pulse = 0.5 + 0.5 * sin(phase * 2.0 + seed * 1.3)
        let s: CGFloat = 2.2 + CGFloat(index % 3) * 0.8
        let color = index % 2 == 0
            ? Color(red: 1.0, green: 0.92, blue: 0.65)
            : Color.white

        return Image(systemName: "sparkle")
            .font(.system(size: s * 3))
            .foregroundStyle(color.opacity(Double(pulse) * 0.85))
            .offset(x: x, y: y)
    }

    // Tier 3: a ring of tiny accent petals (dots in the flower's outer
    // colour) rotating slowly beyond the main bloom silhouette.
    private var accentPetalRing: some View {
        let count = tier >= .magical ? 16 : 12
        let radius = size * 0.52
        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                accentPetal(index: i, total: count, radius: radius)
            }
        }
        .rotationEffect(.degrees(Double(phase) * 6))
    }

    private func accentPetal(index: Int, total: Int, radius: CGFloat) -> some View {
        let angle = CGFloat(index) * (2 * .pi / CGFloat(total))
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        let breath = 0.85 + 0.15 * sin(phase * 1.2 + CGFloat(index) * 0.5)
        return Capsule()
            .fill(accentColor.opacity(0.55))
            .frame(width: 4, height: 9 * breath)
            .rotationEffect(.radians(Double(angle) + .pi / 2))
            .offset(x: x, y: y)
    }

    // Tier 4: full pulsing aura so the flower reads as "magical".
    private var magicalAura: some View {
        let pulse = 0.75 + 0.25 * sin(phase * 1.2)
        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.70).opacity(0.25 * Double(pulse)),
                        Color(red: 1.0, green: 0.85, blue: 0.72).opacity(0.12 * Double(pulse)),
                        .clear
                    ],
                    center: .center,
                    startRadius: size * 0.2,
                    endRadius: size * 0.85
                )
            )
            .frame(width: size * 1.7, height: size * 1.7)
            .blendMode(.plusLighter)
    }
}

// MARK: - Energy Stream
//
// Glitter/energy particles that rise from the halo at the bottom of the
// screen toward the centred flower during the re-entry active stage.
// Visually sells the idea that the dot is "feeding" the flower's bloom.
private struct EnergyStream: View {
    var isActive: Bool

    private static let particleCount = 18

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(paused: !isActive)) { timeline in
                Canvas { context, size in
                    let now = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                    let bottomY = size.height - 110   // near the halo
                    let topY    = size.height * 0.38  // near the flower
                    let centerX = size.width / 2
                    let travel  = bottomY - topY

                    for i in 0..<Self.particleCount {
                        let seed = CGFloat(i) * 5.17
                        let cycle: CGFloat = 1.8 + abs(sin(seed)) * 1.2
                        let offset = abs(cos(seed * 1.3)) * cycle
                        var u = (now + offset).truncatingRemainder(dividingBy: cycle) / cycle
                        if u < 0 { u += 1 }

                        let y = bottomY - travel * u
                        let drift = sin(now * 1.8 + seed) * 18.0
                        let x = centerX + drift

                        let bell = sin(u * .pi)
                        let alpha = bell * (isActive ? 0.9 : 0.0)
                        let sizePt: CGFloat = 3.5 + CGFloat(i % 3) * 1.2

                        let gold = Color(red: 1.0, green: 0.88, blue: 0.58)
                        let rose = Color(red: 1.0, green: 0.82, blue: 0.82)
                        let color = i % 3 == 0 ? Color.white : (i % 3 == 1 ? gold : rose)

                        let rect = CGRect(x: x - sizePt / 2,
                                          y: y - sizePt / 2,
                                          width: sizePt,
                                          height: sizePt)
                        context.fill(Path(ellipseIn: rect),
                                     with: .color(color.opacity(alpha)))

                        // Soft halo under each particle
                        let halo = CGRect(x: x - sizePt * 1.6,
                                          y: y - sizePt * 1.6,
                                          width: sizePt * 3.2,
                                          height: sizePt * 3.2)
                        context.fill(Path(ellipseIn: halo),
                                     with: .color(color.opacity(alpha * 0.18)))
                    }
                }
            }
        }
    }
}

// MARK: - State History Graph
//
// Subtle horizontal dot plot of recent FlowerStateEntry records. Time
// runs left → right, y-position encodes bloomAmount. Kept low-contrast
// and unlabeled so it feels informative but not imposing.
private struct StateHistoryGraph: View {
    let entries: [FlowerStateEntry]

    var body: some View {
        GeometryReader { geo in
            let recent = Array(entries.prefix(12).reversed())
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Baseline
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h - 2))
                    p.addLine(to: CGPoint(x: w, y: h - 2))
                }
                .stroke(Color.appSoftBrown.opacity(0.18), lineWidth: 0.5)

                if recent.count >= 2 {
                    // Connecting line
                    Path { p in
                        for (i, entry) in recent.enumerated() {
                            let x = w * CGFloat(i) / CGFloat(max(recent.count - 1, 1))
                            let y = h - (h - 6) * entry.bloomState.bloomAmount - 2
                            if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                            else      { p.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(Color.appRose.opacity(0.35), lineWidth: 1)
                }

                ForEach(Array(recent.enumerated()), id: \.offset) { i, entry in
                    let x = w * CGFloat(i) / CGFloat(max(recent.count - 1, 1))
                    let y = h - (h - 6) * entry.bloomState.bloomAmount - 2
                    Circle()
                        .fill(entry.bloomState.color.opacity(0.55))
                        .frame(width: 5, height: 5)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Noted Nervous System Section
//
// Inline, borderless version of the Today tab's NervousSystemGuidanceView.
// Shows the affirmation and three always-visible blocks — Breathwork,
// Your Somatic Exercise (renamed from "Somatic Exercise"), and Grounding —
// so the whole support offering lives on the same page without feeling
// like a separate screen.
private struct NotedNervousSystemSection: View {
    let guidance: NervousSystemGuidance

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("\"\(guidance.affirmation)\"")
                .affirmationStyle()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppTheme.Spacing.xs)

            supportBlock(title: "Breathwork", icon: "wind") {
                BreathingAnimationView(exercise: guidance.breathwork)
            }

            supportBlock(title: "Your Somatic Exercise", icon: "figure.mind.and.body") {
                Text(guidance.somaticExercise)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)
            }

            supportBlock(title: "Grounding", icon: "mountain.2.fill") {
                Text(guidance.groundingPrompt)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    @ViewBuilder
    private func supportBlock<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundStyle(guidance.state.color)
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }
            content()
                .padding(.leading, AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Sparkle Emitter

/// Magical glitter that emerges from the stamen area of the bloomed flower.
/// Each sparkle has its own life cycle: fades in just outside the center,
/// drifts outward while twinkling, then fades out near the petal edge.
/// A new sparkle is reborn at the start of every cycle so the halo of
/// glitter feels continuously alive.
private struct SparkleEmitter: View {
    private static let sparkleCount = 34

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let now = CGFloat(timeline.date.timeIntervalSinceReferenceDate)

                // Sparkles are born just outside the stamen tips and drift
                // out until they reach near the outer edge of the canvas.
                let innerR: CGFloat = 46
                let outerR: CGFloat = min(size.width, size.height) / 2 - 6

                for i in 0..<Self.sparkleCount {
                    let seed = CGFloat(i) * 7.13

                    // Per-sparkle cycle length & phase offset so they're
                    // staggered across time and never bunch up.
                    let cycleDuration: CGFloat = 3.4 + abs(sin(seed)) * 1.3
                    let phaseOffset = abs(cos(seed * 1.7)) * cycleDuration
                    var u = (now + phaseOffset).truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
                    if u < 0 { u += 1 }

                    // Distribute around the center with slow angular drift
                    let baseAngle = CGFloat(i) / CGFloat(Self.sparkleCount) * 2 * .pi
                        + sin(seed * 0.7) * 0.18
                    let angleDrift = sin(now * 0.5 + seed * 0.3) * 0.12
                    let angle = baseAngle + angleDrift

                    // Radius grows fast at start, slows toward outside
                    let radiusT = pow(u, 0.65)
                    let r = innerR + (outerR - innerR) * radiusT

                    let x = center.x + cos(angle) * r
                    let y = center.y + sin(angle) * r

                    // Bell-curve opacity (fades in, peaks, fades out)
                    let bell = sin(u * .pi)
                    let twinkle: CGFloat = 0.55 + 0.45 * sin(now * 5 + seed * 4)
                    let opacity = bell * twinkle

                    // Pulsing scale
                    let scale: CGFloat = 0.65 + 0.35 * sin(now * 3.5 + seed * 2)
                    let sparkleSize: CGFloat = 5.5 * scale

                    // Color rotation: gold / warm white / soft rose
                    let color: Color
                    switch i % 3 {
                    case 0: color = Color(red: 1.0, green: 0.86, blue: 0.55)
                    case 1: color = Color(red: 1.0, green: 0.96, blue: 0.88)
                    default: color = Color(red: 1.0, green: 0.80, blue: 0.82)
                    }

                    // Soft halo glow underneath the star
                    let halo = Path(ellipseIn: CGRect(
                        x: x - sparkleSize * 1.7,
                        y: y - sparkleSize * 1.7,
                        width: sparkleSize * 3.4,
                        height: sparkleSize * 3.4
                    ))
                    context.fill(halo, with: .color(color.opacity(opacity * 0.20)))

                    // Sharp 4-point sparkle star
                    let star = sparkleStar(at: CGPoint(x: x, y: y), size: sparkleSize)
                    context.fill(star, with: .color(color.opacity(opacity * 0.95)))
                }
            }
        }
    }

    private func sparkleStar(at center: CGPoint, size: CGFloat) -> Path {
        Path { p in
            let s = size
            let inner = size * 0.22
            p.move(to: CGPoint(x: center.x, y: center.y - s))
            p.addLine(to: CGPoint(x: center.x + inner, y: center.y - inner))
            p.addLine(to: CGPoint(x: center.x + s, y: center.y))
            p.addLine(to: CGPoint(x: center.x + inner, y: center.y + inner))
            p.addLine(to: CGPoint(x: center.x, y: center.y + s))
            p.addLine(to: CGPoint(x: center.x - inner, y: center.y + inner))
            p.addLine(to: CGPoint(x: center.x - s, y: center.y))
            p.addLine(to: CGPoint(x: center.x - inner, y: center.y - inner))
            p.closeSubpath()
        }
    }
}

#Preview {
    NavigationStack {
        AutoFlowerCreatorView()
    }
}
