import Foundation

/// Specifies how many times a behavior or task should repeat.
///
/// - ``count(_:)``: Execute a specific number of times
/// - ``infinite``: Execute indefinitely until stopped
public enum BehaviorIterations {
    /// Execute a specific number of times.
    case count(Int)

    /// Execute indefinitely until stopped.
    case infinite

    /// Returns the iteration count, or `nil` if infinite.
    var count: Int? {
        if case let .count(count) = self {
            return count
        } else {
            return nil
        }
    }
}
