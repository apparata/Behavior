import Foundation

/// The `Mute` task succeeds whether its child succeeds or fails.
///
/// Returns:
/// - `.running` if the child is running
/// - `.succeeded` if the child has failed or succeeded.
///
public final class Mute<Context>: BuiltInBehaviorTask<Context> {

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
        case .succeeded: .succeeded
        case .failed: .succeeded
        }
    }
}
