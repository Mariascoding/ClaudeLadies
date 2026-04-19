import Foundation
import SwiftData

@Model
final class FlowerStateEntry {
    var timestamp: Date
    var bloomStateRaw: String

    init(timestamp: Date = .now, bloomState: BloomState) {
        self.timestamp = timestamp
        self.bloomStateRaw = bloomState.rawValue
    }

    var bloomState: BloomState {
        BloomState(rawValue: bloomStateRaw) ?? .bud
    }
}
