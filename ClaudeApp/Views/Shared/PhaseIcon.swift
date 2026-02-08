import SwiftUI

struct PhaseIcon: View {
    let phase: CyclePhase
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: phase.icon)
            .font(.system(size: size))
            .foregroundStyle(phase.accentColor)
            .symbolRenderingMode(.hierarchical)
    }
}
