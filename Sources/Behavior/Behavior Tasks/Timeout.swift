import Foundation

/// A decorator task that fails its child if it runs longer than a time limit.
///
/// The `Timeout` task enforces a maximum execution time on its child task.
/// If the child doesn't complete within the specified duration, it fails.
///
/// ## Behavior
///
/// - Executes the child task while tracking elapsed time
/// - Succeeds if child succeeds within the time limit
/// - Fails if child fails OR if timeout is exceeded
/// - Prevents tasks from running indefinitely
///
/// ## Returns
///
/// - `.running` if the child is running and time remains
/// - `.succeeded` if the child has succeeded within the time limit
/// - `.failed` if the child has failed or the timeout has been exceeded
///
/// ## Example
///
/// ```swift
/// Timeout(5.0, FindPath())  // Fail if pathfinding takes > 5 seconds
/// ```
public final class Timeout<Context>: BuiltInBehaviorTask<Context> {

    /// The maximum duration the child is allowed to run (in seconds).
    public let duration: TimeInterval

    /// The child task to monitor for timeout.
    public let child: BehaviorTask<Context>

    private var accumulatedTime: TimeInterval = 0

    /// Creates a timeout decorator.
    ///
    /// - Parameters:
    ///   - duration: The maximum duration the child can run in seconds (minimum: 0).
    ///   - child: The task to monitor for timeout.
    public init(_ duration: TimeInterval, _ child: BehaviorTask<Context>) {
        self.duration = max(0, duration)
        self.child = child
        super.init()
        self.child.parent = self
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {

        if !isFirstRun {
            accumulatedTime += time.elapsed
        }

        // Check if timeout exceeded
        if accumulatedTime >= duration {
            return .failed
        }

        let result = child.tick(for: context, time: time, behavior: behavior)

        switch result {
        case .running:
            return .running
        case .succeeded:
            return .succeeded
        case .failed:
            return .failed
        }
    }

    public override func reset() {
        super.reset()
        accumulatedTime = 0
        child.reset()
    }
}
