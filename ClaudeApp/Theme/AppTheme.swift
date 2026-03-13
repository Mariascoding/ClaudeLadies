import SwiftUI

enum AppTheme {
    // MARK: - Spacing
    enum Spacing {
        static var xxs: CGFloat { ThemeOverrides.shared.activeTheme?.spaceXXS ?? 2 }
        static var xs: CGFloat { ThemeOverrides.shared.activeTheme?.spaceXS ?? 4 }
        static var sm: CGFloat { ThemeOverrides.shared.activeTheme?.spaceSM ?? 8 }
        static var md: CGFloat { ThemeOverrides.shared.activeTheme?.spaceMD ?? 16 }
        static var lg: CGFloat { ThemeOverrides.shared.activeTheme?.spaceLG ?? 24 }
        static var xl: CGFloat { ThemeOverrides.shared.activeTheme?.spaceXL ?? 32 }
        static var xxl: CGFloat { ThemeOverrides.shared.activeTheme?.spaceXXL ?? 48 }
    }

    // MARK: - Corner Radii
    enum Radius {
        static var sm: CGFloat { ThemeOverrides.shared.activeTheme?.radiusSM ?? 8 }
        static var md: CGFloat { ThemeOverrides.shared.activeTheme?.radiusMD ?? 12 }
        static var lg: CGFloat { ThemeOverrides.shared.activeTheme?.radiusLG ?? 20 }
        static var xl: CGFloat { ThemeOverrides.shared.activeTheme?.radiusXL ?? 28 }
        static var pill: CGFloat { ThemeOverrides.shared.activeTheme?.radiusPill ?? 100 }
    }

    // MARK: - Shadows
    static var softShadow: Color {
        if let theme = ThemeOverrides.shared.activeTheme {
            return Color.black.opacity(theme.shadowOpacity)
        }
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.3)
                : UIColor.black.withAlphaComponent(0.06)
        })
    }
    static var softShadowRadius: CGFloat {
        ThemeOverrides.shared.activeTheme?.shadowRadius ?? 8
    }
    static var softShadowY: CGFloat {
        ThemeOverrides.shared.activeTheme?.shadowY ?? 2
    }

    // MARK: - Typography
    static var fontFamily: Font.Design {
        ThemeOverrides.shared.activeTheme?.fontFamily ?? (ColorTheme.current == .lux ? .serif : .rounded)
    }
    static var fontFamilySerif: Font.Design {
        ThemeOverrides.shared.activeTheme?.fontFamilyDisplay ?? .serif
    }
    static var lineSpacing: CGFloat {
        ThemeOverrides.shared.activeTheme?.lineSpacing ?? 0
    }

    // MARK: - Animation
    static let gentleAnimation: Animation = .easeInOut(duration: 0.3)
    static let breathAnimation: Animation = .easeInOut(duration: 4.0).repeatForever(autoreverses: true)
}
