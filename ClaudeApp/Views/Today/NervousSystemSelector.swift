import SwiftUI

struct NervousSystemSelector: View {
    let selectedState: NervousSystemState?
    let onSelect: (NervousSystemState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Nervous System")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                .textCase(.uppercase)
                .kerning(1.0)

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NervousSystemState.allCases) { state in
                    stateButton(state)
                }
            }

            if let selected = selectedState {
                Text(selected.description)
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                    .transition(.opacity)
            }
        }
        .warmCard()
    }

    private func stateButton(_ state: NervousSystemState) -> some View {
        let isSelected = selectedState == state

        return Button {
            withAnimation(AppTheme.gentleAnimation) {
                onSelect(state)
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: state.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : state.color)

                Text(state.displayName)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? state.color : state.color.opacity(0.06))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
        }
    }
}
