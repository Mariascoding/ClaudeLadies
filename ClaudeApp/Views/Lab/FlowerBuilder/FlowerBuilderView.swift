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

    // Inline rename
    @State private var renamingDesign: SavedFlowerDesign?

    // Toast
    @State private var savedConfirmationName: String?

    // Clear all
    @State private var showClearAllAlert = false
    @State private var isDrawerOpen = true

    // Paint mode
    @State private var isPaintMode = false
    @State private var petalColors: [String: Color] = [:]
    @State private var activePaintColor: Color = .appRose
    @State private var paintHistory: [(key: String, oldColor: Color?)] = []
    // Per-petal tap cycle: tracks phase (1=painted, 2=at previous, 3=at base) and what color it had before painting
    @State private var petalTapPhase: [String: (phase: Int, previousColor: Color?)] = [:]

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
                    isAnimating: !isNaming && renamingDesign == nil && !showClearAllAlert && !isPaintMode,
                    isPaintMode: isPaintMode,
                    petalColors: petalColors,
                    selectedPart: selectedPart,
                    onPetalTap: { key in
                        withAnimation(AppTheme.gentleAnimation) {
                            handlePetalTap(key: key)
                        }
                    }
                )
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(isPaintMode)
                .warmCard()
                .overlay(alignment: .topTrailing) {
                    if isPaintMode {
                        Text("Tap a petal")
                            .font(.system(.caption2, design: AppTheme.fontFamily, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.appRose.opacity(0.8))
                            .clipShape(Capsule())
                            .padding(AppTheme.Spacing.sm)
                            .allowsHitTesting(false)
                    }
                }
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
                        VStack(spacing: AppTheme.Spacing.sm) {
                            FlowerPartPicker(
                                part: .outerPetals,
                                selection: $outerDesign,
                                colorSelection: $outerColor,
                                displayName: \.displayName,
                                isPaintMode: $isPaintMode,
                                paintColor: $activePaintColor
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
                            gradientSlider(
                                label: "Opacity Gradient",
                                value: $geometry.outerGradientStrength,
                                accent: FlowerPart.outerPetals.accentColor
                            )
                        }
                    case .innerPetals:
                        VStack(spacing: AppTheme.Spacing.sm) {
                            FlowerPartPicker(
                                part: .innerPetals,
                                selection: $innerDesign,
                                colorSelection: $innerColor,
                                displayName: \.displayName,
                                isPaintMode: $isPaintMode,
                                paintColor: $activePaintColor
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
                            gradientSlider(
                                label: "Opacity Gradient",
                                value: $geometry.innerGradientStrength,
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
                    VStack(spacing: AppTheme.Spacing.sm) {
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
                                    petalColors = [:]
                                    paintHistory = []
                                    petalTapPhase = [:]
                                }
                            }

                            Button {
                                saveName = generateAutoName()
                                withAnimation(AppTheme.gentleAnimation) {
                                    isNaming = true
                                }
                            } label: {
                                Text("Save Preset")
                                    .font(.system(.body, design: AppTheme.fontFamily, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                    .padding(.vertical, AppTheme.Spacing.md)
                                    .background(Color.appRose)
                                    .clipShape(Capsule())
                            }
                        }

                        // Paint mode hint + clear
                        if isPaintMode {
                            paintHintBar
                        }
                    }
                }
                Spacer().frame(height: AppTheme.Spacing.lg)
            }
            .padding(.top, isDrawerOpen ? 90 : 44)
        }
        .background(Color.appCream)
        .navigationTitle("Flower Builder")
        .overlay(alignment: .top) {
            presetsDrawer
        }
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
        .alert("Clear Saved Presets?", isPresented: $showClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear Saved", role: .destructive) {
                for design in savedDesigns {
                    modelContext.delete(design)
                }
                try? modelContext.save()
            }
        } message: {
            Text("This will delete all \(savedDesigns.count) saved presets.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            if isPaintMode && !paintHistory.isEmpty {
                withAnimation(AppTheme.gentleAnimation) {
                    undoLastPaint()
                }
            }
        }
    }

    // MARK: - Presets Drawer

    private var presetsDrawer: some View {
        VStack(spacing: 0) {
            if isDrawerOpen {
                VStack(spacing: AppTheme.Spacing.sm) {
                    // Header
                    HStack {
                        Text("Presets")
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(Color.appSoftBrown.opacity(0.8))
                        Spacer()
                        if !savedDesigns.isEmpty {
                            Button {
                                showClearAllAlert = true
                            } label: {
                                Text("Clear Saved")
                                    .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                                    .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                            }
                        }
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

                    // Inline rename field
                    if let design = renamingDesign {
                        InlineFlowerNameField(
                            initialName: design.name,
                            title: "Rename Preset",
                            onSave: { newName in
                                design.name = newName
                                try? modelContext.save()
                                withAnimation(AppTheme.gentleAnimation) {
                                    renamingDesign = nil
                                }
                            },
                            onCancel: {
                                withAnimation(AppTheme.gentleAnimation) {
                                    renamingDesign = nil
                                }
                            }
                        )
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                // Built-in presets
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

                                // Saved presets
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
                                            withAnimation(AppTheme.gentleAnimation) {
                                                renamingDesign = design
                                            }
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(design.outerColor.opacity(0.6))
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

    // MARK: - Gradient Slider

    private func gradientSlider(label: String, value: Binding<CGFloat>, accent: Color) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))

            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = CGFloat($0) }
                ),
                in: 0...1
            )
            .tint(accent)

            Text("\(Int(value.wrappedValue * 100))%")
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 40, alignment: .trailing)
        }
        .warmCard()
    }

    // MARK: - Paint Hint Bar

    private var paintHintBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(activePaintColor)
                .frame(width: 16, height: 16)
                .overlay(Circle().strokeBorder(Color.appSoftBrown.opacity(0.2), lineWidth: 0.5))

            Text("Tap petals to paint")
                .font(.system(.caption, design: AppTheme.fontFamily))
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))

            Spacer()

            if !paintHistory.isEmpty {
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        undoLastPaint()
                    }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                }
            }

            if !petalColors.isEmpty {
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        petalColors = [:]
                        paintHistory = []
                        petalTapPhase = [:]
                    }
                } label: {
                    Text("Clear Paint")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appRose.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Actions

    /// Compares two Colors by resolved RGB components (Color == is unreliable).
    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        let ra = a.resolve(in: EnvironmentValues())
        let rb = b.resolve(in: EnvironmentValues())
        return abs(ra.red - rb.red) < 0.01
            && abs(ra.green - rb.green) < 0.01
            && abs(ra.blue - rb.blue) < 0.01
    }

    private func handlePetalTap(key: String) {
        if let info = petalTapPhase[key] {
            switch info.phase {
            case 1:
                // Tap 2: revert to previous color
                if let prev = info.previousColor {
                    petalColors[key] = prev
                } else {
                    petalColors.removeValue(forKey: key)
                }
                petalTapPhase[key] = (phase: 2, previousColor: info.previousColor)

            case 2:
                // Tap 3: revert to base (remove all paint)
                petalColors.removeValue(forKey: key)
                petalTapPhase[key] = (phase: 3, previousColor: nil)

            default:
                // Tap 4+: paint again, restart cycle
                let current = petalColors[key]
                paintHistory.append((key: key, oldColor: current))
                petalColors[key] = activePaintColor
                petalTapPhase[key] = (phase: 1, previousColor: current)
            }
        } else {
            // Tap 1: first paint on this petal
            let current = petalColors[key]
            paintHistory.append((key: key, oldColor: current))
            petalColors[key] = activePaintColor
            petalTapPhase[key] = (phase: 1, previousColor: current)
        }
    }

    private func undoLastPaint() {
        guard let last = paintHistory.popLast() else { return }
        if let oldColor = last.oldColor {
            petalColors[last.key] = oldColor
        } else {
            petalColors.removeValue(forKey: last.key)
        }
        // Reset tap cycle for that petal so it doesn't get confused
        petalTapPhase.removeValue(forKey: last.key)
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
            petalColors = [:]
            paintHistory = []
            petalTapPhase = [:]
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
            petalColors = design.petalColorOverrides
            paintHistory = []
            petalTapPhase = [:]
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
            geometry: geometry,
            petalColors: petalColors
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
    var title: String = "Name Your Preset"
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @State private var name: String = ""

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))

            TextField("Preset name", text: $name)
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

// MARK: - Shake-to-Undo Support

extension Notification.Name {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}
