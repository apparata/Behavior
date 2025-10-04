import Foundation

/// A composite task that executes all children concurrently.
///
/// The `Parallel` task runs all its children simultaneously (within the same tick).
/// It succeeds when all children succeed and fails immediately if any child fails.
///
/// ## Behavior
///
/// - Executes all children every tick (until completion)
/// - Stops and returns `.failed` immediately when any child fails
/// - Returns `.succeeded` only when all children have succeeded
/// - Useful for running multiple actions or checks simultaneously
///
/// ## Returns
///
/// - `.running` if at least one child is running and no child has failed
/// - `.succeeded` if all children have succeeded
/// - `.failed` if any child has failed
///
/// ## Example
///
/// ```swift
/// Parallel {
///     PlayAnimation()    // Run animation
///     PlaySound()        // Play sound at same time
///     UpdateUI()         // Update UI simultaneously
/// }
/// ```
public final class Parallel<Context>: BuiltInBehaviorTask<Context> {

    /// The child tasks to execute in parallel.
    public let children: [BehaviorTask<Context>]

    /// Creates a parallel task with an array of tasks.
    ///
    /// - Parameter children: The tasks to execute concurrently.
    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    /// Creates a parallel task using a result builder.
    ///
    /// - Parameter children: A result builder closure that returns the tasks to execute concurrently.
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
