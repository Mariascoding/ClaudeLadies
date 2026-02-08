import Foundation

enum CycleCalculator {
    struct CyclePosition {
        let dayInCycle: Int
        let phase: CyclePhase
        let dayInPhase: Int
        let phaseProgress: Double
    }

    /// Computes the current cycle position given the last period start date and cycle parameters.
    static func currentPosition(
        lastPeriodStart: Date,
        cycleLength: Int,
        periodLength: Int,
        on date: Date = Date()
    ) -> CyclePosition {
        let calendar = Calendar.current
        let startOfLastPeriod = calendar.startOfDay(for: lastPeriodStart)
        let today = calendar.startOfDay(for: date)

        let totalDays = calendar.dateComponents([.day], from: startOfLastPeriod, to: today).day ?? 0
        let dayInCycle = (totalDays % cycleLength) + 1

        let phases = phaseDays(cycleLength: cycleLength, periodLength: periodLength)
        let (phase, dayInPhase) = phaseFor(dayInCycle: dayInCycle, phases: phases)

        let phaseDuration = phases[phase] ?? 1
        let phaseProgress = Double(dayInPhase) / Double(phaseDuration)

        return CyclePosition(
            dayInCycle: dayInCycle,
            phase: phase,
            dayInPhase: dayInPhase,
            phaseProgress: phaseProgress
        )
    }

    /// Returns the proportional day ranges for each phase.
    static func phaseDays(cycleLength: Int, periodLength: Int) -> [CyclePhase: Int] {
        let menstrualDays = periodLength
        let ovulationDays = max(2, Int(round(Double(cycleLength) * 0.11)))
        let remainingDays = cycleLength - menstrualDays - ovulationDays
        let follicularDays = Int(round(Double(remainingDays) * 0.45))
        let lutealDays = remainingDays - follicularDays

        return [
            .menstrual: menstrualDays,
            .follicular: follicularDays,
            .ovulation: ovulationDays,
            .luteal: lutealDays
        ]
    }

    /// Returns the phase boundaries as cumulative day thresholds.
    static func phaseBoundaries(cycleLength: Int, periodLength: Int) -> [(phase: CyclePhase, startDay: Int, endDay: Int)] {
        let days = phaseDays(cycleLength: cycleLength, periodLength: periodLength)
        let order: [CyclePhase] = [.menstrual, .follicular, .ovulation, .luteal]

        var boundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)] = []
        var currentDay = 1

        for phase in order {
            let duration = days[phase] ?? 0
            boundaries.append((phase: phase, startDay: currentDay, endDay: currentDay + duration - 1))
            currentDay += duration
        }

        return boundaries
    }

    private static func phaseFor(dayInCycle: Int, phases: [CyclePhase: Int]) -> (CyclePhase, Int) {
        let order: [CyclePhase] = [.menstrual, .follicular, .ovulation, .luteal]
        var cumulative = 0

        for phase in order {
            let duration = phases[phase] ?? 0
            if dayInCycle <= cumulative + duration {
                return (phase, dayInCycle - cumulative)
            }
            cumulative += duration
        }

        return (.luteal, 1)
    }
}
