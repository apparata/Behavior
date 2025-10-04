import Foundation

/// A control task that always fails immediately.
///
/// The `Fail` task is a simple task that does nothing and immediately returns `.failed`.
/// It's useful for testing, placeholder logic, or forcing a failure state in a tree.
///
/// ## Behavior
///
/// - Does nothing
/// - Returns `.failed` immediately
///
/// ## Returns
///
/// - `.failed` (always)
///
/// ## Example
///
/// ```swift
/// Sequence {
///     CheckCondition()
///     Fail()  // Force sequence to fail
/// }
/// ```
public final class Fail<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .failed
    }
}
