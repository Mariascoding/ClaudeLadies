import SwiftUI

struct PeriodCalendarView: View {
    let cycleLogs: [CycleLog]
    let cycleLength: Int
    let periodLength: Int
    let expectedNextPeriodStart: Date?
    let delayDays: Int
    let lastPeriodStartDate: Date?
    let phaseBoundaries: [(phase: CyclePhase, startDay: Int, endDay: Int)]
    let onAddPeriod: (Date) -> Void
    let onExtendPeriod: (Date) -> Void
    let onRemovePeriod: (Date) -> Void
    let onAddOvulation: (Date) -> Void
    let onRemoveOvulation: (Date) -> Void
    let manualOvulationDates: Set<Date>
    let canExtendPeriod: (Date) -> Bool
    let canRemovePeriod: (Date) -> Bool
    let isManualOvulation: (Date) -> Bool

    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = nil

    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    // MARK: - Ovulation calculation

    private var ovulationDayInCycle: Int {
        max(1, cycleLength - 14)
    }

    private var ovulationWindowLength: Int {
        guard let ovBounds = phaseBoundaries.first(where: { $0.phase == .ovulation }) else { return 2 }
        return ovBounds.endDay - ovBounds.startDay + 1
    }

    // MARK: - Colors

    private let periodColor = Color.red
    private let ovulationColor = Color.green

    // MARK: - Selection mode

    private enum SelectionMode {
        case add, extend, remove
    }

