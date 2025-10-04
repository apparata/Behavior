import Foundation

/// The `Tree` node has a name specified as a string parameter. A tree definition has one sequence child
/// and can be referenced from other trees by its name using a `Subtree` task. Any behavior tree requires
/// exactly one root tree named `“Root”`, which is the first tree being ticked.
///
/// Returns:
/// - `.running` if the sequence is running.
/// - `.succeeded` if the sequence has succeeded.
/// - `.failed` if the sequence has failed.
///
public final class Tree<Context>: BuiltInBehaviorTask<Context> {

    public override var description: String {
        "Tree(\(name))"
    }

    public let name: String

    public let sequence: Sequence<Context>

    public init(_ name: String, _ sequence: [BehaviorTask<Context>]) {
        self.name = name
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    public init(
        _ name: String,
        @BehaviorTreeBuilder<Context> sequence: () -> [BehaviorTask<Context>]
    ) {
        self.name = name
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        sequence.tick(for: context, time: time, behavior: behavior)
    }

    public override func reset() {
        super.reset()
        sequence.reset()
    }
}
