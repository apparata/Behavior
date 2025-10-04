import Foundation

/// A named tree definition that can be referenced and reused.
///
/// The `Tree` node represents a named subtree in a behavior tree system. It wraps
/// a sequence of tasks and can be referenced from other trees using the ``Subtree`` task.
///
/// ## Overview
///
/// Trees enable modular behavior design by allowing you to:
/// - Define reusable behavior patterns
/// - Reference them by name from multiple locations
/// - Organize complex behaviors into manageable pieces
///
/// Every behavior requires exactly one root tree named `"Root"`,
/// which is the entry point for execution.
///
/// ## Returns
///
/// - `.running` if the sequence is running
/// - `.succeeded` if the sequence has succeeded
/// - `.failed` if the sequence has failed
///
/// ## Example
///
/// ```swift
/// Behavior(for: context) {
///     Tree("Root") {
///         Subtree("Attack")
///     }
///
///     Tree("Attack") {
///         FindTarget()
///         MoveToTarget()
///         DamageTarget()
///     }
/// }
/// ```
public final class Tree<Context>: BuiltInBehaviorTask<Context> {

    public override var description: String {
        "Tree(\(name))"
    }

    /// The name of this tree.
    public let name: String

    /// The sequence of tasks that defines this tree's behavior.
    public let sequence: Sequence<Context>

    /// Creates a tree with a name and an array of tasks.
    ///
    /// - Parameters:
    ///   - name: The name of the tree for referencing with ``Subtree``.
    ///   - sequence: The tasks that make up this tree.
    public init(_ name: String, _ sequence: [BehaviorTask<Context>]) {
        self.name = name
        self.sequence = Sequence(sequence)
        super.init()
        self.sequence.parent = self
    }

    /// Creates a tree with a name using a result builder.
    ///
    /// - Parameters:
    ///   - name: The name of the tree for referencing with ``Subtree``.
    ///   - sequence: A result builder closure that returns the tasks for this tree.
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
