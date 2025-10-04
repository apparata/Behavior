import Foundation

/// References and executes a named tree by name.
///
/// The `Subtree` task allows you to reference and execute a tree defined elsewhere
/// in the behavior. This enables code reuse and modular behavior design.
///
/// ## Behavior
///
/// - Looks up the tree by name in the behavior's tree dictionary
/// - Executes the referenced tree
/// - Returns `.failed` if no tree with the given name exists
///
/// ## Returns
///
/// - `.running` if the referenced tree is running
/// - `.succeeded` if the referenced tree has succeeded
/// - `.failed` if the referenced tree has failed, or if no tree matches the name
///
/// ## Example
///
/// ```swift
/// Tree("Root") {
///     Subtree("Attack")    // References "Attack" tree defined elsewhere
/// }
///
/// Tree("Attack") {
///     FindTarget()
///     DealDamage()
/// }
/// ```
public final class Subtree<Context>: BuiltInBehaviorTask<Context> {

    /// The name of the tree to execute.
    private let name: String

    /// Creates a subtree reference.
    ///
    /// - Parameter name: The name of the tree to execute.
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
