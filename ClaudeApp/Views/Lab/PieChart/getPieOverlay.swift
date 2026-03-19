import SwiftUI

func getPieOverlay(for cycleLength: Int) -> [PieSegment] {
    let periodUnits = Int(round(5.0))
    let follicularUnits = Int(round(8.0))
    let ovulationUnits = Int(round(3.0))
    let lutealUnits = max(cycleLength - (periodUnits + follicularUnits + ovulationUnits), 12)

    let used = periodUnits + follicularUnits + ovulationUnits
    let finalLuteal = max(min(lutealUnits, max(cycleLength - used, 0)), 0)

    struct PhaseDef {
        let id: String
        let count: Int
    }

    let phases: [PhaseDef] = [
        .init(id: "menstrual",  count: min(periodUnits, cycleLength)),
        .init(id: "follicular", count: max(min(follicularUnits, cycleLength - min(periodUnits, cycleLength)), 0)),
        .init(id: "ovulation",  count: max(min(ovulationUnits, cycleLength - min(periodUnits, cycleLength) - max(min(follicularUnits, cycleLength - min(periodUnits, cycleLength)), 0)), 0)),
        .init(id: "luteal",     count: max(min(finalLuteal, cycleLength - (min(periodUnits, cycleLength)
                                                                           + max(min(follicularUnits, cycleLength - min(periodUnits, cycleLength)), 0)
                                                                           + max(min(ovulationUnits, cycleLength - min(periodUnits, cycleLength) - max(min(follicularUnits, cycleLength - min(periodUnits, cycleLength)), 0)), 0))), 0))
    ]

    func gray(_ t: Double) -> Color {
        let clamped = min(max(t, 0.0), 1.0)
        let v = 1.0 - clamped
        return Color(red: v, green: v, blue: v)
    }

    var segments: [PieSegment] = []
    segments.reserveCapacity(cycleLength)

    var globalDayIndex = 0

    for phase in phases where phase.count > 0 {
        for i in 0..<phase.count {
            let denom = max(phase.count - 1, 1)
            let t = Double(i) / Double(denom)

            segments.append(
                PieSegment(
                    id: "\(phase.id)_\(globalDayIndex)",
                    units: 1.0,
                    color: gray(t)
                )
            )

            globalDayIndex += 1
            if globalDayIndex >= cycleLength { break }
        }
        if globalDayIndex >= cycleLength { break }
    }

    if segments.count > cycleLength {
        segments = Array(segments.prefix(cycleLength))
    } else if segments.count < cycleLength {
        for j in segments.count..<cycleLength {
            segments.append(PieSegment(id: "pad_\(j)", units: 1.0, color: .black))
        }
    }

    return segments
}
