import Foundation

// MARK: - Data Types

enum SymptomCluster: String, CaseIterable, Identifiable {
    case hormonalImbalance
    case inflammationOxidativeStress
    case histamineIntolerance
    case nervousSystemDysregulation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hormonalImbalance: "Hormonal Imbalance"
        case .inflammationOxidativeStress: "Inflammation & Oxidative Stress"
        case .histamineIntolerance: "Histamine Intolerance"
        case .nervousSystemDysregulation: "Nervous System Dysregulation"
        }
    }

    var icon: String {
        switch self {
        case .hormonalImbalance: "waveform.path.ecg"
        case .inflammationOxidativeStress: "flame.fill"
        case .histamineIntolerance: "allergens"
        case .nervousSystemDysregulation: "brain.head.profile"
        }
    }

    var description: String {
        switch self {
        case .hormonalImbalance:
            "Symptoms linked to estrogen-progesterone fluctuations throughout your cycle."
        case .inflammationOxidativeStress:
            "Symptoms driven by inflammatory pathways and cellular oxidative stress."
        case .histamineIntolerance:
            "Symptoms associated with excess histamine or reduced DAO enzyme activity."
        case .nervousSystemDysregulation:
            "Symptoms reflecting nervous system sensitivity and stress response patterns."
        }
    }

    var symptoms: Set<Symptom> {
        switch self {
        case .hormonalImbalance:
            [.headache, .hairLoss, .acne, .moodSwings, .breastTenderness, .fatigue]
        case .inflammationOxidativeStress:
            [.bloating, .jointPain, .cramps, .backPain, .digestiveIssues]
        case .histamineIntolerance:
            [.headache, .bloating, .nausea, .insomnia, .anxiety, .acne, .cramps]
        case .nervousSystemDysregulation:
            [.anxiety, .insomnia, .irritability, .restless, .brainFog, .fatigue]
        }
    }

    var primaryProtocol: NutritionProtocol {
        switch self {
        case .hormonalImbalance: .seedCycling
        case .inflammationOxidativeStress: .cellDetox
        case .histamineIntolerance: .daoSt
        case .nervousSystemDysregulation: .seedCycling // fallback; distributed in scoring
        }
    }
}

enum ClusterStrength: Comparable {
    case insufficient
    case mild
    case moderate
    case strong

    var displayName: String {
        switch self {
        case .insufficient: "Insufficient"
        case .mild: "Mild"
        case .moderate: "Moderate"
        case .strong: "Strong"
        }
    }

    var multiplier: Double {
        switch self {
        case .insufficient: 0.0
        case .mild: 0.5
        case .moderate: 1.0
        case .strong: 1.5
        }
    }
}

enum RecommendationConfidence {
    case high
    case moderate
    case low

    var displayName: String {
        switch self {
        case .high: "High Confidence"
        case .moderate: "Moderate Confidence"
        case .low: "Low Confidence"
        }
    }

    var icon: String {
        switch self {
        case .high: "checkmark.seal.fill"
        case .moderate: "checkmark.seal"
        case .low: "questionmark.circle"
        }
    }
}

struct SymptomFrequencyInfo: Identifiable {
    let symptom: Symptom
    let count: Int
    let percentageOfEntries: Double

    var id: String { symptom.rawValue }
}

struct ClusterResult: Identifiable {
    let cluster: SymptomCluster
    let matchingSymptoms: [SymptomFrequencyInfo]
    let totalOccurrences: Int
    let peakCycleDay: Int?
    let peakPhase: CyclePhase?
    let strength: ClusterStrength
    let explanation: String

    var id: String { cluster.rawValue }
}

struct DataCoverage {
    let monthsTracked: Int
    let totalEntries: Int
    let earliestDate: Date?
    let latestDate: Date?
    let totalDaysSpan: Int

    var summaryText: String {
        if monthsTracked >= 1 {
            "Based on \(monthsTracked) month\(monthsTracked == 1 ? "" : "s") of tracking with \(totalEntries) symptom entries"
        } else {
            "Based on \(totalDaysSpan) days of tracking with \(totalEntries) symptom entries"
        }
    }
}

