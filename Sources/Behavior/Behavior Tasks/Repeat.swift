import Foundation

/// A control flow task that repeats a sequence a specified number of times.
///
/// The `Repeat` task executes its child sequence multiple times based on the iteration count.
/// If iterations is `.infinite`, it repeats indefinitely. It succeeds after completing all
/// iterations successfully and fails if the sequence fails at any point.
///
/// ## Behavior
///
/// - Executes the sequence repeatedly
/// - Counts down remaining iterations on each success
/// - Fails immediately if the sequence fails
/// - Succeeds when all iterations complete successfully
///
/// ## Returns
///
/// - `.running` if currently executing or between iterations
/// - `.succeeded` if all iterations have completed successfully
/// - `.failed` if the sequence has failed
///
/// ## Example
///
/// ```swift
/// Repeat(.count(3)) {
///     Jump()
///     Wait(1.0)
/// }
/// // Jumps 3 times with 1 second between each
/// ```
public final class Repeat<Context>: BuiltInBehaviorTask<Context> {

    /// The number of times to repeat the sequence.
    public let iterations: BehaviorIterations

    /// The sequence of tasks to repeat.
    public let sequence: Sequence<Context>

    private var remainingIterations: Int?

    /// Creates a repeat task with an iteration count and an array of tasks.
    ///
    /// - Parameters:
    ///   - iterations: The number of times to repeat (default: once). Use `.infinite` for endless repetition.
    ///   - sequence: The tasks to repeat.
    public init(
        _ iterations: BehaviorIterations = .count(1),
        _ sequence: [BehaviorTask<Context>]
    ) {
        self.iterations = iterations
        self.remainingIterations = self.iterations.count.map { max(0, $0) }
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    /// Creates a repeat task with an iteration count using a result builder.
    ///
    /// - Parameters:
    ///   - iterations: The number of times to repeat (default: once). Use `.infinite` for endless repetition.
    ///   - sequence: A result builder closure that returns the tasks to repeat.
    public init(
        _ iterations: BehaviorIterations = .count(1),
        @BehaviorTreeBuilder<Context> _ sequence: () -> [BehaviorTask<Context>]
    ) {
        self.iterations = iterations
        self.remainingIterations = self.iterations.count.map { max(0, $0) }
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {

        guard remainingIterations != 0 else {
            return state ?? .succeeded
        }

        switch sequence.tick(for: context, time: time, behavior: behavior) {
        case .running:
            return .running
        case .failed:
            return .failed
        case .succeeded:
            if var remainingIterations {
                remainingIterations -= 1
                self.remainingIterations = remainingIterations
                if remainingIterations <= 0 {
                    return .succeeded
                }
            }
            // Reset sequence for next iteration
            sequence.reset()
            return .running
        }
    }

    public override func reset() {
        super.reset()
        remainingIterations = iterations.count.map { max(0, $0) }
        sequence.reset()
    }
}
