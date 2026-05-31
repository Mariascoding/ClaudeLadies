import SwiftUI
import SwiftData

// MARK: - Cycle Bloom
//
// Re-uses the Auto Flower's generated flower (same archetype +
// config seeded from name/age/period), but renders it in the
// inner-season state dictated by the user's cycle phase:
//
//   · Menstrual   (Inner Winter)   → bud, cool muted palette
//   · Follicular  (Inner Spring)   → opening, fresh
//   · Ovulation   (Inner Summer)   → blooming, full warmth
//   · Luteal      (Inner Autumn)   → flourishing, rich gold
//
// Intake mirrors Auto Flower's multi-step flow so we can pick any
// last-period date and watch the flower land in the matching inner
// season — useful for testing every state.

struct CycleBloomView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \AutoFlowerProfile.createdDate, order: .reverse)
    private var savedProfiles: [AutoFlowerProfile]

    // Intake state — mirrors AutoFlowerCreatorView
    @State private var showingIntro: Bool = true
    @State private var inputStep: Int = 0          // 0=period, 1=age, 2=name
    @State private var hasPeriod: Bool = true
    @State private var periodDate: Date = .now
    @State private var ageSelection: Int = 28
    @State private var nameInput: String = ""

    @FocusState private var nameFieldFocused: Bool

    @State private var composition: Composition? = nil
    @State private var budPulse: CGFloat = 1.0
    /// Dev switch — when set, forces the bloom view to render in this
    /// season regardless of the actual cycle position.
    @State private var seasonOverride: InnerSeason? = nil

    private static let totalInputSteps: Int = 3
    private static let ageRange: ClosedRange<Int> = 10...80
    private static let restingBudProgress: CGFloat = 0.11

    private var savedProfile: AutoFlowerProfile? { savedProfiles.first }

    var body: some View {
        ZStack {
            if let c = composition {
                let effective = effectiveComposition(c)
                seasonalBackground(season: effective.season).ignoresSafeArea()
                bloomStage(composition: effective)
            } else {
                Color.appCream.ignoresSafeArea()
                intakeFlow
            }
        }
        .overlay(alignment: .topTrailing) {
            if composition == nil {
                devSkipButton
            }
        }
        .navigationTitle("Cycle Bloom")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            budPulse = 1.0
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                budPulse = 1.07
            }
        }
    }

    // MARK: - Intake Flow (multi-step, mirrors Auto Flower)

    @ViewBuilder
    private var intakeFlow: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    budFlowerStage

                    Spacer(minLength: 0)

                    VStack(spacing: AppTheme.Spacing.lg) {
                        if showingIntro {
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
                .animation(.easeInOut(duration: 0.45), value: showingIntro)
                .animation(.easeInOut(duration: 0.55), value: inputStep)
            }
        }
    }

    // MARK: - Bud Flower (centred during intake)

    @ViewBuilder
    private var budFlowerStage: some View {
        FlowerBloomCanvas(
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
            ),
            isHolding: .constant(false),
            holdProgress: .constant(Self.restingBudProgress),
            bloomState: .constant(.bud),
            showBackground: false,
            interactive: false
        )
        .frame(width: 200, height: 200)
        .scaleEffect(budPulse)
        .frame(width: 240, height: 240)
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: - Intro Stage (marketing copy + Begin / Continue-as)

    @ViewBuilder
    private var introStage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Watch your flower bloom through every season of your cycle.")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.90))
                Text("Bud, opening, opened, flourishing — all the same flower.")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(Color.appRose)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Spacing.xl)

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
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity.combined(with: .move(edge: .top))
            )
        )
    }

    // MARK: - Input Stage (period → age → name)

    @ViewBuilder
    private var inputStage: some View {
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
    }

    // Period yes/no + date

    @ViewBuilder
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

    @ViewBuilder
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

    // Age picker

    @ViewBuilder
    private var ageFloating: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("How many seasons have you walked?")
                .font(.system(.title3, design: .serif))
                .italic()
                .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                .multilineTextAlignment(.center)

            Menu {
                Picker("Age", selection: $ageSelection) {
                    ForEach(Self.ageRange, id: \.self) { Text("\($0) years").tag($0) }
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
                    Capsule().fill(Color.appRose.opacity(0.4)).frame(height: 1)
                }
            }
            .tint(Color.appRose)
        }
    }

    // Name

    @ViewBuilder
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
                Capsule().fill(Color.appRose.opacity(0.4)).frame(height: 1)
            }
            .submitLabel(.done)
            .onSubmit(handleKeyboardSubmit)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: handleKeyboardSubmit) {
                        Text("Express")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(currentStepValid ? Color.appRose : Color.appSoftBrown.opacity(0.4))
                    }
                    .disabled(!currentStepValid)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                nameFieldFocused = true
            }
        }
    }

    // Step indicator (3 dots)

    @ViewBuilder
    private var stepIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(0..<Self.totalInputSteps, id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(i == inputStep ? Color.appRose : Color.appSoftBrown.opacity(0.25))
                    .frame(width: i == inputStep ? 22 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: inputStep)
    }

    // Footer button (Begin / Continue / Express)

    @ViewBuilder
    private var footerButton: some View {
        if showingIntro {
            beginButton
        } else if inputStep < Self.totalInputSteps - 1 {
            continueButton
        } else {
            expressButton
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
        return Button(action: advanceStep) {
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
        return Button(action: completeIntake) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "wand.and.stars")
                Text("Bloom")
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

    // Dev skip — jump straight to the bloom view with saved profile or
    // a default "Dev" so we don't have to re-run intake while iterating.

    private var devSkipButton: some View {
        Button(action: skipToBloom) {
            HStack(spacing: 4) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 9))
                Text("skip")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
            }
            .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.appWarmWhite.opacity(0.85))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.appSoftBrown.opacity(0.25), lineWidth: 0.5)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.trailing, AppTheme.Spacing.md)
        .zIndex(10)
    }

    // MARK: - Step Logic

    private var currentStepValid: Bool {
        switch inputStep {
        case 0: return true
        case 1: return Self.ageRange.contains(ageSelection)
        case 2: return !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return false
        }
    }

    private func advanceStep() {
        guard currentStepValid, inputStep < Self.totalInputSteps - 1 else { return }
        nameFieldFocused = false
        withAnimation(.easeInOut(duration: 0.55)) {
            inputStep += 1
        }
    }

    private func handleKeyboardSubmit() {
        guard currentStepValid else { return }
        if inputStep < Self.totalInputSteps - 1 {
            advanceStep()
        } else {
            completeIntake()
        }
    }

    private func completeIntake() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        guard !trimmed.isEmpty else { return }
        nameFieldFocused = false

        let resolvedDate = hasPeriod ? periodDate : .now

        // Update / insert the shared AutoFlowerProfile so Auto Flower
        // and Cycle Bloom share the same flower identity.
        if let existing = savedProfile {
            existing.displayName = trimmed
            existing.ageSelection = ageSelection
            existing.hasPeriod = hasPeriod
            existing.periodDate = resolvedDate
            existing.createdDate = .now
        } else {
            let profile = AutoFlowerProfile(
                displayName: trimmed,
                ageSelection: ageSelection,
                hasPeriod: hasPeriod,
                periodDate: resolvedDate
            )
            modelContext.insert(profile)
        }
        try? modelContext.save()

        let c = Composition.build(
            displayName: trimmed,
            ageSelection: ageSelection,
            periodDate: resolvedDate
        )
        withAnimation(.spring(response: 0.9, dampingFraction: 0.78)) {
            composition = c
        }
    }

    private func loadFlower(from profile: AutoFlowerProfile) {
        nameInput = profile.displayName
        ageSelection = profile.ageSelection
        hasPeriod = profile.hasPeriod
        periodDate = profile.periodDate
        let c = Composition.build(
            displayName: profile.displayName,
            ageSelection: profile.ageSelection,
            periodDate: profile.hasPeriod ? profile.periodDate : .now
        )
        withAnimation(.easeInOut(duration: 0.6)) {
            composition = c
        }
    }

    private func skipToBloom() {
        if let profile = savedProfile {
            loadFlower(from: profile)
            return
        }
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? "Dev" : trimmed.capitalized
        let date = hasPeriod ? periodDate : .now
        let c = Composition.build(
            displayName: name,
            ageSelection: ageSelection,
            periodDate: date
        )
        withAnimation(.easeInOut(duration: 0.45)) {
            composition = c
        }
    }

    // MARK: - Bloom Stage (centred flower with metadata)

    /// Returns a Composition with the dev `seasonOverride` applied if
    /// one is selected. Lets us preview every bloom stage without
    /// needing to pick a different last-period date.
    private func effectiveComposition(_ base: Composition) -> Composition {
        guard let override = seasonOverride, override != base.season else {
            return base
        }
        return base.withSeason(override)
    }

    @ViewBuilder
    private func bloomStage(composition c: Composition) -> some View {
        VStack(spacing: 0) {
            stageSwitcher(currentSeason: c.season)
                .padding(.top, AppTheme.Spacing.xs)

            topMetadata(composition: c)
                .padding(.top, AppTheme.Spacing.xs)

            Spacer(minLength: 0)

            ZStack {
                SeasonalParticles(season: c.season)
                    .frame(width: 360, height: 360)
                    .allowsHitTesting(false)

                CycleBloomFlower(composition: c)
                    .frame(width: 300, height: 300)
                    .saturation(c.season.saturationBoost)
            }

            Spacer(minLength: 0)

            bottomMetadata(composition: c)
                .padding(.bottom, AppTheme.Spacing.lg)

            Button {
                withAnimation(.easeInOut(duration: 0.45)) {
                    composition = nil
                    showingIntro = true
                    inputStep = 0
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New flower")
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
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .transition(.opacity)
    }

    /// Dev pill row that flips between the four bloom stages on tap.
    /// Active pill is filled in the season's accent colour; an "AUTO"
    /// pill clears the override so the cycle phase takes over again.
    @ViewBuilder
    private func stageSwitcher(currentSeason: InnerSeason) -> some View {
        HStack(spacing: 6) {
            Text("STAGE")
                .font(.system(size: 8, weight: .medium))
                .tracking(2.5)
                .foregroundStyle(Color.appSoftBrown.opacity(0.45))
                .padding(.trailing, 4)

            ForEach(InnerSeason.allCases, id: \.self) { season in
                stagePill(
                    label: season.shortLabel,
                    active: currentSeason == season,
                    onTap: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                            seasonOverride = season
                        }
                    }
                )
            }

            stagePill(
                label: "AUTO",
                active: seasonOverride == nil,
                onTap: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                        seasonOverride = nil
                    }
                }
            )
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.appWarmWhite.opacity(0.85))
        )
    }

    @ViewBuilder
    private func stagePill(label: String, active: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(active ? .white : Color.appSoftBrown.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule(style: .continuous)
                        .fill(active ? Color.appRose : Color.clear)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.appSoftBrown.opacity(active ? 0 : 0.18), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func topMetadata(composition c: Composition) -> some View {
        VStack(spacing: 4) {
            Text("CYCLE BLOOM")
                .font(.system(size: 9, weight: .medium))
                .tracking(4)
                .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            Text(c.displayName)
                .font(.custom("SnellRoundhand-Bold", size: 32))
                .foregroundStyle(c.tinted.outer)
        }
    }

    @ViewBuilder
    private func bottomMetadata(composition c: Composition) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text(c.season.title.uppercased())
                .font(.system(size: 11, weight: .medium))
                .tracking(4)
                .foregroundStyle(c.tinted.outer.opacity(0.85))

            Text(c.season.lyric)
                .font(.system(.subheadline, design: .serif, weight: .light))
                .italic()
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            HStack(spacing: AppTheme.Spacing.lg) {
                metaItem(label: "PHASE", value: c.season.matchingPhase.displayName)
                divider()
                metaItem(label: "DAY", value: "\(c.position.dayInCycle) / \(c.cycleLength)")
                divider()
                metaItem(label: "STAGE", value: c.season.bloomState.displayName)
            }
            .padding(.top, AppTheme.Spacing.xs)
        }
    }

    @ViewBuilder
    private func metaItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .tracking(2)
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            Text(value)
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundStyle(Color.appSoftBrown)
        }
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color.appSoftBrown.opacity(0.2))
            .frame(width: 0.5, height: 22)
    }

    // MARK: - Seasonal Background

    @ViewBuilder
    private func seasonalBackground(season: InnerSeason) -> some View {
        LinearGradient(
            colors: season.backgroundGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Composition

extension CycleBloomView {
    struct Composition {
        let displayName: String
        let position: CycleCalculator.CyclePosition
        let cycleLength: Int
        let season: InnerSeason
        let config: AutoFlowerConfig
        let tinted: (outer: Color, inner: Color, stamen: Color, center: Color)
        /// One of seven gorgeous petal silhouettes, derived from the
        /// display name so each user gets a slightly different flower.
        let flowerType: CycleFlowerType

        static func build(
            displayName: String,
            ageSelection: Int,
            periodDate: Date
        ) -> Composition {
            let cycleLength = 28
            let periodLength = 5
            let position = CycleCalculator.currentPosition(
                lastPeriodStart: periodDate,
                cycleLength: cycleLength,
                periodLength: periodLength
            )
            let season = InnerSeason.season(for: position.phase)

            let archetype = MoonWomanArchetypeEngine.archetype(for: periodDate)
            let seed = "\(displayName)|\(ageSelection)|\(Int(periodDate.timeIntervalSinceReferenceDate))"
            let config = MoonWomanArchetypeEngine.flowerConfig(for: archetype, seed: seed)

            let tinted = season.tint(
                outer: config.outerColor,
                inner: config.innerColor,
                stamen: config.stamenColor,
                center: config.centerColor
            )

            let typeIndex = abs(displayName.hashValue) % CycleFlowerType.allCases.count
            let flowerType = CycleFlowerType.allCases[typeIndex]

            return Composition(
                displayName: displayName,
                position: position,
                cycleLength: cycleLength,
                season: season,
                config: config,
                tinted: tinted,
                flowerType: flowerType
            )
        }

        /// Returns a copy of this composition with the season swapped
        /// (re-applying the season's tint to the base config colours).
        /// Used by the dev stage-switcher.
        func withSeason(_ newSeason: InnerSeason) -> Composition {
            let newTinted = newSeason.tint(
                outer: config.outerColor,
                inner: config.innerColor,
                stamen: config.stamenColor,
                center: config.centerColor
            )
            return Composition(
                displayName: displayName,
                position: position,
                cycleLength: cycleLength,
                season: newSeason,
                config: config,
                tinted: newTinted,
                flowerType: flowerType
            )
        }

        /// Returns a copy with the season swapped but the existing
        /// tinted palette preserved. Used by the auto-flower building
        /// animation so the bud → blossom → full morph keeps the same
        /// cycle-phase colour throughout, instead of swapping palettes
        /// each time the season changes.
        func withSeasonKeepingTint(_ newSeason: InnerSeason) -> Composition {
            Composition(
                displayName: displayName,
                position: position,
                cycleLength: cycleLength,
                season: newSeason,
                config: config,
                tinted: tinted,
                flowerType: flowerType
            )
        }
    }
}

// MARK: - Cycle Flower Type
//
// Seven gorgeous petal silhouettes, all drawn as variations on the
// same top-down teardrop so the family aesthetic stays consistent
// while each user gets a uniquely-shaped flower.

enum CycleFlowerType: String, CaseIterable, Identifiable {
    case tulip       // classic teardrop, wide rounded top
    case daisy       // slender petal
    case lotus       // wide and rounded
    case peony       // soft rippled edges
    case rose        // heart-tipped petal with a gentle notch
    case magnolia    // long oval with pointed tip
    case hibiscus    // bell-shaped, wider near the top

    var id: String { rawValue }

    /// Path of one petal, normalised to the given rect. All shapes
    /// keep the same base-at-bottom / tip-at-top orientation so they
    /// can be radial-laid-out identically by the renderer.
    func petalPath(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        switch self {
        case .tulip:
            return Path { p in
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: 0),
                               control: CGPoint(x: w * 1.05, y: h * 0.35))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: h),
                               control: CGPoint(x: -w * 0.05, y: h * 0.35))
                p.closeSubpath()
            }

        case .daisy:
            return Path { p in
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: 0),
                               control: CGPoint(x: w * 0.78, y: h * 0.55))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: h),
                               control: CGPoint(x: w * 0.22, y: h * 0.55))
                p.closeSubpath()
            }

        case .lotus:
            return Path { p in
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addCurve(to: CGPoint(x: w / 2, y: 0),
                           control1: CGPoint(x: w * 1.20, y: h * 0.65),
                           control2: CGPoint(x: w * 0.75, y: h * 0.08))
                p.addCurve(to: CGPoint(x: w / 2, y: h),
                           control1: CGPoint(x: w * 0.25, y: h * 0.08),
                           control2: CGPoint(x: -w * 0.20, y: h * 0.65))
                p.closeSubpath()
            }

        case .peony:
            return Path { p in
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.55),
                               control: CGPoint(x: w * 1.05, y: h * 0.85))
                p.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.10),
                               control: CGPoint(x: w * 1.10, y: h * 0.25))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: 0),
                               control: CGPoint(x: w * 0.60, y: -h * 0.05))
                p.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.10),
                               control: CGPoint(x: w * 0.40, y: -h * 0.05))
                p.addQuadCurve(to: CGPoint(x: w * 0.08, y: h * 0.55),
                               control: CGPoint(x: -w * 0.10, y: h * 0.25))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: h),
                               control: CGPoint(x: -w * 0.05, y: h * 0.85))
                p.closeSubpath()
            }

        case .rose:
            return Path { p in
                // Heart-tipped: a quad curve up to a soft notch at top
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.30),
                               control: CGPoint(x: w * 1.10, y: h * 0.75))
                p.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.05),
                               control: CGPoint(x: w * 0.90, y: -h * 0.02))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: h * 0.18),
                               control: CGPoint(x: w * 0.52, y: h * 0.05))
                p.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.05),
                               control: CGPoint(x: w * 0.48, y: h * 0.05))
                p.addQuadCurve(to: CGPoint(x: w * 0.10, y: h * 0.30),
                               control: CGPoint(x: w * 0.10, y: -h * 0.02))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: h),
                               control: CGPoint(x: -w * 0.10, y: h * 0.75))
                p.closeSubpath()
            }

        case .magnolia:
            return Path { p in
                // Long oval with a pointed tip
                p.move(to: CGPoint(x: w / 2, y: h))
                p.addCurve(to: CGPoint(x: w / 2, y: -h * 0.04),
                           control1: CGPoint(x: w * 0.98, y: h * 0.75),
                           control2: CGPoint(x: w * 0.82, y: h * 0.10))
                p.addCurve(to: CGPoint(x: w / 2, y: h),
                           control1: CGPoint(x: w * 0.18, y: h * 0.10),
                           control2: CGPoint(x: w * 0.02, y: h * 0.75))
                p.closeSubpath()
            }

        case .hibiscus:
            return Path { p in
                // Bell-like: wide near the top, narrows toward base
                p.move(to: CGPoint(x: w * 0.42, y: h))
                p.addQuadCurve(to: CGPoint(x: w / 2, y: 0),
                               control: CGPoint(x: w * 1.15, y: h * 0.40))
                p.addQuadCurve(to: CGPoint(x: w * 0.58, y: h),
                               control: CGPoint(x: -w * 0.15, y: h * 0.40))
                p.closeSubpath()
            }
        }
    }

    /// Display name for the seven flower silhouettes.
    var displayName: String {
        switch self {
        case .tulip:    "Tulip"
        case .daisy:    "Daisy"
        case .lotus:    "Lotus"
        case .peony:    "Peony"
        case .rose:     "Rose"
        case .magnolia: "Magnolia"
        case .hibiscus: "Hibiscus"
        }
    }
}

