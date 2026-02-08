import Foundation
import SwiftData

@Model
final class SymptomEntry {
    var date: Date
    var symptomsRaw: [String]
    var nervousSystemStateRaw: String?
    var cycleLog: CycleLog?

    init(date: Date, symptoms: [Symptom] = [], nervousSystemState: NervousSystemState? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.symptomsRaw = symptoms.map(\.rawValue)
        self.nervousSystemStateRaw = nervousSystemState?.rawValue
    }

    var symptoms: [Symptom] {
        get { symptomsRaw.compactMap { Symptom(rawValue: $0) } }
        set { symptomsRaw = newValue.map(\.rawValue) }
    }

    var nervousSystemState: NervousSystemState? {
        get { nervousSystemStateRaw.flatMap { NervousSystemState(rawValue: $0) } }
        set { nervousSystemStateRaw = newValue?.rawValue }
    }

    func hasSymptom(_ symptom: Symptom) -> Bool {
        symptomsRaw.contains(symptom.rawValue)
    }

    func toggleSymptom(_ symptom: Symptom) {
        if hasSymptom(symptom) {
            symptomsRaw.removeAll { $0 == symptom.rawValue }
        } else {
            symptomsRaw.append(symptom.rawValue)
        }
    }
}
