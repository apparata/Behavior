import Foundation

/// The `Succeed` task does nothing and returns `.succeeded`.
///
/// Returns:
/// - `.succeeded`
///
public final class Succeed<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .succeeded
    }
}
