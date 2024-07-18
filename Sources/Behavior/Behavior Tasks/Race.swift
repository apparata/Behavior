import Foundation

/// The `Race` task runs all its children at the same time. It succeeds on the first child that succeeds
/// and it fails when all the children fail.
///
/// Returns:
/// - `.running` if at least one child is running and none has succeeded.
/// - `.succeeded` if one child has succeeded.
/// - `.failed` if all the children have failed.
///
public final class Race<Context>: BuiltInBehaviorTask<Context> {

    public let children: [BehaviorTask<Context>]

    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
    }

    public init(@BehaviorTreeBuilder<Context> _ children: () -> [BehaviorTask<Context>]) {
        self.children = children()
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        var result: BehaviorState = .failed

        loop: for task in children {
            switch task.tick(for: context, time: time, behavior: behavior) {
            case .running:
                result = .running
                break loop
            case .failed:
                continue loop
            case .succeeded:
                result = .succeeded
                break loop
            }
        }

        return result
    }

    public override func reset() {
        super.reset()
        for child in children {
            child.reset()
        }
    }
}
