import SwiftUI

// MARK: - Lab Demo

struct SpectrumColorPickerView: View {
    @State private var selectedColor: Color = .appRose

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            SpectrumColorPicker(
                selection: $selectedColor,
                onCancel: {},
                onConfirm: {}
            )
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Color Picker")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Reusable Component (140px)

struct SpectrumColorPicker: View {
    @Binding var selection: Color
    var onCancel: () -> Void
    var onConfirm: () -> Void

    @State private var hue: CGFloat = 0.0
    @State private var saturation: CGFloat = 1.0
    @State private var brightness: CGFloat = 1.0
    @State private var savedColors: [SavedColor] = []
    @State private var didInit = false

    private static let presets: [Color] = [
        .red, .orange, .yellow, .green, .mint,
        .cyan, .blue, .indigo, .purple, .pink,
        .white, .gray, .black
    ]

    var body: some View {
        VStack(spacing: 4) {
            // Spectrum
            spectrumCanvas

            // Brightness slider
            brightnessSlider

            // Palette row
            paletteRow

            // Cancel / Confirm
            HStack(spacing: 8) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .strokeBorder(Color.appSoftBrown.opacity(0.3), lineWidth: 1)
                        )
                }

                Button {
                    onConfirm()
                } label: {
                    Text("Confirm")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(Color.appRose)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 26)
        }
        .frame(height: 188)
        .onAppear {
            guard !didInit else { return }
            didInit = true
            loadHSB(from: selection)
            savedColors = SavedColor.load()
        }
    }

    // MARK: - Spectrum

    private var spectrumCanvas: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let step: CGFloat = 2
                var x: CGFloat = 0
                while x < size.width {
                    let h = x / size.width
                    context.fill(
                        Path(CGRect(x: x, y: 0, width: step + 0.5, height: size.height)),
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(hue: h, saturation: 1.0, brightness: brightness),
                                Color(hue: h, saturation: 0.0, brightness: brightness)
                            ]),
                            startPoint: .init(x: x, y: 0),
                            endPoint: .init(x: x, y: size.height)
                        )
                    )
                    x += step
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay {
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .frame(width: 20, height: 20)
                    .position(
                        x: hue * geo.size.width,
                        y: (1 - saturation) * geo.size.height
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = max(0, min(1, value.location.x / geo.size.width))
                        saturation = max(0, min(1, 1 - value.location.y / geo.size.height))
                        updateSelection()
                    }
            )
        }
    }

    // MARK: - Brightness

    private var brightnessSlider: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hue: hue, saturation: saturation, brightness: 0),
                        Color(hue: hue, saturation: saturation, brightness: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())

                Circle()
                    .fill(Color(hue: hue, saturation: saturation, brightness: brightness))
                    .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.15), radius: 2)
                    .frame(width: 16, height: 16)
                    .position(
                        x: brightness * geo.size.width,
                        y: geo.size.height / 2
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        brightness = max(0, min(1, value.location.x / geo.size.width))
                        updateSelection()
                    }
            )
        }
        .frame(height: 16)
    }

    // MARK: - Palette

    private var paletteRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // Add current colour button
                Button {
                    let newColor = SavedColor(hex: currentHex())
                    withAnimation(.easeInOut(duration: 0.2)) {
                        savedColors.append(newColor)
                        SavedColor.save(savedColors)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hue: hue, saturation: saturation, brightness: brightness))
                            .overlay(Circle().strokeBorder(Color.appSoftBrown.opacity(0.2), lineWidth: 0.5))
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1)
                    }
                    .frame(width: 44, height: 44)
                }

                // Divider
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(Color.appSoftBrown.opacity(0.15))
                    .frame(width: 1, height: 30)

                // Preset colours
                ForEach(Self.presets, id: \.description) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 34, height: 34)
                        .overlay(Circle().strokeBorder(Color.appSoftBrown.opacity(0.15), lineWidth: 0.5))
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                        .onTapGesture {
                            loadHSB(from: color)
                            updateSelection()
                        }
                }

                // Saved colours
                if !savedColors.isEmpty {
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(Color.appSoftBrown.opacity(0.15))
                        .frame(width: 1, height: 30)

                    ForEach(savedColors) { saved in
                        Circle()
                            .fill(saved.color)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                            .onTapGesture {
                                loadHSB(from: saved.color)
                                updateSelection()
                            }
                            .onLongPressGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    savedColors.removeAll { $0.id == saved.id }
                                    SavedColor.save(savedColors)
                                }
                            }
                    }
                }
            }
        }
        .frame(height: 44)
    }

    // MARK: - Helpers

    private func updateSelection() {
        selection = Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    private func loadHSB(from color: Color) {
        let uiColor = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = h
        saturation = s
        brightness = b
    }

    private func currentHex() -> String {
        let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Saved Color Persistence

private struct SavedColor: Identifiable, Codable {
    let id: UUID
    let hex: String

    init(hex: String) {
        self.id = UUID()
        self.hex = hex
    }

    var color: Color {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6, let int = UInt64(hex, radix: 16) else { return .gray }
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }

    private static let key = "spectrumPicker_savedColors"

    static func load() -> [SavedColor] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let colors = try? JSONDecoder().decode([SavedColor].self, from: data) else { return [] }
        return colors
    }

    static func save(_ colors: [SavedColor]) {
        if let data = try? JSONEncoder().encode(colors) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
