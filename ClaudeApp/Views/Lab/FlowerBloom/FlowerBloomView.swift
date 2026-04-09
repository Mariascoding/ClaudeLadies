import SwiftUI
import SwiftData

struct FlowerBloomView: View {
    @Query(sort: \SavedFlowerDesign.createdDate, order: .reverse) private var savedDesigns: [SavedFlowerDesign]

    // Active flower configuration
    @State private var activeOuterDesign: OuterPetalDesign = FlowerPreset.rose.outerDesign
    @State private var activeInnerDesign: InnerPetalDesign = FlowerPreset.rose.innerDesign
    @State private var activeStamenDesign: StamenDesign = FlowerPreset.rose.stamen
    @State private var activeCenterDesign: CenterDesign = FlowerPreset.rose.center
    @State private var activeOuterColor: Color = FlowerPreset.rose.outerColor.color
    @State private var activeInnerColor: Color = FlowerPreset.rose.innerColor.color
    @State private var activeStamenColor: Color = FlowerPreset.rose.stamenColor.color
    @State private var activeCenterColor: Color = FlowerPreset.rose.centerColor.color
    @State private var activeGeometry: FlowerGeometry = FlowerPreset.rose.geometry
    @State private var activePetalColors: [String: Color] = [:]
    @State private var activeName: String = "Rose"
    @State private var activeAccentColor: Color = FlowerPreset.rose.accentColor

    // Selection tracking (for pill highlight)
    @State private var selectedPresetId: String? = FlowerPreset.rose.id
    @State private var selectedSavedId: PersistentIdentifier? = nil

    // Bloom state
    @State private var isDesignConfirmed = false
    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0
    @State private var bloomState: BloomState = .bud