struct ProtocolRecommendation {
    let recommended: NutritionProtocol
    let confidence: RecommendationConfidence
    let reasoning: String
    let alternativeProtocol: NutritionProtocol?
    let alternativeReason: String?
}

struct HealthCorrelation: Identifiable {
    let id = UUID()
    let metricType: HealthMetricType
    let phaseAverages: [CyclePhase: Double]
    let overallAverage: Double
    let insight: String
}

struct PatternAnalysis {
    let dataCoverage: DataCoverage
    let clusterResults: [ClusterResult]
    let protocolRecommendation: ProtocolRecommendation?
    let hasEnoughData: Bool
    var healthCorrelations: [HealthCorrelation] = []
}

// MARK: - Engine

enum PatternAnalysisEngine {
    static let minimumEntries = 10
    static let minimumDaysSpan = 14

    static func analyze(
        entries: [SymptomEntry],
        cycleLength: Int,
        periodLength: Int,
        lastPeriodStartDate: Date,
        healthLogs: [HealthMetricLog] = []
    ) -> PatternAnalysis {
        let coverage = computeDataCoverage(entries: entries)

        guard coverage.totalEntries >= minimumEntries,
              coverage.totalDaysSpan >= minimumDaysSpan else {
            return PatternAnalysis(
                dataCoverage: coverage,
                clusterResults: [],
                protocolRecommendation: nil,
                hasEnoughData: false
            )
        }

        let symptomCounts = computeSymptomCounts(entries: entries)
        let cycleDaySymptomMap = computeCycleDaySymptomMap(
            entries: entries,
            cycleLength: cycleLength,
            periodLength: periodLength,
            lastPeriodStartDate: lastPeriodStartDate
        )

        var clusterResults: [ClusterResult] = []
        for cluster in SymptomCluster.allCases {
            let result = scoreCluster(
                cluster: cluster,
                symptomCounts: symptomCounts,
                cycleDaySymptomMap: cycleDaySymptomMap,
                totalEntries: coverage.totalEntries,
                cycleLength: cycleLength,
                periodLength: periodLength
            )
            if result.strength > .insufficient {
                clusterResults.append(result)
            }
        }

        clusterResults.sort { $0.strength > $1.strength || ($0.strength == $1.strength && $0.totalOccurrences > $1.totalOccurrences) }

        let recommendation = computeRecommendation(clusterResults: clusterResults)

        let healthCorrelations = analyzeHealthCorrelations(
            healthLogs: healthLogs,
            cycleLength: cycleLength,
            periodLength: periodLength,
            lastPeriodStartDate: lastPeriodStartDate
        )

        return PatternAnalysis(
            dataCoverage: coverage,
            clusterResults: clusterResults,
            protocolRecommendation: recommendation,
            hasEnoughData: true,
            healthCorrelations: healthCorrelations
        )
    }

    // MARK: - Data Coverage

    private static func computeDataCoverage(entries: [SymptomEntry]) -> DataCoverage {
        let sorted = entries.sorted { $0.date < $1.date }
        let earliest = sorted.first?.date
        let latest = sorted.last?.date

        var daysSpan = 0
        var months = 0
        if let earliest, let latest {
            let calendar = Calendar.current
            daysSpan = max(1, (calendar.dateComponents([.day], from: earliest, to: latest).day ?? 0) + 1)
            months = max(1, calendar.dateComponents([.month], from: earliest, to: latest).month ?? 0)
        }

        return DataCoverage(
            monthsTracked: months,
            totalEntries: entries.count,
            earliestDate: earliest,
            latestDate: latest,
            totalDaysSpan: daysSpan
        )
    }

    // MARK: - Symptom Counts

    private static func computeSymptomCounts(entries: [SymptomEntry]) -> [Symptom: Int] {
        var counts: [Symptom: Int] = [:]
        for entry in entries {
            for symptom in entry.symptoms {
                counts[symptom, default: 0] += 1
            }
        }
        return counts
    }

    // MARK: - Cycle Day Mapping

