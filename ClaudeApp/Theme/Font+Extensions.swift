import SwiftUI

extension View {
    func warmTitle() -> some View {
        self.font(.system(.title2, design: AppTheme.fontFamily, weight: AppTheme.fontFamily == .serif ? .bold : .semibold))
            .lineSpacing(AppTheme.lineSpacing)
            .foregroundStyle(Color.appSoftBrown)
    }

    func warmHeadline() -> some View {
        self.font(.system(.headline, design: AppTheme.fontFamily, weight: .medium))
            .lineSpacing(AppTheme.lineSpacing)
            .foregroundStyle(Color.appSoftBrown)
    }

    func guidanceText() -> some View {
        self.font(.system(.body, design: AppTheme.fontFamilySerif))
            .lineSpacing(AppTheme.lineSpacing)
            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
    }

    func captionStyle() -> some View {
        self.font(.system(.caption, design: AppTheme.fontFamily))
            .lineSpacing(AppTheme.lineSpacing)
            .foregroundStyle(Color.appSoftBrown.opacity(0.6))
    }

    func affirmationStyle() -> some View {
        self.font(.system(.title3, design: AppTheme.fontFamilySerif, weight: AppTheme.fontFamily == .serif ? .bold : .medium))
            .italic()
            .lineSpacing(AppTheme.lineSpacing)
            .foregroundStyle(Color.appSoftBrown.opacity(0.8))
    }

    /// Uppercase tracked label — editorial section marker
    func sectionLabel() -> some View {
        self.font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            .textCase(.uppercase)
            .kerning(1.0)
    }

    /// Uppercase tracked label with custom color
    func sectionLabel(color: Color) -> some View {
        self.font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(color)
            .textCase(.uppercase)
            .kerning(1.0)
    }

    /// Serif body with line spacing — for wisdom/guidance content
    func serifBody() -> some View {
        self.font(.system(.body, design: .serif))
            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
            .lineSpacing(4)
    }

    /// Serif caption italic — for subtle timing/context info
    func serifCaption() -> some View {
        self.font(.system(.caption, design: .serif))
            .italic()
            .foregroundStyle(Color.appSoftBrown.opacity(0.55))
    }
}
