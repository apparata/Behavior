import Foundation

/// The `Not` task inverts the completion state of its child.
/// It succeeds when the child fails and fails when the child succeeds.
///
/// Returns:
/// - `.running` when the child is running.
/// - `.succeeded` when the child has failed.
/// - `.failed` when the child has succeeded.
///
public final class Not<Context>: BuiltInBehaviorTask<Context> {

    public let child: BehaviorTask<Context>

    public init(_ child: BehaviorTask<Context>) {
        self.child = child
    }

    override public func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        switch child.tick(for: context, time: time, behavior: behavior) {
        case .running: .running
        case .succeeded: .failed
        case .failed: .succeeded
        }
    }
}
