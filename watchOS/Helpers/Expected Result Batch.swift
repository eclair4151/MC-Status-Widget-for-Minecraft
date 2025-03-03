import Foundation
import MCStatsDataLayer

class ExpectedResultBatch: Hashable {
    var expectedResults: [UUID: SavedMinecraftServer] = [:]
    
    static func == (lhs: ExpectedResultBatch, rhs: ExpectedResultBatch) -> Bool {
        lhs.expectedResults == rhs.expectedResults
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(expectedResults)
    }
    
    init(expectedResults: [UUID: SavedMinecraftServer]) {
        self.expectedResults = expectedResults
    }
}
