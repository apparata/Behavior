import Foundation

/// A utility task that evaluates a boolean condition.
///
/// The `Condition` task provides a simple way to check boolean conditions without
/// creating custom task classes. It evaluates a closure and returns success or failure
/// based on the result.
///
/// ## Behavior
///
/// - Executes the condition closure
/// - Returns `.succeeded` if the condition returns `true`
/// - Returns `.failed` if the condition returns `false`
///
/// ## Returns
///
/// - `.succeeded` if the condition evaluates to true
/// - `.failed` if the condition evaluates to false
///
/// ## Example
///
/// ```swift
/// Sequence {
///     Condition { context in context.health > 0 }  // Check if alive
///     Attack()
/// }
/// ```
///
/// - Note: The condition closure is strongly referenced.
public final class Condition<Context>: BuiltInBehaviorTask<Context> {

    private let condition: (Context) -> Bool

    /// Creates a condition task.
    ///
    /// - Parameter condition: A closure that evaluates to `true` or `false`.
    public init(_ condition: @escaping (Context) -> Bool) {
        self.condition = condition
        super.init()
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        condition(context) ? .succeeded : .failed
    }
}
