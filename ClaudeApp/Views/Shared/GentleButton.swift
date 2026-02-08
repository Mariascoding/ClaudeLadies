import SwiftUI

struct GentleButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(_ title: String, color: Color = .appRose, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(color)
                .clipShape(Capsule())
        }
    }
}

struct GentleOutlineButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(_ title: String, color: Color = .appSoftBrown, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(color)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        }
    }
}
