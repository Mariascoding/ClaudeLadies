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
}