// MARK: - Inner Season

enum InnerSeason: String, CaseIterable {
    case winter, spring, summer, autumn

    static func season(for phase: CyclePhase) -> InnerSeason {
        switch phase {
        case .menstrual:  .winter
        case .follicular: .spring
        case .ovulation:  .summer
        case .luteal:     .autumn
        }
    }

    /// Inverse of `season(for:)` — used by the bottom-metadata strip
    /// so the displayed phase reflects whichever bloom stage is being
    /// shown (including overrides from the dev stage-switcher).
    var matchingPhase: CyclePhase {
        switch self {
        case .winter: .menstrual
        case .spring: .follicular
        case .summer: .ovulation
        case .autumn: .luteal
        }
    }

    var title: String {
        switch self {
        case .winter: "Inner Winter"
        case .spring: "Inner Spring"
        case .summer: "Inner Summer"
        case .autumn: "Inner Autumn"
        }
    }

    /// Short label for the dev stage-switcher pills.
    var shortLabel: String {
        switch self {
        case .winter: "BUD"
        case .spring: "OPEN"
        case .summer: "FULL"
        case .autumn: "SHED"
        }
    }

    var lyric: String {
        switch self {
        case .winter: "still / closed / drawing inward"
        case .spring: "tender shoots / energy rising"
        case .summer: "full open / radiant heat"
        case .autumn: "golden / ripe / abundant"
        }
    }

