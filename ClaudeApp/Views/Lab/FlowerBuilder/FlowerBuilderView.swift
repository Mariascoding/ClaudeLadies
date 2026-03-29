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
                    centerColor: centerColor
                )
                .frame(height: 300)
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
                    }
                }
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream)
        .navigationTitle("Flower Builder")
    }
}
