import SwiftUI
import SwiftData
import UIKit

// MARK: - Carousel Demo
//
// Horizontal carousel of six wireframed slides driven by a single
// control bar at the bottom that behaves like a scroll-bar AND a
// segmented control at the same time:
//
//   · Drag the bar to scrub continuously through the slides
//     (fractional positions during the drag, slides follow live).
//   · Release to snap to the nearest slide.
//   · Tap directly on any segment to jump to that slide.
//
// Slides themselves are deliberately wireframe-only (light grey
// blocks) so the focus is on the control's behaviour.

struct CarouselDemoView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \AutoFlowerProfile.createdDate, order: .reverse)
    private var savedProfiles: [AutoFlowerProfile]

    @Query private var userProfiles: [UserProfile]

    @StateObject private var moonState = MoonState()
    @State private var nourishViewModel = NourishViewModel()

    @State private var index: Int = 0
    @State private var displayedIndex: Int = 0
    @State private var slideOpacity: Double = 1.0
    @State private var slideScale: CGFloat = 1.0
    @State private var transitionTask: Task<Void, Never>? = nil
    @State private var isDragging: Bool = false
    @State private var affirmationOpacity: Double = 0
    @State private var selectedTimeBlock: TimeOfDay = .morning
    @State private var showFullProtocol: Bool = false
    @State private var seasonOverride: InnerSeason? = nil
    private let slideCount: Int = 6

    /// Set to true once the embedded AutoFlowerCreatorView's full
    /// intake → bloom → noted sequence has finished. While false the
    /// carousel hands the screen entirely to AutoFlowerCreatorView so
    /// the user gets the elaborate setup experience.
    @State private var experienceComplete: Bool = false

    /// Warm blush-cream tone shared across every screen in the
    /// carousel lab (starter + slides) so swiping between them feels
    /// like one continuous page.
    private static let carouselBackground = Color(red: 0.96, green: 0.93, blue: 0.91)

    /// Soft haptic fired each time the slide changes.
    private let slideHaptic = UIImpactFeedbackGenerator(style: .soft)

    private var savedProfile: AutoFlowerProfile? { savedProfiles.first }
    private var userProfile: UserProfile? { userProfiles.first }

    private var bloomComposition: CycleBloomView.Composition? {
        guard let p = savedProfile else { return nil }
        let base = CycleBloomView.Composition.build(
            displayName: p.displayName,
            ageSelection: p.ageSelection,
            periodDate: p.hasPeriod ? p.periodDate : .now
        )
        if let override = seasonOverride, override != base.season {
            return base.withSeason(override)
        }
        return base
    }

    private var cyclePosition: CycleCalculator.CyclePosition? {
        guard let p = userProfile, let last = p.lastPeriodStartDate else {
            // Fallback to AutoFlowerProfile if no main UserProfile yet
            guard let saved = savedProfile, saved.hasPeriod else { return nil }
            return CycleCalculator.currentPosition(
                lastPeriodStart: saved.periodDate,
                cycleLength: 28,
                periodLength: 5
            )
        }
        return CycleCalculator.currentPosition(
            lastPeriodStart: last,
            cycleLength: p.cycleLength,
            periodLength: p.periodLength
        )
    }

    private var cyclePhase: CyclePhase {
        cyclePosition?.phase ?? .follicular
    }

    private var dailyGuidance: DailyGuidance? {
        guard let position = cyclePosition else { return nil }
        return GuidanceEngine.guidance(
            phase: position.phase,
            dayInCycle: position.dayInCycle,
            dayInPhase: position.dayInPhase,
            nervousSystemState: nil
        )
    }

    /// Time block matching the current hour.
    private var currentTimeBlock: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 6..<12:  return .morning
        case 12..<18: return .afternoon
        default:      return .evening
        }
    }

    var body: some View {
        Group {
            if shouldShowCarousel {
                carouselBody
            } else {
                AutoFlowerCreatorView(
                    onNoted: {
                        // Auto Flower has reached its noted phase —
                        // the elaborate intake + bloom + interaction
                        // sequence is done. Take over with the carousel.
                        withAnimation(.easeInOut(duration: 0.6)) {
                            experienceComplete = true
                        }
                    },
                    backgroundColor: Self.carouselBackground
                )
                .transition(.opacity)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await moonState.load() }
            nourishViewModel.load(modelContext: modelContext)
            selectedTimeBlock = currentTimeBlock
            slideHaptic.prepare()
            // Always show the Auto Flower starter first when entering
            // the lab. Returning users can tap "Continue as [Name]" on
            // the intro screen to jump quickly to the carousel.
            experienceComplete = false
            // Affirmation fade-in over the moon
            withAnimation(.easeInOut(duration: 2.5).delay(0.6)) {
                affirmationOpacity = 0.85
            }
        }
    }

    /// Once `experienceComplete` is set the carousel slides take over.
    /// It only flips after the user finishes (or skips through) the
    /// embedded Auto Flower experience.
    private var shouldShowCarousel: Bool {
        experienceComplete
    }

    private var carouselBody: some View {
        slideStack
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
            .background(Self.carouselBackground.ignoresSafeArea())
    }


    /// Persistent bottom bar — the carousel control + tracked caption
    /// always pinned to the bottom so the user can scrub no matter how
    /// densely a slide above is filled.
    private var bottomBar: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            controlBar
                .padding(.horizontal, AppTheme.Spacing.lg)
            instructions
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            Self.carouselBackground
                .overlay(
                    Rectangle()
                        .fill(Color.appSoftBrown.opacity(0.08))
                        .frame(height: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Slide Stack

    private var slideStack: some View {
        slide(at: displayedIndex)
            .id(displayedIndex)
            .opacity(slideOpacity)
            .scaleEffect(slideScale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: index) { _, newValue in
                transitionToSlide(newValue)
            }
    }

    /// Sequential fade-with-zoom transition: the current slide fades
    /// out while shrinking a touch, the new slide content swaps in,
    /// then it fades in while growing back from the same scale. The
    /// shrink-grow makes the transition feel breathy without
    /// becoming theatrical.
    private func transitionToSlide(_ newIndex: Int) {
        guard newIndex != displayedIndex else { return }
        slideHaptic.impactOccurred(intensity: 0.75)
        slideHaptic.prepare()
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.20)) {
                slideOpacity = 0
                slideScale = 0.94
            }
            try? await Task.sleep(nanoseconds: 220_000_000)
            if Task.isCancelled { return }
            displayedIndex = newIndex
            withAnimation(.easeIn(duration: 0.26)) {
                slideOpacity = 1
                slideScale = 1.0
            }
        }
    }

    // MARK: - Wireframe Slides
    //
    // Six distinct layouts shown as light-grey placeholders. Each is
    // structurally different enough to make it obvious which slide is
    // on screen as you drag the bar.

    @ViewBuilder
    private func slide(at index: Int) -> some View {
        switch index {
        case 0: cycleBloomSlide
        case 1: phaseInfoSlide
        case 2: moonSlide
        case 3: nourishQuickSlide
        case 4: feelingLogSlide
        case 5: dashboardSlide
        default: EmptyView()
        }
    }

    // MARK: - Slide 0: Cycle Bloom flower

    @ViewBuilder
    private var cycleBloomSlide: some View {
        if let c = bloomComposition {
            VStack(spacing: AppTheme.Spacing.sm) {
                stageSwitcher(currentSeason: c.season)
                    .padding(.top, AppTheme.Spacing.xs)

                // Name + inner-season / phase metadata grouped at the
                // top so the user sees who they are AND where they are
                // before reading the bloom.
                VStack(spacing: 4) {
                    Text(c.displayName)
                        .font(.custom("SnellRoundhand-Bold", size: 28))
                        .foregroundStyle(c.tinted.outer)

                    Text(c.season.title.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .tracking(3.5)
                        .foregroundStyle(c.tinted.outer.opacity(0.85))
                        .padding(.top, 2)

                    Text("\(c.season.matchingPhase.displayName) · Day \(c.position.dayInCycle) / \(c.cycleLength)")
                        .font(.system(.footnote, design: .serif, weight: .light))
                        .italic()
                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                }

                Spacer(minLength: 0)

                CycleBloomFlower(composition: c)
                    .frame(width: 280, height: 280)
                    .scaleEffect(c.season.bloomScale)
                    .saturation(c.season.saturationBoost)

                Spacer(minLength: 0)

                // Affirmation / today's guidance balanced underneath
                // the bud — italic serif, generous side padding so it
                // forms a calm centred line of text rather than a card.
                if let g = dailyGuidance {
                    Text(g.protectMessage)
                        .font(.system(.subheadline, design: .serif, weight: .light))
                        .italic()
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.lg)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("No flower yet")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                Text("Build your flower in the Cycle Bloom lab first.")
                    .font(.system(.subheadline, design: .serif, weight: .light))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Stage Switcher (BUD · OPEN · FULL · SHED)
    //
    // Imported from CycleBloomView so the user can flip between cycle
    // phases for the carousel's bloom display while testing.

    @ViewBuilder
    private func stageSwitcher(currentSeason: InnerSeason) -> some View {
        HStack(spacing: 6) {
            Button {
                // Take the user back to the Auto Flower starter so a
                // fresh flower can be built for a new person.
                withAnimation(.easeInOut(duration: 0.55)) {
                    experienceComplete = false
                    seasonOverride = nil
                }
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 7, weight: .medium))
                    Text("STAGE")
                        .font(.system(size: 8, weight: .medium))
                        .tracking(2.5)
                }
                .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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

    // MARK: - Slide 1: Phase info — Insights' PhaseInfoCard imported
    // as-is so the user sees Hormones, Your Superpower, Nourishment,
    // Movement and Detox for the current cycle phase.

    @ViewBuilder
    private var phaseInfoSlide: some View {
        let description = PhaseDescriptions.description(
            for: seasonOverride?.matchingPhase ?? cyclePhase
        )
        ScrollView {
            VStack {
                PhaseInfoCard(description: description)
                    .padding(.horizontal, AppTheme.Spacing.sm)
            }
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Slide 2: Moon — sky with clouds + moon + affirmation
    // fading over the moon + moon wisdom card underneath.

    private var moonSlide: some View {
        let phase = LunarPhase.from(moonPhase: moonState.moonPhase)
        let wisdom = MoonWisdomContent.wisdom(for: moonState.moonPhase)
        let illumination = Int(moonIllumination * 100)
        let archetype = moonWomanArchetype
        let alignment = moonAlignmentPercent

        return VStack(spacing: AppTheme.Spacing.sm) {
            // Top metadata block — mirrors the Cycle Bloom slide's
            // rhythm: tracked label · cursive name · italic subtitle.
            VStack(spacing: 4) {
                Text("TONIGHT'S MOON")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))

                Text(phase.displayName)
                    .font(.custom("SnellRoundhand-Bold", size: 28))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                    .padding(.top, 2)

                Text("\(illumination)% illuminated · \(wisdom.energyKeyword)")
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
            }
            .padding(.top, AppTheme.Spacing.md)

            Spacer(minLength: 0)

            // Moon lands in exactly the same 280pt envelope as the
            // flower on the previous slide so swiping between them
            // feels like the same hero element morphing.
            MoonView(moonState: moonState)
                .frame(width: 220, height: 220)
                .frame(width: 280, height: 280)

            Spacer(minLength: 0)

            // Bottom block — matches Cycle Bloom's "today's guidance"
            // structure: tracked label + a single italic-serif line.
            VStack(spacing: 6) {
                Text(archetype.label.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.75))

                Text("you are \(alignment)% bleeding with \(archetype.bleedingPhase)")
                    .font(.system(.subheadline, design: .serif, weight: .light))
                    .italic()
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Moon helpers

    /// Standard illumination formula: (1 − cos(2π · phase)) / 2.
    /// Goes new→full→new across the 0…1 phase value.
    private var moonIllumination: Double {
        (1 - cos(2 * .pi * moonState.moonPhase)) / 2
    }

    /// Alignment with the nearest of the four moon-woman archetype
    /// anchors (new / waxing / full / waning). Mirrors the dashboard's
    /// calculation so the two views agree.
    private var moonAlignmentPercent: Int {
        guard let position = cyclePosition else { return 0 }
        let cycleLength = userProfile?.cycleLength ?? 28
        let cycleProgress = Double(position.dayInCycle - 1) / Double(cycleLength)
        var result = moonState.moonPhase - cycleProgress
        result = result.truncatingRemainder(dividingBy: 1.0)
        if result < 0 { result += 1.0 }
        let nearest = [0.0, 0.25, 0.5, 0.75]
            .map { abs(result - $0) }
            .min() ?? 0
        let dist = min(nearest, 1.0 - nearest)
        return Int(min(100, max(0, (1.0 - dist / 0.125) * 100)))
    }

    /// Which moon-woman archetype the user is closest to, plus the
    /// human-readable name of the moon phase she bleeds with.
    private var moonWomanArchetype: (label: String, bleedingPhase: String) {
        guard let position = cyclePosition else {
            return ("Moon Woman", "the moon")
        }
        let cycleLength = userProfile?.cycleLength ?? 28
        let cycleProgress = Double(position.dayInCycle - 1) / Double(cycleLength)
        var p = moonState.moonPhase - cycleProgress
        p = p.truncatingRemainder(dividingBy: 1.0)
        if p < 0 { p += 1.0 }
        switch p {
        case 0..<0.125, 0.875...:
            return ("White Moon Woman", "the new moon")
        case 0.125..<0.375:
            return ("Pink Moon Woman", "the waxing moon")
        case 0.375..<0.625:
            return ("Red Moon Woman", "the full moon")
        default:
            return ("Purple Moon Woman", "the waning moon")
        }
    }

    // MARK: - Slide 2: Nourish quick (current time block only)

    @ViewBuilder
    private var nourishQuickSlide: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: 2) {
                Text(headerLabel(for: selectedTimeBlock))
                    .font(.system(size: 9, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(cyclePhase.accentColor.opacity(0.85))
                Text(selectedTimeBlock.displayName + " · " + selectedTimeBlock.timeHint)
                    .font(.system(.subheadline, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.75))
            }
            .padding(.top, AppTheme.Spacing.md)

            if let plan = nourishViewModel.activePlan {
                TabView(selection: $selectedTimeBlock) {
                    ForEach(TimeOfDay.allCases) { tod in
                        let block = block(for: tod, in: plan)
                        ScrollView {
                            TimeBlockCard(
                                timeBlock: block,
                                accentColor: cyclePhase.accentColor,
                                completedCount: nourishViewModel.completedCount(for: block),
                                isItemCompleted: nourishViewModel.isItemCompleted(_:),
                                onToggle: nourishViewModel.toggleItem(_:),
                                onDismiss: nil
                            )
                            .padding(.horizontal, AppTheme.Spacing.sm)
                        }
                        .scrollIndicators(.hidden)
                        .tag(tod)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                Button {
                    showFullProtocol = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 11))
                        Text("FULL PROTOCOL")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(2.5)
                    }
                    .foregroundStyle(cyclePhase.accentColor)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(cyclePhase.accentColor.opacity(0.55), lineWidth: 0.6)
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, AppTheme.Spacing.xs)
            } else {
                placeholderMessage("Set up your cycle to see today's nourishment.")
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showFullProtocol) {
            fullProtocolSheet
        }
    }

    // MARK: - Full Protocol Sheet
    //
    // Triggered by the "FULL PROTOCOL" button on the quick nourish
    // slide. Lets the user change the active nutrition protocol and
    // swipe through morning / afternoon / evening cards in a larger,
    // dedicated surface.

    private var fullProtocolSheet: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.md) {
                protocolPicker
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.sm)

                if let plan = nourishViewModel.activePlan {
                    TabView(selection: $selectedTimeBlock) {
                        ForEach(TimeOfDay.allCases) { tod in
                            let block = block(for: tod, in: plan)
                            ScrollView {
                                TimeBlockCard(
                                    timeBlock: block,
                                    accentColor: cyclePhase.accentColor,
                                    completedCount: nourishViewModel.completedCount(for: block),
                                    isItemCompleted: nourishViewModel.isItemCompleted(_:),
                                    onToggle: nourishViewModel.toggleItem(_:),
                                    onDismiss: nil
                                )
                                .padding(.horizontal, AppTheme.Spacing.md)
                            }
                            .scrollIndicators(.hidden)
                            .tag(tod)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))

                    if !plan.avoid.isEmpty || !plan.rationale.isEmpty {
                        avoidAndRationale(plan: plan)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.md)
                    }
                } else {
                    placeholderMessage("Set up your cycle to see today's protocol.")
                    Spacer()
                }
            }
            .background(Color.appCream.ignoresSafeArea())
            .navigationTitle("Today's Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFullProtocol = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var protocolPicker: some View {
        Menu {
            Picker(
                "Protocol",
                selection: Binding(
                    get: { nourishViewModel.selectedProtocol ?? .daoSt },
                    set: { nourishViewModel.selectProtocol($0) }
                )
            ) {
                ForEach(NutritionProtocol.allCases) { proto in
                    Text(proto.displayName).tag(proto)
                }
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PROTOCOL")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    Text(nourishViewModel.selectedProtocol?.displayName ?? "DAO Support")
                        .font(.system(.subheadline, design: .serif, weight: .light))
                        .italic()
                        .foregroundStyle(Color.appSoftBrown)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(cyclePhase.accentColor.opacity(0.7))
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appWarmWhite.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(cyclePhase.accentColor.opacity(0.25), lineWidth: 0.5)
            )
        }
        .tint(cyclePhase.accentColor)
    }

    @ViewBuilder
    private func avoidAndRationale(plan: DailyNutritionPlan) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !plan.avoid.isEmpty {
                Text("AVOID")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(cyclePhase.accentColor.opacity(0.85))
                Text(plan.avoid.joined(separator: " · "))
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
            }
            if !plan.rationale.isEmpty {
                Text("WHY")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(cyclePhase.accentColor.opacity(0.85))
                    .padding(.top, 4)
                Text(plan.rationale)
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func block(for tod: TimeOfDay, in plan: DailyNutritionPlan) -> TimeBlock {
        switch tod {
        case .morning:   return plan.morning
        case .afternoon: return plan.afternoon
        case .evening:   return plan.evening
        }
    }

    /// Slightly different uppercase label depending on whether the
    /// user is viewing the time block that matches the current hour.
    private func headerLabel(for tod: TimeOfDay) -> String {
        tod == currentTimeBlock ? "RIGHT NOW" : "NOURISHMENT"
    }

    // MARK: - Slide 4: Feeling Log (symptom check-in grid)

    @ViewBuilder
    private var feelingLogSlide: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: 2) {
                Text("HOW DO YOU FEEL")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(cyclePhase.accentColor.opacity(0.85))
                Text("tap each symptom that's moving in you today")
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
            }
            .padding(.top, AppTheme.Spacing.md)

            let common = PeriodSymptomWisdom.commonSymptoms(for: cyclePhase)

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: AppTheme.Spacing.sm
                ) {
                    ForEach(common.prefix(12), id: \.self) { symptom in
                        feelingChip(symptom: symptom)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .scrollDisabled(true)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func feelingChip(symptom: Symptom) -> some View {
        let isSelected = nourishViewModel.isSymptomSelected(symptom)
        Button {
            nourishViewModel.toggleSymptom(symptom)
        } label: {
            VStack(spacing: 6) {
                Text(symptom.emoji).font(.system(size: 24))
                Text(symptom.displayName)
                    .font(.system(.caption, design: .serif, weight: .light))
                    .foregroundStyle(Color.appSoftBrown.opacity(isSelected ? 1.0 : 0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? cyclePhase.accentColor.opacity(0.18) : Color.appWarmWhite.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? cyclePhase.accentColor.opacity(0.6) : Color.appSoftBrown.opacity(0.12), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Slide 5: Dashboard

    private var dashboardSlide: some View {
        DashboardView()
    }

    // MARK: - Helpers

    @ViewBuilder
    private func placeholderMessage(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, design: .serif).italic())
            .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func wireframeFrame<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            content()
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Slide 1: header bar + big hero image + paragraph lines
    private var slideHeaderAndParagraph: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            wireRect(height: 26, width: .ratio(0.55))
            RoundedRectangle(cornerRadius: 12)
                .fill(wireFill)
                .frame(maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 10) {
                wireRect(height: 10, width: .ratio(1.0))
                wireRect(height: 10, width: .ratio(0.95))
                wireRect(height: 10, width: .ratio(0.85))
                wireRect(height: 10, width: .ratio(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Slide 2: two-column layout (image block + text)
    private var slideTwoColumns: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            RoundedRectangle(cornerRadius: 8)
                .fill(wireFill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 10) {
                wireRect(height: 18, width: .ratio(1.0))
                wireRect(height: 8, width: .ratio(0.9))
                wireRect(height: 8, width: .ratio(1.0))
                wireRect(height: 8, width: .ratio(0.7))
                wireRect(height: 8, width: .ratio(0.85))
                wireRect(height: 8, width: .ratio(0.6))
                Spacer()
                Capsule().fill(wireAccent).frame(width: 80, height: 26)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Slide 3: 2×2 grid of cards
    private var slideGridOfFour: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                gridCard
                gridCard
            }
            HStack(spacing: AppTheme.Spacing.sm) {
                gridCard
                gridCard
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var gridCard: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(wireFill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                VStack(alignment: .leading, spacing: 6) {
                    Circle().fill(wireAccent).frame(width: 28, height: 28)
                    Spacer()
                    wireRect(height: 10, width: .ratio(0.8))
                    wireRect(height: 8, width: .ratio(0.5))
                }
                .padding(12)
            )
    }

    // Slide 4: stacked list rows
    private var slideStackedList: some View {
        VStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { _ in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Circle().fill(wireAccent).frame(width: 32, height: 32)
                    VStack(alignment: .leading, spacing: 5) {
                        wireRect(height: 10, width: .ratio(0.6))
                        wireRect(height: 7, width: .ratio(0.4))
                    }
                    Spacer()
                    wireRect(height: 10, width: .fixed(48))
                }
                .frame(maxHeight: .infinity)
                Rectangle()
                    .fill(Color.appSoftBrown.opacity(0.10))
                    .frame(height: 0.5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Slide 5: hero avatar + caption lines
    private var slideAvatarAndLines: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Circle()
                .fill(wireFill)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 220, maxHeight: 220)
            VStack(spacing: 10) {
                wireRect(height: 18, width: .fixed(200))
                wireRect(height: 9, width: .fixed(260))
                wireRect(height: 9, width: .fixed(220))
                wireRect(height: 9, width: .fixed(180))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Slide 6: three side-by-side metrics
    private var slideThreeMetrics: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            wireRect(height: 14, width: .ratio(0.4))
            HStack(spacing: AppTheme.Spacing.sm) {
                metricCard
                metricCard
                metricCard
            }
            .frame(maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 10) {
                wireRect(height: 9, width: .ratio(0.85))
                wireRect(height: 9, width: .ratio(0.7))
                wireRect(height: 9, width: .ratio(0.8))
                wireRect(height: 9, width: .ratio(0.55))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var metricCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            wireRect(height: 8, width: .ratio(0.7))
            wireRect(height: 22, width: .ratio(0.5))
            Spacer()
            wireRect(height: 6, width: .ratio(0.4))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(wireFill)
        )
    }

    // MARK: - Wireframe Helpers

    private var wireFill: Color {
        Color.appSoftBrown.opacity(0.10)
    }
    private var wireAccent: Color {
        Color.appSoftBrown.opacity(0.22)
    }

    enum WireWidth {
        case ratio(CGFloat)   // 0…1 of available width
        case fixed(CGFloat)
    }

    @ViewBuilder
    private func wireRect(height: CGFloat, width: WireWidth) -> some View {
        switch width {
        case .ratio(let r):
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: height / 2.5)
                    .fill(wireFill)
                    .frame(width: geo.size.width * r, height: height)
            }
            .frame(height: height)
        case .fixed(let f):
            RoundedRectangle(cornerRadius: height / 2.5)
                .fill(wireFill)
                .frame(width: f, height: height)
        }
    }

    // MARK: - Control Bar (scroll-bar + segmented control hybrid)
    //
    // Drag = scrub continuously (live offset on slides). Release =
    // snap to nearest segment. Tap a segment directly = jump there.

    private var controlBar: some View {
        GeometryReader { geo in
            let segmentWidth = geo.size.width / CGFloat(slideCount)

            ZStack(alignment: .leading) {
                // Segment backgrounds — clearly divided segments so
                // the bar reads as a segmented control at rest.
                HStack(spacing: 1) {
                    ForEach(0..<slideCount, id: \.self) { i in
                        let isActive = i == index
                        Capsule(style: .continuous)
                            .fill(isActive
                                  ? Color.appRose.opacity(0.18)
                                  : Color.appSoftBrown.opacity(0.10))
                            .frame(height: 12)
                    }
                }

                // Sliding thumb — slides smoothly across the bar to
                // the active segment.
                Capsule(style: .continuous)
                    .fill(Color.appRose)
                    .frame(width: segmentWidth - 4, height: 8)
                    .offset(x: CGFloat(index) * segmentWidth + 2)
                    .shadow(color: Color.appRose.opacity(0.35), radius: 3, y: 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: index)
            }
            .frame(height: 14)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = max(0, min(geo.size.width, value.location.x))
                        let frac = x / geo.size.width
                        let segment = min(
                            max(Int(frac * Double(slideCount)), 0),
                            slideCount - 1
                        )
                        isDragging = true
                        if index != segment {
                            index = segment
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
        .frame(height: 14)
    }

    // MARK: - Instructions

    private var instructions: some View {
        VStack(spacing: 4) {
            Text("DRAG TO SCRUB  ·  TAP A SEGMENT TO JUMP")
                .font(.system(size: 9, weight: .medium))
                .tracking(1.8)
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}
