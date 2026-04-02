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

    // Save flow state
    @State private var savedConfirmationName: String?
    @State private var editingDesign: SavedFlowerDesign?
    @State private var showRenameAlert = false
    @State private var renameName = ""

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
                .allowsHitTesting(false)
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

                // My Flowers section
                if !savedDesigns.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("My Flowers")
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                            .padding(.horizontal, AppTheme.Spacing.md)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(savedDesigns) { design in
                                    Button {
                                        loadDesign(design)
                                    } label: {
                                        Text(design.name)
                                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                                            .foregroundStyle(design.outerColor.color)
                                            .padding(.horizontal, AppTheme.Spacing.sm)
                                            .padding(.vertical, AppTheme.Spacing.xs)
                                            .background(
                                                Capsule()
                                                    .fill(design.outerColor.color.opacity(0.1))
                                            )
                                    }
                                    .contextMenu {
                                        Button {
                                            editingDesign = design
                                            renameName = design.name
                                            showRenameAlert = true
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            modelContext.delete(design)
                                            try? modelContext.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                        }
                    }
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

                // Action buttons
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
                        saveFlowerDirectly()
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
                .padding(.bottom, AppTheme.Spacing.lg)
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
        .alert("Rename Flower", isPresented: $showRenameAlert) {
            TextField("Name", text: $renameName)
            Button("Cancel", role: .cancel) {
                editingDesign = nil
            }
            Button("Save") {
                if let design = editingDesign, !renameName.trimmingCharacters(in: .whitespaces).isEmpty {
                    design.name = renameName.trimmingCharacters(in: .whitespaces)
                    try? modelContext.save()
                }
                editingDesign = nil
            }
        }
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
            outerColor = design.outerColor.color
            innerColor = design.innerColor.color
            stamenColorChoice = design.stamenColor.color
            centerColor = design.centerColor.color
            geometry = design.geometry
        }
    }

    private func saveFlowerDirectly() {
        let name = generateAutoName()

        let closestOuter = FlowerColor.closest(to: outerColor)
        let closestInner = FlowerColor.closest(to: innerColor)
        let closestStamen = FlowerColor.closest(to: stamenColorChoice)
        let closestCenter = FlowerColor.closest(to: centerColor)

        let design = SavedFlowerDesign(
            name: name,
            outerDesign: outerDesign,
            innerDesign: innerDesign,
            stamenDesign: stamenDesign,
            centerDesign: centerDesign,
            outerColor: closestOuter,
            innerColor: closestInner,
            stamenColor: closestStamen,
            centerColor: closestCenter,
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
        // Check if current design matches a preset
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

        // Deduplicate against existing saved designs
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
