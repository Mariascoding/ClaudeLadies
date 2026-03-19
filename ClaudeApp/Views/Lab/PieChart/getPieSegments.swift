import SwiftUI

func getPieSegments(for cycleLength: Int) -> [PieSegment] {
    let period = 5.0
    let follicular = 8.0
    let ovulation = 3.0
    let luteal = max(Double(cycleLength) - (period + follicular + ovulation), 12.0)

    return [
        PieSegment(id: "menstrual", units: period, color: Color(red: 0.78, green: 0.35, blue: 0.45)),
        PieSegment(id: "follicular", units: follicular, color: Color(red: 0.45, green: 0.68, blue: 0.52)),
        PieSegment(id: "ovulation", units: ovulation, color: Color(red: 0.88, green: 0.58, blue: 0.38)),
        PieSegment(id: "luteal", units: luteal, color: Color(red: 0.55, green: 0.45, blue: 0.62)),
    ]
}
