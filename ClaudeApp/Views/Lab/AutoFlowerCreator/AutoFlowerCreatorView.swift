import SwiftUI
import SwiftData

// MARK: - Auto Flower Creator View

struct AutoFlowerCreatorView: View {

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
    @State private var ageInput: String = ""
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

    // Mini-flower hold tracking (tap vs press-and-hold differentiation)
    @State private var miniHoldStartTime: Date? = nil
    @State private var miniHoldResetTask: Task<Void, Never>? = nil

    @Environment(\.modelContext) private var modelContext

    @FocusState private var ageFieldFocused: Bool
    @FocusState private var nameFieldFocused: Bool

    private let stepHaptic = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    generatedHeader

                    if phase.isNoted {
                        notedContentStage
                    } else {
                        flowerStage
                        storyText
                        inputStage
                        stepIndicator
                    }

                    footerButton
                }
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, phase.isNoted ? 160 : AppTheme.Spacing.xxl)
                .animation(.spring(response: 0.7, dampingFraction: 0.78), value: phase)
                .animation(.spring(response: 0.6, dampingFraction: 0.82), value: showNervousSystem)
            }

            if phase.isNoted,
               let config = generated?.config {
                VStack(spacing: AppTheme.Spacing.sm) {
                    if let message = toastMessage {
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

                    MiniFlowerWidget(
                        config: config,
                        isHolding: $isHolding,
                        holdProgress: $holdProgress,
                        bloomState: $bloomState
                    )
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
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Auto Flower")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startBudPulse() }
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
        }
        .onChange(of: isHolding) { oldValue, newValue in
            if phase.isInteractive, oldValue, !newValue {
                noteEmotionalState()
                return
            }
            if phase.isNoted {
                handleMiniFlowerHoldChange(oldValue: oldValue, newValue: newValue)
            }
        }
    }

    // MARK: - Header (only after generation begins)

    @ViewBuilder
    private var generatedHeader: some View {
        if let g = generated, !phase.isInput {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(g.displayName)
                    .warmTitle()
                if phase.isBloomedScene {
                    Text(g.flowerName)
                        .affirmationStyle()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, AppTheme.Spacing.md)
            .transition(.opacity)
        }
    }

    // MARK: - Flower Stage

    private var flowerStage: some View {
        let config = generated?.config ?? Self.restingConfig
        let showSparkles = phase.isBloomedScene && holdProgress >= 0.88

        return ZStack {
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
            .frame(width: 300, height: 300)
            .scaleEffect(phase.isInput ? budPulse : 1.0)

            if showSparkles {
                SparkleEmitter()
                    .frame(width: 360, height: 360)
                    .allowsHitTesting(false)
                    .transition(.opacity.animation(.easeInOut(duration: 1.2)))
            }
        }
        .frame(width: 360, height: 360)
        .padding(.vertical, AppTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.6), value: showSparkles)
        .contentShape(Rectangle())
        .onTapGesture {
            if phase.isCaptured {
                beginShrinkToNoted()
            }
        }
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

            if showNervousSystem, let ns = dailyGuidance?.nervousSystemGuidance {
                NotedNervousSystemSection(guidance: ns)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        )
                    )
            }
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var notedPhaseHeader: some View {
        if let position = cyclePosition, let g = dailyGuidance {
            PhaseHeaderView(
                greeting: g.greeting,
                phase: position.phase,
                dayInCycle: position.dayInCycle,
                cycleLength: Self.defaultCycleLength
            )
        }
    }

    /// Borderless clone of `DailyGuidanceCard` — same layout & typography
    /// but without the `.warmCard()` chrome, so the screen feels like one
    /// continuous page.
    @ViewBuilder
    private var notedGuidanceSection: some View {
        if let g = dailyGuidance {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(g.phase.accentColor)
                    Text("Today's Guidance")
                        .warmHeadline()
                }

                Text(g.protectMessage)
                    .guidanceText()
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(g.phase.accentColor.opacity(0.2))

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "clock")
                        .foregroundStyle(g.phase.accentColor.opacity(0.7))
                        .font(.caption)
                    Text(g.decisionTiming)
                        .font(.system(.caption, design: AppTheme.fontFamily))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.Spacing.lg)
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
            .frame(maxWidth: .infinity, minHeight: 160)
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
                TextField(
                    "",
                    text: $ageInput,
                    prompt: Text("years")
                        .font(.system(.title2, design: .serif).italic())
                        .foregroundStyle(Color.appSoftBrown.opacity(0.35))
                )
                .font(.system(.title2, design: .serif).italic())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appSoftBrown)
                .keyboardType(.numberPad)
                .focused($ageFieldFocused)
                .frame(maxWidth: 180)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(Color.appRose.opacity(0.4))
                        .frame(height: 1)
                }

                if let hint = phaseOfLifeHint {
                    Text(hint)
                        .font(.system(.footnote, design: .serif))
                        .italic()
                        .foregroundStyle(Color.appRose.opacity(0.85))
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                ageFieldFocused = true
            }
        }
    }

    /// Soft acknowledgement when the user is outside her bleeding years.
    private var phaseOfLifeHint: String? {
        guard let n = parsedAge else { return nil }
        if n < 13 { return "Maiden \u{2014} your bleed has yet to come" }
        if n >= 50 { return "Wise woman \u{2014} beyond the bleed" }
        return nil
    }

    private var parsedAge: Int? {
        Int(ageInput.trimmingCharacters(in: .whitespacesAndNewlines))
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
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                nameFieldFocused = true
            }
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
            if inputStep < Self.totalInputSteps - 1 {
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
            guard let n = parsedAge else { return false }
            return n > 0 && n < 120
        case 2:
            return !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return false
        }
    }

    private func advanceStep() {
        guard currentStepValid, inputStep < Self.totalInputSteps - 1 else { return }
        ageFieldFocused = false
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
        ageFieldFocused = false

        let date = hasPeriod ? periodDate : Date()
        let archetype = MoonWomanArchetypeEngine.archetype(for: date)
        // Seed combines all user inputs so two women with different ages or
        // names get different flowers even if they share an archetype.
        let seed = "\(trimmed)|\(ageInput)|\(Int(date.timeIntervalSinceReferenceDate))"
        let config = MoonWomanArchetypeEngine.flowerConfig(for: archetype, seed: seed)
        let flowerName = FlowerNamingEngine.flowerName(for: trimmed)
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

    /// After the archetype title has faded in (~1.5s) we linger for a
    /// moment, then softly close the flower back to a bud and invite the
    /// user to press & hold it.
    private func scheduleInteractiveTransition() {
        interactiveTransitionTask?.cancel()
        interactiveTransitionTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            if Task.isCancelled { return }
            transitionToInteractive()
        }
    }

    private func transitionToInteractive() {
        withAnimation(.easeInOut(duration: 1.6)) {
            holdProgress = Self.restingBudProgress
            bloomState = .bud
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
            phase = .interactive
        }
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

        withAnimation(.spring(response: 0.9, dampingFraction: 0.78)) {
            notedBloomState = captured
            phase = .noted
        }

        scheduleHoldToast()
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

    // MARK: - Mini Flower Hold Handling
    //
    // The mini flower is re-interactive in the `.noted` phase: a quick tap
    // toggles the nervous system support section, while a press-and-hold
    // resets the bloom to bud and lets the user grow it again to a new
    // state. We differentiate the two by timing the hold — anything under
    // ~250 ms is treated as a tap, otherwise the flower resets after a
    // short delay (so a tap never accidentally collapses the bloom).

    private func handleMiniFlowerHoldChange(oldValue: Bool, newValue: Bool) {
        if !oldValue && newValue {
            // Press began
            miniHoldStartTime = Date()
            // Dismiss any lingering hint toast
            if toastMessage != nil {
                toastTask?.cancel()
                withAnimation(.easeOut(duration: 0.2)) { toastMessage = nil }
            }
            miniHoldResetTask?.cancel()
            miniHoldResetTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 250_000_000)
                if Task.isCancelled { return }
                // Real hold — reset to bud so the flower visibly grows
                // again from scratch while the finger is still down.
                withAnimation(.easeOut(duration: 0.3)) {
                    holdProgress = Self.restingBudProgress
                    bloomState = .bud
                }
            }
        } else if oldValue && !newValue {
            // Press released
            let elapsed = miniHoldStartTime.map { Date().timeIntervalSince($0) } ?? 0
            miniHoldStartTime = nil
            miniHoldResetTask?.cancel()
            miniHoldResetTask = nil

            if elapsed < 0.25 {
                // Quick tap — toggle the nervous system support section
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    showNervousSystem.toggle()
                }
            } else {
                // Real hold — snap (FlowerBloomCanvas already did), update
                // the noted state, and confirm with a brief toast.
                updateNotedState()
            }
        }
    }

    /// Updates the noted bloom state + daily guidance to whatever the
    /// user just held the flower to, and surfaces a confirmation toast.
    private func updateNotedState() {
        let snapped = BloomState.closest(to: holdProgress)
        notedBloomState = snapped
        prepareDailyContext(for: snapped)
        showToast("New state noted", duration: 1.8)
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
        withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
            phase = .input
            generated = nil
            holdProgress = Self.restingBudProgress
            bloomState = .bud
            inputStep = 0
            ageInput = ""
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
// Once the user has noted their emotional state, the full-size flower
// shrinks and drops to the bottom of the screen as a small pulsing
// widget. Tapping it opens the inline nervous system support section.
// The widget shares the same `isHolding/holdProgress/bloomState`
// bindings as the main view so the flower continues to render the
// exact bloom stage the user landed on.
private struct MiniFlowerWidget: View {
    let config: AutoFlowerConfig
    @Binding var isHolding: Bool
    @Binding var holdProgress: CGFloat
    @Binding var bloomState: BloomState

    @State private var pulse: CGFloat = 1.0

    var body: some View {
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
            interactive: true
        )
        .frame(width: 76, height: 76)
        .scaleEffect(isHolding ? 1.0 : pulse)
        .animation(.easeInOut(duration: 0.25), value: isHolding)
        .onAppear {
            pulse = 1.0
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulse = 1.1
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
