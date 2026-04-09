import SwiftUI
import UIKit

// MARK: - 3D Bloom Haptics Engine

private final class Bloom3DHapticsEngine {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)

    private var firedStates: Set<Int> = []

    private static let thresholds: [(state: Int, progress: CGFloat, style: Int, intensity: CGFloat)] = [
        (1, 0.15, 0, 0.5),   // light
        (2, 0.40, 1, 0.6),   // medium
        (3, 0.70, 1, 0.85),  // medium
        (4, 1.00, 2, 1.0),   // heavy
    ]

    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
    }

    func update(progress: CGFloat) {
        for threshold in Self.thresholds {
            guard progress >= threshold.progress,
                  !firedStates.contains(threshold.state) else { continue }
            firedStates.insert(threshold.state)
            switch threshold.style {
            case 0:
                lightGenerator.impactOccurred(intensity: threshold.intensity)
                lightGenerator.prepare()
            case 1:
                mediumGenerator.impactOccurred(intensity: threshold.intensity)
                mediumGenerator.prepare()
            default:
                heavyGenerator.impactOccurred(intensity: threshold.intensity)
                heavyGenerator.prepare()
            }
        }
    }

    func reset() {
        firedStates.removeAll()
    }
}

// MARK: - 3D Bloom Background

private enum Bloom3DBackground {
    static func color(at progress: CGFloat) -> Color {
        let p = min(max(progress, 0), 1)

        if p < 0.25 {
            let t = p / 0.25
            return lerp(
                UIColor(red: 0.06, green: 0.05, blue: 0.10, alpha: 1),
                UIColor(red: 0.10, green: 0.08, blue: 0.10, alpha: 1), t)
        } else if p < 0.50 {
            let t = (p - 0.25) / 0.25
            return lerp(
                UIColor(red: 0.10, green: 0.08, blue: 0.10, alpha: 1),
                UIColor(red: 0.14, green: 0.10, blue: 0.07, alpha: 1), t)
        } else if p < 0.75 {
            let t = (p - 0.50) / 0.25
            return lerp(
                UIColor(red: 0.14, green: 0.10, blue: 0.07, alpha: 1),
                UIColor(red: 0.18, green: 0.14, blue: 0.06, alpha: 1), t)
        } else {
            let t = (p - 0.75) / 0.25
            return lerp(
                UIColor(red: 0.18, green: 0.14, blue: 0.06, alpha: 1),
                UIColor(red: 0.28, green: 0.22, blue: 0.08, alpha: 1), t)
        }
    }

    private static func lerp(_ a: UIColor, _ b: UIColor, _ t: CGFloat) -> Color {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t)
        )
    }
}

// MARK: - FlowerBuilder3DView

struct FlowerBuilder3DView: View {
    @State private var outerDesign: OuterPetalDesign = .classic
    @State private var innerDesign: InnerPetalDesign = .tulip
    @State private var stamenDesign: StamenDesign = .dewdrops
    @State private var centerDesign: CenterDesign = .smooth

    @State private var outerColor: Color = .appRose
    @State private var innerColor: Color = .appTerracotta
    @State private var stamenColorChoice: Color = Color(red: 0.92, green: 0.78, blue: 0.55)
    @State private var centerColor: Color = .appSage
    @State private var geometry: FlowerGeometry = .default
    @State private var selectedPart: FlowerPart = .outerPetals

    @State private var isDrawerOpen = true

    // Bloom mode state
    @State private var isBloomMode = false
    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0
    @State private var bloomState: BloomState = .bud
    @State private var holdHintVisible = true

    private let haptics = Bloom3DHapticsEngine()
    private let bloomTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    private let bloomDuration: CGFloat = 8.0

