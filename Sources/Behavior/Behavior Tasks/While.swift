import Foundation

/// A control flow task that repeats a sequence while a condition holds true.
///
/// The `While` task evaluates a condition before each iteration and runs a sequence
/// of tasks while the condition succeeds. It's similar to a while loop in programming.
///
/// ## Behavior
///
/// - Evaluates the condition task before each iteration
/// - If condition succeeds, executes the sequence
/// - If condition fails, returns `.succeeded` (loop completed normally)
/// - Re-evaluates condition after sequence succeeds
/// - Continues looping while condition succeeds
///
/// ## Returns
///
/// - `.running` if the condition or sequence is running, or if the sequence succeeded (to continue looping)
/// - `.succeeded` if the condition fails (loop exits normally)
/// - `.failed` if the sequence fails
///
/// ## Example
///
/// ```swift
/// While(HasEnemiesNearby()) {
///     FindNearestEnemy()
///     MoveToEnemy()
///     Attack()
/// }
/// ```
public final class While<Context>: BuiltInBehaviorTask<Context> {

    /// The condition task to evaluate before each iteration.
    public let condition: BehaviorTask<Context>

    /// The sequence of tasks to execute while the condition is true.
    public let sequence: Sequence<Context>

    /// Creates a while loop with a condition and an array of tasks.
    ///
    /// - Parameters:
    ///   - condition: The condition task to evaluate before each iteration.
    ///   - sequence: The tasks to execute while the condition succeeds.
    public init(_ condition: BehaviorTask<Context>, _ sequence: [BehaviorTask<Context>]) {
        self.condition = condition
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    /// Creates a while loop with a condition using a result builder.
    ///
    /// - Parameters:
    ///   - condition: The condition task to evaluate before each iteration.
    ///   - sequence: A result builder closure that returns the tasks to execute.
    public init(
        _ condition: BehaviorTask<Context>,
        @BehaviorTreeBuilder<Context> _ sequence: () -> [BehaviorTask<Context>]
    ) {
        self.condition = condition
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {

        if condition.state == .succeeded {
            // We want to re-evaluate the condition if last run succeeded.
            condition.reset()
        }

        switch condition.tick(for: context, time: time, behavior: behavior) {
        case .running:
            return .running
        case .failed:
            // Condition failed - loop exits normally
            return .succeeded
        case .succeeded:
            break
        }

        let result = sequence.tick(for: context, time: time, behavior: behavior)

        // Check if a child task (like SucceedParent) set our state
        if state == .succeeded || state == .failed {
            return state!
        }

        // Reset sequence after it succeeds so it can run again on next iteration
        // Return .running to continue the loop
        if result == .succeeded {
            sequence.reset()
            return .running
        }

        return result
    }

    public override func reset() {
        super.reset()
        sequence.reset()
    }
}
