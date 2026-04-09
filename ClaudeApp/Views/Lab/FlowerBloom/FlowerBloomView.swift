import SwiftUI

struct FlowerBloomView: View {
    @State private var selectedPreset: FlowerPreset = .rose
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

    // MARK: - Phase 1: Design Picker

    private var designPhase: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Live preview of selected preset
                FlowerBuilderCanvas(
                    outerDesign: selectedPreset.outerDesign,
                    innerDesign: selectedPreset.innerDesign,
                    stamenDesign: selectedPreset.stamen,
                    centerDesign: selectedPreset.center,
                    outerColor: selectedPreset.outerColor.color,
                    innerColor: selectedPreset.innerColor.color,
                    stamenColor: selectedPreset.stamenColor.color,
                    centerColor: selectedPreset.centerColor.color,
                    geometry: selectedPreset.geometry
                )
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .warmCard()
                .padding(.horizontal, AppTheme.Spacing.md)

                // Preset selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(FlowerPreset.allCases) { preset in
                            Button {
                                withAnimation(AppTheme.gentleAnimation) {
                                    selectedPreset = preset
                                }
                            } label: {
                                HStack(spacing: AppTheme.Spacing.xs) {
                                    Image(systemName: preset.icon)
                                        .font(.caption)
                                    Text(preset.displayName)
                                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                }
                                .foregroundStyle(selectedPreset == preset ? .white : preset.accentColor)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(selectedPreset == preset
                                              ? preset.accentColor
                                              : preset.accentColor.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }

                // Flower name
                Text(selectedPreset.displayName)
                    .warmTitle()
                    .animation(AppTheme.gentleAnimation, value: selectedPreset)

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
                                .fill(selectedPreset.accentColor)
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
                outerDesign: selectedPreset.outerDesign,
                innerDesign: selectedPreset.innerDesign,
                stamenDesign: selectedPreset.stamen,
                centerDesign: selectedPreset.center,
                outerColor: selectedPreset.outerColor.color,
                innerColor: selectedPreset.innerColor.color,
                stamenColor: selectedPreset.stamenColor.color,
                centerColor: selectedPreset.centerColor.color,
                geometry: selectedPreset.geometry,
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
