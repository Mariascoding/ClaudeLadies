import SwiftUI
import SwiftData

struct RadialPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var moonState = MoonState()
    @State private var viewModel = TodayViewModel()
    @State private var selectedIndex = 0

    private var currentPhase: CyclePhase {
        viewModel.cyclePosition?.phase ?? .menstrual
    }

    private var phaseDesc: PhaseDescription {
        PhaseDescriptions.description(for: currentPhase)
    }

    private var lunarPhase: LunarPhase {
        LunarPhase.from(moonPhase: moonState.moonPhase)
    }

    private var moonArchetype: MoonArchetypeProfile {
        nearestArchetype(to: moonState.moonPhase).profile
    }

    private let wheelItems: [(icon: String, label: String, color: Color)] = [
        ("moonphase.full.moon", "Moon", Color(red: 0.92, green: 0.78, blue: 0.55)),
        ("shield.lefthalf.filled", "Guidance", .appRose),
        ("waveform.path", "Phase", .appSage),
        ("leaf.fill", "Nourish", .appTerracotta)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                RadialSelectorWheel(
                    selectedIndex: $selectedIndex,
                    items: wheelItems
                ) {
                    MoonView(moonState: moonState)
                }
                .padding(.top, AppTheme.Spacing.lg)

                // Grounding gradient below carousel
                LinearGradient(
                    colors: [
                        Color.appSoftBrown.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                .padding(.horizontal, AppTheme.Spacing.xl)

                // Content card
                Group {
                    switch selectedIndex {
                    case 0: moonCard
                    case 1: guidanceCard
                    case 2: phaseCard
                    case 3: nourishCard
                    default: EmptyView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                .padding(.horizontal, AppTheme.Spacing.md)

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
        }
        .background(SkyBackgroundView())
        .navigationTitle("Radial Picker")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.load(modelContext: modelContext)
            Task { await moonState.load() }
        }
    }

    // MARK: - Moon Card

    private var moonCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            MoonView(moonState: moonState)
                .frame(height: 160)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text(lunarPhase.displayName)
                    .font(.system(.headline, design: .serif, weight: .semibold))
                    .foregroundStyle(Color.appSoftBrown)

                Text("\(Int(MoonUtils.illumination(for: moonState.moonDay) * 100))% illumination")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))

                Divider()
                    .background(Color.appSoftBrown.opacity(0.15))

                HStack(spacing: AppTheme.Spacing.sm) {
                    Circle()
                        .fill(moonArchetype.color.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text(moonArchetype.name)
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.8))
                }

                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(moonArchetype.traits, id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xxs)
                            .background(Color.appSoftBrown.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .warmCard()
    }

    // MARK: - Guidance Card

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if let guidance = viewModel.guidance {
                Label("Protect", systemImage: "shield.lefthalf.filled")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appRose)

                Text(guidance.protectMessage)
                    .guidanceText()

                Divider()
                    .background(Color.appSoftBrown.opacity(0.15))

                Label("Decision Timing", systemImage: "clock")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appRose.opacity(0.8))

                Text(guidance.decisionTiming)
                    .guidanceText()
            } else {
                noDataPlaceholder(message: "Log a period to see daily guidance")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }

    // MARK: - Phase Card

    private var phaseCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if viewModel.cyclePosition != nil {
                HStack {
                    Text(phaseDesc.title)
                        .warmHeadline()
                    Spacer()
                    Text(phaseDesc.innerSeason)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(currentPhase.accentColor.opacity(0.8))
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xxs)
                        .background(currentPhase.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                }

                Label("Hormones", systemImage: "waveform.path")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appSage)

                Text(phaseDesc.hormoneHighlight)
                    .guidanceText()

                Divider()
                    .background(Color.appSoftBrown.opacity(0.15))

                Label("Superpower", systemImage: "sparkles")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appSage.opacity(0.8))

                Text(phaseDesc.superpower)
                    .guidanceText()
            } else {
                noDataPlaceholder(message: "Log a period to see phase insights")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }

    // MARK: - Nourish Card

    private var nourishCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if viewModel.cyclePosition != nil {
                Label("Nourishment", systemImage: "leaf.fill")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appTerracotta)

                Text(phaseDesc.nourishment)
                    .guidanceText()

                Divider()
                    .background(Color.appSoftBrown.opacity(0.15))

                Label("Movement", systemImage: "figure.walk")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appTerracotta.opacity(0.8))

                Text(phaseDesc.movement)
                    .guidanceText()
            } else {
                noDataPlaceholder(message: "Log a period to see nutrition tips")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .warmCard()
    }

    // MARK: - Helpers

    private func noDataPlaceholder(message: String) -> some View {
        Text(message)
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
    }

    private func nearestArchetype(to moonPhaseValue: Double) -> (profile: MoonArchetypeProfile, distance: Double) {
        var best = moonArchetypeProfiles[0]
        var bestDist = Double.greatestFiniteMagnitude

        for profile in moonArchetypeProfiles {
            let diff = abs(moonPhaseValue - profile.anchor)
            let dist = min(diff, 1.0 - diff)
            if dist < bestDist {
                bestDist = dist
                best = profile
            }
        }

        return (best, bestDist)
    }
}
