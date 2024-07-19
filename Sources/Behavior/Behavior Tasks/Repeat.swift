import Foundation

/// The `Repeat` task runs its child sequence `iterations` times. If `iterations` is unspecified,
/// the repetition is infinite. It succeeds after `iteration` successful iterations of the child sequence
/// and it fails if the child sequence fails.
///
/// Returns:
/// - `.running` if
/// - `.succeeded` if
/// - `.failed` if
///
public final class Repeat<Context>: BuiltInBehaviorTask<Context> {

    public let iterations: BehaviorIterations

    public let sequence: Sequence<Context>

    private var remainingIterations: Int?

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
            return .running
        }
    }

    public override func reset() {
        super.reset()
        remainingIterations = iterations.count.map { max(0, $0) }
        sequence.reset()
    }
}