    var bloomState: BloomState {
        switch self {
        case .winter: .bud
        case .spring: .budding
        case .summer: .blooming
        case .autumn: .flourishing
        }
    }

    var bloomProgress: CGFloat {
        switch self {
        case .winter: 0.20
        case .spring: 0.45
        case .summer: 0.78
        case .autumn: 1.00
        }
    }

    var saturationBoost: Double {
        switch self {
        case .winter: 0.78
        case .spring: 0.95
        case .summer: 1.15
        case .autumn: 1.10
        }
    }

    /// Rendered-flower size as a fraction of its container, by inner
    /// season. A bud is always small; the flower grows as the season
    /// progresses toward full bloom. Apply via `.scaleEffect` at call
    /// sites so the bud stays tiny everywhere it appears.
    var bloomScale: CGFloat {
        switch self {
        case .winter: 0.50   // closed bud — small
        case .spring: 0.72   // blossoming — medium
        case .summer: 1.00   // full flourishing flower
        case .autumn: 0.88   // past peak, slightly shrunken
        }
    }

    var backgroundGradient: [Color] {
        switch self {
        case .winter:
            return [Color(red: 0.94, green: 0.93, blue: 0.95),
                    Color(red: 0.88, green: 0.87, blue: 0.91)]
        case .spring:
            return [Color(red: 0.97, green: 0.95, blue: 0.92),
                    Color(red: 0.94, green: 0.93, blue: 0.88)]
        case .summer:
            return [Color(red: 0.99, green: 0.96, blue: 0.91),
                    Color(red: 0.96, green: 0.91, blue: 0.82)]
        case .autumn:
            return [Color(red: 0.98, green: 0.94, blue: 0.88),
                    Color(red: 0.92, green: 0.84, blue: 0.72)]
        }
    }

