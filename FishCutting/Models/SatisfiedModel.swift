import Foundation
import SwiftData

@Model
class SatisfiedTracker {
    var totalSatisfied: Int
    
    init(totalSatisfied: Int) {
        self.totalSatisfied = totalSatisfied
    }
}