    private static func computeCycleDaySymptomMap(
        entries: [SymptomEntry],
        cycleLength: Int,
        periodLength: Int,
        lastPeriodStartDate: Date
    ) -> [Symptom: [Int: Int]] {
        var map: [Symptom: [Int: Int]] = [:]

        for entry in entries {
            let position = CycleCalculator.currentPosition(
                lastPeriodStart: lastPeriodStartDate,
                cycleLength: cycleLength,
                periodLength: periodLength,
                on: entry.date
            )

            for symptom in entry.symptoms {
                map[symptom, default: [:]][position.dayInCycle, default: 0] += 1
            }
        }

        return map
    }

    // MARK: - Cluster Scoring

    private static func scoreCluster(
        cluster: SymptomCluster,
        symptomCounts: [Symptom: Int],
        cycleDaySymptomMap: [Symptom: [Int: Int]],
        totalEntries: Int,
        cycleLength: Int,
        periodLength: Int
    ) -> ClusterResult {
        let clusterSymptoms = cluster.symptoms

        // Find matching symptoms that appear in the data
        var matchingSymptoms: [SymptomFrequencyInfo] = []
        var totalOccurrences = 0
        var aggregatedCycleDayCounts: [Int: Int] = [:]

        for symptom in clusterSymptoms {
            guard let count = symptomCounts[symptom], count > 0 else { continue }
            let percentage = Double(count) / Double(totalEntries) * 100.0
            matchingSymptoms.append(SymptomFrequencyInfo(
                symptom: symptom,
                count: count,
                percentageOfEntries: percentage
            ))
            totalOccurrences += count

            // Aggregate cycle day counts for peak detection
            if let dayCounts = cycleDaySymptomMap[symptom] {
                for (day, dayCount) in dayCounts {
                    aggregatedCycleDayCounts[day, default: 0] += dayCount
                }
            }
        }

        matchingSymptoms.sort { $0.count > $1.count }

        // Find peak cycle day
        let peakEntry = aggregatedCycleDayCounts.max { $0.value < $1.value }
        let peakCycleDay = peakEntry?.key

        // Determine peak phase
        var peakPhase: CyclePhase?
        if let peakDay = peakCycleDay {
            let boundaries = CycleCalculator.phaseBoundaries(
                cycleLength: cycleLength,
                periodLength: periodLength
            )
            for boundary in boundaries {
                if peakDay >= boundary.startDay && peakDay <= boundary.endDay {
                    peakPhase = boundary.phase
                    break
                }
            }
        }

        // Determine strength
        let strength = determineStrength(
            matchingSymptoms: matchingSymptoms,
            totalEntries: totalEntries
        )

        // Generate explanation
        let explanation = generateExplanation(
            cluster: cluster,
            matchingSymptoms: matchingSymptoms,
            peakPhase: peakPhase,
            strength: strength
        )

        return ClusterResult(
            cluster: cluster,
            matchingSymptoms: matchingSymptoms,
            totalOccurrences: totalOccurrences,
            peakCycleDay: peakCycleDay,
            peakPhase: peakPhase,
            strength: strength,
            explanation: explanation
        )
    }

    private static func determineStrength(
        matchingSymptoms: [SymptomFrequencyInfo],
        totalEntries: Int
    ) -> ClusterStrength {
        let symptomsAbove30 = matchingSymptoms.filter { $0.percentageOfEntries >= 30.0 }.count
        let symptomsAbove15 = matchingSymptoms.filter { $0.percentageOfEntries >= 15.0 }.count
        let totalMatching = matchingSymptoms.count

        if symptomsAbove30 >= 3 {
            return .strong
        } else if symptomsAbove15 >= 2 {
            return .moderate
        } else if totalMatching >= 2 {
            return .mild
        }
        return .insufficient
    }

    private static func generateExplanation(
        cluster: SymptomCluster,
        matchingSymptoms: [SymptomFrequencyInfo],
        peakPhase: CyclePhase?,
        strength: ClusterStrength
    ) -> String {
        let topSymptoms = matchingSymptoms.prefix(3).map { $0.symptom.displayName.lowercased() }
        let symptomList = topSymptoms.joined(separator: ", ")

        var text = "Your most frequent \(cluster.displayName.lowercased()) symptoms are \(symptomList)."

        if let phase = peakPhase {
            text += " These tend to peak during your \(phase.displayName.lowercased()) phase."
        }

        switch strength {
        case .strong:
            text += " This is a strong pattern in your data."
        case .moderate:
            text += " This pattern appears moderately in your tracking."
        case .mild:
            text += " This is a mild pattern — continued tracking will clarify it."
        case .insufficient:
            break
        }

        return text
    }

