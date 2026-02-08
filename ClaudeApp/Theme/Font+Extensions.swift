import SwiftUI

extension View {
    func warmTitle() -> some View {
        self.font(.system(.title2, design: .rounded, weight: .semibold))
            .foregroundStyle(Color.appSoftBrown)
    }

    func warmHeadline() -> some View {
        self.font(.system(.headline, design: .rounded, weight: .medium))
            .foregroundStyle(Color.appSoftBrown)
    }

    func guidanceText() -> some View {
        self.font(.system(.body, design: .serif))
            .foregroundStyle(Color.appSoftBrown.opacity(0.85))
    }

    func captionStyle() -> some View {
        self.font(.system(.caption, design: .rounded))
            .foregroundStyle(Color.appSoftBrown.opacity(0.6))
    }

    func affirmationStyle() -> some View {
        self.font(.system(.title3, design: .serif, weight: .medium))
            .italic()
            .foregroundStyle(Color.appSoftBrown.opacity(0.8))
    }
}
