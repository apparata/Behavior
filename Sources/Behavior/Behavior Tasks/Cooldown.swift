import Foundation

/// The `Cooldown` task prevents its child from re-executing for a specified duration after completion.
/// During the cooldown period, it returns the last result without re-running the child.
///
/// Returns:
/// - `.running` if the child is running.
/// - `.succeeded` or `.failed` based on the child's last result (may be cached during cooldown).
///
public final class Cooldown<Context>: BuiltInBehaviorTask<Context> {

    public let duration: TimeInterval
    public let child: BehaviorTask<Context>

    private var cooldownRemaining: TimeInterval = 0
    private var lastResult: BehaviorState?

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
        cooldownRemaining = 0
        lastResult = nil
        child.reset()
    }
}
