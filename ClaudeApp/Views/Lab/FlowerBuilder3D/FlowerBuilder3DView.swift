import SwiftUI

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

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 3D Preview
                Flower3DView(
                    outerDesign: outerDesign,
                    innerDesign: innerDesign,
                    stamenDesign: stamenDesign,
                    centerDesign: centerDesign,
                    outerColor: outerColor,
                    innerColor: innerColor,
                    stamenColor: stamenColorChoice,
                    centerColor: centerColor,
                    geometry: geometry
                )
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .warmCard()
                .padding(.horizontal, AppTheme.Spacing.md)

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

                // Randomize button
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
            .padding(.top, isDrawerOpen ? 90 : 44)
        }
        .background(Color.appCream)
        .navigationTitle("3D Flower")
        .overlay(alignment: .top) {
            presetsDrawer
        }
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
}
