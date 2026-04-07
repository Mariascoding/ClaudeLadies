import SwiftUI
import SwiftData

struct FlowerBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedFlowerDesign.createdDate, order: .reverse) private var savedDesigns: [SavedFlowerDesign]

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

    // Inline save naming
    @State private var isNaming = false
    @State private var saveName = ""

    // Toast
    @State private var savedConfirmationName: String?

    // Clear all
    @State private var showClearAllAlert = false

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
                    geometry: geometry,
                    isAnimating: !isNaming && !showClearAllAlert
                )
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
                .warmCard()
                .padding(.horizontal, AppTheme.Spacing.md)

                // Preset selector
                presetRow

                // My Flowers section
                if !savedDesigns.isEmpty {
                    myFlowersSection
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

                // Action buttons / inline save
                if isNaming {
                    InlineFlowerNameField(
                        initialName: saveName,
                        onSave: { name in
                            saveName = name
                            confirmSave()
                        },
                        onCancel: {
                            withAnimation(AppTheme.gentleAnimation) {
                                isNaming = false
                            }
                        }
                    )
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    HStack(spacing: AppTheme.Spacing.md) {
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

                        Button {
                            saveName = generateAutoName()
                            withAnimation(AppTheme.gentleAnimation) {
                                isNaming = true
                            }
                        } label: {
                            Text("Save Flower")
                                .font(.system(.body, design: AppTheme.fontFamily, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(Color.appRose)
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer().frame(height: AppTheme.Spacing.lg)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream)
        .navigationTitle("Flower Builder")
        .overlay(alignment: .top) {
            if let name = savedConfirmationName {
                Text("Saved \"\(name)\"")
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(Color.appSage.opacity(0.9))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    .padding(.top, AppTheme.Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .alert("Clear All Flowers?", isPresented: $showClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                for design in savedDesigns {
                    modelContext.delete(design)
                }
                try? modelContext.save()
            }
        } message: {
            Text("This will delete all \(savedDesigns.count) saved flowers.")
        }
    }

    // MARK: - Preset Row

    private var presetRow: some View {
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
    }

    // MARK: - My Flowers Section

    private var myFlowersSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("My Flowers")
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                Spacer()
                Button {
                    showClearAllAlert = true
                } label: {
                    Text("Clear All")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(savedDesigns) { design in
                        HStack(spacing: 4) {
                            Button {
                                loadDesign(design)
                            } label: {
                                Text(design.name)
                                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                    .foregroundStyle(design.outerColor)
                            }

                            Button {
                                modelContext.delete(design)
                                try? modelContext.save()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(design.outerColor.opacity(0.4))
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(design.outerColor.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
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

    private func loadDesign(_ design: SavedFlowerDesign) {
        withAnimation(AppTheme.gentleAnimation) {
            outerDesign = design.outerDesign
            innerDesign = design.innerDesign
            stamenDesign = design.stamenDesign
            centerDesign = design.centerDesign
            outerColor = design.outerColor
            innerColor = design.innerColor
            stamenColorChoice = design.stamenColor
            centerColor = design.centerColor
            geometry = design.geometry
        }
    }

    private func confirmSave() {
        let trimmed = saveName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let name = trimmed

        withAnimation(AppTheme.gentleAnimation) {
            isNaming = false
        }

        let design = SavedFlowerDesign(
            name: name,
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
        modelContext.insert(design)
        try? modelContext.save()

        // Show confirmation toast
        withAnimation(AppTheme.gentleAnimation) {
            savedConfirmationName = name
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(AppTheme.gentleAnimation) {
                savedConfirmationName = nil
            }
        }
    }

    // MARK: - Auto Name Generation

    private func generateAutoName() -> String {
        let matchedPreset = FlowerPreset.allCases.first { preset in
            preset.outerDesign == outerDesign &&
            preset.innerDesign == innerDesign &&
            preset.stamen == stamenDesign &&
            preset.center == centerDesign &&
            preset.geometry == geometry
        }

        let closestColor = FlowerColor.closest(to: outerColor)
        let baseName: String

        if let preset = matchedPreset {
            baseName = "\(preset.displayName) \(closestColor.displayName) Bloom"
        } else {
            baseName = "\(outerDesign.displayName) \(closestColor.displayName) Bloom"
        }

        let existingNames = Set(savedDesigns.map(\.name))
        if !existingNames.contains(baseName) {
            return baseName
        }

        var counter = 2
        while existingNames.contains("\(baseName) \(counter)") {
            counter += 1
        }
        return "\(baseName) \(counter)"
    }
}

// MARK: - Isolated Name Field (keystrokes don't re-render parent)

private struct InlineFlowerNameField: View {
    let initialName: String
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @State private var name: String = ""

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Name Your Flower")
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))

            TextField("Flower name", text: $name)
                .font(.system(.body, design: AppTheme.fontFamily))
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        onSave(name)
                    }
                }

            HStack(spacing: AppTheme.Spacing.md) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(.body, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            Capsule()
                                .strokeBorder(Color.appSoftBrown.opacity(0.3), lineWidth: 1)
                        )
                }

                Button {
                    onSave(name)
                } label: {
                    Text("Save")
                        .font(.system(.body, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.appRose)
                        .clipShape(Capsule())
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .warmCard()
        .onAppear {
            name = initialName
        }
    }
}
