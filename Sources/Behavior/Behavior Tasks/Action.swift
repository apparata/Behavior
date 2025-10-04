import Foundation

/// A utility task that executes a closure-based action.
///
/// The `Action` task provides a simple way to perform custom logic without
/// creating dedicated task classes. It executes a closure and returns the
/// state provided by that closure.
///
/// ## Behavior
///
/// - Executes the action closure
/// - Returns the `BehaviorState` from the closure
/// - Supports both simple and time-aware closures
///
/// ## Returns
///
/// - The `BehaviorState` returned by the action closure
///
/// ## Example
///
/// ```swift
/// Action { context in
///     context.doSomething()
///     return .succeeded
/// }
///
/// // Or with time parameter:
/// Action { context, time in
///     context.move(delta: time.elapsed)
///     return .running
/// }
/// ```
///
/// - Note: The action closure is strongly referenced.
public final class Action<Context>: BuiltInBehaviorTask<Context> {

    private let action: (Context, BehaviorTime) -> BehaviorState

    /// Creates an action task with a simple closure.
    ///
    /// - Parameter action: A closure that performs an action and returns a state.
    public init(_ action: @escaping (Context) -> BehaviorState) {
        self.action = { context, _ in action(context) }
        super.init()
    }

    /// Creates an action task with a time-aware closure.
    ///
    /// - Parameter action: A closure that performs an action using timing information and returns a state.
    public init(_ action: @escaping (Context, BehaviorTime) -> BehaviorState) {
        self.action = action
        super.init()
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        action(context, time)
    }
}
