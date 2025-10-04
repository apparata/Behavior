import Foundation

/// The `Retry` task retries its child task up to N times if it fails.
/// It succeeds when the child succeeds and fails only after all retry attempts are exhausted.
///
/// Returns:
/// - `.running` if the child is running.
/// - `.succeeded` if the child has succeeded.
/// - `.failed` if the child has failed and all retry attempts are exhausted.
///
public final class Retry<Context>: BuiltInBehaviorTask<Context> {

    public let maxAttempts: Int
    public let child: BehaviorTask<Context>

    private var attemptCount: Int = 0

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
