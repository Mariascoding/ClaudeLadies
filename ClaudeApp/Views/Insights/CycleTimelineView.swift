import SwiftUI

struct CycleTimelineView: View {
    let boundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)]
    let currentDay: Int
    let cycleLength: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Your Cycle")
                .warmHeadline()

            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .leading) {
                    // Phase bars
                    HStack(spacing: 2) {
                        ForEach(boundaries, id: \.phase) { boundary in
                            let duration = boundary.endDay - boundary.startDay + 1
                            let fraction = CGFloat(duration) / CGFloat(cycleLength)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(boundary.phase.accentColor.opacity(0.3))
                                .frame(width: max(0, (width - CGFloat(boundaries.count - 1) * 2) * fraction))
                                .overlay(
                                    Text(boundary.phase.innerSeason.replacingOccurrences(of: "Inner ", with: ""))
                                        .font(.system(size: 9, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                                )
                        }
                    }
                    .frame(height: 32)

                    // Current position dot
                    let dotPosition = (CGFloat(currentDay - 1) / CGFloat(max(1, cycleLength - 1))) * width
                    Circle()
                        .fill(currentPhase?.accentColor ?? .appRose)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .offset(x: min(max(0, dotPosition - 6), width - 12))
                }
            }
            .frame(height: 32)

            HStack {
                Text("Day 1")
                Spacer()
                Text("Day \(cycleLength)")
            }
            .captionStyle()
        }
        .warmCard()
    }

    private var currentPhase: CyclePhase? {
        boundaries.first { currentDay >= $0.startDay && currentDay <= $0.endDay }?.phase
    }
}
