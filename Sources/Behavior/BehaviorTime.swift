import Foundation

public struct BehaviorTime {

    /// The time that has elapsed since the last tick.
    public let elapsed: TimeInterval

    /// The accumulated time of the entire behavior, i.e. the sum of the elapsed times.
    public let accumulated: TimeInterval

    /// The current actual time.
    public let actual: TimeInterval
}
