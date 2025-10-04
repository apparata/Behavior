import Foundation

/// The `Parallel` task runs all its children at the same time. It succeeds when all the children
/// succeed and it fails on the first child that fails.
///
/// Returns:
/// - `.running` if at least one child is running and no child has failed.
/// - `.succeeded` if all children have succeeded.
/// - `.failed` if one child has failed.
///
public final class Parallel<Context>: BuiltInBehaviorTask<Context> {

    public let children: [BehaviorTask<Context>]

    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    public init(@BehaviorTreeBuilder<Context> _ children: () -> [BehaviorTask<Context>]) {
        self.children = children()
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        var result: BehaviorState = .succeeded

        loop: for task in children {
            switch task.tick(for: context, time: time, behavior: behavior) {
            case .running:
                result = .running
                continue loop
            case .failed:
                result = .failed
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
