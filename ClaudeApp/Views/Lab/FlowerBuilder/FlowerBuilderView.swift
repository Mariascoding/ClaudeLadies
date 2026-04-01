import SwiftUI

struct FlowerBuilderView: View {
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

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Live preview
                FlowerBuilderCanvas(
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
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .warmCard()
                .padding(.horizontal, AppTheme.Spacing.md)

                // Preset selector
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
                    .padding(.horizontal, AppTheme.Spacing.md)
                }

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

                // Active part picker
                Group {
                    switch selectedPart {
                    case .outerPetals:
                        FlowerPartPicker(
                            part: .outerPetals,
                            selection: $outerDesign,
                            colorSelection: $outerColor,
                            displayName: \.displayName
                        )
                    case .innerPetals:
                        FlowerPartPicker(
                            part: .innerPetals,
                            selection: $innerDesign,
                            colorSelection: $innerColor,
                            displayName: \.displayName
                        )
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
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream)
        .navigationTitle("Flower Builder")
    }

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
