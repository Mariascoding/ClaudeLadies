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
    @State private var didInit = false

    var body: some View {
        VStack(spacing: 4) {
            // Spectrum — fills remaining height
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

            // Brightness slider
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
                        .background(Color(hue: hue, saturation: saturation, brightness: brightness))
                        .clipShape(Capsule())
                }
            }
            .frame(height: 26)
        }
        .frame(height: 140)
        .onAppear {
            guard !didInit else { return }
            didInit = true
            let uiColor = UIColor(selection)
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            hue = h
            saturation = s
            brightness = b
        }
    }

    private func updateSelection() {
        selection = Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}
