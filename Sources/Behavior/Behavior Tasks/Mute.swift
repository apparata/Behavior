import Foundation

/// A decorator task that always succeeds regardless of its child's result.
///
/// The `Mute` task (also known as "Succeeder" or "AlwaysSucceed") converts any completion
/// state from its child into success. It's useful for optional tasks or when you want to
/// continue execution regardless of a task's outcome.
///
/// ## Behavior
///
/// - Executes the child task
/// - Returns `.succeeded` when child returns `.failed` or `.succeeded`
/// - Passes through `.running` unchanged
///
/// ## Returns
///
/// - `.running` if the child is running
/// - `.succeeded` if the child has completed (either succeeded or failed)
///
/// ## Example
///
/// ```swift
/// Sequence {
///     Mute(TryOptionalAction())  // Never fails, always continues
///     RequiredAction()
/// }
/// ```
public final class Mute<Context>: BuiltInBehaviorTask<Context> {

    /// The child task whose failure will be muted.
    public let child: BehaviorTask<Context>

    /// Creates a mute decorator.
    ///
    /// - Parameter child: The task whose failure will be converted to success.
    public init(_ child: BehaviorTask<Context>) {
        self.child = child
    }

    override public func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        switch child.tick(for: context, time: time, behavior: behavior) {
        case .running: .running
        case .succeeded: .succeeded
        case .failed: .succeeded
        }
    }
}
