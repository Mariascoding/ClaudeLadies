import SwiftUI

struct FlowerPartPicker<Option: Hashable & Identifiable & CaseIterable>: View where Option.AllCases: RandomAccessCollection {
    let part: FlowerPart
    @Binding var selection: Option
    @Binding var colorSelection: Color
    let displayName: (Option) -> String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Top row: icon, label, design menu
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
            }

            // Bottom row: color wheel picker
            ColorPicker("Color", selection: $colorSelection, supportsOpacity: false)
                .font(.system(.subheadline, design: AppTheme.fontFamily, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.6))
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
