import Foundation

/// The `Sequence` task runs its children one by one, from top to bottom, as long as they succeed.
/// It succeeds when all children succeed and it fails on the first child that fails.
///
/// Returns:
/// - `.running` if a child is running.
/// - `.succeeded` if all children have succeeded.
/// - `.failed` if one child has failed.
///
public final class Sequence<Context>: BuiltInBehaviorTask<Context> {

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
        var result: BehaviorState = .running

        loop: for task in children {
            result = task.tick(for: context, time: time, behavior: behavior)
            switch result {
            case .running:
                break loop
            case .failed:
                break loop
            case .succeeded:
                continue loop
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
