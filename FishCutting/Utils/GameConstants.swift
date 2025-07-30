import Foundation
import CoreGraphics

struct GameConstants {
    static let fishWidth: CGFloat = 275
    static let fishHeight: CGFloat = 130
    static let gameDuration = 60
    static let knifeUpdateInterval: TimeInterval = 0.02
    static let normalKnifeSpeed: CGFloat = 3
    static let fastKnifeSpeed: CGFloat = 4.5
    static let speedUpThreshold = 10
    static let satisfactionThreshold = 80
    static let maxCustomers = 5
    static let maxFishTypes = 5
    static let minCuts = 2
    static let maxCuts = 4
}

enum CustomerState {
    case asking
    case satisfied
    case unsatisfied
    
    var imageSuffix: String {
        switch self {
        case .asking:
            return ""
        case .satisfied:
            return "_satisfied"
        case .unsatisfied:
            return "_unsatisfied"
        }
    }
}