    func tint(
        outer: Color, inner: Color, stamen: Color, center: Color
    ) -> (outer: Color, inner: Color, stamen: Color, center: Color) {
        let blend: Color
        let strength: Double
        switch self {
        case .winter:
            blend = Color(red: 0.78, green: 0.82, blue: 0.92); strength = 0.35
        case .spring:
            blend = Color(red: 0.92, green: 0.86, blue: 0.78); strength = 0.15
        case .summer:
            blend = Color(red: 1.00, green: 0.82, blue: 0.55); strength = 0.18
        case .autumn:
            blend = Color(red: 0.88, green: 0.62, blue: 0.32); strength = 0.25
        }
        return (
            outer:  outer.blended(with: blend, amount: strength),
            inner:  inner.blended(with: blend, amount: strength * 0.85),
            stamen: stamen,
            center: center.blended(with: blend, amount: strength * 0.5)
        )
    }
}

private extension Color {
    func blended(with other: Color, amount: Double) -> Color {
        let a = UIColor(self)
        let b = UIColor(other)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let t = CGFloat(min(max(amount, 0), 1))
        return Color(
            red:   Double(ar + (br - ar) * t),
            green: Double(ag + (bg - ag) * t),
            blue:  Double(ab + (bb - ab) * t)
        )
    }

    /// Blends this colour toward white by `amount` (0…1).
    func lighter(by amount: Double) -> Color {
        blended(with: .white, amount: amount)
    }

    /// Blends this colour toward black by `amount` (0…1).
    func darker(by amount: Double) -> Color {
        blended(with: .black, amount: amount)
    }
}

// MARK: - Cycle Bloom Flower (bird's-eye)
//
// Four distinct stages, all seen from above:
//
//   1. Winter / Bud      – broad green leaves spread around a small,
//                          closed round bud in the centre.
//   2. Spring / Opening  – leaves smaller, the bud is larger and the
//                          outermost petals are unfurling halfway.
//   3. Summer / Opened   – a full top-down rosette of petals, stamens
//                          visible in the centre.
//   4. Autumn / Shedding – one petal has drifted free of the cluster;
//                          a seed-pod centre is forming.
//
// Built bespoke with SwiftUI Shapes (CycleBloomPetalShape, LeafShape) and laid
// out radially from a single centre point so the flower reads as a
// bird's-eye view rather than a side profile.

