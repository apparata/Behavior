import Foundation

/// A composite task that tries children sequentially until one succeeds.
///
/// The `Fallback` task (also known as "Selector") is one of the fundamental composite nodes
/// in behavior trees. It runs its children one by one, from top to bottom, as long as they fail.
/// It's the behavior tree equivalent of a logical OR operation.
///
/// ## Behavior
///
/// - Executes children in order
/// - Stops and returns `.succeeded` immediately when a child succeeds
/// - Continues to the next child when one fails
/// - Returns `.failed` only when all children have failed
///
/// ## Returns
///
/// - `.running` if a child is currently running
/// - `.succeeded` if any child has succeeded
/// - `.failed` if all children have failed
///
/// ## Example
///
/// ```swift
/// Fallback {
///     HasAmmo()          // Try this first
///     FindAmmo()         // If no ammo, try to find some
///     Retreat()          // If can't find ammo, retreat
/// }
/// ```
public final class Fallback<Context>: BuiltInBehaviorTask<Context> {

    /// The child tasks to try in sequence.
    public let children: [BehaviorTask<Context>]

    /// Creates a fallback with an array of tasks.
    ///
    /// - Parameter children: The tasks to try in order.
    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    /// Creates a fallback using a result builder.
    ///
    /// - Parameter children: A result builder closure that returns the tasks to try.
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
