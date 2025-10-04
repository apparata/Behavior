import Foundation

/// Timing information passed to behavior tasks during execution.
///
/// `BehaviorTime` provides three time values that tasks can use for time-based logic:
/// - ``elapsed``: Delta time since the last tick
/// - ``accumulated``: Total time the behavior has been running
/// - ``actual``: Current wall clock time
///
/// ## Usage
///
/// ```swift
/// let time = BehaviorTime(
///     elapsed: deltaTime,
///     accumulated: totalTime,
///     actual: Date().timeIntervalSince1970
/// )
/// behavior.tick(time: time)
/// ```
public struct BehaviorTime {

    /// The time interval that has elapsed since the last tick.
    ///
    /// This is typically the frame delta time and is used for time-based calculations
    /// like cooldowns, timeouts, and animations.
    public let elapsed: TimeInterval

    /// The accumulated time of the entire behavior.
    ///
    /// This is the sum of all elapsed times since the behavior started,
    /// representing the total runtime of the behavior.
    public let accumulated: TimeInterval

    /// The current actual time (wall clock time).
    ///
    /// This is typically a Unix timestamp or similar absolute time value,
    /// useful for logging and debugging.
    public let actual: TimeInterval
}
