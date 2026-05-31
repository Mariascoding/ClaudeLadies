import SwiftUI
import SwiftData

// MARK: - Dashboard
//
// Everything-on-one-page lab: a single non-scrolling screen with a
// header strip and a 2×2 grid of tiles. Each tile compresses one
// of the main "Insights" data sources into a glanceable form:
//
//   · Top strip: current phase, day in cycle, date, inner season
//   · Tile A: moon-woman alignment dial
//   · Tile B: mini month calendar with period + phase tints
//   · Tile C: pattern analysis (cluster bars + phase tags)
//   · Tile D: recent symptoms (chips for last ~30 days)
//
// Designed to fit a phone screen with no scrolling — tiles auto-size
// to the available height via GeometryReader.

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var profiles: [UserProfile]
    @Query(sort: \SymptomEntry.date, order: .reverse) private var symptomEntries: [SymptomEntry]
    @Query(sort: \CycleLog.startDate, order: .reverse) private var cycleLogs: [CycleLog]

    @StateObject private var moonState = MoonState()

    private var profile: UserProfile? { profiles.first }

    private var cyclePosition: CycleCalculator.CyclePosition? {
        guard let p = profile, let last = p.lastPeriodStartDate else { return nil }
        return CycleCalculator.currentPosition(
            lastPeriodStart: last,
            cycleLength: p.cycleLength,
            periodLength: p.periodLength
        )
    }

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            // Row 1 — inner season label + wide moon alignment dial
            GridRow {
                innerSeasonTile
                moonAlignmentTile
                    .gridCellColumns(2)
            }

            // Row 2 — wide mini calendar + compact day counter
            GridRow {
                miniCalendarTile
                    .gridCellColumns(2)
                dayCounterTile
            }

            // Row 3 — compact pattern + wide symptoms
            GridRow {
                patternTile
                symptomsTile
                    .gridCellColumns(2)
            }
        }
        .padding(12)
        .background(Color.appCream.ignoresSafeArea())
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await moonState.load() } }
    }

    // MARK: - Inner Season Tile (small, hero label)

    @ViewBuilder
    private var innerSeasonTile: some View {
        tileShell {
            if let position = cyclePosition {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        PhaseIcon(phase: position.phase, size: 18)
                        Text("PHASE")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2.5)
                            .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    }
                    Spacer(minLength: 0)
                    Text(position.phase.innerSeason)
                        .font(.system(size: 17, weight: .light, design: .serif))
                        .foregroundStyle(position.phase.accentColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text(position.phase.displayName)
                        .font(.system(size: 10, weight: .light))
                        .tracking(1)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.65))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                Text("—")
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.4))
            }
        }
    }

    // MARK: - Day Counter Tile (small, big number)

    @ViewBuilder
    private var dayCounterTile: some View {
        tileShell {
            VStack(alignment: .leading, spacing: 4) {
                Text("DAY")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                Spacer(minLength: 0)
                if let position = cyclePosition {
                    Text("\(position.dayInCycle)")
                        .font(.system(size: 38, weight: .light, design: .serif))
                        .foregroundStyle(Color.appSoftBrown)
                    Text("of \(profile?.cycleLength ?? 28)")
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                } else {
                    Text("—")
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                }
                Text(Self.dateFormatter.string(from: .now).uppercased())
                    .font(.system(size: 9, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f
    }()

    // MARK: - Tile A: Moon Alignment

    @ViewBuilder
    private var moonAlignmentTile: some View {
        tile(title: "MOON ALIGNMENT") {
            VStack(spacing: 4) {
                AlignmentDial(
                    percent: alignmentPercent,
                    accent: Color(red: 0.92, green: 0.78, blue: 0.55)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text(profileLabel)
                    .font(.system(.footnote, design: .serif, weight: .light))
                    .italic()
                    .foregroundStyle(Color.appSoftBrown.opacity(0.7))
                    .lineLimit(1)
            }
        }
    }

    /// Distance from the user's last period to the nearest moon archetype
    /// anchor (white/pink/red/purple) → percentage 0–100.
    private var alignmentPercent: Int {
        guard let position = cyclePosition else { return 0 }
        let cycleProgress = Double(position.dayInCycle - 1) / Double(profile?.cycleLength ?? 28)
        var result = moonState.moonPhase - cycleProgress
        result = result.truncatingRemainder(dividingBy: 1.0)
        if result < 0 { result += 1.0 }
        let anchors = [0.0, 0.25, 0.5, 0.75]
        let nearest = anchors.map { abs(result - $0) }.min() ?? 0
        let dist = min(nearest, 1.0 - nearest)
        return Int(min(100, max(0, (1.0 - dist / 0.125) * 100)))
    }

    private var profileLabel: String {
        guard cyclePosition != nil else { return "—" }
        let cycleProgress = Double((cyclePosition?.dayInCycle ?? 1) - 1) / Double(profile?.cycleLength ?? 28)
        var p = moonState.moonPhase - cycleProgress
        p = p.truncatingRemainder(dividingBy: 1.0)
        if p < 0 { p += 1.0 }
        switch p {
        case 0..<0.125, 0.875...: return "White Moon Woman"
        case 0.125..<0.375:       return "Pink Moon Woman"
        case 0.375..<0.625:       return "Red Moon Woman"
        default:                  return "Purple Moon Woman"
        }
    }

    // MARK: - Tile B: Mini Calendar

    @ViewBuilder
    private var miniCalendarTile: some View {
        tile(title: "THIS MONTH") {
            MiniMonthCalendar(
                cycleLogs: cycleLogs,
                profile: profile
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Tile C: Pattern Analysis

    @ViewBuilder
    private var patternTile: some View {
        tile(title: "PATTERN") {
            patternContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var patternContent: some View {
        if let p = profile, let last = p.lastPeriodStartDate {
            let analysis = PatternAnalysisEngine.analyze(
                entries: symptomEntries,
                cycleLength: p.cycleLength,
                periodLength: p.periodLength,
                lastPeriodStartDate: last
            )
            if !analysis.hasEnoughData {
                let progress = Double(analysis.dataCoverage.totalEntries) / Double(PatternAnalysisEngine.minimumEntries)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Building patterns")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)
                    Text("\(analysis.dataCoverage.totalEntries) / \(PatternAnalysisEngine.minimumEntries) entries")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(Color.appSoftBrown.opacity(0.6))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.appSoftBrown.opacity(0.12))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.appTerracotta.opacity(0.6))
                                .frame(width: geo.size.width * min(progress, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)
                    Spacer()
                }
            } else if analysis.clusterResults.isEmpty {
                Text("No clusters detected yet.")
                    .font(.system(size: 10, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            } else {
                ClusterBars(clusters: Array(analysis.clusterResults.prefix(4)))
            }
        } else {
            Text("—")
                .foregroundStyle(Color.appSoftBrown.opacity(0.4))
        }
    }

    // MARK: - Tile D: Recent Symptoms

    @ViewBuilder
    private var symptomsTile: some View {
        tile(title: "RECENT SYMPTOMS") {
            let recent = recentSymptomCounts
            if recent.isEmpty {
                Text("Nothing logged in the last 30 days.")
                    .font(.system(size: 10, design: .serif).italic())
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                FlowLayout(spacing: 5) {
                    ForEach(recent.prefix(12), id: \.symptom) { item in
                        symptomChip(symptom: item.symptom, count: item.count)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    /// Counts each symptom across the last 30 days of entries.
    private var recentSymptomCounts: [(symptom: Symptom, count: Int)] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        let recent = symptomEntries.filter { $0.date >= cutoff }
        var counts: [Symptom: Int] = [:]
        for entry in recent {
            for s in entry.symptoms { counts[s, default: 0] += 1 }
        }
        return counts
            .map { (symptom: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    @ViewBuilder
    private func symptomChip(symptom: Symptom, count: Int) -> some View {
        HStack(spacing: 4) {
            Text(symptom.emoji).font(.system(size: 10))
            Text(symptom.displayName)
                .font(.system(size: 9, weight: .light, design: .serif))
            Text("·\(count)")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.appSoftBrown.opacity(0.5))
        }
        .foregroundStyle(Color.appSoftBrown.opacity(0.85))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(Color.appWarmWhite.opacity(0.85))
        )
        .overlay(
            Capsule().stroke(Color.appSoftBrown.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Tile Shell

    @ViewBuilder
    private func tile<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        tileShell {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private func tileShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.appWarmWhite.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appSoftBrown.opacity(0.1), lineWidth: 0.5)
            )
    }
}

// MARK: - Alignment Dial

private struct AlignmentDial: View {
    let percent: Int
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appSoftBrown.opacity(0.12), lineWidth: 8)
            Circle()
                .trim(from: 0, to: CGFloat(percent) / 100.0)
                .stroke(
                    AngularGradient(
                        colors: [accent.opacity(0.5), accent, accent.opacity(0.85)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(percent)")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown)
                Text("PERCENT")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
            }
        }
        .padding(8)
    }
}

// MARK: - Mini Month Calendar

private struct MiniMonthCalendar: View {
    let cycleLogs: [CycleLog]
    let profile: UserProfile?

    private let calendar = Calendar.current
    private let today = Date()

    var body: some View {
        VStack(spacing: 3) {
            Text(monthLabel)
                .font(.system(size: 10, weight: .medium))
                .tracking(1.2)
                .foregroundStyle(Color.appSoftBrown.opacity(0.7))

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 7, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(Color.appSoftBrown.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            VStack(spacing: 2) {
                ForEach(0..<weeksInMonth, id: \.self) { week in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { dow in
                            dayCell(weekIndex: week, dayOfWeek: dow)
                        }
                    }
                }
            }
        }
    }

    private var monthLabel: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: today).uppercased()
    }

    private var weekdaySymbols: [String] {
        ["M", "T", "W", "T", "F", "S", "S"]
    }

    private var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: today)?.count ?? 30
    }

    /// Day-of-week of the 1st (Monday-anchored, 0…6).
    private var startOffset: Int {
        let wd = calendar.component(.weekday, from: firstDayOfMonth)
        // Sunday = 1, so subtract 2 to put Monday at 0
        return (wd + 5) % 7
    }

    private var weeksInMonth: Int {
        Int(ceil(Double(daysInMonth + startOffset) / 7.0))
    }

    @ViewBuilder
    private func dayCell(weekIndex: Int, dayOfWeek: Int) -> some View {
        let dayNumber = weekIndex * 7 + dayOfWeek - startOffset + 1
        if dayNumber < 1 || dayNumber > daysInMonth {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 18)
        } else {
            let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDayOfMonth) ?? today
            let isToday = calendar.isDateInToday(date)
            let isPeriod = isInPeriod(date)
            let phaseColor = phaseColor(for: date)

            ZStack {
                Circle()
                    .fill(isPeriod ? Color.appRose.opacity(0.7) : phaseColor.opacity(isToday ? 0.4 : 0.15))
                    .frame(width: 18, height: 18)
                if isToday {
                    Circle()
                        .stroke(Color.appSoftBrown, lineWidth: 1)
                        .frame(width: 18, height: 18)
                }
                Text("\(dayNumber)")
                    .font(.system(size: 8, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(isPeriod ? .white : Color.appSoftBrown.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func isInPeriod(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        for log in cycleLogs {
            let start = calendar.startOfDay(for: log.startDate)
            let end: Date = log.endDate.map { calendar.startOfDay(for: $0) }
                ?? calendar.date(byAdding: .day, value: (profile?.periodLength ?? 5) - 1, to: start)
                ?? start
            if day >= start && day <= end { return true }
        }
        return false
    }

    private func phaseColor(for date: Date) -> Color {
        guard let p = profile, let last = p.lastPeriodStartDate else { return .appSoftBrown }
        let position = CycleCalculator.currentPosition(
            lastPeriodStart: last,
            cycleLength: p.cycleLength,
            periodLength: p.periodLength
        )
        // Offset day relative to today's day-in-cycle
        let dayDelta = calendar.dateComponents([.day], from: today, to: date).day ?? 0
        let targetDay = ((position.dayInCycle - 1 + dayDelta) % p.cycleLength + p.cycleLength) % p.cycleLength + 1
        let boundaries = CycleCalculator.phaseBoundaries(
            cycleLength: p.cycleLength,
            periodLength: p.periodLength
        )
        let phase = boundaries.first { targetDay >= $0.startDay && targetDay <= $0.endDay }?.phase ?? .menstrual
        return phase.accentColor
    }
}

// MARK: - Cluster Bars

private struct ClusterBars: View {
    let clusters: [ClusterResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(clusters, id: \.cluster) { cluster in
                clusterRow(cluster)
            }
        }
    }

    @ViewBuilder
    private func clusterRow(_ result: ClusterResult) -> some View {
        let strengthFraction: CGFloat = {
            switch result.strength {
            case .insufficient: return 0.15
            case .mild:         return 0.40
            case .moderate:     return 0.70
            case .strong:       return 1.0
            }
        }()
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(result.cluster.displayName)
                    .font(.system(size: 9, weight: .light, design: .serif))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.85))
                Spacer()
                Text("\(result.totalOccurrences)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.55))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appSoftBrown.opacity(0.10))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(result.cluster.tint.opacity(0.85))
                        .frame(width: geo.size.width * strengthFraction, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

private extension SymptomCluster {
    var tint: Color {
        switch self {
        case .hormonalImbalance:            .appRose
        case .inflammationOxidativeStress:  .appTerracotta
        case .histamineIntolerance:         .appSage
        case .nervousSystemDysregulation:   Color(red: 0.69, green: 0.61, blue: 0.82)
        }
    }
}
