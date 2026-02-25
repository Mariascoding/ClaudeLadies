import SwiftUI

struct SoftRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: radius, style: .continuous)
    }
}

extension View {
    func warmCard(padding: CGFloat = AppTheme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(Color.appWarmWhite)
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.lg))
            .shadow(color: AppTheme.softShadow, radius: AppTheme.softShadowRadius, y: AppTheme.softShadowY)
    }
}