    var body: some View {
        Group {
            if isDesignConfirmed {
                bloomPhase
            } else {
                designPhase
            }
        }
        .navigationTitle(isDesignConfirmed ? "Flower Bloom" : "Pick a Flower")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDesignConfirmed ? .dark : .light, for: .navigationBar)
    }

    // MARK: - Selection Helpers

    private func selectPreset(_ preset: FlowerPreset) {
        activeOuterDesign = preset.outerDesign
        activeInnerDesign = preset.innerDesign
        activeStamenDesign = preset.stamen
        activeCenterDesign = preset.center
        activeOuterColor = preset.outerColor.color
        activeInnerColor = preset.innerColor.color
        activeStamenColor = preset.stamenColor.color
        activeCenterColor = preset.centerColor.color
        activeGeometry = preset.geometry
        activePetalColors = [:]
        activeName = preset.displayName
        activeAccentColor = preset.accentColor
        selectedPresetId = preset.id
        selectedSavedId = nil
    }

    private func selectSavedDesign(_ design: SavedFlowerDesign) {
        activeOuterDesign = design.outerDesign
        activeInnerDesign = design.innerDesign
        activeStamenDesign = design.stamenDesign
        activeCenterDesign = design.centerDesign
        activeOuterColor = design.outerColor
        activeInnerColor = design.innerColor
        activeStamenColor = design.stamenColor
        activeCenterColor = design.centerColor
        activeGeometry = design.geometry
        activePetalColors = design.petalColorOverrides
        activeName = design.name
        activeAccentColor = design.outerColor
        selectedPresetId = nil
        selectedSavedId = design.persistentModelID
    }

    // MARK: - Phase 1: Design Picker

    private var designPhase: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Live preview of selected flower
                FlowerBuilderCanvas(
                    outerDesign: activeOuterDesign,
                    innerDesign: activeInnerDesign,
                    stamenDesign: activeStamenDesign,
                    centerDesign: activeCenterDesign,
                    outerColor: activeOuterColor,
                    innerColor: activeInnerColor,
                    stamenColor: activeStamenColor,
                    centerColor: activeCenterColor,
                    geometry: activeGeometry,
                    petalColors: activePetalColors
                )
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .warmCard()
                .padding(.horizontal, AppTheme.Spacing.md)

                // Flower selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        // Built-in presets
                        ForEach(FlowerPreset.allCases) { preset in
                            Button {
                                withAnimation(AppTheme.gentleAnimation) {
                                    selectPreset(preset)
                                }
                            } label: {
                                HStack(spacing: AppTheme.Spacing.xs) {
                                    Image(systemName: preset.icon)
                                        .font(.caption)
                                    Text(preset.displayName)
                                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                }
                                .foregroundStyle(selectedPresetId == preset.id ? .white : preset.accentColor)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(selectedPresetId == preset.id
                                              ? preset.accentColor
                                              : preset.accentColor.opacity(0.1))
                                )
                            }
                        }

                        // Saved designs
                        if !savedDesigns.isEmpty {
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(Color.appSoftBrown.opacity(0.15))
                                .frame(width: 1, height: 30)

                            ForEach(savedDesigns) { design in
                                Button {
                                    withAnimation(AppTheme.gentleAnimation) {
                                        selectSavedDesign(design)
                                    }
                                } label: {
                                    HStack(spacing: AppTheme.Spacing.xs) {
                                        Image(systemName: "paintbrush.pointed")
                                            .font(.caption)
                                        Text(design.name)
                                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                    }
                                    .foregroundStyle(selectedSavedId == design.persistentModelID ? .white : design.outerColor)
                                    .padding(.horizontal, AppTheme.Spacing.sm)
                                    .padding(.vertical, AppTheme.Spacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(selectedSavedId == design.persistentModelID
                                                  ? design.outerColor
                                                  : design.outerColor.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }

                // Flower name
                Text(activeName)
                    .warmTitle()
                    .animation(AppTheme.gentleAnimation, value: activeName)

                // Confirm button
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isDesignConfirmed = true
                    }
                } label: {
                    Text("Bloom This Flower")
                        .font(.system(.headline, design: AppTheme.fontFamily, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            Capsule()
                                .fill(activeAccentColor)
                        )
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream)
    }

    // MARK: - Phase 2: Bloom Canvas

    private var currentDisplayState: BloomState {
        isHolding ? BloomState.closest(to: holdProgress) : bloomState
    }

    private var bloomPhase: some View {
        ZStack(alignment: .bottom) {
            FlowerBloomCanvas(
                outerDesign: activeOuterDesign,
                innerDesign: activeInnerDesign,
                stamenDesign: activeStamenDesign,
                centerDesign: activeCenterDesign,
                outerColor: activeOuterColor,
                innerColor: activeInnerColor,
                stamenColor: activeStamenColor,
                centerColor: activeCenterColor,
                geometry: activeGeometry,
                petalColors: activePetalColors,
                isHolding: $isHolding,
                holdProgress: $holdProgress,
                bloomState: $bloomState
            )
            .ignoresSafeArea()

            // Progress ring overlay
            if isHolding {
                bloomProgressRing
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            VStack(spacing: AppTheme.Spacing.md) {
                // Bloom state badge
                bloomStateBadge
                    .animation(.easeInOut(duration: 0.3), value: currentDisplayState)

                if !isHolding {
                    Text("Press & Hold to Bloom")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .environment(\.colorScheme, .dark)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isDesignConfirmed = false
                        isHolding = false
                        holdProgress = 0
                        bloomState = .bud
                    }
                } label: {
                    Text("Change Flower")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .opacity(isHolding ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: isHolding)
            }
            .padding(.bottom, 40)
        }
        .animation(.easeInOut(duration: 0.4), value: isHolding)
    }

    // MARK: - Bloom State Badge

    private var bloomStateBadge: some View {
        let state = currentDisplayState
        return VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: state.icon)
                    .font(.system(.subheadline, weight: .medium))
                Text(state.displayName)
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
            }
            .foregroundStyle(state.color)

            Text(state.emotionalLabel)
                .font(.system(.caption, design: AppTheme.fontFamily))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Progress Ring

    private var bloomProgressRing: some View {
        GeometryReader { geo in
            let ringSize = min(geo.size.width, geo.size.height) * 0.85
            let ringRadius = ringSize / 2

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 3)
                    .frame(width: ringSize, height: ringSize)

                // Progress arc
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        currentDisplayState.color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))

                // Tick marks at state thresholds
                ForEach(BloomState.allCases) { state in
                    Circle()
                        .fill(holdProgress >= state.bloomAmount
                              ? state.color
                              : Color.white.opacity(0.15))
                        .frame(width: 8, height: 8)
                        .offset(y: -ringRadius)
                        .rotationEffect(.degrees(Double(state.bloomAmount) * 360 - 90))
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}
