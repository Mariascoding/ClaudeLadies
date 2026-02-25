import SwiftUI

enum AppTheme {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radii
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 100
    }

    // MARK: - Shadows
    static var softShadow: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.3)
                : UIColor.black.withAlphaComponent(0.06)
        })
    }
    static let softShadowRadius: CGFloat = 8
    static let softShadowY: CGFloat = 2

    // MARK: - Animation
    static let gentleAnimation: Animation = .easeInOut(duration: 0.3)
    static let breathAnimation: Animation = .easeInOut(duration: 4.0).repeatForever(autoreverses: true)
}
