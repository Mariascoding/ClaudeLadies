import SwiftUI

struct RadialSelectorWheel<MoonContent: View>: View {
    @Binding var selectedIndex: Int
    let items: [(icon: String, label: String, color: Color)]
    @ViewBuilder var moonView: () -> MoonContent

    @State private var rotationAngle: Double = 0
    @State private var dragStartAngle: Double = 0
    @GestureState private var isDragging = false

    // Ellipse radii for 3D tilt appearance
    private let radiusX: CGFloat = 140
    private let radiusY: CGFloat = 50
    private let frameWidth: CGFloat = 380
    private let frameHeight: CGFloat = 280

    var body: some View {
        ZStack {
            // Subtle elliptical track
            Ellipse()
                .stroke(
                    Color.appSoftBrown.opacity(0.1),
                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                )
                .frame(width: radiusX * 2, height: radiusY * 2)

            // Carousel items — sorted by zIndex so front renders on top
            let indexed = items.indices.map { index in
                (index: index, depth: depthInfo(for: index))
            }.sorted { $0.depth.zIndex < $1.depth.zIndex }

            ForEach(indexed, id: \.index) { item in
                carouselNode(index: item.index, depth: item.depth)
                    .zIndex(item.depth.zIndex)
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }

    // MARK: - Carousel Node

    @ViewBuilder
    private func carouselNode(index: Int, depth: DepthInfo) -> some View {
        let isSelected = index == selectedIndex

        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                rotateToItem(index)
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                // Hero visual
                if index == 0 {
                    // Moon item — render the actual MoonView
                    moonView()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    // SF Symbol hero
                    Image(systemName: items[index].icon)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 50, weight: .light))
                        .foregroundStyle(items[index].color)
                        .frame(width: 80, height: 80)
                }

                // Label
                Text(items[index].label)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(
                        isSelected
                            ? items[index].color
                            : Color.appSoftBrown.opacity(0.6)
                    )

                // Summary text — only visible for near-front item
                if depth.normDepth > 0.85 {
                    Text(summaryText(for: index))
                        .font(.system(.caption2, design: .serif))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: 140)
                        .transition(.opacity)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(depth.scale)
        .opacity(depth.opacity)
        .blur(radius: depth.blur)
        .position(
            x: frameWidth / 2 + depth.position.x,
            y: frameHeight / 2 + depth.position.y
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedIndex)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: rotationAngle)
    }

    // MARK: - Depth Calculation

    private struct DepthInfo {
        let position: CGPoint
        let scale: CGFloat
        let opacity: Double
        let blur: CGFloat
        let zIndex: Double
        let normDepth: Double
    }

    private func depthInfo(for index: Int) -> DepthInfo {
        let angle = itemAngle(for: index)
        let depthFactor = cos(angle) // -1 = front, +1 = back
        let normDepth = (1 - depthFactor) / 2 // 0 = back, 1 = front

        let x = radiusX * CGFloat(sin(angle))
        let y = radiusY * CGFloat(cos(angle))

        return DepthInfo(
            position: CGPoint(x: x, y: y),
            scale: 0.55 + 0.45 * normDepth,
            opacity: 0.25 + 0.75 * normDepth,
            blur: 3 * (1 - normDepth),
            zIndex: 100 * normDepth,
            normDepth: normDepth
        )
    }

    // MARK: - Geometry

    private func itemAngle(for index: Int) -> Double {
        rotationAngle + Double(index) * (.pi / 2) + .pi  // +π so item 0 starts at front
    }

    // MARK: - Summary Text

    private func summaryText(for index: Int) -> String {
        switch index {
        case 0: return "Lunar phase & archetype"
        case 1: return "Daily guidance & protection"
        case 2: return "Cycle phase insights"
        case 3: return "Nutrition & movement"
        default: return ""
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                let delta = value.translation.width / 150
                withAnimation(.interactiveSpring()) {
                    rotationAngle = dragStartAngle + Double(delta) * .pi
                }
            }
            .onEnded { _ in
                snapToNearest()
            }
            .simultaneously(with: DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDragging {
                        dragStartAngle = rotationAngle
                    }
                }
            )
    }

    // MARK: - Snap Logic

    private func snapToNearest() {
        var normalized = rotationAngle.truncatingRemainder(dividingBy: 2 * .pi)
        if normalized < 0 { normalized += 2 * .pi }

        let slotAngle = Double.pi / 2
        let snapSlot = Int(round(normalized / slotAngle)) % 4

        let snappedAngle = Double(snapSlot) * slotAngle
        let newIndex = (4 - snapSlot) % 4

        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            rotationAngle = snappedAngle
            selectedIndex = newIndex
        }
        dragStartAngle = snappedAngle
    }

    private func rotateToItem(_ index: Int) {
        let targetSlot = (4 - index) % 4
        let targetAngle = Double(targetSlot) * (.pi / 2)

        var normalized = rotationAngle.truncatingRemainder(dividingBy: 2 * .pi)
        if normalized < 0 { normalized += 2 * .pi }

        var delta = targetAngle - normalized
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }

        rotationAngle += delta
        selectedIndex = index
        dragStartAngle = rotationAngle
    }
}