    // MARK: - Protocol Recommendation

    private static func computeRecommendation(clusterResults: [ClusterResult]) -> ProtocolRecommendation? {
        guard !clusterResults.isEmpty else { return nil }

        var protocolScores: [NutritionProtocol: Double] = [:]

        // Find strongest non-nervous-system cluster for weight distribution
        let nonNervousResults = clusterResults.filter { $0.cluster != .nervousSystemDysregulation }
        let strongestCoCluster = nonNervousResults.max { $0.totalOccurrences < $1.totalOccurrences }

        for result in clusterResults {
            if result.cluster == .nervousSystemDysregulation {
                // Distribute 30% weight to strongest co-occurring cluster's protocol
                if let coCluster = strongestCoCluster {
                    let score = Double(result.totalOccurrences) * result.strength.multiplier * 0.3
                    protocolScores[coCluster.cluster.primaryProtocol, default: 0] += score
                }
                // Remaining 70% distributed evenly across all protocols
                let evenScore = Double(result.totalOccurrences) * result.strength.multiplier * 0.7 / 3.0
                for proto in NutritionProtocol.allCases {
                    protocolScores[proto, default: 0] += evenScore
                }
            } else {
                let score = Double(result.totalOccurrences) * result.strength.multiplier
                protocolScores[result.cluster.primaryProtocol, default: 0] += score
            }
        }

        let sorted = protocolScores.sorted { $0.value > $1.value }
        guard let top = sorted.first else { return nil }

        let alternative = sorted.dropFirst().first

        // Determine confidence
        let confidence: RecommendationConfidence
        if let second = alternative {
            let ratio = top.value / max(second.value, 1.0)
            if ratio >= 2.0 {
                confidence = .high
            } else if ratio >= 1.3 {
                confidence = .moderate
            } else {
                confidence = .low
            }
        } else {
            confidence = .high
        }

        let reasoning = generateReasoning(
            protocol: top.key,
            clusterResults: clusterResults,
            confidence: confidence
        )

        var alternativeReason: String?
        if let alt = alternative {
            alternativeReason = "\(alt.key.displayName) may also help with some of your symptoms."
        }

        return ProtocolRecommendation(
            recommended: top.key,
            confidence: confidence,
            reasoning: reasoning,
            alternativeProtocol: alternative?.key,
            alternativeReason: alternativeReason
        )
    }

    private static func generateReasoning(
        protocol proto: NutritionProtocol,
        clusterResults: [ClusterResult],
        confidence: RecommendationConfidence
    ) -> String {
        let relevantClusters = clusterResults.filter {
            $0.cluster.primaryProtocol == proto && $0.cluster != .nervousSystemDysregulation
        }

        let clusterNames = relevantClusters.map { $0.cluster.displayName.lowercased() }

        switch proto {
        case .seedCycling:
            if clusterNames.isEmpty {
                return "Seed Cycling can help support overall hormonal balance based on your symptom patterns."
            }
            return "Your \(clusterNames.joined(separator: " and ")) symptoms suggest Seed Cycling could help regulate your hormonal rhythm."
        case .cellDetox:
            if clusterNames.isEmpty {
                return "Cell Detox can support your body's natural detoxification based on your symptom patterns."
            }
            return "Your \(clusterNames.joined(separator: " and ")) symptoms suggest Cell Detox could help reduce inflammation and support cellular health."
        case .daoSt:
            if clusterNames.isEmpty {
                return "DAO Support can help manage histamine-related symptoms in your pattern."
            }
            return "Your \(clusterNames.joined(separator: " and ")) symptoms suggest DAO Support could help improve histamine tolerance."
        }
    }

    // MARK: - Health Correlations

