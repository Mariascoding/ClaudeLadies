import SwiftUI

struct NervousSystemSelector: View {
    let selectedState: NervousSystemState?
    let onSelect: (NervousSystemState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("How does your nervous system feel?")
                .warmHeadline()

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NervousSystemState.allCases) { state in
                    stateButton(state)
                }
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
            VStack(spacing: 6) {
                Image(systemName: state.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : state.color)

                Text(state.displayName)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.appSoftBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(isSelected ? state.color : state.color.opacity(0.08))
            .clipShape(SoftRoundedRectangle(radius: AppTheme.Radius.md))
        }
    }
}
