import Foundation

/// A decorator task that retries a failed child task up to N times.
///
/// The `Retry` task gives a child task multiple attempts to succeed before failing.
/// It's useful for unreliable operations that may succeed on subsequent attempts.
///
/// ## Behavior
///
/// - Executes the child task
/// - If child succeeds, returns `.succeeded`
/// - If child fails, resets it and tries again (up to max attempts)
/// - Only fails after all retry attempts are exhausted
///
/// ## Returns
///
/// - `.running` if the child is running or retrying
/// - `.succeeded` if the child has succeeded on any attempt
/// - `.failed` if the child has failed on all attempts
///
/// ## Example
///
/// ```swift
/// Retry(3, UnstableNetworkRequest())  // Try up to 3 times
/// ```
public final class Retry<Context>: BuiltInBehaviorTask<Context> {

    /// The maximum number of attempts (including the initial attempt).
    public let maxAttempts: Int

    /// The child task to retry on failure.
    public let child: BehaviorTask<Context>

    private var attemptCount: Int = 0

    /// Creates a retry decorator.
    ///
    /// - Parameters:
    ///   - maxAttempts: The maximum number of attempts (minimum: 1).
    ///   - child: The task to retry on failure.
    public init(_ maxAttempts: Int, _ child: BehaviorTask<Context>) {
        self.maxAttempts = max(1, maxAttempts)
        self.child = child
        super.init()
        self.child.parent = self
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {

        let result = child.tick(for: context, time: time, behavior: behavior)

        switch result {
        case .running:
            return .running
        case .succeeded:
            return .succeeded
        case .failed:
            attemptCount += 1
            if attemptCount < maxAttempts {
                // Reset child for next attempt
                child.reset()
                return .running
            } else {
                // All attempts exhausted
                return .failed
            }
        }
    }

    public override func reset() {
        super.reset()
        attemptCount = 0
        child.reset()
    }
}
