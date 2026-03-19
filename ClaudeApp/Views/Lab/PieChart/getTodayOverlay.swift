import SwiftUI

func getTodayOverlay(
    for cycleLength: Int,
    todayUnit: Int,
    highlightColor: Color = .white,
    dimOpacity: Double = 0.0
) -> [PieSegment] {
    let clampedToday = min(max(todayUnit, 0), max(cycleLength - 1, 0))

    return (0..<cycleLength).map { i in
        PieSegment(
            id: "today_\(i)",
            units: 1.0,
            color: (i == clampedToday)
                ? highlightColor
                : highlightColor.opacity(dimOpacity)
        )
    }
}
