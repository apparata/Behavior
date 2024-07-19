import Foundation

/// The `Fallback` task runs its child one by one, from top to bottom, as long as they fail.
/// It succeeds on the first child that succeeds and it fails when all children fail.
///
/// Returns:
/// - `.running` if a child is running.
/// - `.succeeded` if one child has succeeded.
/// - `.failed` if all the children have failed.
///
public final class Fallback<Context>: BuiltInBehaviorTask<Context> {

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
        var result: BehaviorState = .running

        loop: for task in children {
            result = task.tick(for: context, time: time, behavior: behavior)
            switch result {
            case .running:
                break loop
            case .failed:
                continue loop
            case .succeeded:
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
