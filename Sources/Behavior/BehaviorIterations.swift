import Foundation

public enum BehaviorIterations {
    case count(Int)
    case infinite

    var count: Int? {
        if case let .count(count) = self {
            return count
        } else {
            return nil
        }
    }
}