struct CycleBloomFlower: View {
    let composition: CycleBloomView.Composition

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    @State private var phase: CGFloat = 0
    @State private var breath: CGFloat = 1.0

    private var leafColor: Color { Color(red: 0.42, green: 0.58, blue: 0.36) }
    private var leafDeep:  Color { Color(red: 0.28, green: 0.44, blue: 0.26) }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                leavesLayer(size: size, center: center)
                petalsLayer(size: size, center: center)
                centerLayer(size: size, center: center)
                if composition.season == .autumn {
                    sheddingPetal(size: size, center: center)
                }
                // Magical shiny dust drifting across the petals,
                // present in every stage so the flower always reads
                // a touch enchanted.
                ShinyDustLayer(
                    accent: composition.tinted.outer,
                    radius: size * 0.42
                )
                .frame(width: size, height: size)
                .allowsHitTesting(false)
            }
            .scaleEffect(breath)
        }
        .onReceive(timer) { _ in
            phase += 1.0 / 60.0
            breath = 1.0 + sin(phase * 1.6) * 0.012
        }
    }

    // MARK: - Leaves
    // Visible at the bud + opening stages, hidden once the flower is
    // fully opened (petals cover them in a top-down view).

    @ViewBuilder
    private func leavesLayer(size: CGFloat, center: CGPoint) -> some View {
        switch composition.season {
        case .winter:
            // Broad, round lotus pads — much larger than spring's
            // pointed leaves, with subtle overlap and slow sway.
            lotusPads(size: size, center: center)
        case .spring, .summer, .autumn:
            // The four green leaves persist through opening, full bloom
            // and shedding — they're the flower's living stem cushion.
            pointedLeaves(size: size, center: center)
        }
    }

    @ViewBuilder
    private func lotusPads(size: CGFloat, center: CGPoint) -> some View {
        let count = 6
        ForEach(0..<count, id: \.self) { i in
            let baseAngle = Double(i) / Double(count) * 360
            let sway = sin(Double(phase) * 0.45 + Double(i) * 1.2) * 1.8
            Ellipse()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.52, green: 0.68, blue: 0.42), location: 0.0),
                            .init(color: Color(red: 0.42, green: 0.58, blue: 0.34), location: 0.5),
                            .init(color: Color(red: 0.24, green: 0.38, blue: 0.22), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 138, height: 96)
                .shadow(color: Color(red: 0.20, green: 0.30, blue: 0.18).opacity(0.30),
                        radius: 6, x: 2, y: 6)
                .offset(y: -64)
                .rotationEffect(.degrees(baseAngle + sway))
                .position(center)
        }
    }

    @ViewBuilder
    private func pointedLeaves(size: CGFloat, center: CGPoint) -> some View {
        let count = 4
        let leafSize = leafSpec
        let outer = leafOuterReach
        let baseRotation = leafBaseRotation
        // Constant clockwise twist applied to every flower so the leaf
        // cluster leans about one leaf's width to the right of true.
        let rightwardTwist: Double = 62
        ForEach(0..<count, id: \.self) { i in
            // Evenly spaced 90° intervals — the only per-flower
            // variance now lives in baseRotation (cluster rotation as
            // a whole) and the universal rightward twist.
            let baseAngle = Double(i) / Double(count) * 360
                + baseRotation
                + rightwardTwist
            let sway = sin(Double(phase) * 0.6 + Double(i) * 1.7) * 2.5
            LeafShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: leafColor.lighter(by: 0.12), location: 0.0),
                            .init(color: leafColor,                   location: 0.55),
                            .init(color: leafDeep,                    location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: leafSize.width, height: leafSize.length)
                .shadow(color: leafDeep.opacity(0.30), radius: 3, x: 1, y: 3)
                .offset(y: -(leafSize.length / 2 + outer))
                .rotationEffect(.degrees(baseAngle + sway))
                .position(center)
        }
    }

    /// Deterministic per-flower rotation offset for the leaf cluster as
    /// a whole — derived from the displayName hash so the same flower
    /// always has the same leaf orientation, but different flowers
    /// land at different angles (no two flowers look identically
    /// arranged at the compass points).
    private var leafBaseRotation: Double {
        let hash = abs(composition.displayName.hashValue)
        return Double(hash % 360) - 180  // –180° … +180°
    }

    /// Small per-leaf jitter so even the same flower's four leaves
    /// don't sit at perfectly spaced 90° intervals.
    private func leafJitter(for index: Int) -> Double {
        let hash = abs((composition.displayName + "\(index)").hashValue)
        return Double(hash % 26) - 13  // –13° … +13°
    }

    /// Pointed-leaf size grows a touch each stage so the cushion of
    /// greenery feels alive alongside the flower. Spring / summer /
    /// autumn leaves are all kept realistic — shorter and tucked
    /// closer to the flower centre rather than dramatically extended.
    private var leafSpec: (length: CGFloat, width: CGFloat) {
        switch composition.season {
        case .winter: return (length: 78, width: 42)
        case .spring: return (length: 70, width: 40)
        case .summer: return (length: 92, width: 50)
        case .autumn: return (length: 78, width: 44)
        }
    }

    /// How far outward (past the flower's centre + half a leaf) the
    /// leaves are pushed. Keeping the values modest so the leaves sit
    /// close to the flower's base — only tips peek past the petals.
    private var leafOuterReach: CGFloat {
        switch composition.season {
        case .winter: return 20
        case .spring: return 22
        case .summer: return 22
        case .autumn: return 22
        }
    }

    // MARK: - Petals
    // Number, size, and openness vary per stage. Petals are arranged
    // around the centre as teardrops pointing outward.

    @ViewBuilder
    private func petalsLayer(size: CGFloat, center: CGPoint) -> some View {
        let spec = petalSpec
        ForEach(0..<spec.count, id: \.self) { i in
            petal(at: i, total: spec.count, spec: spec, center: center)
        }
    }

    @ViewBuilder
    private func petal(
        at index: Int,
        total: Int,
        spec: PetalSpec,
        center: CGPoint
    ) -> some View {
        let baseAngle = Double(index) / Double(total) * 360 + spec.angleOffset
        let sway = sin(Double(phase) * 0.9 + Double(index) * 1.3) * 2.0
        // Autumn petals are slightly more transparent so the flower
        // reads as "past peak but still beautiful".
        let topOpacity: Double  = composition.season == .autumn ? 0.82 : 0.95
        let baseOpacity: Double = composition.season == .autumn ? 0.55 : 0.70

        // Depth via a three-stop radial-ish gradient — bright highlight
        // up near the tip, mid base in the body, deeper shadow down by
        // the petal base so each petal reads as a curving surface.
        let highlight = composition.tinted.outer.lighter(by: 0.18).opacity(topOpacity)
        let body      = composition.tinted.outer.opacity(topOpacity)
        let shade     = composition.tinted.outer.darker(by: 0.22).opacity(baseOpacity)

        CycleBloomPetalShape(type: composition.flowerType)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: highlight, location: 0.05),
                        .init(color: body,      location: 0.50),
                        .init(color: shade,     location: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Centre-shadow ridge — a faint dark line down the middle
            // gives each petal a hint of a fold so the surface reads as
            // 3D rather than a flat sticker.
            .overlay(
                CycleBloomPetalShape(type: composition.flowerType)
                    .fill(
                        LinearGradient(
                            colors: [
                                .black.opacity(0),
                                .black.opacity(0.08),
                                .black.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(0.6)
                    )
                    .mask(
                        Capsule()
                            .frame(width: max(spec.width * 0.18, 4), height: spec.length * 0.85)
                            .blur(radius: 2)
                    )
            )
            .frame(width: spec.width, height: spec.length)
            .shadow(color: composition.tinted.outer.darker(by: 0.35).opacity(0.20),
                    radius: 4, x: 1, y: 4)
            .offset(y: -spec.length / 2 - spec.inset)
            .rotationEffect(.degrees(baseAngle + sway + spec.curl))
            .position(center)
    }

    private struct PetalSpec {
        let count: Int
        let length: CGFloat
        let width: CGFloat
        /// Distance from centre that the petal *base* starts at.
        let inset: CGFloat
        /// Extra rotation applied to each petal — used to fold petals
        /// inward when the bloom is closed.
        let curl: Double
        /// Rotation offset applied to every petal — used by autumn to
        /// interlock the petals with the 4 leaves so the leaves peek
        /// between petals at the four compass points.
        var angleOffset: Double = 0
    }

    private var petalSpec: PetalSpec {
        switch composition.season {
        case .winter:
            // Outer petals are rendered as part of the layered bud
            return PetalSpec(count: 0, length: 0, width: 0, inset: 0, curl: 0)
        case .spring:
            // Tulip-style opening — 6 broad cupped petals overlapping,
            // gently curled inward, dark interior visible at centre.
            return PetalSpec(count: 6, length: 106, width: 80, inset: -18, curl: 6)
        case .summer:
            // Full rosette — lusher this round: 12 wider petals so
            // the flower reads as magnificent at peak.
            return PetalSpec(count: 12, length: 112, width: 72, inset: 6, curl: 0)
        case .autumn:
            // Past peak, over-opened: 5 large petals plus a single
            // tipping petal. AngleOffset 45° still lets leaves peek
            // between most petals at the cardinal positions.
            return PetalSpec(
                count: 5,
                length: 112,
                width: 78,
                inset: 14,
                curl: -7,
                angleOffset: 45
            )
        }
    }

    // MARK: - Shedding petal (autumn only) — one petal lightly tipping
    // off the cluster: the flower is over-open and a single petal is
    // beginning to detach, but is still close to where it was.

    @ViewBuilder
    private func sheddingPetal(size: CGFloat, center: CGPoint) -> some View {
        let spec = petalSpec
        fallingPetal(
            spec: spec,
            center: center,
            angle: 215,
            driftBase: 8,        // only a little — barely detached
            phaseOffset: 0,
            opacity: 0.78
        )
    }

    @ViewBuilder
    private func fallingPetal(
        spec: PetalSpec,
        center: CGPoint,
        angle: Double,
        driftBase: CGFloat,
        phaseOffset: Double,
        opacity: Double
    ) -> some View {
        let drift = driftBase + CGFloat(sin(Double(phase) * 0.45 + phaseOffset)) * 3
        let tilt  = 22 + sin(Double(phase) * 0.35 + phaseOffset) * 4
        let outer = composition.tinted.outer
        CycleBloomPetalShape(type: composition.flowerType)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: outer.lighter(by: 0.10).opacity(0.80), location: 0.0),
                        .init(color: outer.opacity(0.65),                   location: 0.5),
                        .init(color: outer.darker(by: 0.20).opacity(0.45),  location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: spec.width, height: spec.length)
            .shadow(color: outer.darker(by: 0.35).opacity(0.22),
                    radius: 4, x: 1, y: 4)
            .offset(y: -spec.length / 2 - spec.inset - drift)
            .rotationEffect(.degrees(angle + tilt))
            .position(center)
            .opacity(opacity)
    }

    // MARK: - Centre
    // Per-stage centre treatment: closed cap (bud), peeking bud
    // (opening), stamens (opened), seed pod (shedding).

    @ViewBuilder
    private func centerLayer(size: CGFloat, center: CGPoint) -> some View {
        switch composition.season {
        case .winter:
            lotusBudLayered(size: size, center: center)
        case .spring:
            tulipCenter(size: size, center: center)
        case .summer:
            openedCentre(size: size, center: center)
        case .autumn:
            seedPodCentre(size: size, center: center)
        }
    }

    /// Lotus-style closed bud seen from above: three concentric rings
    /// of overlapping teardrop petals coming together at a tight point
    /// in the centre, painted in a cream-blush palette that softens
    /// the user's seeded outer colour toward the lotus aesthetic.
    @ViewBuilder
    private func lotusBudLayered(size: CGFloat, center: CGPoint) -> some View {
        let p = lotusBudPalette

        ZStack {
            // Outer ring — 5 large teardrops, offset by 36° so the
            // middle ring sits in the gaps.
            ForEach(0..<5, id: \.self) { i in
                let angle = Double(i) / 5 * 360
                CycleBloomPetalShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: p.outerLight.lighter(by: 0.10), location: 0.0),
                                .init(color: p.outerLight,                   location: 0.45),
                                .init(color: p.outerDeep,                    location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 46, height: 70)
                    .shadow(color: p.outerDeep.darker(by: 0.30).opacity(0.25),
                            radius: 3, x: 1, y: 3)
                    .offset(y: -32)
                    .rotationEffect(.degrees(angle))
            }

            // Middle ring — sits in the seams of the outer ring.
            ForEach(0..<5, id: \.self) { i in
                let angle = Double(i) / 5 * 360 + 36
                CycleBloomPetalShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: p.midLight.lighter(by: 0.10), location: 0.0),
                                .init(color: p.midLight,                   location: 0.45),
                                .init(color: p.midDeep,                    location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 38, height: 54)
                    .shadow(color: p.midDeep.darker(by: 0.30).opacity(0.22),
                            radius: 2.5, x: 1, y: 2)
                    .offset(y: -23)
                    .rotationEffect(.degrees(angle))
            }

            // Inner ring — small tight petals forming the pointed tip.
            ForEach(0..<5, id: \.self) { i in
                let angle = Double(i) / 5 * 360
                CycleBloomPetalShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: p.innerLight.lighter(by: 0.08), location: 0.0),
                                .init(color: p.innerLight,                   location: 0.5),
                                .init(color: p.innerDeep,                    location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 28, height: 38)
                    .shadow(color: p.innerDeep.darker(by: 0.30).opacity(0.20),
                            radius: 2, x: 0.5, y: 1.5)
                    .offset(y: -14)
                    .rotationEffect(.degrees(angle))
            }

            // Tight closed centre tip.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [p.innerLight, p.innerDeep],
                        center: .init(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: 9
                    )
                )
                .frame(width: 14, height: 14)
        }
        .position(center)
    }

    /// Cream/blush palette layered over the user's seeded outer colour.
    /// Keeps the flower's identity (outer hue) but softens it toward
    /// the pale lotus-bud cream + blush tones in the reference image.
    private var lotusBudPalette: (
        outerLight: Color, outerDeep: Color,
        midLight: Color, midDeep: Color,
        innerLight: Color, innerDeep: Color
    ) {
        let base = composition.config.outerColor
        let cream = Color(red: 0.97, green: 0.92, blue: 0.88)
        let blush = Color(red: 0.93, green: 0.80, blue: 0.82)
        let deep  = Color(red: 0.86, green: 0.66, blue: 0.72)
        return (
            outerLight: base.blended(with: cream, amount: 0.55),
            outerDeep:  base.blended(with: blush, amount: 0.45),
            midLight:   base.blended(with: cream, amount: 0.40),
            midDeep:    base.blended(with: blush, amount: 0.35),
            innerLight: base.blended(with: blush, amount: 0.20),
            innerDeep:  base.blended(with: deep,  amount: 0.25)
        )
    }

    @ViewBuilder
    private func closedBud(size: CGFloat, center: CGPoint, diameter: CGFloat) -> some View {
        ZStack {
            // Main bud body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            composition.tinted.outer.opacity(0.95),
                            composition.tinted.outer.opacity(0.78),
                            composition.tinted.outer.opacity(0.65)
                        ],
                        center: .init(x: 0.35, y: 0.30),
                        startRadius: 2,
                        endRadius: diameter * 0.5
                    )
                )
                .frame(width: diameter, height: diameter)

            // Subtle highlight kiss
            Circle()
                .fill(.white.opacity(0.35))
                .frame(width: diameter * 0.18, height: diameter * 0.18)
                .offset(x: -diameter * 0.18, y: -diameter * 0.18)
                .blur(radius: 1.5)

            // Closed-cap line suggesting petal seam
            Capsule()
                .fill(composition.tinted.inner.opacity(0.45))
                .frame(width: diameter * 0.42, height: 1)
        }
        .position(center)
    }

    /// Spring (opening) centre — what you see when a tulip-like
    /// flower has cupped petals halfway open: a dark warm well at the
    /// base, six small stamen marks radiating outward, and a green
    /// stigma point at the very centre. Bridges the closed lotus bud
    /// of winter and the full stamen ring of summer.
    @ViewBuilder
    private func tulipCenter(size: CGFloat, center: CGPoint) -> some View {
        ZStack {
            // Dark warm well — the inside of the cupped petals
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            composition.tinted.outer.blended(
                                with: Color(red: 0.30, green: 0.18, blue: 0.20),
                                amount: 0.55
                            ),
                            composition.tinted.outer.opacity(0.85)
                        ],
                        center: .init(x: 0.4, y: 0.3),
                        startRadius: 0,
                        endRadius: 26
                    )
                )
                .frame(width: 46, height: 46)

            // Stamen anthers — small dark capsules radiating outward
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6 * .pi * 2
                let r: CGFloat = 11
                Capsule()
                    .fill(Color(red: 0.22, green: 0.16, blue: 0.16))
                    .frame(width: 2.2, height: 8)
                    .offset(
                        x: cos(angle) * r,
                        y: sin(angle) * r
                    )
                    .rotationEffect(.radians(angle + .pi / 2))
            }

            // Central green stigma — the lotus reference's signature
            // pale-green tip surrounded by stamens.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.70, green: 0.80, blue: 0.50),
                            Color(red: 0.48, green: 0.60, blue: 0.32)
                        ],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 5
                    )
                )
                .frame(width: 6.5, height: 6.5)
        }
        .position(center)
    }

    @ViewBuilder
    private func openedCentre(size: CGFloat, center: CGPoint) -> some View {
        ZStack {
            // Inner ring of smaller petals
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6 * 360 + 30
                CycleBloomPetalShape(type: composition.flowerType)
                    .fill(composition.tinted.inner.opacity(0.95))
                    .frame(width: 22, height: 32)
                    .offset(y: -22)
                    .rotationEffect(.degrees(angle))
            }

            // Stamen dots
            ForEach(0..<14, id: \.self) { i in
                let angle = Double(i) / 14 * .pi * 2
                let r: CGFloat = 12
                let pulse = 0.5 + 0.5 * sin(Double(phase) * 2.0 + Double(i) * 0.5)
                Circle()
                    .fill(composition.tinted.stamen.opacity(0.9))
                    .frame(width: 2.4 + CGFloat(pulse) * 0.8, height: 2.4 + CGFloat(pulse) * 0.8)
                    .offset(
                        x: cos(angle) * r,
                        y: sin(angle) * r
                    )
            }

            // Central pistil
            Circle()
                .fill(
                    RadialGradient(
                        colors: [composition.tinted.center.opacity(0.95),
                                 composition.tinted.center.opacity(0.6)],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 14, height: 14)
        }
        .position(center)
    }

    @ViewBuilder
    private func seedPodCentre(size: CGFloat, center: CGPoint) -> some View {
        ZStack {
            // Pod shell — slightly larger than summer's pistil, in a
            // greener / pod-coloured tone (lotus seed head reference).
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.72, green: 0.74, blue: 0.45),
                            Color(red: 0.55, green: 0.58, blue: 0.32)
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 24
                    )
                )
                .frame(width: 38, height: 38)

            // Seed dimples
            ForEach(0..<7, id: \.self) { i in
                let angle = Double(i) / 7 * .pi * 2
                Circle()
                    .fill(Color(red: 0.38, green: 0.42, blue: 0.22))
                    .frame(width: 3.5, height: 3.5)
                    .offset(
                        x: cos(angle) * 9,
                        y: sin(angle) * 9
                    )
            }
            // Centre seed
            Circle()
                .fill(Color(red: 0.38, green: 0.42, blue: 0.22))
                .frame(width: 3.5, height: 3.5)
        }
        .position(center)
    }
}

