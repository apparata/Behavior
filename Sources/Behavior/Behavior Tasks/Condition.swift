import Foundation

/// The `Condition` task evaluates a boolean condition and returns `.succeeded` if true or `.failed` if false.
///
/// NOTE: The condition closure is strongly referenced.
///
/// Returns:
/// - `.succeeded` if the condition evaluates to true.
/// - `.failed` if the condition evaluates to false.
///
public final class Condition<Context>: BuiltInBehaviorTask<Context> {

    private let condition: (Context) -> Bool

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
