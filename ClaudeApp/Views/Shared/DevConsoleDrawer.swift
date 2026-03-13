import SwiftUI

struct DevConsoleDrawer: View {
    @AppStorage("devConsoleEnabled") private var isEnabled = false
    @State private var isExpanded = false

    private var activeTheme: DesignTheme? {
        ThemeOverrides.shared.activeTheme
    }

    var body: some View {
        if isEnabled {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    dragHandle

                    if isExpanded {
                        Divider().opacity(0.3)
                        themePicker
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
                .shadow(color: Color.black.opacity(0.15), radius: 12, y: -4)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .animation(.spring(response: 0.3), value: isExpanded)
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        VStack(spacing: 2) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)

            if !isExpanded {
                Text("DEV")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.secondary.opacity(0.5))
            }
        }
        .padding(.top, 6)
        .padding(.bottom, isExpanded ? 4 : 6)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    withAnimation(.spring(response: 0.3)) {
                        if value.translation.height < -20 { isExpanded = true }
                        else if value.translation.height > 20 { isExpanded = false }
                    }
                }
        )
    }

    // MARK: - Theme Picker

    private var themePicker: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Design Theme")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.secondary)

                Spacer()

                if activeTheme != nil {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            ThemeOverrides.shared.activeTheme = nil
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 9))
                            Text("Reset")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color.primary.opacity(0.5))
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DesignTheme.all) { theme in
                        themeCard(theme)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .padding(.bottom, 8)
    }

    // MARK: - Theme Card

    private func themeCard(_ theme: DesignTheme) -> some View {
        let isSelected = activeTheme?.id == theme.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                ThemeOverrides.shared.activeTheme = isSelected ? nil : theme
            }
        } label: {
            VStack(spacing: 6) {
                // Icon + Name
                HStack(spacing: 4) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 10))
                    Text(theme.name)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)

                // Color swatches
                HStack(spacing: 3) {
                    Circle().fill(theme.primary).frame(width: 12, height: 12)
                    Circle().fill(theme.secondary).frame(width: 12, height: 12)
                    Circle().fill(theme.tertiary).frame(width: 12, height: 12)
                }

                // Attributes
                HStack(spacing: 6) {
                    attributeLabel(spacingLabel(theme))
                    attributeLabel(radiusLabel(theme))
                    attributeLabel(shadowLabel(theme))
                }

                // Font indicator
                Text(fontLabel(theme))
                    .font(.system(size: 9, weight: .medium, design: theme.fontFamily))
                    .foregroundStyle(Color.secondary.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(isSelected ? 0.08 : 0.03))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isSelected ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Helpers

    private func attributeLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .medium, design: .monospaced))
            .foregroundStyle(Color.secondary.opacity(0.6))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.primary.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    private func spacingLabel(_ theme: DesignTheme) -> String {
        switch theme.spaceMD {
        case ...13: "S"
        case 14...17: "M"
        default: "L"
        }
    }

    private func radiusLabel(_ theme: DesignTheme) -> String {
        switch theme.radiusMD {
        case ...7: "r:S"
        case 8...13: "r:M"
        default: "r:L"
        }
    }

    private func shadowLabel(_ theme: DesignTheme) -> String {
        switch theme.shadowOpacity {
        case ...0.04: "sh:S"
        case 0.04...0.08: "sh:M"
        default: "sh:L"
        }
    }

    private func fontLabel(_ theme: DesignTheme) -> String {
        switch theme.fontFamily {
        case .rounded: "Rounded"
        case .serif: "Serif"
        case .default: "System"
        default: "Custom"
        }
    }
}
