import Foundation

/// A control task that always succeeds immediately.
///
/// The `Succeed` task is a simple task that does nothing and immediately returns `.succeeded`.
/// It's useful for testing, placeholder logic, or forcing a success state in a tree.
///
/// ## Behavior
///
/// - Does nothing
/// - Returns `.succeeded` immediately
///
/// ## Returns
///
/// - `.succeeded` (always)
///
/// ## Example
///
/// ```swift
/// Fallback {
///     ComplexTask()
///     Succeed()  // Always succeeds as fallback
/// }
/// ```
public final class Succeed<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .succeeded
    }
}