    private var selectionMode: SelectionMode {
        guard let selected = selectedDate else { return .add }
        if canRemovePeriod(selected) { return .remove }
        if canExtendPeriod(selected) { return .extend }
        return .add
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.appRose)
                Text("Period Calendar")
                    .warmHeadline()
                Spacer()
            }

            // Delay banner
            if delayDays > 0 {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Period is \(delayDays) day\(delayDays == 1 ? "" : "s") late")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                }
                .foregroundStyle(Color.appRose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(Color.appRose.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
            }

            // Month navigation
            HStack {
                Button {
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.appSoftBrown)
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.appSoftBrown)

                Spacer()

                Button {
                    shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.appSoftBrown)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                        .frame(height: 24)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                            .onTapGesture {
                                let day = calendar.startOfDay(for: date)
                                guard day <= calendar.startOfDay(for: Date()) else { return }
                                withAnimation(AppTheme.gentleAnimation) {
                                    if selectedDate == day {
                                        selectedDate = nil
                                    } else {
                                        selectedDate = day
                                    }
                                }
                            }
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }

            // Legend
            legendView

            // Selection info + action buttons
            if let selected = selectedDate {
                selectionBar(for: selected)

                // Ovulation button (shown when day is not a period day)
                if selectionMode != .remove {
                    ovulationBar(for: selected)
                }
            }
        }
        .warmCard()
    }

    // MARK: - Selection Bar

    @ViewBuilder
    private func selectionBar(for date: Date) -> some View {
        let fmt = dateFormatter
        let mode = selectionMode

        VStack(spacing: AppTheme.Spacing.sm) {
            switch mode {
            case .remove:
                Text("Remove period containing \(fmt.string(from: date))")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            case .extend:
                Text("Extend period through \(fmt.string(from: date))")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            case .add:
                let endDate = calendar.date(byAdding: .day, value: periodLength - 1, to: date)!
                Text("\(fmt.string(from: date)) – \(fmt.string(from: endDate)) (\(periodLength) days)")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                GentleOutlineButton("Cancel", color: .appSoftBrown) {
                    withAnimation(AppTheme.gentleAnimation) {
                        selectedDate = nil
                    }
                }

                switch mode {
                case .remove:
                    GentleButton("Remove Period", color: .red) {
                        onRemovePeriod(date)
                        withAnimation(AppTheme.gentleAnimation) {
                            selectedDate = nil
                        }
                    }
                case .extend:
                    GentleButton("Extend Period", color: .appRose) {
                        onExtendPeriod(date)
                        withAnimation(AppTheme.gentleAnimation) {
                            selectedDate = nil
                        }
                    }
                case .add:
                    GentleButton("Add Period", color: .appRose) {
                        onAddPeriod(date)
                        withAnimation(AppTheme.gentleAnimation) {
                            selectedDate = nil
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.sm)
        .background(mode == .remove ? Color.red.opacity(0.06) : Color.appRose.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }

    @ViewBuilder
    private func ovulationBar(for date: Date) -> some View {
        let isManual = isManualOvulation(date)

        Button {
            if isManual {
                onRemoveOvulation(date)
            } else {
                onAddOvulation(date)
            }
            withAnimation(AppTheme.gentleAnimation) {
                selectedDate = nil
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: isManual ? "minus.circle.fill" : "plus.circle.fill")
                Text(isManual ? "Remove Ovulation" : "Mark Ovulation")
                    .font(.system(.body, design: .rounded, weight: .medium))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isManual ? Color.red : Color.green)
            .clipShape(Capsule())
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }

    // MARK: - Day Cell

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let status = dayStatus(for: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = selectedDate == calendar.startOfDay(for: date)
        let dayNumber = calendar.component(.day, from: date)

        ZStack {
            // Status background
            switch status {
            case .recorded:
                Circle()
                    .fill(periodColor.opacity(0.55))
            case .active:
                Circle()
                    .fill(periodColor.opacity(0.40))
            case .predicted:
                Circle()
                    .fill(periodColor.opacity(0.12))
                    .overlay(
                        Circle()
                            .strokeBorder(periodColor.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                    )
            case .ovulation:
                Circle()
                    .fill(ovulationColor.opacity(0.35))
                    .overlay(
                        Circle()
                            .strokeBorder(ovulationColor.opacity(0.8), lineWidth: 1.5)
                    )
            case .none:
                Circle()
                    .fill(Color.appSoftBrown.opacity(0.04))
            }

            // Selected highlight
            if isSelected {
                Circle()
                    .strokeBorder(Color.appRose, lineWidth: 2.5)
            }

            // Today outline
            if isToday && !isSelected {
                Circle()
                    .strokeBorder(Color.appSoftBrown, lineWidth: 2)
            }

            Text("\(dayNumber)")
                .font(.system(.caption, design: .rounded, weight: (isToday || isSelected) ? .bold : .regular))
                .foregroundStyle(dayTextColor(status: status, isToday: isToday, isSelected: isSelected))
        }
        .frame(height: 36)
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            legendDot(color: periodColor.opacity(0.55), label: "Period")
            legendDot(color: periodColor.opacity(0.12), label: "Predicted", dashed: true, dashColor: periodColor)
            legendDot(color: ovulationColor.opacity(0.35), label: "Ovulation", bordered: true, borderColor: ovulationColor)
            legendDot(color: .clear, label: "Today", bordered: true, borderColor: .appSoftBrown)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func legendDot(color: Color, label: String, dashed: Bool = false, dashColor: Color = .clear, bordered: Bool = false, borderColor: Color = .clear) -> some View {
        HStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color)
                if dashed {
                    Circle()
                        .strokeBorder(dashColor.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                }
                if bordered {
                    Circle()
                        .strokeBorder(borderColor.opacity(0.6), lineWidth: 1.5)
                }
            }
            .frame(width: 10, height: 10)

            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))
        }
    }

    // MARK: - Day Status

    private enum DayStatus {
        case recorded, active, predicted, ovulation, none
    }

    private func dayStatus(for date: Date) -> DayStatus {
        let day = calendar.startOfDay(for: date)

        for log in cycleLogs {
            let logStart = calendar.startOfDay(for: log.startDate)

            if let endDate = log.endDate {
                let logEnd = calendar.startOfDay(for: endDate)
                if day >= logStart && day <= logEnd {
                    return .recorded
                }
            } else {
                let today = calendar.startOfDay(for: Date())
                if day >= logStart && day <= today {
                    return .active
                }
            }
        }

        if let expected = expectedNextPeriodStart {
            let expectedStart = calendar.startOfDay(for: expected)
            if let expectedEnd = calendar.date(byAdding: .day, value: periodLength - 1, to: expectedStart) {
                if day >= expectedStart && day <= expectedEnd {
                    return .predicted
                }
            }
        }

        if isOvulationDay(day) {
            return .ovulation
        }

        return .none
    }

    private func isOvulationDay(_ day: Date) -> Bool {
        // Check manual ovulation dates first
        if manualOvulationDates.contains(day) {
            return true
        }

        let ovOffset = ovulationDayInCycle - 1

        var cycleStarts: [Date] = []

        for log in cycleLogs {
            cycleStarts.append(calendar.startOfDay(for: log.startDate))
        }

        if let lastStart = lastPeriodStartDate {
            let start = calendar.startOfDay(for: lastStart)
            if !cycleStarts.contains(start) {
                cycleStarts.append(start)
            }
        }

        if let expected = expectedNextPeriodStart {
            let start = calendar.startOfDay(for: expected)
            if !cycleStarts.contains(start) {
                cycleStarts.append(start)
            }
        }

        for cycleStart in cycleStarts {
            if let ovStart = calendar.date(byAdding: .day, value: ovOffset, to: cycleStart),
               let ovEnd = calendar.date(byAdding: .day, value: ovOffset + ovulationWindowLength - 1, to: cycleStart) {
                if day >= ovStart && day <= ovEnd {
                    return true
                }
            }
        }

        return false
    }

    private func dayTextColor(status: DayStatus, isToday: Bool, isSelected: Bool = false) -> Color {
        if isSelected { return Color.appRose }
        switch status {
        case .recorded, .active:
            return .white
        case .predicted:
            return periodColor
        case .ovulation:
            return Color(red: 0.0, green: 0.45, blue: 0.0)
        case .none:
            return isToday ? Color.appSoftBrown : Color.appSoftBrown.opacity(0.7)
        }
    }

    // MARK: - Calendar Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(AppTheme.gentleAnimation) {
                displayedMonth = newMonth
            }
        }
    }

    private var daysInMonth: [Date?] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = weekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            var dayComponents = components
            dayComponents.day = day
            days.append(calendar.date(from: dayComponents))
        }

        return days
    }
}
