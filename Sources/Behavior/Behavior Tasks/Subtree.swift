import Foundation

/// The `Subtree` task runs the named behavior tree.
///
/// Returns:
/// - `.running` if the tree is running.
/// - `.succeeded` if the tree has succeeded.
/// - `.failed` if the tree has failed, or if there is no tree matching the name.
///
public final class Subtree<Context>: BuiltInBehaviorTask<Context> {

    private let name: String

    public init(_ name: String) {
        self.name = name
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        guard let tree = behavior.trees[name] else {
            return .failed
        }
        let result = tree.tick(for: context, time: time, behavior: behavior)
        return result
    }
}