// MARK: - Shiny Dust Layer
//
// Tiny golden + white sparkle motes drifting across the flower itself
// (in addition to the seasonal background particles). Adds a touch of
// magic to every stage — like pollen catching the light.
private struct ShinyDustLayer: View {
    let accent: Color
    let radius: CGFloat
    private static let count: Int = 22

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                for i in 0..<Self.count {
                    let seed = CGFloat(i) * 7.31
                    let cycle: CGFloat = 3.5 + abs(sin(seed)) * 2.5
                    let offset = abs(cos(seed * 1.21)) * cycle
                    var u = (now + offset).truncatingRemainder(dividingBy: cycle) / cycle
                    if u < 0 { u += 1 }

                    let angle = CGFloat(i) / CGFloat(Self.count) * .pi * 2
                        + sin(seed * 0.43) * 0.35
                        + CGFloat(now) * 0.03
                    let r = radius * (0.30 + u * 0.65)
                    let drift = sin(now * 1.2 + seed) * 3
                    let x = center.x + cos(angle) * r + drift
                    let y = center.y + sin(angle) * r

                    let bell = sin(u * .pi)
                    let twinkle = 0.45 + 0.55 * sin(now * 4.0 + seed * 2.0)
                    let alpha = bell * twinkle * 0.85

                    let dot: CGFloat = 1.5 + CGFloat(i % 3) * 0.6
                    let goldOrWhite: Color = i % 2 == 0
                        ? Color(red: 1.0, green: 0.92, blue: 0.62)
                        : .white

                    // Soft halo glow first
                    let halo = CGRect(
                        x: x - dot * 1.8,
                        y: y - dot * 1.8,
                        width: dot * 3.6,
                        height: dot * 3.6
                    )
                    context.fill(
                        Path(ellipseIn: halo),
                        with: .color(goldOrWhite.opacity(Double(alpha) * 0.22))
                    )

                    // Sharp 4-point sparkle on top
                    let star = sparkleStar(at: CGPoint(x: x, y: y), size: dot)
                    context.fill(star, with: .color(goldOrWhite.opacity(Double(alpha))))
                }
            }
        }
    }

    private func sparkleStar(at center: CGPoint, size: CGFloat) -> Path {
        Path { p in
            let s = size
            let inner = size * 0.25
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

// MARK: - Petal / Leaf Shapes

private struct CycleBloomPetalShape: Shape {
    var type: CycleFlowerType = .tulip

    func path(in rect: CGRect) -> Path {
        type.petalPath(in: rect)
    }
}

private struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            let w = rect.width
            let h = rect.height
            // More pointed at top, broader in the middle than CycleBloomPetalShape.
            p.move(to: CGPoint(x: w / 2, y: h))
            p.addQuadCurve(
                to: CGPoint(x: w / 2, y: 0),
                control: CGPoint(x: w * 0.92, y: h * 0.25)
            )
            p.addQuadCurve(
                to: CGPoint(x: w / 2, y: h),
                control: CGPoint(x: w * 0.08, y: h * 0.25)
            )
            p.closeSubpath()
        }
    }
}

