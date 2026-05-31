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

            // Inline spectrum color picker
            if showColors {
                VStack(spacing: AppTheme.Spacing.xs) {
                    if let paintBinding = isPaintMode {
                        paintModeToggle(paintBinding)
                    }
                    SpectrumColorPicker(selection: activeColorBinding)
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .warmCard()
    }

    private func paintModeToggle(_ paintBinding: Binding<Bool>) -> some View {
        HStack {
            Button {
                withAnimation(AppTheme.gentleAnimation) {
                    paintBinding.wrappedValue.toggle()
                }
            } label: {
                let brushColor = paintColor?.wrappedValue ?? part.accentColor
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: paintBinding.wrappedValue ? "paintbrush.fill" : "paintbrush")
                        .font(.system(size: 13, weight: .medium))
                    Text("Paint")
                        .font(.system(.caption, design: AppTheme.fontFamily, weight: .medium))
                }
                .foregroundStyle(paintBinding.wrappedValue ? brushColor : Color.appSoftBrown.opacity(0.6))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(paintBinding.wrappedValue
                              ? (paintColor?.wrappedValue ?? part.accentColor).opacity(0.15)
                              : Color.appSoftBrown.opacity(0.05))
                )
            }
            Spacer()
        }
    }
}