    private var displayState: BloomState {
        isHolding ? BloomState.closest(to: holdProgress) : bloomState
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 3D Preview — always in the same position
                Flower3DView(
                    outerDesign: outerDesign,
                    innerDesign: innerDesign,
                    stamenDesign: stamenDesign,
                    centerDesign: centerDesign,
                    outerColor: outerColor,
                    innerColor: innerColor,
                    stamenColor: stamenColorChoice,
                    centerColor: centerColor,
                    geometry: geometry,
                    isBloomMode: isBloomMode,
                    bloomProgress: holdProgress
                )
                .frame(height: isBloomMode ? 420 : 350)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isBloomMode {
                            Bloom3DBackground.color(at: holdProgress)
                        } else {
                            Color.appWarmWhite
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .shadow(color: .black.opacity(isBloomMode ? 0 : 0.06), radius: 8, y: 2)
                .overlay(alignment: .bottom) {
                    if isBloomMode {
                        // Transparent touch layer for bloom hold gesture
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isHolding {
                                            isHolding = true
                                            holdHintVisible = false
                                            haptics.prepare()
                                        }
                                    }
                                    .onEnded { _ in
                                        isHolding = false
                                        haptics.reset()
                                    }
                            )
                    } else {
                        // Bloom button overlaid on the 3D preview
                        Button {
                            enterBloomMode()
                        } label: {
                            Text("Bloom This Flower")
                                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.sm)
                                .background(.ultraThinMaterial, in: Capsule())
                                .environment(\.colorScheme, .dark)
                        }
                        .padding(.bottom, AppTheme.Spacing.md)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .animation(.easeInOut(duration: 0.4), value: isBloomMode)

                // Below the preview: either build controls or bloom UI
                if isBloomMode {
                    bloomControls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    buildControls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.top, (!isBloomMode && isDrawerOpen) ? 90 : 44)
        }
        .scrollDisabled(isBloomMode && isHolding)
        .background(isBloomMode ? Bloom3DBackground.color(at: holdProgress) : Color.appCream)
        .animation(.easeInOut(duration: 0.5), value: isBloomMode)
        .navigationTitle(isBloomMode ? "3D Bloom" : "3D Flower")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isBloomMode ? .dark : .light, for: .navigationBar)
        .overlay(alignment: .top) {
            if !isBloomMode {
                presetsDrawer
            }
        }
        .onReceive(bloomTimer) { _ in
            guard isBloomMode, isHolding else { return }
            let dt: CGFloat = 1.0 / 60.0
            holdProgress = min(holdProgress + dt / bloomDuration, 1.0)
            haptics.update(progress: holdProgress)
        }
        .onChange(of: isHolding) { _, holding in
            guard isBloomMode, !holding else { return }
            let snapped = BloomState.closest(to: holdProgress)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                bloomState = snapped
                holdProgress = snapped.bloomAmount
            }
        }
    }

    // MARK: - Build Controls

    private var buildControls: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Part selector
            Picker("Flower Part", selection: $selectedPart) {
                ForEach(FlowerPart.allCases) { part in
                    Text(part.shortName).tag(part)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .warmCard()
            .padding(.horizontal, AppTheme.Spacing.md)

            // Active part controls
            Group {
                switch selectedPart {
                case .outerPetals:
                    VStack(spacing: AppTheme.Spacing.sm) {
                        FlowerPartPicker(
                            part: .outerPetals,
                            selection: $outerDesign,
                            colorSelection: $outerColor,
                            displayName: \.displayName
                        )
                        petalCountSlider(
                            label: "Petals",
                            count: Binding(
                                get: { geometry.outerCount },
                                set: { newValue in
                                    geometry.outerCount = newValue
                                    geometry.backCount = max(newValue - 2, 0)
                                }
                            ),
                            range: 3...30,
                            accent: FlowerPart.outerPetals.accentColor
                        )
                    }
                case .innerPetals:
                    VStack(spacing: AppTheme.Spacing.sm) {
                        FlowerPartPicker(
                            part: .innerPetals,
                            selection: $innerDesign,
                            colorSelection: $innerColor,
                            displayName: \.displayName
                        )
                        petalCountSlider(
                            label: "Petals",
                            count: Binding(
                                get: { geometry.innerCount },
                                set: { geometry.innerCount = $0 }
                            ),
                            range: 0...20,
                            accent: FlowerPart.innerPetals.accentColor
                        )
                    }
                case .stamen:
                    FlowerPartPicker(
                        part: .stamen,
                        selection: $stamenDesign,
                        colorSelection: $stamenColorChoice,
                        displayName: \.displayName
                    )
                case .center:
                    FlowerPartPicker(
                        part: .center,
                        selection: $centerDesign,
                        colorSelection: $centerColor,
                        displayName: \.displayName
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .animation(AppTheme.gentleAnimation, value: selectedPart)

            GentleOutlineButton("Randomize") {
                withAnimation(AppTheme.gentleAnimation) {
                    outerDesign = OuterPetalDesign.allCases.randomElement()!
                    innerDesign = InnerPetalDesign.allCases.randomElement()!
                    stamenDesign = StamenDesign.allCases.randomElement()!
                    centerDesign = CenterDesign.allCases.randomElement()!
                    outerColor = FlowerColor.allCases.randomElement()!.color
                    innerColor = FlowerColor.allCases.randomElement()!.color
                    stamenColorChoice = FlowerColor.allCases.randomElement()!.color
                    centerColor = FlowerColor.allCases.randomElement()!.color
                    geometry = .default
                }
            }

            Spacer().frame(height: AppTheme.Spacing.lg)
        }
    }

    // MARK: - Bloom Controls

    private var bloomControls: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Bloom state badge
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: displayState.icon)
                        .font(.system(.subheadline, weight: .medium))
                    Text(displayState.displayName)
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
                }
                .foregroundStyle(displayState.color)

                Text(displayState.emotionalLabel)
                    .font(.system(.caption, design: AppTheme.fontFamily))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .environment(\.colorScheme, .dark)
            .animation(.easeInOut(duration: 0.3), value: displayState)

            // Hold hint
            if holdHintVisible && !isHolding {
                Text("Press & Hold to Bloom")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .environment(\.colorScheme, .dark)
                    .transition(.opacity)
            }

            // Change flower button
            if !isHolding {
                Button {
                    exitBloomMode()
                } label: {
                    Text("Change Flower")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer().frame(height: AppTheme.Spacing.lg)
        }
        .animation(.easeInOut(duration: 0.4), value: isHolding)
    }

    // MARK: - Presets Drawer

    private var presetsDrawer: some View {
        VStack(spacing: 0) {
            if isDrawerOpen {
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Text("Presets")
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.8))
                        Spacer()
                        Button {
                            withAnimation(AppTheme.gentleAnimation) {
                                isDrawerOpen = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(.title3))
                                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(FlowerPreset.allCases) { preset in
                                Button {
                                    applyPreset(preset)
                                } label: {
                                    HStack(spacing: AppTheme.Spacing.xs) {
                                        Image(systemName: preset.icon)
                                            .font(.caption)
                                        Text(preset.displayName)
                                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                    }
                                    .foregroundStyle(preset.accentColor)
                                    .padding(.horizontal, AppTheme.Spacing.sm)
                                    .padding(.vertical, AppTheme.Spacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(preset.accentColor.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if !isDrawerOpen {
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        isDrawerOpen = true
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("Presets")
                            .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(.caption2, weight: .semibold))
                    }
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(.top, AppTheme.Spacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(AppTheme.gentleAnimation, value: isDrawerOpen)
    }

    // MARK: - Petal Count Slider

    private func petalCountSlider(label: String, count: Binding<Int>, range: ClosedRange<Int>, accent: Color) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))

            Slider(
                value: Binding(
                    get: { Double(count.wrappedValue) },
                    set: { count.wrappedValue = Int($0.rounded()) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
            .tint(accent)

            Text("\(count.wrappedValue)")
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 28, alignment: .trailing)
        }
        .warmCard()
    }

    // MARK: - Actions

    private func applyPreset(_ preset: FlowerPreset) {
        withAnimation(AppTheme.gentleAnimation) {
            outerDesign = preset.outerDesign
            innerDesign = preset.innerDesign
            stamenDesign = preset.stamen
            centerDesign = preset.center
            outerColor = preset.outerColor.color
            innerColor = preset.innerColor.color
            stamenColorChoice = preset.stamenColor.color
            centerColor = preset.centerColor.color
            geometry = preset.geometry
        }
    }

    private func enterBloomMode() {
        holdProgress = 0
        bloomState = .bud
        isHolding = false
        holdHintVisible = true
        withAnimation(.easeInOut(duration: 0.4)) {
            isBloomMode = true
        }
    }

    private func exitBloomMode() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isBloomMode = false
            isHolding = false
            holdProgress = 0
            bloomState = .bud
        }
    }
}
