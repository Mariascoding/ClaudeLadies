import SwiftUI

struct FlowerPartPicker<Option: Hashable & Identifiable & CaseIterable>: View where Option.AllCases: RandomAccessCollection {
    let part: FlowerPart
    @Binding var selection: Option
    @Binding var colorSelection: Color
    let displayName: (Option) -> String

    /// Optional paint mode binding — when non-nil, a paintbrush circle appears in the palette.
    var isPaintMode: Binding<Bool>? = nil
    /// The active brush color — shown on the paintbrush, set by palette taps while painting.
    var paintColor: Binding<Color>? = nil

    @State private var showColors = false

    /// Whether paint mode is currently on (convenience).
    private var painting: Bool {
        isPaintMode?.wrappedValue == true
    }

    /// The binding that color picks should target:
    /// paint mode → brush color, normal mode → layer base color.
    private var activeColorBinding: Binding<Color> {
        if painting, let pc = paintColor {
            return pc
        }
        return $colorSelection
    }

    /// The color to highlight as "selected" in the palette.
    private var highlightedColor: Color {
        painting ? (paintColor?.wrappedValue ?? colorSelection) : colorSelection
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Main row: icon, name, shape menu, color dot
            HStack {
                Image(systemName: part.icon)
                    .foregroundStyle(part.accentColor)
                    .font(.system(.body, design: AppTheme.fontFamily, weight: .medium))

                Text(part.displayName)
                    .warmHeadline()

                Spacer()

                Menu {
                    ForEach(Array(Option.allCases)) { option in
                        Button {
                            withAnimation(AppTheme.gentleAnimation) {
                                selection = option
                            }
                        } label: {
                            Label(
                                displayName(option),
                                systemImage: selection == option ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(displayName(selection))
                            .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                            .foregroundStyle(part.accentColor)

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundStyle(part.accentColor.opacity(0.7))
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(part.accentColor.opacity(0.1))
                    )
                }

                // Color dot — tap to toggle palette
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        showColors.toggle()
                    }
                } label: {
                    Circle()
                        .fill(colorSelection)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.appSoftBrown.opacity(0.2), lineWidth: 1)
                        )
                }
            }

            // Inline color palette
            if showColors {
                colorPalette
            }
        }
        .warmCard()
    }

    private var colorPalette: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            // Color wheel for custom colors — bound to the active target
            ColorPicker("", selection: activeColorBinding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                                center: .center
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .fill(Color.appWarmWhite)
                                .frame(width: 14, height: 14)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.appSoftBrown.opacity(0.15), lineWidth: 1)
                        )
                        .allowsHitTesting(false)
                )

            // Paintbrush circle — tap to toggle paint mode
            if let paintBinding = isPaintMode {
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        paintBinding.wrappedValue.toggle()
                    }
                } label: {
                    let brushColor = paintColor?.wrappedValue ?? part.accentColor
                    ZStack {
                        Circle()
                            .fill(paintBinding.wrappedValue ? brushColor : Color.appSoftBrown.opacity(0.08))
                            .frame(width: 32, height: 32)
                        Image(systemName: paintBinding.wrappedValue ? "paintbrush.fill" : "paintbrush")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(paintBinding.wrappedValue ? .white : Color.appSoftBrown.opacity(0.6))
                    }
                    .overlay(
                        Circle()
                            .strokeBorder(
                                paintBinding.wrappedValue ? brushColor : Color.appSoftBrown.opacity(0.15),
                                lineWidth: paintBinding.wrappedValue ? 2.5 : 1
                            )
                    )
                }
            }

            // Preset colors — route to active target
            ForEach(FlowerColor.allCases) { fc in
                Button {
                    withAnimation(AppTheme.gentleAnimation) {
                        activeColorBinding.wrappedValue = fc.color
                    }
                } label: {
                    Circle()
                        .fill(fc.color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    FlowerColor.closest(to: highlightedColor) == fc
                                        ? Color.appSoftBrown
                                        : Color.appSoftBrown.opacity(0.15),
                                    lineWidth: FlowerColor.closest(to: highlightedColor) == fc ? 2.5 : 1
                                )
                        )
                }
            }
        }
        .padding(.top, AppTheme.Spacing.xs)
    }
}
