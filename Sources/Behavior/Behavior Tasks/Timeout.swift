import Foundation

/// The `Timeout` task fails its child if it runs longer than the specified duration.
/// It succeeds when the child succeeds within the time limit and fails if the child fails
/// or if the timeout is exceeded.
///
/// Returns:
/// - `.running` if the child is running and time remains.
/// - `.succeeded` if the child has succeeded within the time limit.
/// - `.failed` if the child has failed or the timeout has been exceeded.
///
public final class Timeout<Context>: BuiltInBehaviorTask<Context> {

    public let duration: TimeInterval
    public let child: BehaviorTask<Context>

    private var accumulatedTime: TimeInterval = 0

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
