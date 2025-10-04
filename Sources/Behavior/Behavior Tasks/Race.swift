import Foundation

/// A composite task that races children, succeeding on the first success.
///
/// The `Race` task runs all its children concurrently and completes as soon as
/// one child succeeds. It only fails if all children fail.
///
/// ## Behavior
///
/// - Executes all children every tick (until completion)
/// - Stops and returns `.succeeded` immediately when any child succeeds
/// - Returns `.failed` only when all children have failed
/// - Useful for trying multiple approaches simultaneously
///
/// ## Returns
///
/// - `.running` if at least one child is running and none has succeeded
/// - `.succeeded` if any child has succeeded
/// - `.failed` if all children have failed
///
/// ## Example
///
/// ```swift
/// Race {
///     FindPathA()        // Try route A
///     FindPathB()        // Try route B simultaneously
///     FindPathC()        // Try route C simultaneously
/// }
/// // Succeeds as soon as any path is found
/// ```
public final class Race<Context>: BuiltInBehaviorTask<Context> {

    /// The child tasks to race.
    public let children: [BehaviorTask<Context>]

    /// Creates a race task with an array of tasks.
    ///
    /// - Parameter children: The tasks to race against each other.
    public init(_ children: [BehaviorTask<Context>]) {
        self.children = children
        super.init()
        for child in self.children {
            child.parent = self
        }
    }

    /// Creates a race task using a result builder.
    ///
    /// - Parameter children: A result builder closure that returns the tasks to race.
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
