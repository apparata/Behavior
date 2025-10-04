import Foundation

/// A composite task that executes children sequentially until one fails.
///
/// The `Sequence` task is one of the fundamental composite nodes in behavior trees.
/// It runs its children one by one, from top to bottom, as long as they succeed.
/// It's the behavior tree equivalent of a logical AND operation.
///
/// ## Behavior
///
/// - Executes children in order
/// - Stops and returns `.failed` immediately when a child fails
/// - Continues to the next child when one succeeds
/// - Returns `.succeeded` only when all children have succeeded
///
/// ## Returns
///
/// - `.running` if a child is currently running
/// - `.succeeded` if all children have succeeded
/// - `.failed` if any child has failed
///
/// ## Example
///
/// ```swift
/// Sequence {
///     FindTarget()      // Must succeed to continue
///     MoveToTarget()    // Must succeed to continue
///     Attack()          // Final action
/// }
/// ```
public final class Sequence<Context>: BuiltInBehaviorTask<Context> {

    /// The child tasks to execute in sequence.
    public let children: [BehaviorTask<Context>]

    /// Creates a sequence with an array of tasks.
    ///
    /// - Parameter children: The tasks to execute in order.
    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    /// Creates a sequence using a result builder.
    ///
    /// - Parameter children: A result builder closure that returns the tasks to execute.
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
