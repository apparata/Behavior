import Foundation

/// The `While` task has two children: the first is the condition and the second is a ``Sequence``.
/// It repeats the condition and runs the sequence unless the condition fails. The sequence is started after
/// the first success of the condition. It succeeds if the sequence succeeds and it fails when any child fails.
///
/// Returns:
/// - `.running` if either the condition or the sequence is running.
/// - `.succeeded` if the sequence has succeeded.
/// - `.failed` if either the condition or the sequence has failed.
///
public final class While<Context>: BuiltInBehaviorTask<Context> {

    public let condition: BehaviorTask<Context>

    public let sequence: Sequence<Context>

    public init(_ condition: BehaviorTask<Context>, _ sequence: [BehaviorTask<Context>]) {
        self.condition = condition
        self.sequence = Sequence(sequence)
    }

    public init(
        _ condition: BehaviorTask<Context>,
        @BehaviorTreeBuilder<Context> _ sequence: () -> [BehaviorTask<Context>]
    ) {
        self.condition = condition
        self.sequence = Sequence(sequence)
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
