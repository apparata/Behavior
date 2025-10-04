import Foundation

/// A control task that always returns running.
///
/// The `Run` task is a simple task that does nothing and always returns `.running`.
/// It's useful for testing, creating infinite loops, or placeholder logic.
///
/// ## Behavior
///
/// - Does nothing
/// - Returns `.running` on every tick
/// - Never completes unless reset or interrupted
///
/// ## Returns
///
/// - `.running` (always)
///
/// ## Example
///
/// ```swift
/// Fallback {
///     CompleteableTask()
///     Run()  // Keeps trying forever as fallback
/// }
/// ```
public final class Run<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .running
    }
}
