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
/// - If condition fails, returns `.failed`
/// - Re-evaluates condition after sequence succeeds
/// - Continues looping while condition succeeds
///
/// ## Returns
///
/// - `.running` if either the condition or the sequence is running
/// - `.succeeded` if the sequence has succeeded (loop continues next tick)
/// - `.failed` if either the condition or the sequence has failed
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
            // We want to re-evaluate the state if last run succeeded.
            condition.reset()
        }

        switch condition.tick(for: context, time: time, behavior: behavior) {
        case .running:
            return .running
        case .failed:
            return .failed
        case .succeeded:
            break
        }

        return sequence.tick(for: context, time: time, behavior: behavior)
    }

    public override func reset() {
        super.reset()
        sequence.reset()
    }
}
