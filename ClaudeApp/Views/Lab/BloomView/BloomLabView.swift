import SwiftUI

struct BloomLabView: View {
    @State private var isHolding = false

    var body: some View {
        ZStack(alignment: .bottom) {
            BloomCanvas(isHolding: $isHolding)
                .ignoresSafeArea()

            Text("Press & Hold to Bloom")
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .environment(\.colorScheme, .dark)
                .opacity(isHolding ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: isHolding)
                .padding(.bottom, 40)
        }
        .navigationTitle("Bloom")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
