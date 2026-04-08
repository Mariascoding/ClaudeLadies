import SwiftUI

struct SpectrumColorPickerView: View {
    @State private var hue: CGFloat = 0.0
    @State private var saturation: CGFloat = 1.0
    @State private var brightness: CGFloat = 1.0

    private var selectedColor: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    private var hexString: String {
        let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    private var previewTextColor: Color {
        let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5 ? .black : .white
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Color preview
                selectedColor
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))
                    .overlay {
                        Text(hexString)
                            .font(.system(.title3, design: .monospaced, weight: .semibold))
                            .foregroundStyle(previewTextColor)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)

                // Spectrum picker — 100px tall
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Spectrum")
                        .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))

                    spectrumCanvas
                }
                .padding(.horizontal, AppTheme.Spacing.md)

                // Brightness slider
                brightnessSlider

                // Color values
                colorValuesCard

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Color Picker")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Spectrum Canvas

    private var spectrumCanvas: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let columnWidth: CGFloat = 2
                var x: CGFloat = 0
                while x < size.width {
                    let h = x / size.width
                    context.fill(
                        Path(CGRect(x: x, y: 0, width: columnWidth + 0.5, height: size.height)),
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(hue: h, saturation: 1.0, brightness: brightness),
                                Color(hue: h, saturation: 0.0, brightness: brightness)
                            ]),
                            startPoint: .init(x: x, y: 0),
                            endPoint: .init(x: x, y: size.height)
                        )
                    )
                    x += columnWidth
                }
            }
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
            .overlay {
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .frame(width: 24, height: 24)
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
                    }
            )
        }
        .frame(height: 100)
    }

    // MARK: - Brightness Slider

    private var brightnessSlider: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Brightness")
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                Spacer()
                Text("\(Int(brightness * 100))%")
                    .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .semibold))
                    .foregroundStyle(selectedColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
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
                        .fill(selectedColor)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                        .shadow(color: .black.opacity(0.15), radius: 3)
                        .frame(width: 28, height: 28)
                        .position(
                            x: brightness * geo.size.width,
                            y: geo.size.height / 2
                        )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            brightness = max(0, min(1, value.location.x / geo.size.width))
                        }
                )
            }
            .frame(height: 28)
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Color Values

    private var colorValuesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().strokeBorder(Color.appSoftBrown.opacity(0.2), lineWidth: 0.5))
                Text("Color Values")
                    .warmHeadline()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                valueCell(label: "Hue", value: "\(Int(hue * 360))\u{00B0}")
                valueCell(label: "Sat", value: "\(Int(saturation * 100))%")
                valueCell(label: "Bri", value: "\(Int(brightness * 100))%")
            }

            let rgb = rgbComponents()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                valueCell(label: "R", value: "\(rgb.r)")
                valueCell(label: "G", value: "\(rgb.g)")
                valueCell(label: "B", value: "\(rgb.b)")
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func valueCell(label: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(label)
                .captionStyle()
            Text(value)
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .foregroundStyle(Color.appSoftBrown)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(Color.appSoftBrown.opacity(0.06))
        .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.sm))
    }

    private func rgbComponents() -> (r: Int, g: Int, b: Int) {
        let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
