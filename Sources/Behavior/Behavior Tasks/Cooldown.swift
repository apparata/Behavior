import Foundation

/// A decorator task that prevents re-execution for a duration after completion.
///
/// The `Cooldown` task rate-limits its child by enforcing a cooldown period after the child completes.
/// During the cooldown, it returns the cached result without re-executing the child.
///
/// ## Behavior
///
/// - Executes the child task normally
/// - When child completes, starts a cooldown timer
/// - During cooldown, returns the cached result without re-running
/// - After cooldown expires, allows child to execute again
///
/// ## Returns
///
/// - `.running` if the child is currently running
/// - `.succeeded` or `.failed` based on the child's result (cached during cooldown)
///
/// ## Example
///
/// ```swift
/// Cooldown(5.0, ExpensiveAbility())  // Can only use ability once per 5 seconds
/// ```
public final class Cooldown<Context>: BuiltInBehaviorTask<Context> {

    /// The cooldown duration after child completes (in seconds).
    public let duration: TimeInterval

    /// The child task to rate-limit.
    public let child: BehaviorTask<Context>

    private var cooldownRemaining: TimeInterval = 0
    private var lastResult: BehaviorState?

    /// Creates a cooldown decorator.
    ///
    /// - Parameters:
    ///   - duration: The cooldown duration in seconds after completion (minimum: 0).
    ///   - child: The task to rate-limit.
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

        // Update cooldown timer
        if cooldownRemaining > 0 {
            cooldownRemaining = max(0, cooldownRemaining - time.elapsed)
        }

        // If in cooldown, return cached result
        if cooldownRemaining > 0, let lastResult {
            return lastResult
        }

        // Run the child
        let result = child.tick(for: context, time: time, behavior: behavior)

        // If child completed, start cooldown
        switch result {
        case .succeeded, .failed:
            lastResult = result
            cooldownRemaining = duration
            child.reset()
        case .running:
            break
        }

        return result
    }

    public override func reset() {
        super.reset()
        // Preserve cooldown state across resets - that's the whole point
        // Only reset the child task
        child.reset()
    }
}