    static func analyzeHealthCorrelations(
        healthLogs: [HealthMetricLog],
        cycleLength: Int,
        periodLength: Int,
        lastPeriodStartDate: Date
    ) -> [HealthCorrelation] {
        guard healthLogs.count >= 7 else { return [] }

        var correlations: [HealthCorrelation] = []

        // Group logs by phase
        var phaseGroups: [CyclePhase: [HealthMetricLog]] = [:]
        for log in healthLogs {
            let position = CycleCalculator.currentPosition(
                lastPeriodStart: lastPeriodStartDate,
                cycleLength: cycleLength,
                periodLength: periodLength,
                on: log.date
            )
            phaseGroups[position.phase, default: []].append(log)
        }

        // Analyze each metric type
        correlations.append(contentsOf: correlateMetric(
            type: .sleep,
            logs: healthLogs,
            phaseGroups: phaseGroups,
            extract: { $0.sleepDurationHours }
        ))

        correlations.append(contentsOf: correlateMetric(
            type: .hrv,
            logs: healthLogs,
            phaseGroups: phaseGroups,
            extract: { $0.hrvMs }
        ))

        correlations.append(contentsOf: correlateMetric(
            type: .restingHeartRate,
            logs: healthLogs,
            phaseGroups: phaseGroups,
            extract: { $0.restingHeartRateBpm }
        ))

        correlations.append(contentsOf: correlateMetric(
            type: .basalBodyTemperature,
            logs: healthLogs,
            phaseGroups: phaseGroups,
            extract: { $0.basalBodyTemperatureCelsius }
        ))

        correlations.append(contentsOf: correlateMetric(
            type: .steps,
            logs: healthLogs,
            phaseGroups: phaseGroups,
            extract: { $0.steps.map { Double($0) } }
        ))

        return correlations
    }

    private static func correlateMetric(
        type: HealthMetricType,
        logs: [HealthMetricLog],
        phaseGroups: [CyclePhase: [HealthMetricLog]],
        extract: (HealthMetricLog) -> Double?
    ) -> [HealthCorrelation] {
        let allValues = logs.compactMap { extract($0) }
        guard allValues.count >= 5 else { return [] }

        let overallAvg = allValues.reduce(0, +) / Double(allValues.count)

        var phaseAverages: [CyclePhase: Double] = [:]
        for (phase, phaseLogs) in phaseGroups {
            let vals = phaseLogs.compactMap { extract($0) }
            guard !vals.isEmpty else { continue }
            phaseAverages[phase] = vals.reduce(0, +) / Double(vals.count)
        }

        guard phaseAverages.count >= 2 else { return [] }

        let insight = generateHealthInsight(type: type, phaseAverages: phaseAverages, overall: overallAvg)

        return [HealthCorrelation(
            metricType: type,
            phaseAverages: phaseAverages,
            overallAverage: overallAvg,
            insight: insight
        )]
    }

    private static func generateHealthInsight(
        type: HealthMetricType,
        phaseAverages: [CyclePhase: Double],
        overall: Double
    ) -> String {
        let sorted = phaseAverages.sorted { $0.value > $1.value }
        guard let highest = sorted.first, let lowest = sorted.last else {
            return "Tracking more data will reveal patterns."
        }

        switch type {
        case .sleep:
            return "You sleep most during your \(highest.key.displayName.lowercased()) phase (\(String(format: "%.1f", highest.value)) hrs) and least during \(lowest.key.displayName.lowercased()) (\(String(format: "%.1f", lowest.value)) hrs)."

        case .hrv:
            return "Your HRV peaks in the \(highest.key.displayName.lowercased()) phase (\(String(format: "%.0f", highest.value)) ms). Lower HRV during \(lowest.key.displayName.lowercased()) is a normal hormonal pattern."

        case .restingHeartRate:
            return "Resting heart rate is lowest during \(lowest.key.displayName.lowercased()) (\(String(format: "%.0f", lowest.value)) bpm) and rises in \(highest.key.displayName.lowercased()) \u{2014} a common progesterone effect."

        case .basalBodyTemperature:
            return "Temperature rises after ovulation due to progesterone. Your \(highest.key.displayName.lowercased()) phase averages \(String(format: "%.1f", highest.value))\u{00B0}C."

        case .steps:
            return "You\u{2019}re most active during \(highest.key.displayName.lowercased()) (\(String(format: "%.0f", highest.value)) steps) and gentler during \(lowest.key.displayName.lowercased())."
        }
    }
}