// MARK: - Seasonal Particles

private struct SeasonalParticles: View {
    let season: InnerSeason

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let maxR = min(size.width, size.height) * 0.48
                let count = season.particleCount

                for i in 0..<count {
                    let seed = CGFloat(i) * 5.71
                    let cycle: CGFloat = 6.0 + abs(sin(seed)) * 5.0
                    let offset = abs(cos(seed * 1.13)) * cycle
                    var u = (now + offset).truncatingRemainder(dividingBy: cycle) / cycle
                    if u < 0 { u += 1 }

                    let angle = CGFloat(i) / CGFloat(count) * .pi * 2
                        + CGFloat(now) * 0.04
                        + sin(seed * 0.7) * 0.45
                    let r = maxR * (0.55 + u * 0.45)
                    let drift = sin(now * 0.6 + seed) * 6
                    let x = center.x + cos(angle) * r + drift
                    let y = center.y + sin(angle) * r

                    let bell = sin(u * .pi)
                    let alpha = bell * 0.55
                    let dot: CGFloat = 1.4 + CGFloat(i % 3) * 0.7
                    let rect = CGRect(x: x - dot / 2, y: y - dot / 2, width: dot, height: dot)

                    let color: Color = season.particleColor(i: i)
                    context.fill(Path(ellipseIn: rect), with: .color(color.opacity(Double(alpha))))
                }
            }
        }
    }
}

private extension InnerSeason {
    var particleCount: Int {
        switch self {
        case .winter: 32
        case .spring: 26
        case .summer: 38
        case .autumn: 30
        }
    }

    func particleColor(i: Int) -> Color {
        switch self {
        case .winter:
            return i % 2 == 0
                ? .white
                : Color(red: 0.85, green: 0.88, blue: 0.95)
        case .spring:
            return i % 3 == 0
                ? Color(red: 0.95, green: 0.85, blue: 0.85)
                : (i % 3 == 1
                   ? Color(red: 0.82, green: 0.92, blue: 0.78)
                   : .white)
        case .summer:
            return i % 2 == 0
                ? Color(red: 1.0, green: 0.92, blue: 0.65)
                : .white
        case .autumn:
            return i % 3 == 0
                ? Color(red: 0.88, green: 0.55, blue: 0.30)
                : (i % 3 == 1
                   ? Color(red: 0.96, green: 0.78, blue: 0.42)
                   : Color(red: 0.78, green: 0.42, blue: 0.30))
        }
    }
}
