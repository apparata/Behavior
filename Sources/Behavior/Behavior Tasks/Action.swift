import Foundation

/// The `Action` task executes a closure and returns the result.
///
/// NOTE: The action closure is strongly referenced.
///
/// Returns:
/// - The `BehaviorState` returned by the action closure.
///
public final class Action<Context>: BuiltInBehaviorTask<Context> {

    private let action: (Context, BehaviorTime) -> BehaviorState

    public init(_ action: @escaping (Context) -> BehaviorState) {
        self.action = { context, _ in action(context) }
        super.init()
    }

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
